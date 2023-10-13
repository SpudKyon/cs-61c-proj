.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int arrays
# Arguments:
#   a0 (int*) is the pointer to the start of arr0
#   a1 (int*) is the pointer to the start of arr1
#   a2 (int)  is the number of elements to use
#   a3 (int)  is the stride of arr0
#   a4 (int)  is the stride of arr1
# Returns:
#   a0 (int)  is the dot product of arr0 and arr1
# Exceptions:
#   - If the number of elements to use is less than 1,
#     this function terminates the program with error code 36
#   - If the stride of either array is less than 1,
#     this function terminates the program with error code 37
# =======================================================
dot:
    addi t0, x0, 1
    bgt t0, a2, error1
    bgt t0, a3, error2
    bgt t0, a4, error2
    add t0, x0, x0 # sum
    add t1, x0, x0 # i1
    add t2, x0, x0 # i2
    add t5, x0, x0 # ith
loop_start:
    beq t5, a2, loop_end
    slli t3, t1, 2
    slli t4, t2, 2
    add t3, a0, t3
    add t4, a1, t4
    lw t3, 0(t3)
    lw t4, 0(t4)
    mul t3, t3, t4
    add t0, t0, t3
loop_continue:
    add t1, t1, a3
    add t2, t2, a4
    addi t5, t5, 1
    j loop_start

    # Epilogue
loop_end:
    mv a0, t0
    jr ra
error1:
    li a0, 36
    j exit
error2:
    li a0, 37
    j exit