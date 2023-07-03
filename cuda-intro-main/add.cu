#include <iostream>
#include <math.h>

// Kernel function to add the elements of two arrays
__global__
void add(int n, float *x, float *y)
{
    // Varibles to allow kernal loop to run in parallel
    // We can use special cuda variables to calculate which index of the array we are going to operate on
    // (current block id) * (number of threads in block) + (index of current thread in block)
    int index = blockIdx.x * blockDim.x + threadIdx.x;
    // stride is set to the entire size of the array, this is a little confusing but a blog about this
    // approach can be found here https://developer.nvidia.com/blog/cuda-pro-tip-write-flexible-kernels-grid-stride-loops/
    // The i < n condition in the loop statement will prevent calculations out of the array bounds
    int stride = blockDim.x * gridDim.x;  // (number of threads in block) * (number of blocks)

    // loop using special index and stride values
    for (int i = index; i < n; i+=stride)
        y[i] = x[i] + y[i];
}

int main(void)
{
    // Test Parameters
    int N = 1<<20; // 1M elements
    float *x, *y; //define x and y as floats

    // Tuning Variables 
    int threads_in_block = 256; // CUDA uses 32 threads/block so use multiples of 32
    int number_of_blocks = ( N + threads_in_block - 1 ) / threads_in_block; // Calculate number of blocks need to get "N" threads

    // Allocate Unified Memory – accessible from CPU or GPU as arrays
    cudaMallocManaged(&x, N*sizeof(float));
    cudaMallocManaged(&y, N*sizeof(float));

    // initialize x and y arrays on the host
    for (int i = 0; i < N; i++) {
        x[i] = 1.0f;
        y[i] = 2.0f;
    }

    // Run kernel on 1M elements on the GPU
    add<<<number_of_blocks, threads_in_block>>>(N, x, y);

    // Wait for GPU to finish before accessing on host
    cudaDeviceSynchronize();

    // Check for errors (all values should be 3.0f)
    float maxError = 0.0f;
    for (int i = 0; i < N; i++)
        maxError = fmax(maxError, fabs(y[i]-3.0f));
    std::cout << "Max error: " << maxError << std::endl;

    // Free memory
    cudaFree(x);
    cudaFree(y);

    return 0;
}