.global _start

.section .data
    hello_message: .asciz "Hello, World!\n"

.section .text
_start:
    // Write "Hello, World!" to stdout (file descriptor 1)
    mov r0, #1              // File descriptor 1 (stdout)
    ldr r1, =hello_message  // Address of the string
    mov r2, #14             // Length of the string (including newline)
    mov r7, #4              // syscall number for sys_write
    swi 0                   // Make the syscall

    // Exit the program with status code 0
    mov r0, #0              // Exit status code 0
    mov r7, #1              // syscall number for sys_exit
    swi 0                   // Make the syscall

