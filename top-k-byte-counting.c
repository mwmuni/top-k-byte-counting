#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define BINS 256
#define NUM_BYTES (sizeof(int) / sizeof(char))
#define K 3

void find_top_k(int *data, int n, int byte_pos, int k, int *top_k, int *current_k) {
    if (n == 0 || *current_k >= k || byte_pos >= NUM_BYTES) {
        return;
    }

    // Create counts for each possible byte value
    int counts[BINS] = {0};
    for (int i = 0; i < n; i++) {
        int byte_value = (data[i] >> (8 * (NUM_BYTES - 1 - byte_pos))) & 0xFF;
        counts[byte_value]++;
    }

    // Process bins from highest byte value to lowest
    for (int i = BINS - 1; i >= 0; i--) {
        if (counts[i] == 0) continue;

        if (*current_k + counts[i] <= k) {
            // Include all numbers in this bin
            for (int j = 0; j < n; j++) {
                int byte_value = (data[j] >> (8 * (NUM_BYTES - 1 - byte_pos))) & 0xFF;
                if (byte_value == i) {
                    top_k[*current_k] = data[j];
                    (*current_k)++;
                    if (*current_k >= k) return;
                }
            }
        } else {
            // Need to further partition this bin by the next byte
            int counts_in_bin = counts[i];
            int *bin_numbers = malloc(counts_in_bin * sizeof(int));
            int idx = 0;
            for (int j = 0; j < n; j++) {
                int byte_value = (data[j] >> (8 * (NUM_BYTES - 1 - byte_pos))) & 0xFF;
                if (byte_value == i) {
                    bin_numbers[idx++] = data[j];
                }
            }
            // Recurse on this bin with the next byte
            find_top_k(bin_numbers, counts_in_bin, byte_pos + 1, k, top_k, current_k);
            free(bin_numbers);
            if (*current_k >= k) return;
        }
    }
}

int main() {
    int data[] = {399, 18, 512, 42, 123, 34, 255, 67, 89, 101, 44, 111, 222, 333, 444, 555, 666, 777, 888, 999};
    int n = sizeof(data) / sizeof(data[0]);
    int k = K;
    int top_k[K];
    int current_k = 0;

    find_top_k(data, n, 0, k, top_k, &current_k);

    printf("Top %d numbers are:\n", k);
    // Optional: Sort the top_k array if you want the numbers in order
    for (int i = 0; i < current_k; i++) {
        printf("%d\n", top_k[i]);
    }
    return 0;
}
