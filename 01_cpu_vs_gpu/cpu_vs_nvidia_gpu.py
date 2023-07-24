from numba import jit

from timeit import default_timer as timer

def cpu_func(n):
    acc=[]
    i=0
    while i < n:
        acc.append(i)
        i += 1
    return acc

@jit(target_backend="cuda")
def gpu_func(n):
    acc=[]
    i=0
    while i < n:
        acc.append(i)
        i += 1
    return acc

if __name__ == "__main__":
    n = 100000000

    start = timer()
    x = cpu_func(n)
    print("With CPU: ", timer()-start)
    print(len(x))

    start = timer()
    y = gpu_func(n)
    print("With GPU: ", timer()-start)
    print(len(y))    


