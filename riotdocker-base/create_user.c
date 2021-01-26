#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <unistd.h>

int main(int argc, char *argv[])
{
    if (argc < 2) {
        return 1;
    }

    setuid(0);

    unsigned uid = atoi(argv[1]);
    char buf[128];

    sprintf(buf, "/usr/sbin/useradd -u %u -d %s -r -g 0 -N %s", uid, HOMEDIR, USERNAME);
    system(buf);
    return 0;
}
