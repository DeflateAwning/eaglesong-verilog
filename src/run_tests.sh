#!/bin/bash

# halt if any stage's exit code is not 0
set -e

# Print the version of the tools used
iverilog -V 2>/dev/null | head -n 1

IVERILOG_ARGS='-g2012 -Wall'

echo "=== Building tb_eaglesong_bit_matrix"
iverilog $IVERILOG_ARGS -o ./tb_eaglesong_bit_matrix.iv_sim.vvp ./rtl/eaglesong_bit_matrix.v ./tb/tb_eaglesong_bit_matrix.v
echo "iverilog exit code: $?"
echo "=== Running tb_eaglesong_bit_matrix"
vvp ./tb_eaglesong_bit_matrix.iv_sim.vvp
echo "=== Done tb_eaglesong_bit_matrix"

echo "=== Building tb_eaglesong_coefficients"
iverilog $IVERILOG_ARGS -o ./tb_eaglesong_coefficients.iv_sim.vvp ./rtl/eaglesong_coefficients.v ./tb/tb_eaglesong_coefficients.v
echo "iverilog exit code: $?"
echo "=== Running tb_eaglesong_coefficients"
vvp ./tb_eaglesong_coefficients.iv_sim.vvp
echo "=== Done tb_eaglesong_coefficients"

echo "=== Building tb_eaglesong_permutation"
iverilog $IVERILOG_ARGS -o ./tb_eaglesong_permutation.iv_sim.vvp ./rtl/eaglesong_permutation.sv ./tb/tb_eaglesong_permutation.sv
echo "iverilog exit code: $?"
echo "=== Running tb_eaglesong_permutation"
vvp ./tb_eaglesong_permutation.iv_sim.vvp
echo "=== Done tb_eaglesong_permutation"

echo "=== Building tb_eaglesong_all_permutations"
iverilog $IVERILOG_ARGS -o ./tb_eaglesong_all_permutations.iv_sim.vvp ./rtl/eaglesong_all_permutations.sv ./rtl/eaglesong_permutation.sv ./tb/tb_eaglesong_all_permutations.sv
echo "iverilog exit code: $?"
echo "=== Running tb_eaglesong_all_permutations"
vvp ./tb_eaglesong_all_permutations.iv_sim.vvp
echo "=== Done tb_eaglesong_all_permutations"
