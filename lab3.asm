model small
.stack 100h
.data
a dw ?
b dw ?
c dw ?
d dw ?
ae dw ?
be dw ?
ce dw ?
de dw ?
b_cube dw ?
Digits dw 0
Incorrect db 'The input is invalid. Please try again$'
Result db 'The result is $'
Prompt db 'Enter a, b, c, d; each in a new line:$'
OverflowString db 'Error. The result is out of bounds.$'
DivisionByZero db 'Error. Division by zero.$'
.code


Interrupt proc
 mov ah, 4Ch
 int 21h
 ret
Interrupt endp


HandleOverflow proc
; Overflow Error message
 lea dx, OverflowString
 mov ah, 09h
 int 21h
 mov dl, 0Ah
 mov ah, 02h
 int 21h
 call Interrupt
HandleOverflow endp


HandleDivisionByZero proc
; Division by zero Error message
 lea dx, DivisionByZero
 mov ah, 09h
 int 21h
 mov dl, 0Ah
 mov ah, 02h
 int 21h
 call Interrupt
 ret
HandleDivisionByZero endp


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
 cmp al, 3Ah
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


ReadSigned proc
 mov ae, ax
 mov ce, cx
 mov de, dx
; Read a signed number to bx
RetrySigned:
; Set bx to 0
 xor bx, bx
 xor si, si

CycleReadSigned:
; Read a character
 mov ah, 01h
 int 21h

; Check for Enter
 cmp al, 0Dh
 jz EndCycleSigned

; If symbol is -, si == 0 and bx == 0, then si := 1
 cmp al, '-'
 jnz SkipSigned
 cmp si, 0
 jnz SkipSigned
 cmp bx, 0
 jnz SkipSigned
 mov si, 1
 jmp CycleReadSigned
SkipSigned:

; Check for bad characters
 cmp al, '0'
 jc BadCharSigned
 cmp al, 3Ah
 jnc BadCharSigned

; Convert caracter to the number and add to the result
 xor cx, cx
 mov cl, al
 sub cx, '0'
 mov ax, bx
 mov dx, 10
 imul dx
 jo BadCharSigned
 add ax, cx
 jo BadCharSigned
 mov bx, ax
 jmp CycleReadSigned

; Write a warning about incorrect input
BadCharSigned:
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
 jmp RetrySigned

EndCycleSigned:
; If si == 1, bx := -bx
 cmp si, 1
 jnz ReturnSigned
 neg bx
ReturnSigned:
 mov ax, ae
 mov cx, ce
 mov dx, de
 ret
ReadSigned endp



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


WriteSigned proc
; Write a signed number from ax to console
 mov ae, ax
 mov be, bx
 mov ce, cx
 mov de, dx
; If the number is negative, print - and take the absolute value
 test ax, 1000000000000000b
 jz Positive
 mov bx, ax
 xor dx, dx
 mov dl, '-'
 mov ah, 02h
 int 21h
 mov ax, bx
 neg ax

Positive:
 call Write
 mov ax, ae
 mov bx, be
 mov cx, ce
 mov dx, de
 ret
WriteSigned endp


PrintPrompt proc
  lea dx, Prompt
  mov ah, 09h
  int 21h
  mov dl, 0Ah
  mov ah, 02h
  int 21h
  ret
PrintPrompt endp


PrintResult proc
; Print ax after Result contents
 mov bx, ax
 lea dx, Result
 mov ah, 09h
 int 21h
 mov ax, bx

 call WriteSigned
 ret
PrintResult endp


Read_abcd proc
 call ReadSigned
 mov a, bx

 call ReadSigned
 mov b, bx

 call ReadSigned
 mov c, bx

 call ReadSigned
 mov d, bx

 ret
Read_abcd endp


Power proc
; ax := bx^cx
 mov ax, 1
 cmp cx, 0
 jz PowerEnd

PowerLoop:
 imul bx
 jo PowerOverflow
 loop PowerLoop

 jmp PowerEnd

PowerOverflow:
 call HandleOverflow

PowerEnd:
 ret
Power endp


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


Sort_abcd proc
; choose two biggest from a, b, c, d (bubble sort until a and b contain biggest numbers)
 mov ax, c
 cmp ax, d
 js Swap_1
Return_1:
 mov ax, b
 cmp ax, c
 js Swap_2
Return_2:
 mov ax, a
 cmp ax, b
 js Swap_3
Return_3:
 mov ax, c
 cmp ax, d
 js Swap_4
Return_4:
 mov ax, b
 cmp ax, c
 js Swap_5
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
 ret
Sort_abcd endp


Start:
 mov ax, @data
 mov ds, ax

; Read the variables
 call PrintPrompt
 call Read_abcd

; calculate b^3 and move to b_cube
 mov bx, b
 mov cx, 3
 call Power
 mov b_cube, ax

; calculate a^2 and move to ax
 mov bx, a
 mov cx, 2
 call Power

; if a^2 <> b^3 jump to Cond2
 cmp ax, b_cube
 jnz Cond2

; else res = a*b + c/d
; calculate a*b and save to bx
 mov ax, a
 imul b
 jo Overflow
 mov bx, ax

; calculate c/d and save to ax
 mov ax, c
 mov dx, d
 cmp dx, 0
 jz DivByZero
 cwd
 idiv d

; calculate a*b + c/d and save to ax, finish the program
 add ax, bx
 jo Overflow

 jmp Final

Cond2:
; calculate c*d and save to bx
 mov ax, c
 imul d
 jo Overflow
 mov bx, ax

; calculate a/b and save to ax
 mov ax, a
 mov dx, b
 cmp dx, 0
 jz DivByZero
 cwd
 idiv b

; if c*d == a/b jump to Equals
 cmp ax, bx
 jz Equals

; else choose two biggest from a, b, c, d and multiply
 call Sort_abcd
 ; multyply two greaters numbers and save to ax, finish the program
 mov ax, a
 imul b
 jo Overflow

 jmp Final

Equals:
 ; calculate a xor b and move to ax, finish the program
 mov ax, a
 xor ax, b

 jmp Final

Final:
 call PrintResult
 call Interrupt

Overflow:
 call HandleOverflow

DivByZero:
 call HandleDivisionByZero

end Start


; Если a ^ 2<> b ^ 3 то
;
;      Если  c * d = a / b то
;
;        Результат = a XOR b     Пример (2, 1, 1, 2  =>  3 (3h)), (2, -1, 1, -2 => -3)
;
;     Иначе
;
;        Результат = найти 2 наибольших среди a,d,c,d и перемножить  Пример (1, 2, 3, 4  =>  12 (0Ch)), (-2, -3, 4, -5 => -8)
;
; Иначе
;
;       Результат = a * b + c/d   Пример (8, 4, 5, 2  =>  34 (22h)), (-8, 4, -2, -1 => -30)
