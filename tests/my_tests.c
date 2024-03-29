#include <assert.h>
#include <inttypes.h>
#include <pthread.h>
#include <stddef.h>
#include <stdio.h>
#include <stdbool.h>

bool failed = false;

// To jest deklaracja funkcji, którą trzeba zaimplementować.
uint64_t core(uint64_t n, char const *p);

// Tę funkcję woła rdzeń.
uint64_t get_value(uint64_t n) {
    assert(n < N);
    return n + 1;
}

// Tę funkcję woła rdzeń.
void put_value(uint64_t n, uint64_t v) {
    assert(n < N);
    assert(v == n + 4);
}

// Tę funkcję woła rdzeń.
void print_register(uint64_t n, uint64_t v, uint64_t u) {
    printf("Core %lu printed value %lu and %lu\n", n, v % 16, u);
}

// To jest struktura służąca do przekazania do wątku parametrów wywołania
// rdzenia i zapisania wyniku obliczenia.
typedef struct {
    uint64_t n, result;
    char const *p;
} core_call_t;

typedef struct {
    char* computation;
    char* name;
    uint64_t result;
} test_t;

// Wszystkie rdzenie powinny wystartować równocześnie.
static volatile int wait = 0;

// Ta funkcja uruchamia obliczenie na jednym rdzeniu.
static void * core_thread(void *params) {
    core_call_t *cp = (core_call_t*)params;

    // Wszystkie rdzenie powinny wystartować równocześnie.
    while (wait == 0);

    cp->result = core(cp->n, cp->p);

    return NULL;
}

int main() {
    static pthread_t tid[N];
    static core_call_t params[N];

    static const test_t tests[N] = {
            {.computation = "01234n+P56789E-+D+*G*1n-+S2ED+E1-+75+-BC", .name = "Example", .result = 112},
            {.computation = "01234n+P56789E-+D+*G*1n-+S2ED+E1-+75+-BC", .name = "Example 2", .result = 56},
            {.computation = "76+", .name = "Addition", .result = 13},
            {.computation = "59*", .name = "Multiplication", .result = 45},
            {.computation = "7-", .name = "Negation", .result = -7},
            {.computation = "0123456789", .name = "Numbers", .result = 9},
            {.computation = "nnn2n", .name = "Core number", .result = 6},
            {.computation = "70011-2-+BC", .name = "Jump", .result = 7},
            {.computation = "41B4", .name = "Jump 2", .result = 4},
            {.computation = "45C", .name = "Pop computation", .result = 4},
            {.computation = "5D", .name = "Duplicate computation", .result = 5},
            {.computation = "60E", .name = "Swap values", .result = 6},
            {.computation = "G", .name = "Get computation", .result = 13},
            {.computation = "84n+P", .name = "Put computation", .result = 8},
            {.computation = "111", .name = "Placeholder", .result = 1}
    };

    for (size_t n = 0; n < N; ++n) {
        params[n].n = n;
        params[n].result = 0;
        params[n].p = tests[n].computation;
    }

    for (size_t n = 0; n < N; ++n)
        assert(0 == pthread_create(&tid[n], NULL, &core_thread, (void*)&params[n]));

    wait = 1; // Wystartuj rdzenie.

    for (size_t n = 0; n < N; ++n)
        assert(0 == pthread_join(tid[n], NULL));

    for (size_t n = 0; n < N; ++n) {
        if (params[n].result == tests[n].result) {
            printf("\033[0;32mOK\033[0m\tCore number %zu on test %s.\n", n, tests[n].name);
        }
        else {
            printf("\033[0;31mFAIL\033[0m\tCore number %zu on test %s. Got: %lu\tExpected: %lu\n", n, tests[n].name, params[n].result, tests[n].result);
            failed = true;
        }
    }

    if (failed) return 1;
    return 0;
}
