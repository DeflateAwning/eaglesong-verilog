#!/bin/bash

set -e

# Print the version of the tools used
verilator --version

# verilator --trace -Irtl/ -Itb/ -cc tb/tb_eaglesong_digest_top.sv rtl/eaglesong_digest_top.sv --exe tb_eaglesong_digest_top.cpp --timing
verilator --trace -Irtl/ -Itb/ -cc rtl/eaglesong_digest_top.sv --exe tb_eaglesong_digest_top.cpp --timing
echo "=== Done verilator generation ==="

# make -C obj_dir/ -fVeaglesong_digest_top.mk
make -C obj_dir/ -fVeaglesong_digest_top.mk
echo "=== Done make ==="

./obj_dir/Veaglesong_digest_top
echo "=== Done running eaglesong_digest_top ==="
