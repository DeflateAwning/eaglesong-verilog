#include <stdio.h>
#include <stdint.h>
#include <string.h>

// prototype
void EaglesongHash( unsigned char * output, const unsigned char * input, int input_length );

uint8_t run_one_test( const unsigned char * input, uint16_t input_length, const unsigned char * expected_output_hex_str ) {
    // returns 0 if the test passes, 1 if it fails

    unsigned char output[32];
    unsigned char output_hex_str[300];
    output_hex_str[0] = 0;

    EaglesongHash(output, input, input_length);

    // make the output_hex_str
    for( uint8_t i = 0 ; i < 32 ; ++i ) {
        sprintf(&output_hex_str[strlen(output_hex_str)], "%02x", output[i]);
    }

    printf("Input: %s = ", input);
    // print input
    for( uint8_t i = 0 ; i < input_length ; ++i ) {
        printf("%02x", input[i]);
    }
    printf(" (len = %d)\n", input_length);
    printf("expected output=%s\n", expected_output_hex_str);
    printf("actual   output=%s\n", output_hex_str);

    uint8_t is_match = 1;
    uint8_t mismatch_idx = 0;
    for (mismatch_idx = 0; mismatch_idx < strlen(expected_output_hex_str); mismatch_idx++) {
        if (output_hex_str[mismatch_idx] != expected_output_hex_str[mismatch_idx]) {
            is_match = 0;
            break;
        }
    }
    if (! is_match) {
        printf("WHERE:          ");
        for (uint8_t i = 0; i < mismatch_idx; i++) {
            printf(" ");
        }
        printf("^\nTest failed. ERROR!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n");
        return 1;
    }
    else {
        printf("Test passed.\n");
    }
    return 0;
}

void main( int argc, char ** argv ) {
    uint8_t test_fail_count = 0;

    printf("============= Starting test 0 =============\n");
    uint8_t test0input[32] = "Hello, world!\n";
    test_fail_count += run_one_test(test0input, strlen(test0input),
                                    "64867e2441d162615dc2430b6bcb4d3f4b95e4d0db529fca1eece73c077d72d6");
    printf("============= Done test 0 =============\n");


    // Ones below line up with tests in Verilator

    printf("============= Starting test 4 =============\n");
    uint8_t test4input[32] = {33, 171, 95, 7, 243, 253, 131, 21, 216, 99, 103, 211, 165, 214, 209, 194,
                                253, 92, 153, 235, 172, 116, 61, 142, 120, 33, 235, 89, 234, 111, 7, 240};
    test_fail_count += run_one_test(
        test4input, 32,
        "7df6cb8acd710a57409ce18224c8b340237699f7c75ee1bf5e1100aab1a38bc1");
    printf("============= Done test 4 =============\n");

    printf("============= Starting test 5 =============\n");
    // contains both '0x00' and '0xFF' bytes
    uint8_t test5input[32] = {33, 203, 57, 70, 205, 255, 102, 53, 87, 12, 176, 198, 245, 211, 253, 96,
                                221, 99, 237, 68, 110, 125, 47, 36, 80, 180, 13, 179, 2, 0, 3, 5};
    test_fail_count += run_one_test(
        test5input, 32,
        "39295743dff7453f57ee2ebbbeebd55fb72006baadb8c9f5835a7d9d52d17cd2");
    printf("============= Done test 5 =============\n");

    printf("%d tests failed.\n", test_fail_count);
    printf("============= Done all tests =============\n");
   
}
