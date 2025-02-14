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

#if defined(__clang__)
    puts("__clang__ defined.");
#endif

#if defined(__APPLE__)
    puts("__APPLE__ defined.");
#endif

    return 0;
}


// References:
// https://github.com/cpredef/predef/blob/master/Compilers.md
// https://github.com/cpredef/predef/blob/master/OperatingSystems.md
