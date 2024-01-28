#!/bin/bash

# halt if any stage's exit code is not 0
set -e

# Print the version of the tools used
iverilog -V 2>/dev/null | head -n 1


echo "=== Building tb_eaglesong_bit_matrix"
iverilog -Wall -o ./tb_eaglesong_bit_matrix.iv_sim.vvp ./rtl/eaglesong_bit_matrix.v ./tb/tb_eaglesong_bit_matrix.v
echo "iverilog exit code: $?"
echo "=== Running tb_eaglesong_bit_matrix"
vvp ./tb_eaglesong_bit_matrix.iv_sim.vvp
echo "=== Done tb_eaglesong_bit_matrix"

echo "=== Building tb_eaglesong_coefficients"
iverilog -Wall -o ./tb_eaglesong_coefficients.iv_sim.vvp ./rtl/eaglesong_coefficients.v ./tb/tb_eaglesong_coefficients.v
echo "iverilog exit code: $?"
echo "=== Running tb_eaglesong_coefficients"
vvp ./tb_eaglesong_coefficients.iv_sim.vvp
echo "=== Done tb_eaglesong_coefficients"

