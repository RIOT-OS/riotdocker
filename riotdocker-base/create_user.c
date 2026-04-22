/*
 * Docker runs containers with local root privileges. That means, that all
 * accesses to shared directories and files will be performed as root, leading
 * to possibly inaccessible files and files with the wrong owner (root instead
 * of the local user).
 *
 * Docker allows to set the user ID and user group with the `--user` argument
 * when running a Docker container. That argument however only sets the
 * respective IDs and not the user- and groupname.
 *
 * Therefore, this file is compiled as a binary that is executed by `run.sh`
 * every time a Docker container (or child of the `riotdocker-base` container)
 * is executed. It sets the home directory, user- and groupnames and UID:GID.
 *
 * The username and groupname is set to `riotbuild`, but they are just aliases,
 * as the underlying rights mechanism only checks the IDs and not the names.
 */

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
    unsigned gid = atoi(argv[2]);
    char buf[128];

    /* create the usergroup */
    sprintf(buf, "/usr/sbin/groupadd -g %u %s", gid, USERNAME);
    system(buf);

    /* set the UID, Home Directory, User Group */
    sprintf(buf, "/usr/sbin/useradd -u %u -d %s -g %u %s", uid, HOMEDIR, gid, USERNAME);
    system(buf);

    return 0;
}
