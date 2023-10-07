.global _start

.global puts
.global gets
.global atoi
.global itoa
.global exit
.global recursive_tree_search

.section .text
#_start:








############################################
puts: 
 addi sp , sp, -4
 sw ra, 0(sp)
 # a0 : string
 #mv a0, s10 ######
 # suponho que o buffer do STDIN seja o a1
 mv a5, a0
 li t0, 0 # ASCII DO '\0'
 li t1, 0 # i++
 la a1, output_buffer
 for_5:

  lbu t2, 0(a5) # t2 = a5[i]
  
  beq t2, t0, stop_1 # if(t2 == '\0') -> adiciona '\n' e da break
  sb t2, 0(a1) # a1[i] = a5[i]
  addi a5, a5, 1
  addi a1, a1, 1 #
  addi t1, t1, 1 #i++
  j for_5
  stop_1:
   addi t0 ,t0, 10 # t0 = '\n'
   sb t0, 0(a1) #
 end_5:
 mv a2, t1
 addi a2, a2, 1
 sub a1, a1, t1
 #addi a1, a1, 1
 jal write
 lw ra, 0(sp)
 addi sp, sp ,4
 ret
############################################

############################################
gets:
addi sp , sp, -4
 sw ra, 0(sp)
 # a0 = buffer a ser preenchido
 mv s1, a0
 jal read_dynamic
 final_read:
 mv a0, s1
 # suponho que o buffer do STDIN seja o a1

 mv a5, a1
 li t0, 10 # ASCII DE '\n'
 li t1, 0 # i = 0
 for_6:

  lbu t2, 0(a5) # t2 = a5[i]

  beq t2, t0, stop_2 # if(t2 == '\n') -> adiciona '\0' e da break
  sb t2, 0(a0) # a0[i] = a5[i]
  addi a5, a5, 1
  addi a0, a0, 1 #
  addi t1, t1, 1
  j for_6
  stop_2:
   addi t0, t0, -10 # t0 = '\0'
   sb t0, 0(a0) #
 end_6:
 sub a0, a0, t1
 lw ra, 0(sp)
 addi sp, sp ,4
 #mv s10, a0 ######
  ret

###############################################
num_digits:
   # dado um numero(a0)
   #retornar o numero de digitos(a2) 

   mv t3, a0
   li t0, 0 # i = 0
   #li t1, 10
   for_2:

   div t3, t3, t1

   addi t0, t0, 1 # i++
   beq t3, zero, end_2 # if(a1 == 0) -> break
   j for_2
   end_2:

   mv a2, t0
   ret
##############################################

##############################################
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
  #dado o numero de digitos(a2),passar para string com o '\0' no final
   mv a5, a1 # movendo a string para a5
  #
   add a5, a5, a2
   li t0, 0 # ASCII de '\0'
   sb t0, 0(a5)
   addi a5, a5, -1
   mv a3, a0
   li t1, 10
   for_3:

   rem t2, a3, t1 # t2 = a0 % 10
   div a3, a3, t1 # a0 =/ 10

   addi t2, t2, 48 # int -> char
   sb t2, 0(a5) # a5[i] = t2

   beq a3, zero, end_3 # if(a1 == 0) -> break

   addi a5, a5, -1
   j for_3
   end_3:

   #colocando o sinal de '-', se for o caso:

   addi t6, t6, -1
   beq t6, zero, set_b
   j segue_b
   set_b:
    addi a5, a5, -1 # n sei c precisa,bom testar
    li t0, 45 # ASCII  de '-'
    sb t0, 0(a5) # a5[0] = '-'
   segue_b:
  mv a1, a5 # colocando a string preenchida de volta em a1
  lw ra, 0(sp)
  addi sp, sp, 4
  ret
##############################################

#############################################
  hex_to_int:
   addi sp, sp, -4
   sw ra, 0(sp)

   #numero de digitos em hex --> a2
   li t1, 16
   jal num_digits # num_digits(a0,16) = numeros de digitos considerando a0 em hex
   #
   mv a3, a0
   #dado o numero de digitos(a2),passar para string com o '\0' no final
   mv a5, a1 # movendo a string para a5
  #
   add a5, a5, a2
   li t0, 0 # ASCII de '\0'
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
   mv a1, a5 # colocando a string preenchida de volta em a1
   lw ra, 0(sp)
   addi sp, sp, 4
   ret
#########################################################

###############################################
recursive_tree_search:
  # a0 : root
  # a1 : val
  addi sp, sp, -12
  sw ra, 0(sp)
  sw t1, 4(sp)
  sw t2, 8(sp)

  lw t0, 0(a0) # val
  lw t1, 4(a0) # left
  lw t2, 8(a0) # right


  beq t0, a1, achou_1
  j cont_1
  achou_1:
   li a0, 1
   j ret_salvo
  cont_1:
  beq t1, zero, pula_left
  mv a0, t1
  jal recursive_tree_search
  bne a0, zero, achou_2
  pula_left:
  beq t2, zero, pula_right
  mv a0, t2
  jal recursive_tree_search
  bne a0, zero, achou_2
  pula_right:
  # se chegou aqui, n achou nada
  li a0, 0
  j ret_salvo
  achou_2:
  addi a0, a0, 1
  #j ret_salvo

  ret_salvo:
  lw ra, 0(sp)
  lw t1, 4(sp)
  lw t2, 8(sp)
  addi sp, sp, 12
  ret
###########################################################

#########################################################
itoa:
  addi sp, sp, -4
  sw ra, 0(sp)
  #a0 : int value
  #a1 : char* str
  #a2 : int base
  
  #se a2 == 10 --> chama dec_to_int
  li t0, 10

  beq a2, t0, dec
  j hex
  dec:
   jal dec_to_int # dec_to_int(value,str)
   j cont_geral
  hex:
   jal hex_to_int # hex_to_int(value,str)
  cont_geral:
  lw ra, 0(sp)
  addi sp, sp, 4
  #retornar em a0 a string
  mv a0, a1
  #a unica coisa que muda e que a1 agora está preenchido
  ret
######################################################

#################################################
atoi:
  # string termina com '\0'

  #string em a0(?):
  mv a5, a0
  #a5 aponta para str[0],mas como saber quanto de espaço essa str ocupa
  #

  # return em a0
  li a0 , 0
  #checar a5[0] == '-'
  lbu t0, 0(a5) # t0 = a5[0]
  li t1, 45 # ASCII de '-'
  beq t0, t1, is_negative 
  j not_negative
  is_negative:
   li a7, -1 # sinal
   addi a5, a5, 1
   j cont
  not_negative:
   li a7, 1
   #precisa ver se os inputs terao o '+'
  
  cont:
   li t0, 10
   loop:

    lbu t1, 0(a5) # t1 = a5[i]

    beq t1, zero, end_loop # if(a5[i] == '\0')

    addi t1, t1, -48 # char --> int

    mul a0, a0, t0 
    add a0, a0, t1

    addi a5, a5, 1 # prox idx
   j loop
   end_loop:
   mul a0, a0, a7 # set do sinal
   ret
########################################################
 
###############################################
read_dynamic:
    addi sp, sp, -4
    sw ra ,0(sp)
    li t1, 10 # ASCII DE '\n'
    #la a1, input_address
    li t0 , 0 # i = 0
    mv a1, s1
    loop_1:
        #addi a1, a1, 1   
        jal read
        lbu t2, 0(a1)
        #addi t0, t0, 1 # i++
        addi a1, a1, 1
        beq t2, t1, end_loop_1
        j loop_1
        

    end_loop_1:
    lw ra, 0(sp)
    addi sp, sp, 4
    mv a1, s1
    ret


##############################################

read:
   li a0, 0  # file descriptor = 0 (stdin)
   #la a1, input_address #  buffer to write the data
   #add a1, a1, t0
   li a2, 1   # size (reads only 1 byte)
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
output_buffer: .skip 100
