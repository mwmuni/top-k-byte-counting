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
    - [Example Execution](#example-execution)
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

```mermaid
flowchart TD
    A[Start find_top_k(data, byte_pos, top_k)] --> B{Check base cases}
    B -->|data is empty| C[Return]
    B -->|top_k.size() >= K| C[Return]
    B -->|byte_pos >= NUM_BYTES| C[Return]
    B --> D[Initialize counts[0...255] to zero]
    D --> E[For each num in data]
    E --> F[Extract byte_value at byte_pos]
    F --> G[Increment counts[byte_value]]
    G --> H[For i from 255 downto 0]
    H --> I{counts[i] == 0?}
    I -->|Yes| H
    I -->|No| J{top_k.size() + counts[i] <= K?}
    J -->|Yes| K[Add nums with byte_value == i to top_k]
    K --> L{top_k.size() >= K?}
    L -->|Yes| C[Return]
    L -->|No| H
    J -->|No| M[Create bin_numbers where byte_value == i]
    M --> N[Recursive call find_top_k(bin_numbers, byte_pos + 1, top_k)]
    N --> O{top_k.size() >= K?}
    O -->|Yes| C[Return]
    O -->|No| H
    H --> P[End find_top_k]
```

### Example Execution

Example Execution

Given:

std::vector<int> data = {399, 18, 512, 42, 123, 34, 255, 67, 89,
                         101, 44, 111, 222, 333, 444, 555, 666, 777, 888, 999};
const int K = 3;

1. First Call: find_top_k(data, 0, top_k)

Counts:

Counts of the most significant byte values are calculated.


Processing Bins:

Start from bin 255 downto 0.

Collect numbers from bins until top_k.size() >= K.



2. Recursive Calls

If a bin has more numbers than can fit in top_k, make a recursive call with byte_pos + 1.


3. Termination

The recursion continues until the top K numbers are found or all bytes are processed.


4. Result

top_k contains:

[999, 888, 777]  // The top 3 numbers


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
