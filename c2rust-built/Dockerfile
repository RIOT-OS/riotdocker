FROM immunant/c2rust:ubuntu-bionic-latest as c2rust

# --locked --git --branch ignores --locked; new (2021-03-something) cargo
# versions behave properly, but C2Rust is on a 2019-12-05 toolchain.
#
# Cleaning up cargo home again as set by C2Rust image (that's what contributes
# most to the delta between the immunant container and this one).
RUN git clone --recursive https://github.com/chrysn-pull-requests/c2rust -b for-riot && \
    cargo install --locked --root /usr --path c2rust/c2rust && \
    rm -rf c2rust && \
    rm -rf ${CARGO_HOME}
