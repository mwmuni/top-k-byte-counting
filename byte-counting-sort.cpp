#include <iostream>
#include <vector>
#include <array>

const int BINS = 256;
const int NUM_BYTES = sizeof(int);

void msd_radix_sort(std::vector<int>& data, int byte_pos) {
    if (data.size() <= 1 || byte_pos >= NUM_BYTES) return;

    // Create bins for each possible byte value
    std::array<std::vector<int>, BINS> bins;

    // Distribute the numbers into bins based on the current byte
    for (int num : data) {
        int byte_value = (num >> (8 * (NUM_BYTES - 1 - byte_pos))) & 0xFF;
        bins[byte_value].push_back(num);
    }

    // Clear the original vector to collect sorted numbers
    data.clear();

    // Process bins from lowest to highest byte value for ascending order
    for (int i = 0; i < BINS; ++i) {
        if (!bins[i].empty()) {
            // Recursively sort non-empty bins at the next byte position
            if (bins[i].size() > 1 && byte_pos + 1 < NUM_BYTES) {
                msd_radix_sort(bins[i], byte_pos + 1);
            }
            // Append sorted numbers to the main data vector
            data.insert(data.end(), bins[i].begin(), bins[i].end());
        }
    }
}

int main() {
    std::vector<int> data = {399, 18, 512, 42, 123, 34, 255, 67, 89,
                             101, 44, 111, 222, 333, 444, 555, 666, 777, 888, 999};

    msd_radix_sort(data, 0);

    std::cout << "Sorted numbers are:\n";
    for (int num : data) {
        std::cout << num << '\n';
    }
    return 0;
}
