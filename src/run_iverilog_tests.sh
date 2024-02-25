#!/bin/bash

# halt if any stage's exit code is not 0
set -e

# Print the version of the tools used
iverilog -V 2>/dev/null | head -n 1

IVERILOG_ARGS='-g2012 -Wall'
VVP_RUN_LOG_FILENAME='/tmp/vvp_run_log.txt'

# create empty run log
date --iso-8601=seconds > $VVP_RUN_LOG_FILENAME

echo "=== Building tb_eaglesong_permutation"
iverilog $IVERILOG_ARGS -o ./tb_eaglesong_permutation.iv_sim.vvp ./rtl/eaglesong_permutation.sv ./tb/tb_eaglesong_permutation.sv
echo "iverilog exit code: $?"
echo "=== Running tb_eaglesong_permutation"
vvp ./tb_eaglesong_permutation.iv_sim.vvp | tee -a $VVP_RUN_LOG_FILENAME
echo "=== Done tb_eaglesong_permutation"

echo "=== Building tb_eaglesong_all_permutations"
iverilog $IVERILOG_ARGS -o ./tb_eaglesong_all_permutations.iv_sim.vvp ./rtl/eaglesong_all_permutations.sv ./rtl/eaglesong_permutation.sv ./tb/tb_eaglesong_all_permutations.sv
echo "iverilog exit code: $?"
echo "=== Running tb_eaglesong_all_permutations"
vvp ./tb_eaglesong_all_permutations.iv_sim.vvp | tee -a $VVP_RUN_LOG_FILENAME
echo "=== Done tb_eaglesong_all_permutations"

echo "=== Building tb_eaglesong_absorb_comb"
iverilog $IVERILOG_ARGS -o ./tb_eaglesong_absorb_comb.iv_sim.vvp ./rtl/eaglesong_absorb_comb.sv ./tb/tb_eaglesong_absorb_comb.sv
echo "iverilog exit code: $?"
echo "=== Running tb_eaglesong_absorb_comb"
vvp ./tb_eaglesong_absorb_comb.iv_sim.vvp | tee -a $VVP_RUN_LOG_FILENAME
echo "=== Done tb_eaglesong_absorb_comb"

echo "=== Building tb_eaglesong_digest_top"
iverilog $IVERILOG_ARGS -o ./tb_eaglesong_digest_top.iv_sim.vvp \
    ./rtl/eaglesong_digest_top.sv \
    ./rtl/eaglesong_absorb_comb.sv \
    ./rtl/eaglesong_permutation.sv \
    ./rtl/eaglesong_all_permutations.sv \
    ./tb/tb_eaglesong_digest_top.sv
echo "iverilog exit code: $?"
echo "=== Running tb_eaglesong_digest_top"
vvp ./tb_eaglesong_digest_top.iv_sim.vvp | tee -a $VVP_RUN_LOG_FILENAME
echo "=== Done tb_eaglesong_digest_top"

echo "===== Done running all testbenches. ====="

grep "Argh" $VVP_RUN_LOG_FILENAME

echo "===== Done reiterating errors. ====="
