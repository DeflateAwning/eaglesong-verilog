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

    printf("\n\n\n========== STARTING TEST %s ======================\n", test_name);

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

    printf("========== ^^ RESULTS OF TEST %s ======================\n", test_name);

    uint32_t ret_val = 0;
    for (int i = 0; i < 8; i++) {
        if (dut->output_val[i] != expected_output_funky[i]) {
            printf("ERROR: output_val[%d] is not as expected. Got %08X, expected %08X.\n", i, dut->output_val[i], expected_output_funky[i]);
            ret_val = 100;
        }
    }

    // must call before we return, otherwise the trace isn't saved
    m_trace->close();
    delete dut;
    
    if (ret_val > 0) return ret_val;

    if (sim_time >= MAX_SIM_TIME) {
        printf("LOG: ending because sim_time>=MAX_SIM_TIME.\n");
        return 1;
    }

    if (sim_time >= 150) {
        printf("LOG: ending because sim_time>=150.\n");
        return 2;
    }
    
    return 0;
}

int main(int argc, char** argv, char** env) {
    Verilated::commandArgs(argc, argv);
    Verilated::traceEverOn(true);

    const uint8_t number_of_tests = 6;
    uint8_t test_results[number_of_tests];
    memset(test_results, 0, number_of_tests);

    // TEST 0
    uint8_t input_vals_0[32];
    memset(input_vals_0, 0, number_of_tests);
    const uint8_t input_length_bytes_0 = 14; // "Hello, world!\n"
    memcpy(input_vals_0, (uint8_t*)"Hello, world!\n", input_length_bytes_0);
    assert (strlen((char*)input_vals_0) == input_length_bytes_0);
    test_results[0] = run_full_test((const uint8_t *)input_vals_0, input_length_bytes_0, "test_0_hello_world");

    // TEST 1
    uint8_t input_vals_1[32];
    const uint8_t input_length_bytes_1 = 31; // 31 chars, plus null terminator
    memcpy(input_vals_1, (uint8_t*)"ABCDEFGHIJKLMNOPQRSTUVWXYZ12345", input_length_bytes_1);
    assert (strlen((char*)input_vals_1) == 31);
    test_results[1] = run_full_test((const uint8_t *)input_vals_1, input_length_bytes_1, "test_1_31_chars");

    // TEST 2
    const uint8_t full_test_len = 32;
    uint8_t input_vals_2[32]; // all the same value
    memset(input_vals_2, 42, full_test_len);
    test_results[2] = run_full_test((const uint8_t *)input_vals_2, full_test_len, "test_2_32_bytes_all_the_same");

    // PYTHON:
    // from random import randint
    // print([randint(0, 255) for i in range(32)])

    // TEST 3
    uint8_t input_vals_3[32] = {182, 33, 37, 171, 74, 97, 148, 190, 119, 209, 236, 4, 184,
                                13, 32, 5, 38, 209, 211,
                                217, 17, 71, 125, 75, 119, 157, 25, 132, 188, 139, 167, 206};
    test_results[3] = run_full_test((const uint8_t *)input_vals_3, full_test_len, "test_3_32_bytes_rand");

    // FIXME: start here! it failed last time I tried with a 32-char test a second ago

    // TEST 4 (also in model)
    uint8_t input_vals_4[32] = {33, 171, 95, 7, 243, 253, 131, 21, 216, 99, 103, 211, 165, 214, 209, 194,
                                253, 92, 153, 235, 172, 116, 61, 142, 120, 33, 235, 89, 234, 111, 7, 240};
    test_results[4] = run_full_test((const uint8_t *)input_vals_4, full_test_len, "test_4_32_bytes_rand");

    // TEST 5 (also in model)
    uint8_t input_vals_5[32] = {33, 203, 57, 70, 205, 255, 102, 53, 87, 12, 176, 198, 245, 211, 253, 96,
                                221, 99, 237, 68, 110, 125, 47, 36, 80, 180, 13, 179, 2, 0, 3, 5};
    test_results[5] = run_full_test((const uint8_t *)input_vals_5, full_test_len, "test_5_32_bytes_rand");


    // TODO: add tests of runtime-generated random 32-byte arrays

    // print results
    printf("============= TEST RESULTS ============\n");
    for (int i = 0; i < number_of_tests; i++) {
        printf("Test %d: %s (code=%d)\n", i, (test_results[i] == 0) ? "PASS" : "FAIL", test_results[i]);
    }
    printf("=========== END TEST RESULTS ===========\n");

    printf("Done all tests.\n");
    exit(EXIT_SUCCESS);
}
