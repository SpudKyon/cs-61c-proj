.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
#   a0 (int*) is the pointer to the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   None
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# ==============================================================================
relu:
    # Prologue
    add t0, x0, a1 # len
    addi t2, x0, 1
    blt t0, t2, error
    addi t1, x0, 0 # i
loop_start:
    beq t1, t0, loop_end # if i == n break
    slli t2, t1, 2
    add t3, t2, a0
    lw t4, 0(t3)
    bgt t4, x0, loop_continue # if arr[i] > 0
    sub t4, x0, x0
    sw t4, 0(t3)

loop_continue:
    addi t1, t1, 1
    j loop_start
loop_end:
    # Epilogue
    jr ra
error:
    li a0, 36
    j exit