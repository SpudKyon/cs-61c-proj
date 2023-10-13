.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
#   d = matmul(m0, m1)
# Arguments:
#   a0 (int*)  is the pointer to the start of m0
#   a1 (int)   is the # of rows (height) of m0
#   a2 (int)   is the # of columns (width) of m0
#   a3 (int*)  is the pointer to the start of m1
#   a4 (int)   is the # of rows (height) of m1
#   a5 (int)   is the # of columns (width) of m1
#   a6 (int*)  is the pointer to the the start of d
# Returns:
#   None (void), sets d = matmul(m0, m1)
# Exceptions:
#   Make sure to check in top to bottom order!
#   - If the dimensions of m0 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m1 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m0 and m1 don't match,
#     this function terminates the program with exit code 38
# =======================================================
matmul:
    bge x0,a1,Exception
    bge x0,a2,Exception
    bge x0,a4,Exception
    bge x0,a5,Exception
    bne a2,a4,Exception
    addi sp,sp,-40
    sw ra,0(sp)
    sw a0,4(sp)     #array1
    sw a1,8(sp)     #n
    sw a2,12(sp)    #m
    sw a3,16(sp)    #array2
    sw a5,20(sp)    #k
    sw a6,24(sp)    #arrayD
    sw s0,28(sp)
    sw s1,32(sp)
    sw s2,36(sp)
    mv s0,x0    #index for row(0,n)  
    mv s1,x0    #index for arrayD
outer_loop_start:
    lw t0,8(sp) #load n in t0
    bge s0,t0,outer_loop_end
    mv s2,x0    #inner_loop index = 0       
inner_loop_start:
    lw t2,20(sp)    #load k in t2
    bge s2,t2,inner_loop_end
    #Calculate a0 for every Loop
    lw a0,4(sp)
    lw t1,12(sp)    #load m in t1
    slli t0,s0,2
    mul t1,t0,t1
    add a0,a0,t1    #argument a0
    #Calcualte a1 for every Loop
    lw a1,16(sp)
    slli t2,s2,2
    add a1,a1,t2    #argument a1
    lw a2,12(sp)    #load m in a2
    addi a3,x0,1    #argument a3
    lw a4,20(sp)    #argument a4
    jal dot
    #Calculate arrayD
    slli t0,s1,2
    lw a5,24(sp)
    add a5,a5,t0
    sw a0,0(a5)
    addi s1,s1,1    #s1+=1
    addi s2,s2,1
    j inner_loop_start
inner_loop_end:
    addi s0,s0,1
    j outer_loop_start
outer_loop_end:
    lw s2,36(sp)
    lw s1,32(sp)
    lw s0,28(sp)
    lw a6,24(sp)
    lw a5,20(sp)
    lw a4,12(sp)
    lw a3,16(sp)
    lw a2,12(sp)
    lw a1,8(sp)
    lw a0,4(sp)
    lw ra,0(sp)
    addi sp,sp,40
    jr ra
Exception:
    addi,a0,x0,38
    j exit