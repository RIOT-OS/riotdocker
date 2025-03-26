#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main(int argc, char **argv)
{
    static char *rustc = "rustc";
    static char *fix_linking = "-Ctarget-feature=-crt-static";
    char **args = calloc(sizeof(char *), argc + 1);
    if (!args) {
        puts("calloc() failed");
        return EXIT_FAILURE;
    }

    args[0] = rustc;
    args[1] = fix_linking;


    int pos = 1;
    while (argv[pos] != NULL) {
        args[pos + 1] = argv[pos];
        pos++;
    }

    int retval = execv("/usr/bin/rustup-init", args);
    printf("execv() failed with: %d\n", retval);
    return EXIT_FAILURE;
}
