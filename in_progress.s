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
    #quando for borda no filtro,fazer os shifts ou n,isso pode estar afetando...
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
    
    
    mul s7, t5, t6 # s7 = max

    for_2:
        beq t0, s7, cont_2

        # quando i % x == 0 --> y++ e x = 0
        rem s3, t0, t5
        div s4, t0, t6

        jal filtro

        li s1,  0
        li s2, 0
        #lbu s5, 0(a5)
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

filtro:
    # s3 : i
    # s4 : j

    #1)lidando com a borda(index >= x ou >= y)

    beq s3, zero,cont_3
    beq s4, zero,cont_3

    #mv s8, t0
    addi s8, t5, -1
    beq s3, s8, cont_3
    addi s8, t6, -1
    beq s4, s8, cont_3
    j somatorio
    cont_3:
    li s5, 0
    ret
    #1)

    #2)caso nao seja 0 por violar os indexes,fazer o filtro 
    somatorio:
    li s5, 0
    li s6, 3
    li t1, -1
    li t2, 0 # k
    la a4 ,matrix
    for_k: 
    beq t2, s6, end_k
    li t3, 0 # q
    for_q:
    beq t3, s6, end_q
    # w[k][q]
    mul a3, s6, t2 # a3 = 3*k
    add a3, a3, t3 # a3 += q
    add t4, a4, a3 # index : 3*q + k 
    lbu s1, 0(t4) # s1 = w[k][q]
    addi s1, s1, -48

    # como eu guardei os -1 como 1 na string,preciso checar esse caso
    li a3, 1
    beq s1, a3, is_one
    j not_one
    is_one:
        mul s1, s1, t1
    not_one:

    #W[i + k - 1][j + q - 1]; W = a5(input_file)
    li a3, 0
    li a6 , 0
    # (j+q-1):
    add a3, a3, t3 # a3 += q
    addi a3, a3, -1 # a3 += -1
    add a3, a3, s4 # a3 += j

    #1)checar  se o index em a3 e valido
    
    bge a3, t6, invalido # a3 >= y
    blt a3, zero, invalido # a3 < 0


    # (i+k-1)
    add a6, a6, t2 # a6 += k
    addi a6, a6, -1 # a6 += -1
    add a6, a6, s3 # a6 += i

    #1)checar  se o index em a6 e valido
    
    bge a6, t5, invalido # a6 >= x
    blt a6, zero, invalido # a6 < 0

    rot:
    mul a6, a6, t6 # a6 *= y
    add a6, a6, a3 # a6 += a3
    add t4, a5, a6 # index : (i+k-1)*x + (j+q-1)
    lbu s2, 0(t4) # t4 = W[i+k-1][i+k-1]

    mul t4, s1, s2 # t4 = w[k][q] * W[i+k-1][j+q-1]

    j cont
    invalido:
    li t4, 0    

    cont:
    add s5, s5, t4 # s5 += t4


    addi t3, t3, 1 # q++
    j for_q
    end_q:
    addi t2, t2, 1 # k++
    j for_k
    end_k:

   #checando se s5 > 255 ou s5 < 0
    li s8, 255
    bge s5, s8, set_max
    blt s5, zero, set_min
    j normal
    set_max:
    li s5, 255
    j normal
    set_min:
    li s5, 0
    normal:
    ret






.section .data
input_file: .asciz "image.pgm"
buffer: .skip 100
buffer_1: .skip 262159
matrix: .asciz "111181111"
