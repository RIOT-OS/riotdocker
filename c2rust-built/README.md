This image contains built and usable versions of [c2rust].
It is provided because upstream [does not release binaries] for c2rust and its companion tools,
and because the [branch this is built from (for-riot)] contains some fixes to c2rust required to work on RIOT.

As this changes rarely,
and because on the github-workers infrastructure this is [difficult to get right],
this is not built and used through CI yet,
but manually built an published as:

    docker build . -t chrysn/c2rust-built

The resulting image fulfils three roles:

* c2rust can be executed in there immediately, or used as a base for other images.
* The binaries in `/usr/bin/c2rust` can be extracted and used in other images.
* The `./c2rust_0.0_amd64.deb` package can be copied and installed in other images.
  Unlike copying the binaries over, this also ensures that the right LLVM dependencies are installed there.

[c2rust]: https://github.com/immunant/c2rust
[does not release binaries]: https://github.com/immunant/c2rust/issues/326
[branch this is built from (for-riot)]: https://github.com/chrysn-pull-requests/c2rust/tree/for-riot
[difficult to get right]: https://github.com/RIOT-OS/riotdocker/pull/141
