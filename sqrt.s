.global _start

.section .text
_start:
jal read
# jal write



jal exit

sqrt:
    # sqrt(x)
    # a0 = x
    li t0, 0 # i = 0
    li t1, 10 # t1 = 10(max itr)
    div t2, a0, 2 # guess,k(t2) = x/2
    # for loop
    bge t0, t1, if # break if i >= 10

    div t3, a0, t2 # t3 = y/k  
    add a0, a0, t3 # x(a0) = x(a0) + t3
    div a0, a0, 2 # a0 /= 2

    addi t0, t0, 1 # i++
    j 1b # volta
    ret # retorna em ra(a0)



pow:
    # pow (x,y)
    li t0, 0 # i = 0
    # a3 = x
    # a4 = y

    # for loop
    bge t0, a3, 1f # break if i >= y
    mult a3, a3, a3 # a3 = a3*a3
    addi t0, t0, 1 # i++
    j 1b # volta pro inicio
    mv a0, a3 # a0 = a3
    ret # retorna em ra(a3)

to_number:

    # a0 = numero retornado
    # input_address =  buffer
    # a2 = n

    li t0, 0 # i = 0
    li t5, 3 # j = 3
    li a2, 3 # n = 3 ,esse é o valor que dita até qual index vai converter(na verdade a2 = t0 + 3)
    add a2, a2, t0 # a2 = t0 + 3 , sempre pega de t0 ate 3 na frente

    # for loop
    bge t0, a2, 1f # break if i >= n
    add t1, input_address, t0 # buffer + i
    lb t1, 0(t1) # t1 = buffer[i]
    beqz t1, 1f # break if buffer[i] == '\0'
    addi t2, t1, -48 # t2 = buffer[i] - 48
    # chamar pow(x,y); x = 10 e y = j
    li a3, 10 # a3 = 10
    addi a4, t5, zero # a4 = j
    jal ra, pow # pow(10,j)
    # ##
    mult t3, t2, ra # t3 = (buffer[i] - 48) * pow(10,j)
    add a0, a0, t3 # a0 += t3
    addi t0, t0, 1 # i++
    addi t5, t5, -1 # j--
    j 1b # volta    
    ret # retorna em ra(a0)





read:
    li a0, 0  # file descriptor = 0 (stdin)
    la a1, input_address #  buffer to write the data
    li a2, 1  # size (reads only 1 byte)
    li a7, 63 # syscall read (63)
    ecall

write:
    li a0, 1            # file descriptor = 1 (stdout)
    la a1, string       # buffer
    li a2, 19           # size
    li a7, 64           # syscall write (64)
    ecall    

exit:
   li a0, 1
   li a7, 93
   ecall

.section .data
input_address: .skip 0x10  # buffer
string: .asciz "Hello! It works!!!\n"
