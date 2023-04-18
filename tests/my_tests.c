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
            "83n+P"
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

    for (size_t n = 0; n < N; ++n) {
        params[n].n = n;
        params[n].result = 0;
        params[n].p = computation[n];
    }

    for (size_t n = 0; n < N; ++n)
        assert(0 == pthread_create(&tid[n], NULL, &core_thread, (void*)&params[n]));

    wait = 1; // Wystartuj rdzenie.

    for (size_t n = 0; n < N; ++n)
        assert(0 == pthread_join(tid[n], NULL));

    for (size_t n = 0; n < N; ++n) {
        if (params[n].result == result[n]) {
            printf("\033[0;32mOK\033[0m\tCore number %zu on test %s.\n", n, test_names[n]);
        }
        else {
            printf("\033[0;31mFAIL\033[0m\tCore number %zu on test %s. Got: %llu\tExpected: %llu\n", n, test_names[n], params[n].result, result[n]);
            failed = true;
        }
    }

    if (failed) return 1;
    return 0;
}
