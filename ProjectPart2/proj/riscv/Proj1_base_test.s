# Troy Tomson
# Logical Tests
# All values are in hex!

# x1 = 1
addi x1, x0, 0x00000001
# x2 = 2
addi x2, x0, 0x00000002
# x3 = 3
addi x3, x0, 0x00000003
# x4 = 4
addi x4, x0, 0x00000004
# x5 = 5
addi x5, x0, 0x00000005

# x6 = 0x00000009
add x6, x4, x5

# x7 = 0x00000002
sub x7, x5, x3

# x8 = 0x00000001
addi x8, x0, 1

# x8 = 0x00010000
slli x8, x8, 16

# x8 = 0x00000010
srli x8, x8, 12

# x9 = 0x00000002
and x9, x3, x2

# x10 = 0x00000002
andi x10, x3, 2

# x9 = 0x00000003
or x9, x2, x1

# x10 = 0x00000003
ori x10, x2, 1

# x9 = 0x00000007
xor x9, x2, x5

# x10 = 0x00000007
xori x10, x2, 5

# x11 = 0x00000001
slt x11, x3, x5

# x11 = 0x00000001
slti x11, x3, 5

# x11 = 0x00000001
sltiu x11, x2, 3

# x11 = 0x00000010
sll x11, x1, x4

# x11 = 0x00000001
srl x11, x8, x4

# x12 = 0xFFFFFFF0
addi x12, x0, -16

# x12 = 0xFFFFFFFC
sra x12, x12, x2

# x12 = 0xFFFFFFFC
srai x12, x12, 2

# x13 = 0x10010000
lui x13, 0x10010

# memory addr 0x10010000 = 0x00000001
sw x1, 0(x13)

# x14 = 0x00000001
lw x14, 0(x13)

# memory addr 0x10010004 = 0x0001
sh x1, 4(x13)

# x15 = 0x00000001
lhu x15, 4(x13)

# memory addr 0x10010006 = 0x01
sb x1, 6(x13)

# x16 = 0x01
lb x16, 6(x13)

# x17 = 0x00001234
lui x17, 0x1
addi x17, x17, 0x234

# memory addr 0x10010008 = 0x00001234
sw x17, 8(x13)

# x18 = 0x00000034
lbu x18, 8(x13)

# x19 = 0x00000012
lbu x19, 9(x13)

# x20 = 0x00001234
lhu x20, 8(x13)

# x21 = current addr of pc
auipc x21, 0

# x22 = load upper PC addr 0x00001000
auipc x22, 0x1

# x23 = 0x00001004
sub x23, x22, x21

# wfi test
wfi
