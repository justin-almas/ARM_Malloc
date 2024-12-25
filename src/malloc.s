.global _start

.section .data
    exit_message: .asciz "Exiting\n"
    addr_list: .word 0x20000000
    max: .word 0x50000000

.section .text
_start:
	bl add_to_list
	bl exit

/*metadata is as follows
+0 next pointer 32 bits
+4 size
*/

add_to_list:
	//address of block in r0
	push {r4-r11}
	//for simplicity, assume always one valid block
	ldr r1, =addr_list
	ldr r1, [r1]
	pop {r4-r11}
	bx lr






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
