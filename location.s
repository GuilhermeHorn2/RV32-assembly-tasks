.global _start

.section .text
_start:

##1)inputs
#read(input_1,12)
la a1, input_1
li a2, 12
jal read
#

#read(input_2,20)
la a1, input_2
li a2, 20
jal read
# 1)

#2)pegar A,B,C(distancias) do input_2 e guardar em um buffer
#X = T(ns) * c(m/s) -> X = T*3/10

li a1, 0
li a2, 0
la a5, input_2
addi a5, a5, 15
jal to_number
mv a6, a0

#A
la a5, input_2
#addi a5, a5, 5
jal to_number
la a5, dists
jal set_dist
sb a0, 0(a5) # dists[0] = A
mv s1, a0 # s1 = Da
#

#B
la a5, input_2
addi a5, a5, 5
jal to_number
la a5, dists
jal set_dist
sb a0, 1(a5) # dists[1] = B
mv s2, a0 # s2 = Db
#

#C
la a5, input_2
addi a5, a5, 10
jal to_number
la a5, dists
jal set_dist
sb a0, 2(a5) # dists[2] = C
mv s3, a0 # s3 = Dc
#



#2)

#3)pegar Yb e Xc do input_1 e guardar em coord

#Yb
la a5, input_1
addi a5, a5, 1
jal to_number
la a5, input_1
jal set_input
la a5, coord
sb a0, 0(a5)
mv s4, a0 # s4 = Yb
#

#Xc
la a5, input_1
addi a5, a5, 7
jal to_number
la a5, input_1
addi a5, a5, 6
jal set_input
la a5, coord
sb a0, 1(a5)
mv s5, a0 # s5 = Xc
#
#3)

jal reset

#4) a0 = y
jal calc_y
la a5, local
sb a0, 1(a5)
mv s6, a0 # s6 = y
#4)

#5) a1 = x
li t6 ,-1

jal calc_x_abs # abs(x)^2 =  a1
jal sqrt #a1 = abs(x)
mul a1, a1, t6
jal apply_eq
mv a2, t4
jal abs # abs(a2)
mv t0, a2 # t0 -> erro se x < 0
mul a1, a1, t6
jal apply_eq
mv a2, t4
jal abs # abs(a2)
mv t1, a2 # t1 --> erro se x >= 0
bge t1, t0, negative # t1 > t0
la a5, local
sb a1, 0(a5)  
j continue

negative:
   la a5, local
   sb a1, 0(a5)
   mul a1, a1, t6
   j continue


#5)

#6)colocando a0(y) e a1(x) no buffer do output
continue:
#checa se a0 < 0 ou >0 e colocar manualmente o sinal dps faz o set_output(a0)-> so aceita a0 ; a5 e o buffer
#set output so aceita valores > 0

#mv a1, a6
#mv a0, s2

mv a4, a0

#colocando X = "(+ ou -)...."

mv a2, a1
jal set_signal # set_signal(a2) -> retorna em a3
jal abs # abs(a2)
la a5, output
sb a3, 0(a5) # colocando o sinal em [0]
#addi a5, a5, 1
li t0 ,4 # indo para o index [4]
mv a0, a2
jal preset_a # coloc o espaço em [5]
jal set_output # preenche [1,2,3,4]

mv a0, a4

#colocando Y = "(+ ou -)...."
mv a2, a0
jal set_signal # set_signal(a2) -> retorna em a3
jal abs # abs(a2)
la a5, output
addi a5, a5, 6 # indo para o index [6]
sb a3, 0(a5) # colocando o sinal em [6]
la a5, output
li t0 ,10
add a5, a5, 10 # index [10]
mv a0, a2
jal set_output #preenche [7,8,9,10]
li t1, 10 # colocando o '\n'
la a5, output
sb t1, 11(a5) # colocar o '\n' no index [11]

#6)

jal write # write(output)


jal exit

preset_a:

   addi t6, t0, 1 # t6 = t0 + 1
   add a5, a5, t6 # a5 = a5 + (t0+1)
   li t4, 32 # colocando o espaço no buffer[t0+1](1)
   sb t4, 0(a5) # colocando o espaço no buffer[t0+1](2)
   addi a5, a5, -1 # aponta pro buffer[t0]
   ret

set_signal:
   #dado um valor em a2,retornar o valor de + ou - na tabela ASCII em a3
   bge zero, a2, is_negative_c # if 0 > a2, jump par negative
   j continue_c

   is_negative_c:
      li a3, 45 # a3 = 45('-')
      ret

   continue_c:
      li a3, 43 # a3 = 43('+')
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

apply_eq:
   #aplicar a eq (x-Xc)^2 + y^2 = Dc^2 e ver o quanto essa igualdade é proxima 
   # a0 = y
   # a1 = x
   la a5, dists
   lbu t0 ,2(a5)
   mul t0, s3, s3 #t0 = Dc^2
   mul t1, s6, s6 #t1 = y^2
   la a5, coord
   lbu t2, 1(a5) # t2 = Xc
   #
   sub t3, a1, s5 # t3 = x - Xc
   mul t3, t3, t3 # t3 = (x-Xc)^2
   add t4, t3, t1 # t4 = (x-Xc)^2 + y^2
   sub t4, t4, t0 # t4 = erro
   ret



   ret

abs:
   # calc abs de a2
   li t6, -1
   bge zero, a2, is_neative_b
   j finally_b

   is_neative_b:
      mul a2, a2, t6
      j finally_b

   finally_b:
      ret


calc_x_abs:
   # y = a0
   la a5, dists
   lbu t0 ,0(a5) # t0 = Da
   mul t1, s6, s6 # t1 = y^2
   mul t0, s1, s1 # t0 *= t0 = Da^2
   sub a1, t0, t1 # a1 = Da^2 - y^2
   ret

reset:
   li t0, 0
   li t1, 0
   li t2, 0
   li t3, 0
   li t4, 0
   li t5 ,0
   li a0, 0
   li a1, 0
   li a5, 0
   ret

calc_y:
   # dado o dist e coord:
   #t0 = Da
   #t1 = Db
   #t2 = Yb
   #
   # t3 = Yb^2
   mul t3, s4, s4 
   mul t0, s1, s1 #Da^2
   mul t1, s2, s2 #Db^2
   li t4, 2 
   mul t2, s4, t4 # 2Yb
   #a0 = (Da^2 + Yb^2 - Db^2)/2Yb
   add a0, t0, t3 # a0 = Da^2 + Yb^2
   sub a0, a0, t1 # a0 -= Db^2
   div a0, a0, t2 # a0 =/ 2Yb
   ret

set_input:
   #a5 = input_1
   #vou retornar 1 sinal em t5 = 1 ou -1
   li t6, -1
   lbu t4, 0(a5)
   li t5, 45 # 45 => '-' em ASCII
   beq t4, t5, is_negative_a # input_1[0] == 45
   j finally_a
   is_negative_a:
      mul a0, a0, t6
      j finally_a

   finally_a:
      ret



set_dist:
   #a6 = Tr
   #a0 = Tx
   li t6, -1
   li t5, 10
   sub a0, a0, a6
   bge zero, a0, set_is_negative #if Tx-Tr < 0 vai para is_negative
   j set_finally

   set_is_negative:
      mul a0, a0, t6
      j set_finally

   set_finally:
      li t0, 3
      mul a0, a0, t0 # a0 *= 3
      div a0, a0, t5 # a0 =/ 10
      ret



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
sqrt:
   # sqrt(x)
   # a1 = x
   li t0, 0 # i = 0
   li t1, 21 # t1 = 10(max itr)
   li t4, 2 # t4 = 2
   div t2, a1, t4 # guess,k(t2) = x/2
   # for loop
   sqrt_a:
      bge t0, t1, sqrt_b # break if i >= 10

      div t3, a1, t2 # t3 = y/k  
      add t2, t2, t3 # x(a0) = x(a0) + t3
      div t2, t2, t4 # a0 /= 2

      addi t0, t0, 1 # i++
      j sqrt_a # volta
   sqrt_b:
      mv a1, t2
      ret # retorna em ra(a1)



read:
   li a0, 0  # file descriptor = 0 (stdin)
   #la a1, input_address #  buffer to write the data
   #li a2, 20  # size (reads only 1 byte)
   li a7, 63 # syscall read (63)
   ecall
   ret

write:
   li a0, 1            # file descriptor = 1 (stdout)
   la a1, output 
   li a2, 12
   li a7, 64           
   ecall
   ret

exit:
   li a0, 0
   li a7, 93
   ecall
   ret

.section .data
input_1: .skip 12  # buffer
input_2: .skip 20
output: .skip 12  # buffer

#buffer das distancias
dists: .skip 3

#buffer das coordendas
coord: .skip 2

#buffer da localizacao
local: .skip 2

teste: .skip 20
