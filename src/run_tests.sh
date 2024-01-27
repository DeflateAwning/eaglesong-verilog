#!/bin/bash

# Print the version of the tools used
iverilog -V 2>/dev/null | head -n 1

# Compile the testbenchs
echo "=== Building tb_eaglesong_bit_matrix"
iverilog -o ./tb_eaglesong_bit_matrix.iv_sim.vvp ./rtl/eaglesong_bit_matrix.v ./tb/tb_eaglesong_bit_matrix.v
echo "=== Running tb_eaglesong_bit_matrix"
vvp ./tb_eaglesong_bit_matrix.iv_sim.vvp
