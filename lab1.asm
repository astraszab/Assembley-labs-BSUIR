model small
.stack 100h
.data
a dw 8
b dw 4
c dw 5
d dw 2

.code

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
