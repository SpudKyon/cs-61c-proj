.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Writes a matrix of integers into a binary file
# FILE FORMAT:
#   The first 8 bytes of the file will be two 4 byte ints representing the
#   numbers of rows and columns respectively. Every 4 bytes thereafter is an
#   element of the matrix in row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is the pointer to the start of the matrix in memory
#   a2 (int)   is the number of rows in the matrix
#   a3 (int)   is the number of columns in the matrix
# Returns:
#   None
# Exceptions:
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fwrite error or eof,
#     this function terminates the program with error code 30
# ==============================================================================
write_matrix:
    addi sp,sp,-24
    sw ra,0(sp)
    sw a1,4(sp)     #pointer of matrix start
    sw a2,8(sp)     #number of rows
    sw a3,12(sp)    #number of columns
    
    addi a1,x0,1    #Permission bit for write
    jal fopen
    addi t0,x0,-1
    beq a0,t0,Exceptions_fopen  #fopen fail?
    sw a0,16(sp)    #File Description
    addi a1,sp,8
    addi a2,x0,2    #number of element
    addi a3,x0,4
    jal fwrite
    addi t0,x0,2
    bne a0,t0,Exceptions_fwrite     #fwrite fail?
    lw a0,16(sp)    #File Descriptor
    lw a1,4(sp)
    lw a2,8(sp)
    lw a3,12(sp)    
    mul a2,a2,a3    #number of elements
    sw a2,20(sp)    #number of element
    addi a3,x0,4    #4 Byte each elment
    jal fwrite
    lw t0,20(sp)
    bne a0,t0,Exceptions_fwrite #fwrite fail?
    lw a0,16(sp)
    jal fclose
    bne a0,x0,Exceptions_fclose
    lw ra,0(sp)
    addi sp,sp,24
    jr ra
    
Exceptions_fopen:
    lw ra,0(sp)
    addi sp,sp,24
    addi a0,x0,27
    j exit
Exceptions_fwrite:
    lw ra,0(sp)
    addi sp,sp,24
    addi a0,x0,30
    j exit    
Exceptions_fclose:
    lw ra,0(sp)
    addi sp,sp,24
    addi a0,x0,28
    j exit    