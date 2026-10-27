# Troy Tomson
# Branch Tests
# All values are in hex!

# x1 = 1
addi x20, x0, 0x00000001
# x2 = 2
addi x21, x0, 0x00000002
# x3 = 3
addi x22, x0, 0x00000003
# x4 = 4
addi x23, x0, 0x00000004

func0:
  #NOBRANCH, x5 = 0x00000001
  bge x21, x22, func1
  addi x5, x0, 1
  
func1:
  #NOBRANCH, x6 = 0x00000001
  beq x21, x22, func2
  addi x6, x0, 1

func2:
  #BRANCH, x7 = 0x00000000
  bne x21, x22, func3
  addi x7, x0, 1

func3:
  #BRANCH, x8 = 0x00000000
  blt x21, x22, func4
  addi x8, x0, 1

func4:
  #BRANCH, x9 = 0x00000000
  bltu x21, x22, func5
  addi x9, x0, 1

func5:
  #NOBRANCH, x10 = 0x00000001
  bgeu x21, x22, func6
  addi x10, x0, 1

func6:
  # Init sp save
  addi x13, sp, 0
  # Recurse 5 times
  addi x10, x0, 5
  # Call func 7 and save
  la x16, func7
  jalr x1, 0(x16)
  # x12 = 0x00000005
  addi x12, x10, 0
  # x14 = 0x00000000
  sub x14, sp, x13
  # Skip the recursive function body
  jal x0, jump_done

func7:
  # Base case: return when recurse is equal to 0
  beq x10, x0, func7_base
  # Allocate sp frame
  addi sp, sp, -16
  # Save the ra
  sw x1, 12(sp)
  # Decrement the recurse value
  addi x10, x10, -1
  # Recursive call
  jal x1, func7
  addi x10, x10, 1
  # Restore the ra
  lw x1, 12(sp)
  # dealloc sp
  addi sp, sp, 16
  jalr x0, 0(x1)


func7_base:
  # Return when depth = 0
  jalr x0, 0(x1)


jump_done:
  # wfi test
  wfi

