#!/usr/bin/env python3

while 1:
	a = input(">>").strip().upper()
	if '=' in a:
		a = a.split('=')[1].strip()
	print(a)


