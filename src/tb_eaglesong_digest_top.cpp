#include <stdlib.h>
#include <iostream>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "obj_dir/Veaglesong_digest_top.h"
#include "obj_dir/Veaglesong_digest_top___024unit.h"

#define MAX_SIM_TIME 5000
vluint64_t sim_time = 0;

Veaglesong_digest_top *dut;
VerilatedVcdC *m_trace;

void tick() {
    dut->clk ^= 1;
    dut->eval();
    m_trace->dump(sim_time++);

    dut->clk ^= 1;
    dut->eval();
    m_trace->dump(sim_time++);
}

int main(int argc, char** argv, char** env) {
    dut = new Veaglesong_digest_top;

    Verilated::traceEverOn(true);
    m_trace = new VerilatedVcdC;
    dut->trace(m_trace, 5);
    m_trace->open("waveform.vcd");

    ////////////
    tick();
    tick();
    
    // set the 'Hello, world!\n' test (literally, that text)
    // PYTHON: a = "48 65 6C 6C 6F 2C 20 77 6F 72 6C 64 21 0A".split(' ')
    // PYTHON bad: print(', '.join(['0x' + i for i in a]))
    // PYTHON bad: for idx, val in enumerate(a): print(f"dut->input_val[{idx}] = 0x{val};")
    // PYTHON: for i in range(0, len(a), 4): print(f"dut->input_val[{i//4}] = 0x{''.join(a[i+4:i:-1])};")
    dut->input_val[0] = 0x6C6C6548;
    dut->input_val[1] = 0x77202C6F;
    dut->input_val[2] = 0x646C726F;
    dut->input_val[3] = 0x0A21;

    // Note: the rest of the 32 bytes get set to zero
    dut->input_length_bytes = 14;
    dut->start_eval = 1;
    
    tick();
    
    dut->start_eval = 0; // trigger the start
    
    tick();
    
    while (sim_time < MAX_SIM_TIME) {
        tick();
    }

    m_trace->close();
    delete dut;
    exit(EXIT_SUCCESS);
}
