#include <assert.h>
#include <inttypes.h>
#include <pthread.h>
#include <stddef.h>
#include <stdio.h>

// Ustalamy liczbę rdzeni.
#define N 3

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
            "0123456789",
            "56E"
            "78C"
    };
    static const uint64_t result[N] = {9, 5, 7};

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
            printf("\033[0;32mOK\033[0m\tCore number %zu.\n", n);
        }
        else {
            printf("\033[0;31mFAIL\033[0m\tCore number %zu. Got: %llu\tExpected: %llu\n", n, params[n].result, result[n]);
        }
    }
}
