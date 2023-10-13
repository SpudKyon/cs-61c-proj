.globl classify

.text
# =====================================
# COMMAND LINE ARGUMENTS
# =====================================
# Args:
#   a0 (int)        argc
#   a1 (char**)     argv
#   a1[1] (char*)   pointer to the filepath string of m0
#   a1[2] (char*)   pointer to the filepath string of m1
#   a1[3] (char*)   pointer to the filepath string of input matrix
#   a1[4] (char*)   pointer to the filepath string of output file
#   a2 (int)        silent mode, if this is 1, you should not print
#                   anything. Otherwise, you should print the
#                   classification and a newline.
# Returns:
#   a0 (int)        Classification
# Exceptions:
#   - If there are an incorrect number of command line args,
#     this function terminates the program with exit code 31
#   - If malloc fails, this function terminates the program with exit code 26
#
# Usage:
#   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>
classify:
    addi t0,x0,5
    bne a0,t0,Exceptions_argc
    addi sp,sp,-64
    sw ra,0(sp)
    sw a0,4(sp)
    sw a1,8(sp)
    sw a2,12(sp)
    # Read pretrained m0
    addi a0,x0,4
    jal malloc      #malloc for row pointer m0
    beq a0,x0,Exceptions_malloc
    mv a1,a0
    sw a1,16(sp)    #store row pointer m0
    addi a0,x0,4
    jal malloc      #malloc for column pointer m0
    beq a0,x0,Exceptions_malloc
    mv a2,a0
    sw a2,20(sp)    #store column pointer m0
    lw t1,8(sp)
    lw a0,4(t1)     #*(a1+4) file pointer for m0
    lw a1,16(sp)    #store row pointer m0 
    jal read_matrix
    sw a0,24(sp)    #matrix m0 pointer in memory
    
    # Read pretrained m1
    addi a0,x0,4
    jal malloc      #malloc for row pointer m1
    beq a0,x0,Exceptions_malloc
    mv a1,a0
    sw a1,28(sp)    #store row pointer m1
    addi a0,x0,4
    jal malloc      #malloc for column pointer m1
    beq a0,x0,Exceptions_malloc
    mv a2,a0
    sw a2,32(sp)    #store column pointer m1
    lw t1,8(sp)
    lw a0,8(t1)     #*(a1+8) file pointer for m1
    lw a1,28(sp)    #load row pointer m1
    jal read_matrix
    sw a0,36(sp)    #matrix m1 pointer in memory    

    # Read input matrix
    addi a0,x0,4
    jal malloc      #malloc for row pointer input
    beq a0,x0,Exceptions_malloc
    mv a1,a0
    sw a1,40(sp)    #store row pointer input
    addi a0,x0,4
    jal malloc      #malloc for column pointer input
    beq a0,x0,Exceptions_malloc
    mv a2,a0
    sw a2,44(sp)    #store column pointer input
    lw t1,8(sp)
    lw a0,12(t1)     #*(a1+12) file pointer for input
    lw a1,40(sp)    #store row pointer input
    jal read_matrix
    sw a0,48(sp)    #matrix input pointer in memory        

    # Compute h = matmul(m0, input)
    lw a1,16(sp)    
    lw a1,0(a1)     #load row number m0
    lw a2,20(sp)
    lw a2,0(a2)     #load column number m0
    
    
    lw a4,40(sp)
    lw a4,0(a4)     #load row number input
    lw a5,44(sp)
    lw a5,0(a5)     #load column number input
    
    slli t1,a1,2    #calculate a0 for malloc
    mul a0,t1,a5
    jal malloc
    beq a0,x0,Exceptions_malloc #malloc for result array
    mv a6,a0
    sw a6,52(sp)    #store mal1_result pointer___h
    
    lw a0,24(sp)    #load matrix m0
    lw a1,16(sp)    
    lw a1,0(a1)     #load row number m0
    lw a2,20(sp)
    lw a2,0(a2)     #load column number m0
    lw a3,48(sp)    #load matrix input
    lw a4,40(sp)
    lw a4,0(a4)     #load row number input
    lw a5,44(sp)
    lw a5,0(a5)     #load column number input   
    jal matmul
    # Compute h = relu(h)
    lw a0,52(sp)
    lw a1,16(sp)    
    lw a1,0(a1)     #load row number m0
    lw a5,44(sp)
    lw a5,0(a5)     #load column number input
    
    mul a1,a1,a5    #number of element in h
    jal relu
    # Compute o = matmul(m1, h)
    lw a1,28(sp)    
    lw a1,0(a1)     #load row number m1
    lw a2,32(sp)
    lw a2,0(a2)     #load column number m1
    lw a4,16(sp)    
    lw a4,0(a4)     #load row number h
    lw a5,44(sp)
    lw a5,0(a5)     #load column number h
    
    slli t1,a1,2    #calculate a0 for malloc
    mul a0,a5,t1
    jal malloc
    beq a0,x0,Exceptions_malloc #malloc for result array
    mv a6,a0
    sw a6,56(sp)    #store mal1_result pointer___o
    
    lw a0,36(sp)
    lw a1,28(sp)    
    lw a1,0(a1)     #load row number m1
    lw a2,32(sp)
    lw a2,0(a2)     #load column number m1
    lw a3,52(sp)    #load h pointer
    lw a4,16(sp)    
    lw a4,0(a4)     #load row number h
    lw a5,44(sp)
    lw a5,0(a5)     #load column number h
    jal matmul
    # Write output matrix o
    lw t1,8(sp)
    lw a0,16(t1)     #*(a1+4) file pointer for output File
    lw a1,56(sp)    #pointer to matrix o
    lw a2,28(sp)    
    lw a2,0(a2)     #load row number o
    lw a3,44(sp)
    lw a3,0(a3)     #load column number o
    jal write_matrix
    # Compute and return argmax(o)
    lw a0,56(sp)    #pointer to matrix o
    lw t0,28(sp)    
    lw t0,0(t0)     #load row number o
    lw t1,44(sp)
    lw t1,0(t1)     #load column number o
    mul a1,t0,t1
    jal argmax
    sw a0,60(sp)    #store argmax
    # If enabled, print argmax(o) and newline
    lw t0,12(sp)
    beq t0,x0,Print
Continue:
    #free
    lw a0,16(sp)    #free row pointer m0
    jal free
    lw a0,20(sp)    #free column pointer m0
    jal free
    lw a0,24(sp)    #free matrix m0
    jal free
    lw a0,28(sp)    #free row pointer m1
    jal free
    lw a0,32(sp)    #free column pointer m1
    jal free
    lw a0,36(sp)    #free matrix m1
    jal free
    lw a0,40(sp)    #free row pointer input
    jal free
    lw a0,44(sp)    #free column pointer input
    jal free
    lw a0,48(sp)    #free matrix input
    jal free
    lw a0,52(sp)    #free mal1_result matrix___h
    jal free
    lw a0,56(sp)    #free mal1_result matrix___o
    jal free
    lw ra,0(sp)
    lw a0,60(sp)    #load argmax
    addi sp,sp,64
    jr ra
Exceptions_argc:
    addi a0,x0,31
    j exit
Exceptions_malloc:
    addi a0,x0,26
    addi sp,sp,64
    j exit
Print:
    lw a0,60(sp)
    jal print_int
    li a0 '\n'
    jal print_char
    j Continue