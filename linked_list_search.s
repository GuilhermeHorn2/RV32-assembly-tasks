.global _start

.section .text
_start:

jal read

la a5, input_address
jal to_int

#li a0, 45

jal search_sum
#teste:
mv s9, a1 

#mv a1, a0
jal num_digits

jal to_string

#rot_2:
#la a1, input_address
#addi a2, a2, 5
li s0, -1
la a1, output_buffer
addi a2, a2, 1
#teste:
beq s9, s0, fazeroq
j padrao
fazeroq:
 la a1, n_achou
 li a2, 3
padrao:
jal write 






jal exit



num_digits:
   # dado um numero(a1)
   #retornar o numero de digitos(a2) 

   mv s1, a1
   li t0, 0 # i = 0
   li t1, 10
   for_2:

   div s1, s1, t1

   addi t0, t0, 1 # i++
   beq s1, zero, end_2 # if(a1 == 0) -> break
   j for_2
   end_2:

   mv a2, t0
   ret

to_string:
   #dado o numero de digitos(a2),passar para string com o '\n' no final
   la a5, output_buffer
   add a5, a5, a2
   li t0, 10 # ASCII de '\n'
   sb t0, 0(a5)
   addi a5, a5, -1

   li t1, 10
   for_3:

   rem t2, a1, t1 # t2 = a1 % 10
   div a1, a1, t1 # a1 =/ 10

   addi t2, t2, 48 # int -> char
   sb t2, 0(a5) # a5[i] = t2

   beq a1, zero, end_3 # if(a1 == 0) -> break

   addi a5, a5, -1
   j for_3
   end_3:
   ret





to_int:
  #la a5, input_address # string termina com '\n'
  # return em a0
  li a0 , 0
  #checar a5[0] == '-'
  lbu t0, 0(a5) # t0 = a5[0]
  li t1, 45 # ASCII de '-'
  beq t0, t1, is_negative 
  j not_negative
  is_negative:
   li s0, -1 # sinal
   addi a5, a5, 1
   j cont
  not_negative:
   li s0, 1
  
  cont:
   li t0, 10
   loop:

    lbu t1, 0(a5) # t1 = a5[i]

    beq t1, t0, end_loop # if(a5[i] == '\n')

    addi t1, t1, -48 # char --> int

    mul a0, a0, t0 
    add a0, a0, t1


    addi a5, a5, 1 # prox idx
   j loop
   end_loop:
   mul a0, a0, s0 # set do sinal
   ret

 


search_sum:
   la a5, head_node # a5 = endereço do head node
   # a0 = soma que queremos achar
   #retorna em a1
   mv s5, a0
   li t0, 0 #i = 0
   li t1, 0 # j = 0
   while_strt:

   # s1 = VAL1
   lw s1, 0(a5)

   # s2 = VAL2
   lw s2, 4(a5)

   add s3, s1, s2 # s3 = s1 + s2

   #ver se s5 == s3
   beq s3, s5, achou

   # s4 = next_node
   lw s4, 8(a5)

   # checar se s4 == NULL(0)
   beq s4, zero, while_end # if(s4 == NULL) -> break

   # pular para o proximo node
   mv a5, s4

   addi t1, t1, 1 # j++
   j while_strt
   while_end:
   #retornar em a1 o index do node procurado
   li a1, -1
   ret
   achou:
   mv a1, t1
   ret


read:
   li a0, 0  # file descriptor = 0 (stdin)
   la a1, input_address #  buffer to write the data
   #add a1, a1, t0
   li a2, 10   # size (reads only 1 byte)
   li a7, 63 # syscall read (63)
   ecall
   ret

write:
   li a0, 1            # file descriptor = 1 (stdout)
   #la a1, output_buffer
   #li a2, 5
   li a7, 64           
   ecall
   ret


exit:
   li a0, 0
   li a7, 93
   ecall
   ret

.data
input_address: .skip 10
output_buffer: .skip 10
n_achou: .asciz "-1\n"
