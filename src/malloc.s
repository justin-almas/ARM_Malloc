.global _start

.text
_start:
	push {r0}
    	mov r0, #0              // Exit status code 0
	mov r7, #1              // syscall number for sys_exit
    	swi 0                   // Make the syscall


