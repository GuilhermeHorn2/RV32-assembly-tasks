.section .bss
.align 4
isr_stack:
.skip 1024
isr_stack_end:

.global main

.text

.global Syscall_set_engine_and_steering
.global Syscall_set_handbrake
.global Syscall_read_sensors
.global Syscall_read_sensor_distance
.global Syscall_get_position
.global Syscall_get_rotation
.global Syscall_read_serial
.global Syscall_write_seral
.global Syscall_get_systime
.global Syscall_get_systime


.set gpt, 0xFFFF0100
.set car, 0xFFFF0300
.set serial, 0xFFFF0500
.align 4

read_byte:
  // a0 : endereço de onde o byte lido sera guardado
  li a3, serial
  addi a3, a3, 0x2
  li a4, 1
  sb a4, 0(a3)

  // busy waiting
  while_4:
  lb a4, 0(a3)
  beq a4, zero,end_4
  j while_4
  end_4:

  addi a3, a3, 0x1
  lb a5, 0(a3)
  #sb t0, 0(a0)
ret
  
write_byte:
  // a0 : endereco do byte que sera printado
  li a3, serial
  #addi a3, a3, 1
  lb t0, 0(a0)
  sb t0, 1(a3)

  #li a3, serial
  li a4, 1
  sb a4, 0(a3)

  //busy waiting
  while_6:
  
  lb a4, 0(a3)
  beq a4, zero, end_6
  j while_6
  end_6:

ret
  

Syscall_set_engine_and_steering:
  li a7, 10
  ecall
  ret

Syscall_set_handbrake:
  li a7, 11 
  ecall
  ret

Syscall_read_sensors:
  li a7, 12
  ecall
  ret

Syscall_read_sensor_distance:
  li a7, 13
  ecall
  ret

Syscall_get_position:
  li a7, 15
  ecall
  ret

Syscall_get_rotation:
  li a7, 16
  ecall
  ret

Syscall_read_serial:
  li a7, 17
  ecall
  ret

Syscall_write_seral:
  li a7, 18
  ecall
  ret

Syscall_get_systime:
  li a7, 20
  ecall
  ret

###
int_handler:

  # lembra de guardar os registradores t0,t1,t2,a0,a1,a2,a3,a4
  addi sp, sp, -40
  sw ra, 0(sp)
  sw t0, 4(sp)
  sw t1, 8(sp)
  sw t2, 12(sp)
  sw a0, 16(sp)
  sw a1, 20(sp)
  sw a2, 24(sp)
  sw a3, 28(sp)
  sw a4, 32(sp)
  sw a5, 36(sp)

  ###### Syscall and Interrupts handler ######

  
  # <= Implement your syscall handler here 
  li t0, 10
  beq a7, t0, is_10
  li t0, 11
  beq a7, t0, is_11
  li t0, 12
  beq a7, t0, is_12
  li t0, 13
  beq a7, t0, is_13
  li t0, 15
  beq a7, t0, is_15
  li t0, 16
  beq a7, t0, is_16
  li t0, 17
  beq a7, t0, is_17
  li t0, 18
  beq a7, t0, is_18
  li t0, 20
  beq a7, t0, is_20
  inf:
  j inf
  #######
  is_10:
    // a0 : direction
    // a1 :  angle
    
    # check for valid parameters
    li t0, 1
    beq a0, t0, check_angle
    li t0, -1
    beq a0, t0, check_angle
    beq a0, zero, check_angle
    
    invalid:
    li a0, -1
    j cont_1

    check_angle:
      li t0, 128
      bge a1, t0, invalid
      li t0, -127
      blt a1, t0, invalid

    #set direction
    li a2, car
    addi a2, a2, 0x21
    sb a0, 0(a2)
    #

    #set angle
    li a2, car
    addi a2, a2, 0x20
    sb a1, 0(a2)
    #
    li a0, 0
    j cont_1
  is_11:
    // a0 : 1 -> use
    li a2, car
    addi a2, a2, 0x22
    sb a0, 0(a2)
  j cont_1 
  ###

  is_12:
   // a0 : array[256]
  li a3, car
  addi a3, a3, 0x1
  li a1, 1
  sb a1, 0(a3)

  // busy waiting
  while_9:
    lb a1, 0(a3)
    beq a1, zero, end_9
    j while_9
  end_9:

  li a3, car
  addi a3, a3, 0x24
  mv a4, a0
  li t1, 256
  li t0, 0
  while_10:
    beq t0, t1, end_10
    lb t2, 0(a3)
    sb t2, 0(a0)
    addi a0, a0, 1
    addi a3, a3, 1
    addi t0, t0, 1
    j while_10
  end_10:
  mv a0, a4
  j cont_1

  is_13:
   // ret a0 -> distancia
  li a3, car
  addi a3, a3, 0x2
  li t0, 1
  sb t0, 0(a3)

  // busy waiting
  while_11:
    lb t0, 0(a3)
    beq t0, zero, end_11
    j while_11
  end_11:
  li a3, car
  addi a3, a3, 0x1c

  lw a0, 0(a3)


  j cont_1

  is_15:
    // a0,a1,a2 : pos x,pos y,pos z
    li a3, car

    //ativar o GPS
    li t0, 1
    sb t0, 0(a3)
    //busy waiting
    while_3:
    lb t0, 0(a3)
    beq t0, zero, end_3
    j while_3
    end_3:
    
    lw t0, 0x10(a3)
    lw t1, 0x14(a3)
    lw t2, 0x18(a3)

    sw t0, 0(a0)
    sw t1, 0(a1)
    sw t2, 0(a2)

    j cont_1
  #####

  is_16:
  // a0,a1,a2 : angles -> a0,a1,a2
  li a3, car
  li t0, 1
  sb t0, 0(a3)

  // busy waiting
  while_12:
    lb t0, 0(a3)
    beq t0, zero, end_12
    j while_12
  end_12:
  
  lw t0, 4(a3)
  lw t1, 8(a3)
  lw t2, 12(a3)

  sw t0, 0(a0)
  sw t1, 0(a1)
  sw t2, 0(a2)

  j cont_1

  is_17:
   // a0 : buffer ; a1 : size

    li t0, 0
    li t1, 10 # ASCII do '\n'
    while_5:
    beq t0, a1, end_5 

    jal read_byte
    beq a5, zero, end_5 # if(a0[i] == null) --> break
    #
    beq a5, t1, end_5 # if(a0[i] == '\n') --> break ####################
    #
    sb a5, 0(a0)
    addi a0, a0, 1
    addi t0, t0, 1
    j while_5
    end_5:
    mv a0, t0 # return a0 -> number of chars read
  j cont_1

  is_18:
   // a0 : buffer ; a1 : size

    li t1, 0
    while_7:
    beq t1, a1, end_7
    jal write_byte
    addi a0, a0, 1
    addi t1, t1, 1
    j while_7
    end_7:

  j cont_1

  is_20:
   // return a0 -> time since the system was booted 
  li a3, gpt
  li a4, 1
  sb a4, 0(a3)

   //busy waiting
  while_8:
    lb a4, 0(a3)
    beq a4, zero, end_8
    j while_8
  end_8:
  lw a0, 4(a3) # return a0 -> system_time

  j cont_1

  cont_1:
  # lembra de recuperar os registradores t0,t1,t2,a0,a1,a2,a3,a4
  lw a5, 36(sp)
  lw a4, 32(sp)
  lw a3, 28(sp)
  lw a2, 24(sp)
  sw a1, 20(sp)
  sw a0, 16(sp)
  sw t2, 12(sp)
  sw t1, 8(sp)
  sw t0, 4(sp)
  lw ra, 0(sp)
  addi sp, sp, 40

  csrr t0, mepc  # load return address (address of 
                 # the instruction that invoked the syscall)
  addi t0, t0, 4 # adds 4 to the return address (to return after ecall) 
  csrw mepc, t0  # stores the return address back on mepc
  mret           # Recover remaining context (pc <- mepc)
  

.globl _start
_start:

 # 0) int_handler
  la t0, int_handler  # Load the address of the routine that will handle interrupts
  csrw mtvec, t0      # (and syscalls) on the register MTVEC to set
                      # the interrupt array.
 # 0)

# 1) configure user and system stacks

# the user stack so that your program can use it.
li sp, 0x07fffffc

#setando a  system stack
la t0, isr_stack_end
csrw mscratch, t0

# 1)

# 2) change the user mode and go to main
# codigo do livro:
csrr t1, mstatus
li t2, ~0x1800
and t1, t1, t2
csrw mstatus, t1

la t0, main
csrw mepc, t0

mret
# 2)