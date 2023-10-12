.global _start
.section .text
.set car, 0xFFFF0100
_start:

  #endereço base do carro : 0xFFFF0100

  #anda de z = strt --> z = -19
  li a0, -70
  jal turn
  li a0, 6000
  jal go_foward
  #li a0, 1000
  #jal go_foward
  li a0, -25
  jal allways_verify_z

  
  

jal exit

allways_verify_z:
  addi sp, sp, -4
  sw ra, 0(sp)
  #a0: valor em z que eu quero que pare quando chegar ou passar dele
  mv a2, a0

  while:

   jal get_z_pos
   #a0 :  pos(z)
   bge a0, a2, end_3
   j while
  end_3:
  jal stop
  lw ra,0(sp)
  addi sp, sp, 4
  ret



go_foward:
  # a0 : intensity
  addi sp, sp, -4
  sw ra, 0(sp)
  mv t1, a0
  li a0, 1
  li t0, 0 
   for_1:
    beq t0, t1, end_1
    jal front_back
    addi t0, t0, 1
    j for_1
   end_1:
  lw ra,0(sp)
  addi sp, sp, 4
  ret

front_back:
  # a0 : 1,0,-1
  li a1, car
  addi a1, a1, 33
  sw a0, 0(a1)
  addi a1, a1, -33
  ret

stop:
  li a1, car
  addi a1, a1, 34
  li a0, 1
  sw a0, 0(a1)
  addi a1, a1, -34
  ret

get_z_pos:
  li t0, 1
  li a1, car
  sw t0, 0(a1)
  addi a1, a1, 11
  lw a0, 0(a1)
  addi a1, a1, -12
  ret

turn:
  # a0 < 0 --> left ; a0 > 0 --> right
  li a1, car
  addi a1, a1, 32
  sw a0, 0(a1)
  addi a1, a1, -32
  ret

exit:
    li a0, 0
    li a7, 93
    ecall
    ret

