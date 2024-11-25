+++
title = 'Building a CPU emulator - Chip-8'
date = 2024-07-14T08:02:14-03:00
tags = ["cpu", "memory", "operation systems"]
categories = ["operation system"]
draft = true
showtoc = true
+++

Building a CPU emulator for Chip-8 (the simplified 1977 CPU archtecture).

<!--more-->

The [CHIP-8](https://en.wikipedia.org/wiki/CHIP-8) architecture from the 1977 
that is simple but non-trivial. So, it is a good choice for building a CPU 
emulator because of its simplicity and manageable instruction set.

## The CHIP-8 architecture

### Memory

CHIP-8 systems used 4 KB of memory, consisting of 4,096 (0x1000) one-byte memory locations. 
The first 512 bytes (from address 0x000 to 0x1FF) were reserved for the CHIP-8
interpreter itself, so programs typically started at address 0x200.


### Registers
- General-Purpose Registers: 
CHIP-8 includes 16 general-purpose 8-bit data registers named V0 through VF.
- Address Register: 
A 16-bit register named I is used for storing memory addresses during operations.

### Stack
The stack is used to store return addresses when subroutines are called.

### Input
Input is handled via a 16-key hexadecimal keypad with keys labeled from 0 to F. 
The keys 2, 4, 6, and 8 are commonly used for directional input, 
corresponding to up, left, right, and down, respectively.

## The Implementation
