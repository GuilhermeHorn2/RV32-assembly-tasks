.global _start

.section .text
_start:
jal read

# "0400 5337 2240 9166"
#  9166 2240 5337 0400



##1) [0,3] + ' '
la a5, input_address
jal to_number
jal sqrt
li t0, 3
jal preset_a
jal set_output # t0 = 3

## 2) [5,8]+ ' '
la a5, input_address
addi a5, a5, 5
jal to_number
jal sqrt
li t0, 8
jal preset_a
jal set_output # t0 = 8

## 3) [10,13]
la a5, input_address
addi a5, a5, 10
jal to_number
jal sqrt
li t0, 13
jal preset_a
jal set_output # t0 = 13

## 4) [15,18]
la a5, input_address
addi a5, a5, 15
jal to_number
jal sqrt
li t0, 18
jal preset_b
jal set_output # t0 = 18



##5) [19] -> \n
la a5, output_address
li t1, 10 # '\n'
sb t1, 19(a5)
#
jal write


jal exit

preset_a:
    la a5, output_address
    addi t6, t0, 1 # t6 = t0 + 1
    add a5, a5, t6 # a5 = a5 + (t0+1)
    li t4, 32 # colocando o espaço no buffer[t0+1](1)
    sb t4, 0(a5) # colocando o espaço no buffer[t0+1](2)
    addi a5, a5, -1 # aponta pro buffer[t0]
    ret

preset_b:
    la a5, output_address
    add a5, a5, t0
    ret

set_output:
    #colocar o valor em a0 no buffer digito a digito,começando to index t0-3<-t0
    # a5 = buffer

    li t1, 0 # i = 0
    li t2, 4 # max = 4
    li t3, 10 # t3 = 10
    set_a:#for loop
        bge t1, t2, set_b # break if i >= 4 

        rem t5, a0, t3 # t5 = a0 % 10
        div a0, a0, t3 # a0 /= 10

        addi t5, t5, 48

        #add t6, a5, 0
        sb t5, 0(a5)
        addi a5, a5, -1

        addi t1, t1, 1 # i++
        j set_a # volta
    set_b:
        ret

sqrt:
    # sqrt(x)
    # a0 = x
    li t0, 0 # i = 0
    li t1, 10 # t1 = 10(max itr)
    li t4, 2 # t4 = 2
    div t2, a0, t4 # guess,k(t2) = x/2
    # for loop
    sqrt_a:
        bge t0, t1, sqrt_b # break if i >= 10

        div t3, a0, t2 # t3 = y/k  
        add t2, t2, t3 # x(a0) = x(a0) + t3
        div t2, t2, t4 # a0 /= 2

        addi t0, t0, 1 # i++
        j sqrt_a # volta
    sqrt_b:
        mv a0, t2
        ret # retorna em ra(a0)




to_number:
    # a0 = numero retornado
    # input_address =  buffer
    # a2 = n
    li a0, 0 
    li t0, 0 # i = 0
    li a2, 4 # n = 3 ,esse é o valor que dita até qual index vai converter(na verdade a2 = t0 + 3)
    add a2, a2, t0 # a2 = t0 + 3 , sempre pega de t0 ate 3 na frente
    li t2, 1000
    li t6, 10
    #la a5, input_address # a5 e o buffer
    
    # for loop
    number_a:
        bge t0, a2, number_b # break if i >= n
        # break
        beq t1, t6, number_b # break if buffer[i] == '\n'
        ##
        add t3, a5, t0 # v + i
        lbu t3, 0(t3) #t3 = v[i]
        addi t3, t3, -48 # char -> int
        mul t3, t3, t2 # v[i] *= 10^(3-i)
        add a0, a0, t3 # a0 += t3
        div t2, t2, t6 # t2 /= 10

        addi t0, t0, 1 # i++
        j number_a # volta
        number_b:    
        ret # retorna em ra(a0)





read:
    li a0, 0  # file descriptor = 0 (stdin)
    la a1, input_address #  buffer to write the data
    li a2, 20  # size (reads only 1 byte)
    li a7, 63 # syscall read (63)
    ecall
    ret

write:
    li a0, 1            # file descriptor = 1 (stdout)
    la a1, output_address 
    li a2, 20 
    li a7, 64           
    ecall
    ret

exit:
    li a0, 0
    li a7, 93
    ecall
    ret

.section .data
input_address: .skip 20  # buffer
output_address: .skip 20  # buffer
