# riotbuild

Dockerfiles for creating build environment for building RIOT projects.

# `tinybuild-*`` and `smallbuild-*`` Containers

Compared to the full fledges `riotbuild` container, the `smallbuild-*`
 containers only a single architecture. The `tinybuild-*` are trimmed down
even more by only supporting C code by dropping the C++ and rust toolchains.
(Except for AVR, which always provides C++ support.)

## Platform Support

| Image                 | Size      | `native32` | `native64` | ARM7 Boards | Cortex M Boards | RISC-V Boards | AVR8 Boards | MSP430 Boards | ESP* Xtensa Boards | ESP* RISC-V Boards |
| `riotbuild`           | ~ 13.5 GB | ✔          | ✔          | ✔           | ✔               | ✔             | ✔           | ✔             | ✔                  | ✔                  |
| `smallbuild-arm`      | ~ 4.3 GB  |            |            | ✔           | ✔               |               |             |               |                    |                    |
| `smallbuild-msp430`   | ~ 0.5 GB  |            |            |             |                 |               |             |✔              |                    |                    |
| `smallbuild-native64` | ~ 2.4 GB  |            | ✔          |             |                 |               |             |               |                    |                    |
| `smallbuild-risc-v`   | ~ 3.3 GB  |            |            |             |                 | ✔             |             |               |                    |                    |
| `tinybuild-arm`       | ~ 1.2 GB  |            |            |             |                 | ✔             |             |               |                    |                    |
| `tinybuild-avr`       | ~ 0.4 GB  |            |            |             |                 |               | ✔           |               |                    |                    |
| `tinybuild-msp430`    | ~ 0.4 GB  |            |            |             |                 |               |             |✔              |                    |                    |
| `tinybuild-native64`  | ~ 0.3 GB  |            | ✔          |             |                 |               |             |               |                    |                    |
| `tinybuild-risc-v`    | ~ 1.1 GB  |            |            |             |                 | ✔             |             |               |                    |                    |

## Language Support

| Image                 | Size      | C | C++   | rust  |
| `riotbuild`           | ~ 13.5 GB | ✔ | ✔ [1] | ✔ [2] |
| `smallbuild-arm`      | ~ 4.3 GB  | ✔ | ✔     | ✔     |
| `smallbuild-msp430`   | ~ 0.5 GB  | ✔ | ✔     |       |
| `smallbuild-native64` | ~ 2.4 GB  | ✔ | ✔     | ✔     |
| `smallbuild-risc-v`   | ~ 3.3 GB  | ✔ | ✔     | ✔     |
| `tinybuild-arm`       | ~ 1.2 GB  | ✔ |       |       |
| `tinybuild-avr`       | ~ 0.4 GB  | ✔ | ✔ [1] |       |
| `tinybuild-msp430`    | ~ 0.4 GB  | ✔ |       |       |
| `tinybuild-native64`  | ~ 0.3 GB  | ✔ |       |       |
| `tinybuild-risc-v`    | ~ 1.1 GB  | ✔ |       |       |

1. On AVR, C++ is supported but libstdc++ is not
2. rust is not provided for some architectures
