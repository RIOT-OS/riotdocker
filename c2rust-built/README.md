This image contains built and usable versions of [c2rust].
It is provided because upstream [does not release binaries] for c2rust and its companion tools.

As this changes rarely,
and because on the github-workers infrastructure this is [difficult to get right],
this is not built and used through CI yet,
but manually built an published as:

    docker build . -t chrysn/c2rust-built

The resulting image fulfils three roles:

* c2rust can be executed in there immediately, or used as a base for other images.
* The binaries in `/usr/bin/c2rust` can be extracted and used in other images.
* The `./c2rust_*.deb` package can be copied and installed in other images.
  Unlike copying the binaries over, this also ensures that the right LLVM dependencies are installed there.

The parts that can be meaningfully performed by a Debian package are,
and the relevant files are located in the `debian/` directory.
As a side effect,
packages can be built using the same infrastructure even without a Docker container:
as long as a recent Rust version is present
and all the typical Debian tools are around,
`dpkg-buildpackage -b` will produce a usable package for the Debian (or derivative) installed on the system.

[c2rust]: https://github.com/immunant/c2rust
[does not release binaries]: https://github.com/immunant/c2rust/issues/326
[difficult to get right]: https://github.com/RIOT-OS/riotdocker/pull/141
