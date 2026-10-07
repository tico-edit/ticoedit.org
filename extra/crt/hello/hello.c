/* hello.c: a friendly greeting from tico. */

#include <stdio.h>

int main(int argc, char *argv[])
{
    if (argc < 2) {
        printf("Hello, %s!\n", "world");
        return 0;
    }

    for (int i = 1; i < argc; i++)
        printf("Hello, %s!\n", argv[i]);

    return 0;
}
