.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
# Exceptions:
#   - If malloc returns an error,
#     this function terminates the program with error code 26
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fread error or eof,
#     this function terminates the program with error code 29
# ==============================================================================
read_matrix:
    addi sp,sp,-28
    sw a0,0(sp)     #store filename pointer
    sw a1,4(sp)     #store row pointer 
    sw a2,8(sp)     #store column pointer
    sw ra,24(sp)
    mv a1,x0        #Permission bits 0
    jal fopen
    addi t0,x0,-1
    beq a0,t0,Exceptions_fopen  #fopen Fail?
    sw a0,12(sp)    #store file descriptor
    lw a1,4(sp)     #load row pointer
    addi a2,x0,4
    jal fread
    addi t0,x0,4
    bne a0,t0,Exceptions_fread  #fread Fail?
    lw a0,12(sp)    #load file descriptor
    lw a1,8(sp)     #load column pointer
    addi a2,x0,4
    jal fread
    addi t0,x0,4
    bne a0,t0,Exceptions_fread  #fread Fail?
    lw t0,4(sp)     #load pointer
    lw t1,8(sp)     #load pointer
    lw a0,0(t0)
    lw t0,0(t1)
    slli a0,a0,2
    mul a0,a0,t0    #size of memory  in Byte
    sw a0,20(sp)
    jal malloc
    beq a0,x0,Exceptions_malloc    #malloc failed?
    sw a0,16(sp)
    
    lw a2,20(sp)
    lw a1,16(sp)    #malloc memory pointer
    lw a0,12(sp)
    jal fread
    lw t0,20(sp)
    bne a0,t0,Exceptions_fread  #fread Fail?
    lw a0,12(sp)
    jal fclose
    bne a0,x0,Exceptions_fclose
    lw a0,16(sp)
    lw ra,24(sp)
    addi sp,sp,28
    jr ra
Exceptions_fopen:
    addi a0,x0,27
    lw ra,24(sp)
    addi sp,sp,28
    j exit
Exceptions_fread:
    addi a0,x0,29
    lw ra,24(sp)
    addi sp,sp,28
    j exit
Exceptions_malloc:
    addi a0,x0,26
    lw ra,24(sp)
    addi sp,sp,28
    j exit
Exceptions_fclose:
    addi a0,x0,28
    lw ra,24(sp)
    addi sp,sp,28
    j exit