; Created for NASM x86-64 assembly practice
; 2018-12-20

    global main                 ; main() MUST be defined for C libraries to be used
    extern printf               ; this is the C library we want to use

    section .text
main:
	mov 	edi, [n]            ; Grab the value of n, a 32-bit integer, from the heap
	call	_factorial          ; factorial(n), which returns a 64-bit integer (return address is automatically pushed to the stack)
    mov     rdi, s              ; setup printf()'s 1st argument (the format)
    mov     rsi, rax            ; setup printf()'s 2nd argument (the return of factorial(n))
    xor     rax, rax            ; set number of arguments to 0 since printf() is varargs
    call    printf              ; printf(s, factorial(n))
    ret                         ; go back to _start, as handled by the compiler
	
_factorial:
	push	rbp                 ; store current base pointer onto stack, move stack pointer to accomodate
	mov		rbp, rsp            ; start at new stack frame by making new base pointer the old stack pointer
	cmp		edi, 1              ; if (n <= 1)
	jle		_factorial_done     ; then return 1
	jmp		_factorial_do       ; else return n * factorial(n - 1)

_factorial_do:
	push	rdi                 ; store the caller-saved 1st argument of factorial(n) for the next recursive call (push and pop must be 64-bit in x86_64, so "push edi" or "pop edi" will not work)
	dec		edi                 ; decrement n since we call factorial(n - 1), not factorial(n)
	call	_factorial          ; factorial(n - 1)
	pop 	rdi                 ; restore this call of factorial(n)'s version of n back since we're done with the last recursive call
	mul		edi                 ; since the return of factorial(n) can be found in rax, and mul does the same, we can just multiply rax with n 
	mov		rsp, rbp            ; return to the old stack frame, making the stack pointer point back to the current base/former stack boundary
	pop		rbp                 ; restore the old base pointer from the stack
	ret                         ; done

_factorial_done:
	mov		rax, 1              ; return 1
	mov		rsp, rbp            ; return to the old stack frame, making the stack pointer point back to the current base/former stack boundary
	pop		rbp                 ; restore the old base pointer from the stack
	ret                         ; done

    section .data
n:  dd      9                   ; we calculate n!
s:  db      "%d", 10, 0         ; printf() format string (note s = { '%', 'd', 10, 0 })
