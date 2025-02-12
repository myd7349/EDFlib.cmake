#include <stdio.h>

int main(void)
{
#if defined(__ELF__)
    puts("__ELF__ defined.");
#else
    puts("__ELF__ not defined.");
#endif

#if defined(__GNUC__)
    printf("__GNUC__ defined: %d.\n", __GNUC__);
#else
    puts("__GNUC__ not defined.");
#endif

    return 0;
}