# Test that an older memory store completes before exception termination.
# The later register write and store must not execute.

.data
target: .word 0           # Word that the older store is allowed to update
untouched: .word 0        # Word that the younger store must leave unchanged

.text
.globl main

main:
    lui x10, %hi(target)      # Begin loading the target word's address
    addi x11, x0, 123        # Set the value the older store should write
    nop
    nop
    nop
    addi x10, x10, %lo(target) # Complete the target word's address
    nop
    nop
    nop

    sw x11, 0(x10)           # Store 123 before the exception; this must finish
    ebreak                   # Trigger a breakpoint exception with cause 3

    addi x12, x0, 99         # Must not write x12 after the exception
    nop
    nop
    nop
    sw x12, 4(x10)           # Must not modify the second word after EBREAK
    wfi                      # Normal halt must not execute after the exception
