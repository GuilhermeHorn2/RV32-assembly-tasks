.global _start
.section .text
.set serial_port, 0xFFFF0100
_start:

  la a1, decider
  li a2, 2
  jal read

  la a0, decider
  lbu t0, 0(a0)

  # 49 -> printar o input_adress
  # 50 -> inverter o input_adress
  # 51 -> dec_to_hex
  # 52 -> calc_op

  li t1, 49
  beq t0, t1, caso_1
  addi t1, t1, 1
  beq t0, t1, caso_2
  addi t1, t1, 1
  beq t0, t1, caso_3
  addi t1, t1, 1
  beq t0, t1, caso_4
  caso_1:
    la a1, input_address
    li a2, 20
    jal read
    la a0, input_address

    mv a1, a0
    li a2, 20
    jal write
    jal exit
  caso_2:
    la a1, input_address
    li a2, 20
    jal read

    la a0, input_address
    jal str_len

    mv a1, a0 # str_len
    la a0, input_address
    jal str_reverse
    la a0, aux

    mv a1, a0
    li a2, 20
    jal write
    jal exit
  caso_3:
  
    la a1, input_address
    li a2, 20
    jal read

    la a0, input_address
    li a1, 10
    jal atoi
    checa_aqui:

    la a1, aux
    jal dec_to_hex
    #mv a0, a1

    mv a1, a0
    li a2, 20
    jal write
    jal exit
  caso_4:
    la a1, input_address
    li a2, 20
    jal read

    jal calc_op
    la a1, aux
    jal dec_to_int

    mv a1, a0
    li a2, 20
    jal write
    jal exit




jal exit


calc_op:
  addi sp, sp, -4
  sw ra, 0(sp)
  # a0 : string do tipo : <num_1> <op> <num_2>

  #1) achar o num_1:
  la a0, input_address
  li a1, 32 # Seria como se a string terminasse em ' '
  jal atoi
  num_1:
  mv s1, a0 # s1 = num_1
  mv t1, a1 # num de digitos do num_1

  #2) achar a op:
  la a0, input_address
  add a0, a0, t1
  addi a0, a0, 1
  op:
  lbu s3, 0(a0) # s3 = op

  #3)
  addi a0, a0, 2
  li a1, 10 # termina m em '\n'
  num_2_atoi:
  jal atoi
  num_2:
  mv s2, a0 # s2 = num_2

  #definir operação

  li t4, 42 # '*'

  bne s3, t4, not_mul
  mul a0, s1, s2
  j return
  not_mul:
  li t4, 43 # '+'
  bne s3, t4, not_add
  add a0, s1, s2
  j return
  not_add:
  li t4, 45 # '-'
  bne s3, t4, not_sub
  sub a0, s1, s2
  j return
  not_sub:
  div a0, s1, s2  

  return:
  lw ra, 0(sp)
  addi sp, sp, 4
  ret



exit:
    li a0, 0
    li a7, 93
    ecall
    ret


read:
  li a0, 0  # file descriptor = 0 (stdin)
  #la a1, input_address #  buffer to write the data
  #add a1, a1, t0
  #li a2, 1   # size (reads only 1 byte)
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

atoi:
 # a0 : string inputada
 # a1 : com qual caracter a string termina

  #string em a0(?):
  mv a5, a0
  #a5 aponta para str[0],mas como saber quanto de espaço essa str ocupa
  #

  # return em a0
  li a0 , 0
  li t2, 0
  #checar a5[0] == '-'
  lbu t0, 0(a5) # t0 = a5[0]
  li t1, 45 # ASCII de '-'
  beq t0, t1, is_negative 
  j not_negative
  is_negative:
   li a7, -1 # sinal
   addi a5, a5, 1
   addi t2, t2, 1
   j cont
  not_negative:
   li a7, 1
   #precisa ver se os inputs terao o '+'
  
  cont:
   li t0, 10
   
   loop:

    lbu t1, 0(a5) # t1 = a5[i]

    beq t1, a1, end_loop # if(a5[i] == '\n')

    addi t1, t1, -48 # char --> int

    mul a0, a0, t0 
    add a0, a0, t1
    addi t2, t2, 1 # i++
    addi a5, a5, 1 # prox idx
   j loop
   end_loop:
   mul a0, a0, a7 # set do sinal
   mv a1, t2 # qnts digitos o numero acabou
   ret

str_len:
  # a0 : str
  li t1, 10 # ASCII DO '\n'
  li t0, 0 # i++
  for_2:

   
   lbu t2, 0(a0) # t2 = a0[i]
   beq t2, t1, end_2
   addi a0, a0, 1
   addi t0, t0, 1 # i++
   j for_2
  end_2:
  mv a0, t0
  ret

str_reverse:
  addi sp, sp, -4
  sw ra, 0(sp)
  # a0 : str
  mv s0, a0 # s0 = str
  # a1 : str_len
  jal str_len
  mv s1, a0 # s1 = str_len
  la t3, aux
  add s0, s0, s1 # s0 += s1
 
  for_1:
   
   
   lbu t1, 0(s0)
   sb t1, 0(t3)

   beq s1, zero, end_1

   addi t3, t3, 1
   addi s0, s0, -1
   addi s1, s1, -1
   j for_1
  end_1:
  lw ra, 0(sp)
  addi sp, sp, 4
  addi t3, t3, 1
  li t1, 10 # ASCII de '\n'
  sb t1, 0(t3)
  la a0, aux
  ret

  num_digits:
    # dado um numero(a0)
    #retornar o numero de digitos(a2) 

    mv t3, a0
    li t0, 0 # i = 0
    #li t1, 10
    for_3:

    div t3, t3, t1

    addi t0, t0, 1 # i++
    beq t3, zero, end_3 # if(a1 == 0) -> break
    j for_3
    end_3:

    mv a2, t0
    ret

##################################################

dec_to_int:
  addi sp, sp, -4
  sw ra, 0(sp)
  li t6, 0
  #checar se o numero em a0 < 0
  
  blt a0, zero, set_a # a0 < 0 
  j segue_a
  set_a:
   li t6, 1
   li t4 , -1
   mul a0, a0, t4 # abs(a0)
  segue_a:

  #
  # dado 1 valor em decimal(a0),passar para string(a1) --> a2 = numero de digitos
  li t1, 10  
  jal num_digits # num_digits(a0,10) = numeros de digitos considerando a0 decimal
  add a2, a2, t6 # se a0 < 0 ,vai sobrar 1 espaço para colocar o '-' no incio
  #
  #dado o numero de digitos(a2),passar para string com o '\n' no final
   mv a5, a1 # movendo a string para a5
  #
   add a5, a5, a2
   li t0, 10 # ASCII de '\n'
   sb t0, 0(a5)
   addi a5, a5, -1
   mv a3, a0
   li t1, 10
   for_5:

   rem t2, a3, t1 # t2 = a0 % 10
   div a3, a3, t1 # a0 =/ 10

   addi t2, t2, 48 # int -> char
   sb t2, 0(a5) # a5[i] = t2

   beq a3, zero, end_5 # if(a1 == 0) -> break

   addi a5, a5, -1
   j for_5
   end_5:

   #colocando o sinal de '-', se for o caso:

   addi t6, t6, -1
   beq t6, zero, set_b
   j segue_b
   set_b:
    addi a5, a5, -1 # n sei c precisa,bom testar
    li t0, 45 # ASCII  de '-'
    sb t0, 0(a5) # a5[0] = '-'
   segue_b:
  mv a0, a5 # colocando a string preenchida de volta em a1
  lw ra, 0(sp)
  addi sp, sp, 4
  ret

set_byte:
  # a0 = 1 -> negativo ; a0 = 0 -> positivo
  # a1 = str
  # a2 = num_digits

    li t0, 8
    sub t0, t0, a2 # quantos digitos faltam para completar o byte

    beq a0, zero, is_pos
    li t1, 102
    j cont_1
    is_pos:
      li t1, 48
    cont_1:

      li t2, 0

      while_3:
        sb t1, 0(a1) # guarda t1 na str
        bge t2, t0, end_9
        addi a1, a1, 1
        addi t2, t2, 1
        j while_3
      end_9:

  ret

set_number:
  # a0 = number
  # se a0 >= 0 -> n faz nada
  # se a0 < 0 -> 256 - abs(a0)
  
  bge a0, zero, faz_nada
  
  li t0, 256
  add a0, t0, a0
  li a3, 1
  j cont_2
  faz_nada:
  li a3, 0
  cont_2:
  ret

dec_to_hex:
  
  addi sp, sp, -4
  sw ra, 0(sp)
  #numero de digitos em hex --> a2
  mv s5 ,a1
  li t1, 16
  jal num_digits # num_digits(a0,16) = numeros de digitos considerando a0 em hex
  jal set_number
  mv s4, a0
  mv a0, a3
  jal set_byte
  rot:
  mv a0, s4
  #
  mv a3, a0
  #dado o numero de digitos(a2),passar para string com o '\n' no final
  mv a5, a1 # movendo a string para a5
  #
  add a5, a5, a2
  li t0, 10 # ASCII de '\n'
  sb t0, 0(a5)
  addi a5, a5, -1
  li t1, 16
  #li t3, 9
  li t4, 58
  li t5, 10
  for_4:

  rem t2, a3, t1 # t2 = a1 % 16
  div a3, a3, t1 # a1 =/ 16

  #S t2 < 10
  addi t2, t2, 48
  bltu t2, t4, quero 
  j ir
  quero:
    #addi t2, t2, 48
    j dormir
  ir:
    # se t2 >= 10
    sub t2, t2, t4 # t2 -= 58
    #add t2, t2, t5 # t2 -= 10
    addi t2, t2, 97

  dormir:

  sb t2, 0(a5) # a5[i] = t2

  beq a3, zero, end_4 # if(a1 == 0) -> break

  addi a5, a5, -1
  j for_4
  end_4:
  mv a0, s5
  lw ra, 0(sp)
  addi sp, sp, 4
  ret



.data
aux: .skip 100
input_address: .skip 100
decider: .skip 10
