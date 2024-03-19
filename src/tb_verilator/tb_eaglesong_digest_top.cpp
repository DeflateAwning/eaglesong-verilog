#include <stdlib.h>
#include <iostream>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "obj_dir/Veaglesong_digest_top.h"
#include "obj_dir/Veaglesong_digest_top___024unit.h"

// function prototype for the reference C function implementation
void EaglesongHash( unsigned char * output, const unsigned char * input, unsigned int input_length );

#define MAX_SIM_TIME 5000
vluint64_t sim_time;

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

// arr is an array of 8x 32-bit elements
void print_funky_32bit_array(const uint32_t arr[]) {
    // prints funky Verilator representation of 32-bit array as a little-endian 256-bit array

    for (int8_t arr_idx = 7; arr_idx >= 0; arr_idx--) {
        for (int8_t byte_num = 3; byte_num >= 0; byte_num--) {
            printf("%02X", (arr[arr_idx] >> (byte_num * 8)) & 0xFF);
        }
        printf(" "); // for readability
    }
    printf("\n");
}

// input_vals is an array of bytes; should be 32 bytes long (even if trailing bytes are 0 and unused)
// expected_output is an array of bytes; must be 32 bytes long
uint8_t run_full_test(const uint8_t input_vals[], uint32_t input_length_bytes, const char test_name[]) {
    // setup
    sim_time = 0;
    dut = new Veaglesong_digest_top;
    m_trace = new VerilatedVcdC;

    dut->trace(m_trace, 5);
    
    char waveform_file_name[100];
    sprintf(waveform_file_name, "waveform_%s.vcd", test_name);
    m_trace->open(waveform_file_name);

    ////////////
    tick();
    tick();
    
    // set the 'Hello, world!\n' test (literally, that text)
    // PYTHON: a = "48 65 6C 6C 6F 2C 20 77 6F 72 6C 64 21 0A".split(' ')
    // PYTHON bad: print(', '.join(['0x' + i for i in a]))
    // PYTHON bad: for idx, val in enumerate(a): print(f"dut->input_val[{idx}] = 0x{val};")
    // PYTHON: for i in range(0, len(a), 4): print(f"dut->input_val[{i//4}] = 0x{''.join(a[i+4:i:-1])};")
    // dut->input_val[0] = 0x6C6C6548;
    // dut->input_val[1] = 0x77202C6F;
    // dut->input_val[2] = 0x646C726F;
    // dut->input_val[3] = 0x00000A21;
    // dut->input_val[4] = 0; // [5], [6], [7] are also 0

    for (uint8_t target_input_val_idx = 0; target_input_val_idx < 8; target_input_val_idx++) {
        dut->input_val[target_input_val_idx] = 0;

        for (uint8_t byte_num = 0; byte_num < 4; byte_num++) {
            const uint8_t byte_val = (target_input_val_idx * 4 + byte_num < input_length_bytes) ? input_vals[target_input_val_idx * 4 + byte_num] : 0;
            dut->input_val[target_input_val_idx] |= ((uint32_t)byte_val) << (byte_num * 8);
        }
    }

    dut->input_length_bytes = input_length_bytes;
    dut->start_eval = 1;
    
    tick();
    
    dut->start_eval = 0; // trigger the start
    
    tick();
    
    while (sim_time < MAX_SIM_TIME) {
        tick();

        // when the output is ready, run a couple more ticks then end
        if (dut->eval_output_ready) {
            printf("LOG: eval_output_ready>0 now. sim_time=%ld. Output value: ", sim_time);
            print_funky_32bit_array(dut->output_val);

            for (int i = 0; i < 5; i++) tick();
            printf("LOG: ending because eval_output_ready>0 now.\n");
            break;
        }
    }

    // check the output
    uint8_t expected_output[32] = {0};
    EaglesongHash(expected_output, input_vals, input_length_bytes);

    uint32_t expected_output_funky[8];
    for (int output_val_idx = 0; output_val_idx < 8; output_val_idx++) {
        uint32_t expected_val = 0;
        for (int byte_num = 3; byte_num >= 0; byte_num--) {
            expected_val |= ((uint32_t)expected_output[output_val_idx * 4 + byte_num]) << (byte_num * 8);
        }

        expected_output_funky[output_val_idx] = expected_val;
    }
    printf("Expected output: ");
    print_funky_32bit_array((const uint32_t *)expected_output_funky);
    printf("Received output: ");
    print_funky_32bit_array(dut->output_val);

    for (int i = 0; i < 8; i++) {
        if (dut->output_val[i] != expected_output_funky[i]) {
            printf("ERROR: output_val[%d] is not as expected. Got %08X, expected %08X.\n", i, dut->output_val[i], expected_output_funky[i]);
            return 100;
        }
    }

    if (sim_time >= MAX_SIM_TIME) {
        printf("LOG: ending because sim_time>=MAX_SIM_TIME.\n");
        return 1;
    }

    if (sim_time >= 150) {
        printf("LOG: ending because sim_time>=150.\n");
        return 2;
    }

    m_trace->close();
    delete dut;
    
    return 0;
}

int main(int argc, char** argv, char** env) {
    Verilated::commandArgs(argc, argv);
    Verilated::traceEverOn(true);

    const uint8_t number_of_tests = 2;
    uint8_t test_results[number_of_tests] = {0};

    // TEST 0
    uint8_t input_vals_0[32] = {0};
    const uint8_t input_length_bytes_0 = 14; // "Hello, world!\n"
    memcpy(input_vals_0, (uint8_t*)"Hello, world!\n", input_length_bytes_0);
    assert (strlen((char*)input_vals_0) == input_length_bytes_0);
    test_results[0] = run_full_test((const uint8_t *)input_vals_0, input_length_bytes_0, "test_0_hello_world");

    // TEST 1
    uint8_t input_vals_1[32] = {0};
    const uint8_t input_length_bytes_1 = 31; // 31 chars, plus null terminator
    memcpy(input_vals_1, (uint8_t*)"ABCDEFGHIJKLMNOPQRSTUVWXYZ12345", input_length_bytes_1);
    assert (strlen((char*)input_vals_1) == 31);
    test_results[1] = run_full_test((const uint8_t *)input_vals_1, input_length_bytes_1, "test_1_31_chars");

    // TODO: add a legit 32-char test
    // FIXME: start here! it failed last time I tried with a 32-char test a second ago

    // print results
    printf("============= TEST RESULTS ============\n");
    for (int i = 0; i < number_of_tests; i++) {
        printf("Test %d: %s (code=%d)\n", i, (test_results[i] == 0) ? "PASS" : "FAIL", test_results[i]);
    }
    printf("=========== END TEST RESULTS ===========\n");

    printf("Done all tests.\n");
    exit(EXIT_SUCCESS);
}
