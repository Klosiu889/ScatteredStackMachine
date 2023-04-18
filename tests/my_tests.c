#include <assert.h>
#include <inttypes.h>
#include <pthread.h>
#include <stddef.h>
#include <stdio.h>
#include <stdbool.h>

// Ustalamy liczbę rdzeni.
#define N 11

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

// To jest struktura służąca do przekazania do wątku parametrów wywołania
// rdzenia i zapisania wyniku obliczenia.
typedef struct {
    uint64_t n, result;
    char const *p;
} core_call_t;

typedef struct {
    char* value;
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
    static const char *computation[N] = {
            "76+",
            "59*",
            "7-",
            "0123456789",
            "nnn2n",
            "703-1-2-+BC",
            "45C",
            "5D",
            "60E",
            "G",
            "84n+P"
    };
    static const char *test_names[N] = {
            "Addition",
            "Multiplication",
            "Negation",
            "Numbers",
            "Core number",
            "Jump",
            "Pop value",
            "Duplicate value",
            "Swap values",
            "Get value",
            "Put value"
    };
    static const uint64_t result[N] = {13, 45, -7, 9, 4, 7, 4, 5, 6, 10, 8};

    static const test_t tests[N] = {
            {.value = "76+", .name = "Addition", .result = 13},
            {.value = "59*", .name = "Multiplication", .result = 45},
            {.value = "7-", .name = "Negation", .result = -7},
            {.value = "0123456789", .name = "Numbers", .result = 9},
            {.value = "nnn2n", .name = "Core number", .result = 4},
            {.value = "703-1-2-+BC", .name = "Jump", .result = 7},
            {.value = "45C", .name = "Pop value", .result = 4},
            {.value = "5D", .name = "Duplicate value", .result = 5},
            {.value = "60E", .name = "Swap values", .result = 6},
            {.value = "G", .name = "Get value", .result = 10},
            {.value = "84n+P", .name = "Put value", .result = 8}
    };

    for (size_t n = 0; n < N; ++n) {
        params[n].n = n;
        params[n].result = 0;
        params[n].p = tests[n].value;
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
            printf("\033[0;31mFAIL\033[0m\tCore number %zu on test %s. Got: %llu\tExpected: %llu\n", n, tests[n].name, params[n].result, tests[n].result);
            failed = true;
        }
    }

    if (failed) return 1;
    return 0;
}
