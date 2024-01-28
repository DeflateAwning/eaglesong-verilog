#include <stdio.h>
#include <stdint.h>
#include <string.h>

void EaglesongHash( unsigned char * output, const unsigned char * input, int input_length );

void run_one_test( const unsigned char * input, const unsigned char * expected_output_hex_str ) {
    unsigned char output[32];
    unsigned char output_hex_str[300];
    output_hex_str[0] = 0;

    EaglesongHash(output, input, strlen(input));

    // make the output_hex_str
    for( uint8_t i = 0 ; i < 32 ; ++i ) {
        sprintf(&output_hex_str[strlen(output_hex_str)], "%02x", output[i]);
    }

    printf("Input: %s\n", input);
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
        printf("^\nERROR!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n");
    }
    else {
        printf("Check passed.\n");
    }

    printf("\n");
}

void main( int argc, char ** argv ) {
    run_one_test("Hello, world!\n", "64867e2441d162615dc2430b6bcb4d3f4b95e4d0db529fca1eece73c077d72d6");

    printf("Done all tests.\n");
   
}
