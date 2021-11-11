This image contains built and usable versions of [c2rust].
It is provided because upstream [does not release binaries] for c2rust and its companion tools,
and because the [branch this is built from (for-riot)] contains some fixes to c2rust required to work on RIOT.

This is built as part of the local CI
and published as riot/c2rust-built,
but used mainly through how it is copied into the riotbuild container.

[c2rust]: https://github.com/immunant/c2rust
[does not release binaries]: https://github.com/immunant/c2rust/issues/326
[branch this is built from (for-riot)]: https://github.com/chrysn-pull-requests/c2rust/tree/for-riot
