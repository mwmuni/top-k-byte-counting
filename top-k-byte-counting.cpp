#include <iostream>
#include <vector>
#include <array>

const int BINS = 256;
const int NUM_BYTES = sizeof(int);
const int K = 3;

void find_top_k(const std::vector<int>& data, int byte_pos, std::vector<int>& top_k) {
    if (data.empty() || top_k.size() >= K || byte_pos >= NUM_BYTES) return;

    std::array<int, BINS> counts = {};
    for (int num : data) {
        int byte_value = (num >> (8 * (NUM_BYTES - 1 - byte_pos))) & 0xFF;
        counts[byte_value]++;
    }

    for (int i = BINS - 1; i >= 0; --i) {
        if (counts[i] == 0) continue;

        if (top_k.size() + counts[i] <= K) {
            for (int num : data) {
                if (((num >> (8 * (NUM_BYTES - 1 - byte_pos))) & 0xFF) == i) {
                    top_k.push_back(num);
                }
            }
        } else {
            std::vector<int> bin_numbers;
            for (int num : data) {
                if (((num >> (8 * (NUM_BYTES - 1 - byte_pos))) & 0xFF) == i) {
                    bin_numbers.push_back(num);
                }
            }
            find_top_k(bin_numbers, byte_pos + 1, top_k);
        }
        if (top_k.size() >= K) return;
    }
}

int main() {
    std::vector<int> data = {399, 18, 512, 42, 123, 34, 255, 67, 89,
                             101, 44, 111, 222, 333, 444, 555, 666, 777, 888, 999};
    std::vector<int> top_k;
    find_top_k(data, 0, top_k);

    std::cout << "Top " << K << " numbers are:\n";
    for (int num : top_k) {
        std::cout << num << '\n';
    }
    return 0;
}
