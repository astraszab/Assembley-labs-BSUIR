model small
.stack 100h
.data
a dw ?
b dw ?
c dw ?
d dw ?
Digits dw 0
Incorrect db 'The input is invalid. Please try again$'
Result db 'The result is $'
Prompt db 'Enter a, b, c, d; each in a new line:$'

.code


Read proc
; Read a number to bx
Retry:
; Set bx to 0
 xor bx, bx

CycleRead:
; Read a character
 mov ah, 01h
 int 21h

; Check for Enter
 cmp al, 0Dh
 jz EndCycle

; Check for bad characters
 cmp al, '0'
 jc BadChar
 cmp al, 40h
 jnc BadChar

; Convert caracter to the number and add to the result
 xor cx, cx
 mov cl, al
 sub cx, '0'
 mov ax, bx
 mov dx, 10
 mul dx
 jc BadChar
 add ax, cx
 jc BadChar
 mov bx, ax
 jmp CycleRead

; Write a warning about incorrect input
BadChar:
 mov dl, 0dh
 mov ah, 02h
 int 21h
 mov dl, 0Ah
 mov ah, 02h
 int 21h
 lea dx, Incorrect
 mov ah, 09h
 int 21h
 mov dl, 0Ah
 mov ah, 02h
 int 21h
 jmp Retry

EndCycle:
 ret
Read endp


Write proc
; Write a number from ax to console
; Fill the stack with digits
PushCycle:
 mov bx, 10
 xor dx, dx
 div bx
 push dx
 inc Digits
 cmp al, 0
 jnz PushCycle

 mov cx, Digits

; Print digits from the stack to console
PopCycle:
 pop dx
 add dl, '0'
 mov ah, 02h
 int 21h
 loop PopCycle

 ret
Write endp


Swap_a_b proc
 mov ax, a
 mov bx, b
 mov a, bx
 mov b, ax
 ret
Swap_a_b endp


Swap_b_c proc
 mov ax, b
 mov bx, c
 mov b, bx
 mov c, ax
 ret
Swap_b_c endp


Swap_c_d proc
 mov ax, c
 mov bx, d
 mov c, bx
 mov d, ax
 ret
Swap_c_d endp


Start:
 mov ax, @data
 mov ds, ax

; Read the variables
 lea dx, Prompt
 mov ah, 09h
 int 21h
 mov dl, 0Ah
 mov ah, 02h
 int 21h

 call Read
 mov a, bx

 call Read
 mov b, bx

 call Read
 mov c, bx

 call Read
 mov d, bx

; calculate b^3 and move to bx
 mov ax, b
 mul b
 mul b
 mov bx, ax

; calculate a^2 and move to ax
 mov ax, a
 mul ax

; if a^2 <> b^3 jump to Cond2
 cmp ax, bx
 jnz Cond2

; else res = a*b + c/d
; calculate a*b and save to bx
 mov ax, a
 mul b
 mov bx, ax

; calculate c/d and save to ax
 xor dx, dx
 mov ax, c
 div d

; calculate a*b + c/d and save to ax, finish the program
 add ax, bx

 jmp Final

Cond2:
; calculate c*d and save to bx
 mov ax, c
 mul d
 mov bx, ax

; calculate a/b and save to ax
 mov ax, a
 xor dx, dx
 div b

; if c*d == a/b jump to Equals
 cmp ax, bx
 jz Equals

; else choose two biggest from a, b, c, d and multiply
; choose two biggest from a, b, c, d (bubble sort until a and b contain biggest numbers)
 mov ax, c
 cmp ax, d
 jc Swap_1
Return_1:
 mov ax, b
 cmp ax, c
 jc Swap_2
Return_2:
 mov ax, a
 cmp ax, b
 jc Swap_3
Return_3:
 mov ax, c
 cmp ax, d
 jc Swap_4
Return_4:
 mov ax, b
 cmp ax, c
 jc Swap_5
Return_5:
 jmp End_sort

Swap_1:
 call Swap_c_d
 jmp Return_1

Swap_2:
 call Swap_b_c
 jmp Return_2

Swap_3:
 call Swap_a_b
 jmp Return_3

Swap_4:
 call Swap_c_d
 jmp Return_4

Swap_5:
 call Swap_b_c
 jmp Return_5

End_sort:
 ; multyply two greaters numbers and save to ax, finish the program
 mov ax, a
 mul b

 jmp Final

Equals:
 ; calculate a xor b and move to ax, finish the program
 mov ax, a
 xor ax, b

 jmp Final

Final:
; Write the result
 mov bx, ax
 lea dx, Result
 mov ah, 09h
 int 21h
 mov ax, bx

 call Write
 mov ah, 4Ch
 int 21h
end Start

; Если a ^ 2<> b ^ 3 то
;
;      Если  c * d = a / b то
;
;        Результат = a XOR b     Пример (2, 1, 1, 2  =>  3 (3h))
;
;     Иначе
;
;        Результат = найти 2 наибольших среди a,d,c,d и перемножить  Пример (1, 2, 3, 4  =>  12 (0Ch))
;
; Иначе
;
;       Результат = a * b + c/d   Пример (8, 4, 5, 2  =>  34 (22h))
