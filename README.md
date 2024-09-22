# Top K Byte Counting

Top K Byte Counting is an efficient C/C++ implementation designed to identify the top **K** integers from a dataset using a byte-wise counting approach. This algorithm achieves linear time complexity, making it highly suitable for large datasets where traditional sorting or heap-based methods may be less efficient.

## Table of Contents

- [Top K Byte Counting](#top-k-byte-counting)
  - [Table of Contents](#table-of-contents)
  - [Description](#description)
  - [Features](#features)
  - [Installation](#installation)
    - [Steps](#steps)
  - [Usage](#usage)
    - [File Structure](#file-structure)
    - [Running the Program](#running-the-program)
  - [Algorithm Overview](#algorithm-overview)
  - [Example](#example)
    - [Source Code Snippet](#source-code-snippet)

## Description

Finding the top **K** elements in a dataset is a common requirement in various applications, such as data analysis, real-time processing, and more. The Top K Byte Counting algorithm leverages byte-wise counting to achieve this efficiently. By focusing on individual byte positions, the algorithm ensures that the most significant bytes are processed first, allowing for rapid exclusion of non-qualifying elements and reducing unnecessary computations.

## Features

- **Linear Time Complexity (O(N))**: Processes the dataset in a single pass, ensuring scalability for large inputs.
- **Memory Efficient**: Utilizes fixed-size counting arrays to minimize additional memory usage.
- **Simple Implementation**: Straightforward C code that's easy to understand and modify.
- **Deterministic Performance**: Consistent execution time without the risk of degradation found in some recursive algorithms.

## Installation

To compile and run the Top K Byte Counting program, ensure you have a C compiler installed on your machine (e.g., `gcc`).

### Steps

1. **Clone the Repository**

   ```bash
   git clone https://github.com/mwmuni/top-k-byte-counting.git
   cd top-k-byte-counting
   ```

2. **Compile the Program**

   ```bash
   gcc -o top-k-byte-counting top-k-byte-counting.c
   ```

3. **Run the Program**

   ```bash
   ./top-k-byte-counting
   ```

## Usage

The program is designed to find the top **K** integers from a predefined array. You can modify the input data and the value of **K** as needed.

### File Structure

- `top-k-byte-counting.c`: Main source file containing the implementation.
- `top-k-byte-counting.cpp`: C++ version of the implementation.
- `byte-counting-sort.cpp`: Additional sorting implementation.

### Running the Program

Upon execution, the program will output the top **K** numbers from the provided dataset.

## Algorithm Overview

Start find_top_k(data, byte_pos, top_k)
|
├── Check base cases:
│   ├── If data is empty, return.
│   ├── If top_k.size() >= K, return.
│   └── If byte_pos >= NUM_BYTES, return.
|
├── Initialize counts[0...255] to zero.
|
├── For each num in data:
│   ├── Extract byte_value at byte_pos.
│   └── Increment counts[byte_value].
|
├── For i from 255 downto 0:
│   ├── If counts[i] == 0, continue.
│   ├── If top_k.size() + counts[i] <= K:
│   │   ├── For each num in data:
│   │   │   ├── If byte_value == i:
│   │   │   │   └── Add num to top_k.
│   │   └── Check if top_k.size() >= K, return if true.
│   └── Else:
│       ├── Create bin_numbers with nums where byte_value == i.
│       ├── Recursive call find_top_k(bin_numbers, byte_pos + 1, top_k).
│       └── Check if top_k.size() >= K, return if true.
|
└── End find_top_k

## Example

### Source Code Snippet

```c
int main() {
    int data[] = {399, 18, 512, 42, 123, 34, 255, 67, 89, 101, 44, 111, 222, 333, 444, 555, 666, 777, 888, 999};
    int n = sizeof(data) / sizeof(data[0]);
    int k = K;
    int top_k[K];
    int current_k = 0;

    find_top_k(data, n, 0, k, top_k, &current_k);

    printf("Top %d numbers are:\n", k);
    for (int i = 0; i < current_k; i++) {
        printf("%d\n", top_k[i]);
    }
    return 0;
}
```
