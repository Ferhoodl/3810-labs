.data # running the file within RARS ( relates to the mem load command )
.word
.text

# store value of 80 into address 20


lui x9, 0x10010 # initialize the offset properly so we can specify the right memory
addi x10, zero, 80
sw x10, 20(x9)

# Load value in mem offset 20 into register 12 and add 20 to that value
lw x12, 20(x9)
addi x12, x12, 20

wfi
