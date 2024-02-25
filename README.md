# eaglesong-verilog

A Verilog implementation of the Eaglesong hash algorithm

## Base Algorithm Specification

The Eaglesong hash algorithm/function is defined and implemented in the
[Nervos Network's Requestion for Comments repo](https://github.com/nervosnetwork/rfcs). RFC 0010 defines the Eaglesong
hash algorithm:
[link to forked spec permalink](https://github.com/nervosnetwork/rfcs/tree/dff5235616e5c7aec706326494dce1c54163c4be/rfcs/0010-eaglesong),
[link to master](https://github.com/nervosnetwork/rfcs/tree/master/rfcs/0010-eaglesong).

This reference implementation has been copied into this repo in the `reference/` folder. It has been modified to serve
as a model of the rough implementation style used in this project.

## Features and Limitations

-   Reasonably comprehensive test cases.
-   Supports input lengths of 1 byte to 32 bytes.
    -   Note that Eaglesong supports infinitely-long inputs by spec; this implementation imposed this limitation for
        ease of development and validation.
-   Execution takes about 43 clock cycles for `input_length <= 31`, and 86 clock cycles for `input_length >= 32`.
-   Works in IVerilog v2.0.0.
    -   For example, System Verilog technically supports assigning an array register to an array register, but IVerilog
        requires that this assignment is done for each array index separately in a `generate` block.

### Warnings and Limitations

This project was created as a school assignment. It should not be used in any security-critical applications without
further validation. Its correctness is not guaranteed.

## Future Work/Options

-   Look at further optimizations by referencing the optimized OpenCL implementation.
-   Look at pipelining to get better throughput-per-logic element.
-   Look at optimizations with longest-path within the all perms block, and maybe setup that section to be clocked.

## License

This project is licensed under the
[CERN Open Hardware Licence Version 2 - Permissive](https://choosealicense.com/licenses/cern-ohl-p-2.0/) license.

## Lessons Learned

-   Both `iverilog`/`vvp` and `verilator` can generate GtkWave `.vcd` waveform files. `vvp` requires a specific argument
    to make it happen, though.
