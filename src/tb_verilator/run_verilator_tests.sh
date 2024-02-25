#!/bin/bash

set -e

# TODO: make paths in here work relative to this script's location

# Print the version of the tools used
verilator --version

# verilator --trace -I../rtl/ -cc ../tb/tb_eaglesong_digest_top.sv ../rtl/eaglesong_digest_top.sv --exe ../tb_verilator/tb_eaglesong_digest_top.cpp --timing
verilator --trace -I../rtl/ -cc ../rtl/eaglesong_digest_top.sv --exe ../tb_verilator/tb_eaglesong_digest_top.cpp --timing
echo "=== Done verilator generation ==="

# make -C obj_dir/ -fVeaglesong_digest_top.mk
make -C obj_dir/ -fVeaglesong_digest_top.mk
echo "=== Done make ==="

./obj_dir/Veaglesong_digest_top
echo "=== Done running eaglesong_digest_top ==="
