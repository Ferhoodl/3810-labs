# QuickSort implementation for RV32I
#
# Sorts the array in ascending order in the SAME memory location.
#
# sort(a0 = array address, a1 = array size)

.data
    array_size: .word 12
    array: .word 65, 12, 10, 89, 11, 70, 67, 5, 9, 45, 90, 7

.text
.globl main

main:
    # Save return address
    addi sp, sp, -16          # Make room to save the return address
    lui a0, %hi(array)        # Load the upper bits of the array address
    lui t0, %hi(array_size)   # Load the upper bits of the array size address
    nop
    sw ra, 12(sp)             # Save the return address for main
    addi a0, a0, %lo(array)   # Complete the array pointer passed to sort
    addi t0, t0, %lo(array_size) # Complete the address of the array size
    nop
    nop
    nop
    lw a1, 0(t0)              # Read the number of elements to sort
    nop
    nop
    nop
    # Call sorting function
    jal ra, sort              # Call sort with the array pointer and size
    nop
    nop
    # Restore stack
    lw ra, 12(sp)             # Restore main's saved return address
    addi sp, sp, 16           # Release main's stack space
    # Exit program
    j end                     # Jump to the program's halt instruction
    nop
    nop

.globl sort
# void sort(int* array, int size) {
#     quickSort(array, 0, size - 1);
# }
sort:
    addi sp, sp, -16          # Create a stack frame for sort
    nop
    nop
    nop
    sw ra, 12(sp)             # Save the return address before calling quickSort
    # quickSort(array, 0, size - 1)
    addi a2, a1, -1           # Set high to the last array index
    addi a1, x0, 0            # Set low to the first array index
    jal ra, quickSort         # Sort the full array recursively
    nop
    nop
    lw ra, 12(sp)             # Restore the caller's return address
    addi sp, sp, 16           # Release sort's stack frame
    nop
    nop
    nop
    jalr zero, 0(ra)          # Return to main after sorting
    nop
    nop

# Sort the array between low and high
quickSort:
    # Save registers
    addi sp, sp, -32          # Reserve space for this recursive call
    nop
    nop
    nop
    sw ra, 28(sp)             # Save the return address across recursive calls
    sw s0, 24(sp)             # Save the caller's array pointer
    sw s1, 20(sp)             # Save the caller's low index
    sw s2, 16(sp)             # Save the caller's high index
    sw s3, 12(sp)             # Save the caller's pivot value
    sw s4, 8(sp)              # Save the caller's partition boundary
    sw s5, 4(sp)              # Save the caller's scan index
    sw s6, 0(sp)              # Preserve s6 for the caller

    mv s0, a0                 # Keep the array pointer across recursive calls
    mv s1, a1                 # Keep the low index across recursive calls
    mv s2, a2                 # Keep the high index across recursive calls
    nop
    nop
    nop
    # Return if low >= high
    bge s1, s2, qs_return     # Stop when this section has at most one element
    nop
    nop

    # Set pivot and indices
    slli t0, s2, 2            # Convert high index to a byte offset
    nop
    nop
    nop
    add t1, s0, t0            # Find the address of the final element
    nop
    nop
    nop
    lw s3, 0(t1)              # Use the final element as the pivot
    addi s4, s1, -1           # Start the smaller-value boundary before low
    mv s5, s1                 # Start scanning at the low index
    nop
    nop
    nop

# Partition the array
qs_partition_loop:
    bge s5, s2, qs_partition_done # Stop scanning before the pivot element
    nop
    nop

    slli t0, s5, 2            # Convert the scan index to a byte offset
    nop
    nop
    nop
    add t1, s0, t0            # Find the current element's address
    nop
    nop
    nop
    lw t2, 0(t1)              # Read the current value to compare with pivot
    nop
    nop
    nop
    # Skip values greater than pivot
    blt s3, t2, qs_next_j     # Leave values greater than pivot on the right
    nop
    nop

    # Swap elements
    addi s4, s4, 1            # Grow the region containing values <= pivot
    nop
    nop
    nop
    slli t3, s4, 2            # Convert the boundary index to bytes
    nop
    nop
    nop
    add t4, s0, t3            # Find the boundary element's address
    nop
    nop
    nop
    lw t5, 0(t4)              # Save the value currently at the boundary
    nop
    nop
    nop
    sw t2, 0(t4)              # Move the qualifying value into the left region
    sw t5, 0(t1)              # Move the old boundary value to the scan position

qs_next_j:
    addi s5, s5, 1            # Advance to the next element to partition
    nop
    nop
    nop
    jal zero, qs_partition_loop # Repeat until all non-pivot values are checked
    nop
    nop

# Move pivot to its sorted position
qs_partition_done:
    addi s4, s4, 1            # Set the pivot's final index after smaller values
    nop
    nop
    nop
    slli t0, s4, 2            # Convert the pivot's final index to bytes
    slli t3, s2, 2            # Convert the original pivot index to bytes
    nop
    nop
    nop
    add t1, s0, t0            # Find the pivot's destination address
    add t4, s0, t3            # Find the pivot's original address
    nop
    nop
    nop
    lw t2, 0(t1)              # Save the value at the pivot destination
    nop
    nop
    nop
    sw s3, 0(t1)              # Put the pivot into its sorted position
    sw t2, 0(t4)              # Move the displaced value to the old pivot slot

    # Sort the left half
    mv a0, s0                 # Pass the same array pointer to quickSort
    mv a1, s1                 # Set left section's low index
    addi a2, s4, -1           # Set left section's high index before pivot
    jal ra, quickSort         # Recursively sort values left of the pivot
    nop
    nop

    # Sort the right half
    mv a0, s0                 # Pass the same array pointer to quickSort
    addi a1, s4, 1            # Set right section's low index after pivot
    mv a2, s2                 # Keep right section's original high index
    jal ra, quickSort         # Recursively sort values right of the pivot
    nop
    nop

# Return to caller
qs_return:
    lw ra, 28(sp)             # Restore the return address for this call
    lw s0, 24(sp)             # Restore caller's array pointer
    lw s1, 20(sp)             # Restore caller's low index
    lw s2, 16(sp)             # Restore caller's high index
    lw s3, 12(sp)             # Restore caller's pivot value
    lw s4, 8(sp)              # Restore caller's partition boundary
    lw s5, 4(sp)              # Restore caller's scan index
    lw s6, 0(sp)              # Restore caller's saved register
    addi sp, sp, 32           # Release the current recursive stack frame
    nop
    nop
    nop
    jalr zero, 0(ra)          # Return to the previous quickSort call
    nop
    nop

end:
    wfi                       # Halt after the array has been sorted
