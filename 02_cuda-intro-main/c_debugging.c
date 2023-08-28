#include <stdio.h>  // for functions like printf, scanf, ...

int main() {   
    int d = 2;

    printf("Welcome to program with a bug: \n");
    scanf("%d", d);

    printf("You gave me: %d \n", d);

    return 0;
}
