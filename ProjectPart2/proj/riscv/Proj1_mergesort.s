# Sorting Algorithm Template in RISC-V Assembly - Troy Tomson
# MergeSort implementation for RV32I
#
# Sorts the array in ascending order in the SAME memory location.
# Supports up to 512 elements.
#
# sort(a0 = array address, a1 = array size)

# Based on this C code merge sort: https://www.geeksforgeeks.org/c/c-program-for-merge-sort/

.data
    array_size: .word 12
    array: .word 65, 12, 10, 89, 11, 70, 67, 5, 9, 45, 90, 7

    # Temporary buffer: 512 words * 4 bytes = 2048 bytes
    .align 2
    temp: .space 2048

.text
.globl main

main:
    # Save return address
    addi sp, sp, -16
    nop
    nop
    nop
    sw ra, 12(sp)

    # Call sorting function
    lasw3 a0, array
    lasw3 a1, array_size
    nop
    nop
    nop
    lw a1, 0(a1)
    nop
    nop
    nop
    jal ra, sort
    nop
    nop

    # Restore stack
    lw ra, 12(sp)
    addi sp, sp, 16

    # Exit program
    j end
    nop
    nop

.globl sort

# void sort(int* array, int size) {
#     mergeSort(array, 0, size - 1);
# }

sort:
    addi sp, sp, -16
    nop
    nop
    nop
    sw ra, 12(sp)
    sw s0, 8(sp)
    nop
    nop

    mv s0, a0

    addi a2, a1, -1
    li a1, 0
    nop

    # mergeSort(array, left, right)
    mv a0, s0
    jal ra, mergeSort
    nop
    nop

    lw s0, 8(sp)
    lw ra, 12(sp)
    addi sp, sp, 16
    nop
    nop
    jalr zero, 0(ra)
    nop
    nop

mergeSort:
    addi sp, sp, -32
    nop
    nop
    nop
    sw ra, 28(sp)
    sw s0, 24(sp)
    sw s1, 20(sp)
    sw s2, 16(sp)
    sw s3, 12(sp)

    mv s0, a0
    mv s1, a1
    mv s3, a2
    nop
    nop
    nop

    # Base case: if left >= right, return
    bge s1, s3, ms_return
    nop
    nop

    # mid = left + (right - left) / 2
    sub t0, s3, s1
    nop
    nop
    nop
    srli t0, t0, 1
    nop
    nop
    nop
    add s2, s1, t0

    # mergeSort(array, left, mid)
    mv a0, s0
    mv a1, s1
    nop
    mv a2, s2
    jal ra, mergeSort
    nop
    nop

    # mergeSort(array, mid + 1, right)
    mv a0, s0
    addi a1, s2, 1
    mv a2, s3
    jal ra, mergeSort
    nop
    nop

    # merge(array, left, mid, right)
    mv a0, s0
    mv a1, s1
    mv a2, s2
    mv a3, s3
    jal ra, merge
    nop
    nop
    
# Return subarray upwards
ms_return:
    lw ra, 28(sp)
    lw s0, 24(sp)
    lw s1, 20(sp)
    lw s2, 16(sp)
    lw s3, 12(sp)
    addi sp, sp, 32
    jalr zero, 0(ra)
    nop
    nop

# Comine sorted halves
merge:
    addi sp, sp, -32
    nop
    nop
    nop
    sw ra, 28(sp)
    sw s0, 24(sp)
    sw s1, 20(sp)
    sw s2, 16(sp)
    sw s3, 12(sp)
    sw s4, 8(sp)
    sw s5, 4(sp)
    sw s6, 0(sp)

    mv s0, a0
    mv s1, a1
    mv s2, a2
    mv s3, a3
    nop
    mv s4, s1
    nop
    nop
    nop
    
# Copy array into temp variable
copy_loop:
    blt s3, s4, copy_done
    nop
    nop

    slli t0, s4, 2
    nop
    nop
    nop
    add t1, s0, t0
    nop
    nop
    nop
    lw t2, 0(t1)

    lasw3 t3, temp
    nop
    nop
    nop
    add t3, t3, t0
    nop
    nop
    nop
    sw t2, 0(t3)

    addi s4, s4, 1
    jal zero, copy_loop
    nop
    nop

copy_done:
    mv s4, s1
    addi s5, s2, 1
    nop
    mv s6, s1
    nop

# Choose which value to copy. Then, call the function to copy it.
# Next, divide the median by 2
merge_loop:
    blt s2, s4, copy_right
    nop
    nop
    blt s3, s5, copy_left
    nop
    nop

    slli t1, s4, 2
    lasw3 t2, temp
    nop
    nop
    nop
    add t2, t2, t1
    nop
    nop
    nop
    lw t0, 0(t2)

    slli t1, s5, 2
    lasw3 t2, temp
    nop
    nop
    nop
    add t2, t2, t1
    nop
    nop
    nop
    lw t3, 0(t2)
    nop
    nop
    nop
    
    # Compare left and right values
    ble t0, t3, choose_left
    nop
    nop
    jal zero, choose_right
    nop
    nop

# Select the left value as being larger
choose_left:
    slli t1, s6, 2
    nop
    nop
    nop
    add t2, s0, t1
    nop
    nop
    nop
    sw t0, 0(t2)

    addi s4, s4, 1
    addi s6, s6, 1
    jal zero, merge_loop
    nop
    nop

# Select the right value as being larger
choose_right:
    slli t1, s6, 2
    nop
    nop
    nop
    add t2, s0, t1
    nop
    nop
    nop
    sw t3, 0(t2)

    addi s5, s5, 1
    addi s6, s6, 1
    jal zero, merge_loop
    nop
    nop
    
# Sort the left value, then the right one
copy_left:
    blt s2, s4, merge_done
    nop
    nop

    slli t1, s4, 2
    lasw3 t2, temp
    nop
    nop
    nop
    add t2, t2, t1
    nop
    nop
    nop
    lw t0, 0(t2)

    slli t1, s6, 2
    nop
    nop
    nop
    add t2, s0, t1
    nop
    nop
    nop
    sw t0, 0(t2)

    addi s4, s4, 1
    addi s6, s6, 1
    jal zero, copy_left
    nop
    nop
    
# Sort the right value, then the left one
copy_right:
    blt s3, s5, merge_done
    nop
    nop

    slli t1, s5, 2
    lasw3 t2, temp
    nop
    nop
    nop
    add t2, t2, t1
    nop
    nop
    nop
    lw t0, 0(t2)

    slli t1, s6, 2
    nop
    nop
    nop
    add t2, s0, t1
    nop
    nop
    nop
    sw t0, 0(t2)

    addi s5, s5, 1
    addi s6, s6, 1
    jal zero, copy_right
    nop
    nop

# Load sorted array into registers 
merge_done:
    lw ra, 28(sp)
    lw s0, 24(sp)
    lw s1, 20(sp)
    lw s2, 16(sp)
    lw s3, 12(sp)
    lw s4, 8(sp)
    lw s5, 4(sp)
    lw s6, 0(sp)
    addi sp, sp, 32
    jalr zero, 0(ra)
    nop
    nop

end:
    wfi
