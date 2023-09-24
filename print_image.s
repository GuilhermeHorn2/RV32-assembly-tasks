.global _start

.section .text
_start:

jal open

li a2, 13
la a1, buffer
jal read

#get_x t5 = x
li a4, 0
la a5, buffer
addi a5, a5, 3
jal get_dim
mv t5, a4

#get_y t6 = y
li a4, 0
addi a5, a5, 1
jal get_dim
addi a5, a5, 4
mv t6, a4


mul a2, t5, t6
la a1, buffer_1
jal read

mv a0, t5
mv a1, t6
jal canvas_size

la a5, buffer_1
jal print_image



jal exit



print_image:
    addi sp, sp, -4
    sw ra, 0(sp)
    # t5 = x
    # t6 = y
    # a5 = buffer
    # t0 = i
    # a0 = coord x
    # a1 = coord y 
    li s3, 0
    li s4, 0
    li t0, 0
    
    
    mul t4, t5, t6 # t4 = max

    for_2:
        beq t0, t4, cont_2

        # quando i % x == 0 --> y++ e x = 0
        rem s3, t0, t5
        div s4, t0, t6


        lbu s5, 0(a5)
        slli s1, s5, 24
        add s2, s2, s1
        slli s1, s5, 16
        add s2, s2, s1
        slli s1, s5, 8
        add s2, s2, s1
        addi s2, s2, 255
        mv a2, s2
        mv a0, s3
        mv a1, s4
        jal set_pixel
        addi a5, a5, 1
        
        li s2, 0
        addi t0, t0, 1
        j for_2
    cont_2:
    lw ra, 0(sp)
    addi sp, sp, 4
    ret


get_dim:
    #addi a5, a5, 3
    # a5 : buffer do cabeçalho
    # x : 0,1,2
    # y : 3,4,5

    #li t0, 0
    li t2, 32
    li t3, 10

    for_1:
        lbu t4, 0(a5)

        beq t4, t3, cont_1
        beq t4, t2, cont_1

        add t4, t4, -48
        #mul t5, t4, t2 # t5 = a0[i] * 100,10,1
        #add a4, a4, t5 # a0 += t5
        #div t2, t2, t3
        mul a4, a4, t3
        add a4, a4, t4

        addi a5, a5, 1

        #addi t0, t0, 1
        j for_1
    cont_1:
    ret


canvas_size:

    li a7, 2201
    ecall
    ret

set_pixel:
   #a0 : coordenada x
   #a1 : coordenada y
   #a2 : cor
   li a7, 2200
   ecall
   ret

open:
   la a0 ,input_file
   li a1, 0
   li a2, 0
   li a7, 1024
   ecall
   mv s0, a0
   ret

read:
    mv a0, s0
    #la a1, buffer
    #li a2, 2
    li a7, 63
    ecall
    ret

exit:
   li a0, 0
   li a7, 93
   ecall
   ret

.section .data
input_file: .asciz "image.pgm"
buffer: .skip 100
buffer_1: .skip 262159
