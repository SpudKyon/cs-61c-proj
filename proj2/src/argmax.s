.globl argmax

.text
# =================================================================
# FUNCTION: Given a int array, return the index of the largest
#   element. If there are multiple, return the one
#   with the smallest index.
# Arguments:
#   a0 (int*) is the pointer to the start of the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   a0 (int)  is the first index of the largest element
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# =================================================================
argmax:
    # Prologue
    ebreak
    addi t0, x0, 1
    blt a1, t0, error # if len < 1 jump to error
    add t0, x0, x0 # max_idx
    add t1, x0, x0 # i

loop_start:
    beq t1, a1, loop_end
    slli t2, t0, 2
    add t2, a0, t2
    lw t2, 0(t2) # arr[max_idx]
    slli t3, t1, 2
    add t3, a0, t3 # arr[i]
    blt t3, t2, loop_continue
    add t0, t1, x0

loop_continue:
    addi t1, t1, 1
    j loop_start

loop_end:
    # Epilogue
    add a0, x0, t0
    jr ra
error:
    li a0, 36
    j exit