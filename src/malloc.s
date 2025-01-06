.global _start

.data
    exit_message: .asciz "Exiting\n"

.section .heap,"aw"
	addr_list: .space 1024

.text
_start:
	mov r0, #0
	//setup initial block with size max
	ldr r1, =addr_list
	str r0, [r1]
	mov r0, #1024
	str r0, [r1, #4]
	bl exit

/*metadata is as follows
+0 next pointer 32 bits
+4 size
*/

add_to_list:
	//address of block in r0
	//push {r4-r11}
	//for simplicity, assume always one valid block
	ldr r1, =addr_list
	mov r2, #0 //previous pointer
	while_add_to_list:
		cmp r1, #0
		beq end_while_add_to_list
		cmp r1, r0
		bhs end_while_add_to_list
		mov r2, r1
		ldr r1, [r1]
		b while_add_to_list

	end_while_add_to_list:
	str r0, [r2]
	str r1, [r0]
	bx lr

remove_from_list:
	//address of block in r0
	ldr r1, =addr_list //curr
	while_remove_from_list:
		ldr r2, [r1]
		cmp r2, #0
		beq end_while_remove_from_list
		cmp r2, r0
		bhs end_while_remove_from_list
		mov r1, r2
		b while_remove_from_list
	
	end_while_remove_from_list:
	cmp r0, r2
	ldreq r3, [r2]
	streq r3, [r1]
	bx lr

find_best_fit:
	//size in r0
	mov r1, #0 //best
	ldr r2, =addr_list //curr
	push {r4}
	while_find_best_fit:
		cmp r2, #0
		beq end_while_find_best_fit
		ldr r3, [r2, #4]
		cmp r3, r0
		moveq r0, r3
		bxeq lr
		cmp r0, r3
		bhs find_best_end_if
		cmp r1, #0
		bne find_best_else_if
		mov r1, r2
		b find_best_end_if
		find_best_else_if:
		ldr r4, [r1, #4]
		cmp r3, r4
		bhs find_best_end_if
		mov r1, r2
			
		find_best_end_if:
		ldr r2, [r2]
		b while_find_best_fit

		
	end_while_find_best_fit:
	mov r0, r1 //return best
	pop {r4}
	bx lr
		

split_block:
	//r0 is block address
	//r1 is size
	ldr r2, [r0, #4] //block size
	add r3, r1, r2  //block + block size
	sub r3, r3, r1  //block + block size - size
	//r3 = newblock
	sub r2, r2, #64
	sub r2, r2, r1
	str r2, [r0, #4]
	str r1, [r3, #4]
	mov r0, r3
	bx lr


merge:
	//r0 has left address
	//r1 has right address
	ldr r2, [r1]
	str r2, [r0]
	ldr r2, [r1, #4]
	add r2, r2, #64
	str r2, [r0, #4]
	bx lr

find_right:
	//r0 has address of freed block
	mov r1, r0 //curr
	ldr r2, [r0, #4] //r2 = freed block size
	add r0, r0, #64 //get to end of metadata
	add r0, r0, r2 //get to end of block
	while_find_right:
		cmp r1, #0
		beq end_while_find_right
		cmp r1, r0
		bxeq lr
		ldr r1, [r1]
		b while_find_right
		
	end_while_find_right:
	mov r0, #0
	bx lr


find_left:
	//r0 has address of freed block
	mov r1, r0 //r1 is curr
	while_find_left:
		cmp r1, #0
		beq end_while_find_left
		cmp r1, r0
		bge end_while_find_left
		ldr r2, [r1, #4] 
		add r2, r2, #64
		cmp r2, r0
		moveq r0, r1
		bxeq lr
		ldr r1, [r1]
		b while_find_left
		
	end_while_find_left:
	mov r0, #0
	bx lr


malloc:
	//r0 has size
	push {lr}
	cmp r0, #0
	movls r0, #0
	bxls lr
	mov r4, r0 //save size in r4
	bl find_best_fit
	//r0 now has bestfit
	cmp r0, #0
	bxeq lr //return null if no fit

	ldr r1, [r0, #4] //bestfit size
	sub r1, r1, r4
	cmp r1, #72
	bhs malloc_else
	mov r5, r0 //preserve bestfit
	bl remove_from_list
	add r5, r5, #64
	mov r0, r5
	pop {lr}
	bx lr

	malloc_else:
	//here r0 still has best fit
	mov r1, r4 //get size into r1
	bl split_block
	add r0, r0, #64
	pop {lr}
	bx lr

free:
	//ptr to free in r0
	push {lr}
	cmp r0, #0
	bxeq lr
	
	
exit:
    mov r0, #1              // File descriptor 1 (stdout)
    ldr r1, =exit_message  // Address of the string
    mov r2, #14             // Length of the string (including newline)
    mov r7, #4              // syscall number for sys_write
    swi 0                   // Make the syscall
    // Exit the program with status code 0
    mov r0, #0              // Exit status code 0
    mov r7, #1              // syscall number for sys_exit
    swi 0                   // Make the syscall
