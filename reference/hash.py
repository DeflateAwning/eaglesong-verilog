from eaglesong import EaglesongHash
import sys
from binascii import hexlify

lines = sys.stdin.readlines()
input_bytes_str = "\n".join(lines)

input_bytes = bytearray(input_bytes_str, "utf8")
print(f"Input: {bytes(input_bytes)}")

output_bytes = EaglesongHash(input_bytes)
print(f"Hash:  {hexlify(bytearray(output_bytes))}")
