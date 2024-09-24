#include <iostream>
#include <vector>
#include <cuda.h>
#include <cuda_runtime.h>
#include <algorithm>

#define BINS 256
#define NUM_BYTES sizeof(int)
#define K 3

// CUDA error checking macro
#define cudaCheckError(ans) { gpuAssert((ans), __FILE__, __LINE__); }
inline void gpuAssert(cudaError_t code, const char *file, int line, bool abort=true){
    if (code != cudaSuccess){
        fprintf(stderr,"GPUassert: %s %s %d\n", cudaGetErrorString(code), file, line);
        if (abort) exit(code);
    }
}

// Kernel to count byte frequencies
__global__ void count_byte_frequencies(const int *data, int n, int byte_pos, int *histogram) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx < n) {
        int byte_value = (data[idx] >> (8 * (NUM_BYTES - 1 - byte_pos))) & 0xFF;
        atomicAdd(&histogram[byte_value], 1);
    }
}

// Kernel to filter data based on byte value
__global__ void filter_data(const int *data, int n, int byte_pos, int byte_value, int *filtered_data) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx < n) {
        int current_byte = (data[idx] >> (8 * (NUM_BYTES - 1 - byte_pos))) & 0xFF;
        if (current_byte == byte_value) {
            // Use atomic to find the index to place the element
            int pos = atomicAdd(&filtered_data[n], 1);
            filtered_data[pos] = data[idx];
        }
    }
}

// Host function to find top K using CUDA
void find_top_k_cuda(const std::vector<int>& host_data, std::vector<int>& top_k) {
    int n = host_data.size();
    int *d_data, *d_histogram, *d_filtered_data;

    // Allocate device memory
    cudaCheckError(cudaMalloc(&d_data, n * sizeof(int)));
    cudaCheckError(cudaMalloc(&d_histogram, BINS * sizeof(int)));
    cudaCheckError(cudaMalloc(&d_filtered_data, (n + 1) * sizeof(int))); // Extra space for count

    // Initialize filtered_data count to 0
    cudaCheckError(cudaMemset(d_filtered_data, 0, (n + 1) * sizeof(int))); // Corrected size

    // Copy data to device
    cudaCheckError(cudaMemcpy(d_data, host_data.data(), n * sizeof(int), cudaMemcpyHostToDevice));

    int byte_pos = 0;
    std::vector<int> current_data = host_data;
    int current_k = 0;

    while (byte_pos < NUM_BYTES && current_k < K) {
        n = current_data.size();

        // Reset histogram
        cudaCheckError(cudaMemset(d_histogram, 0, BINS * sizeof(int)));

        // Copy current data to device
        cudaCheckError(cudaMemcpy(d_data, current_data.data(), n * sizeof(int), cudaMemcpyHostToDevice));

        // Launch kernel to count byte frequencies
        int threads = 256;
        int blocks = (n + threads - 1) / threads;
        count_byte_frequencies<<<blocks, threads>>>(d_data, n, byte_pos, d_histogram);
        cudaCheckError(cudaDeviceSynchronize());

        // Copy histogram back to host
        std::vector<int> host_histogram(BINS, 0);
        cudaCheckError(cudaMemcpy(host_histogram.data(), d_histogram, BINS * sizeof(int), cudaMemcpyDeviceToHost));

        // Iterate over histogram from high to low
        for (int i = BINS - 1; i >= 0 && current_k < K; --i) {
            if (host_histogram[i] == 0) continue;

            if (current_k + host_histogram[i] <= K) {
                // Launch kernel to add all numbers with byte_value == i to top_k
                // First, reset filtered_data count to 0
                cudaCheckError(cudaMemset(d_filtered_data, 0, (n + 1) * sizeof(int))); // Corrected size

                // Launch filter kernel
                filter_data<<<blocks, threads>>>(d_data, n, byte_pos, i, d_filtered_data);
                cudaCheckError(cudaDeviceSynchronize());

                // Copy filtered data count
                int count;
                cudaCheckError(cudaMemcpy(&count, d_filtered_data + n, sizeof(int), cudaMemcpyDeviceToHost));

                if (count > 0) {
                    std::vector<int> temp(count);
                    // Check if count is valid
                    if (count < 0 || count > n) {
                        std::cerr << "Invalid count: " << count << std::endl;
                        return; // or handle the error appropriately
                    }

                    // Perform the memcpy
                    cudaCheckError(cudaMemcpy(temp.data(), d_filtered_data, count * sizeof(int), cudaMemcpyDeviceToHost));

                    for (int num : temp) {
                        top_k.push_back(num);
                        current_k++;
                        if (current_k >= K) break;
                    }
                }
            } else {
                // Need to further partition this bin by the next byte
                // Launch filter kernel to get numbers with byte_value == i
                cudaCheckError(cudaMemset(d_filtered_data, 0, (n + 1) * sizeof(int))); // Corrected size

                filter_data<<<blocks, threads>>>(d_data, n, byte_pos, i, d_filtered_data);
                cudaCheckError(cudaDeviceSynchronize());

                // Copy filtered data count
                int count;
                cudaCheckError(cudaMemcpy(&count, d_filtered_data + n, sizeof(int), cudaMemcpyDeviceToHost));

                if (count > 0) {
                    std::vector<int> temp(count);
                    // Check if count is valid
                    if (count < 0 || count > n) {
                        std::cerr << "Invalid count: " << count << std::endl;
                        return; // or handle the error appropriately
                    }

                    // Perform the memcpy
                    cudaCheckError(cudaMemcpy(temp.data(), d_filtered_data, count * sizeof(int), cudaMemcpyDeviceToHost));
                    current_data = temp;
                }
                break; // Proceed to next byte_pos
            }
        }

        byte_pos++;
    }

    // Free device memory
    cudaFree(d_data);
    cudaFree(d_histogram);
    cudaFree(d_filtered_data);
}

int main() {
    std::vector<int> data = {399, 18, 512, 1024, 42, 123, 34, 255, 67, 89,
                             101, 44, 111, 222, 333, 444, 555, 666, 777, 888, 999};
    std::vector<int> top_k;
    find_top_k_cuda(data, top_k);

    std::cout << "Top " << K << " numbers are:\n";
    for (int num : top_k) {
        std::cout << num << '\n';
    }

    return 0;
}