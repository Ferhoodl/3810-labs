# Compute several Fibonacci numbers and put in array, then print
.data
fibs:.word   0 : 19         # "array" of words to contain fib values
size: .word  19             # size of "array" (agrees with array declaration)
.text
      # RARS places this data section at 0x10010000.  Avoid la here:
      # it expands to an unscheduled auipc/addi dependency.
      lui  s0, 0x10010     # address of fibs
      li   s2, 1           # 1 is the known value of first and second Fib. number
      nop
      nop
      lw   s5, 76(s0)     # size follows the 19-word array
      sw   s2, 0(s0)      # F[0] = 1
      sw   s2, 4(s0)      # F[1] = F[0] = 1
      nop
      addi s1, s5, -2     # Counter for loop, will execute (size-2) times
      
      # Loop to compute each Fibonacci number using the previous two Fib. numbers.
loop: lw   s3, 0(s0)      # Get value from array F[n-2]
      lw   s4, 4(s0)      # Get value from array F[n-1]
      nop
      nop
      nop
      add  s2, s3, s4    # F[n] = F[n-1] + F[n-2]
      nop
      nop
      nop
      sw   s2, 8(s0)      # Store newly computed F[n] in array
      addi s0, s0, 4      # increment address to now-known Fib. number storage
      addi s1, s1, -1     # decrement loop counter
      nop
      nop
      nop
      bne s1, zero, loop  # repeat while not finished
      nop
      nop
      
      # Fibonacci numbers are computed and stored in array. Print them.
      lui  a0, 0x10010     # first argument for print (array)
      add  a1, zero, s5  # second argument for print (size)
      jal  print            # call print routine. 
      nop
      nop

      # The program is finished. Exit.
      j die 
      nop
      nop
		
###############################################################
# Subroutine to print the numbers on one line.
      .data
space:.asciz  " "          # space to insert between numbers
head: .asciz  "The Fibonacci numbers are:\n"
      .text
print:add  t0, zero, a0  # starting address of array of data to be printed
      add  t1, zero, a1  # initialize loop counter to array size
      lui  a0, 0x10010
      nop
      nop
      nop
      addi a0, a0, 82      # head follows size and the two-byte space string
      ori  a7, zero , 4           # specify Print String service
      ecall               # print the heading string
      
out:  lw   a0, 0(t0)      # load the integer to be printed (the current Fib. number)
      ori  a7, zero , 1           # specify Print Integer service
      ecall               # print fibonacci number
      
      lui  a0, 0x10010
      nop
      nop
      nop
      addi a0, a0, 80      # space follows the size word
      ori  a7, zero , 4           # specify Print String service
      ecall               # print the spacer string
      
      addi t0, t0, 4      # increment address of data to be printed
      addi t1, t1, -1     # decrement loop counter
      nop
      nop
      nop
      bne t1, zero , out         # repeat while not finished
      nop
      nop
      
      jr   ra              # return from subroutine
      nop
      nop
      
# End of subroutine to print the numbers on one line
###############################################################

die:
wfi
