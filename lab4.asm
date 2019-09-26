model small
.stack 100h
.data
Prompt db 'Please enter the string: $'
Str1 db 100 dup('$')
Str2 db 100 dup('$')

.code

Interrupt proc
  mov ah, 4Ch
  int 21h
  ret
Interrupt endp


PrintPrompt proc
  lea dx, Prompt
  mov ah, 09h
  int 21h
  mov dl, 0Ah
  mov ah, 02h
  int 21h
  ret
PrintPrompt endp


PrintString proc
; Print a string from dx to console
  mov bx, dx

  mov dl, 0Ah
  mov ah, 02h
  int 21h

  mov dx, bx

  mov ah, 09h
  int 21h

  mov dl, 0Ah
  mov ah, 02h
  int 21h

  ret
PrintString endp


ReadString proc
; Read a string from console to di
CycleRead:
; Read a character
  mov ah, 01h
  int 21h

; Check for Enter
  cmp al, 0Dh
  jz EndCycle

; Save a character to the string
  stosb
  jmp CycleRead

EndCycle:
  mov al, '$'
  stosb
  ret
ReadString endp


IsVowel proc
; Determines if al is vowel. Returns the result in bx
  cmp al, 'a'
  jz ItIsVowel
  cmp al, 'e'
  jz ItIsVowel
  cmp al, 'i'
  jz ItIsVowel
  cmp al, 'o'
  jz ItIsVowel
  cmp al, 'u'
  jz ItIsVowel
  cmp al, 'y'
  jz ItIsVowel
  cmp al, 'A'
  jz ItIsVowel
  cmp al, 'E'
  jz ItIsVowel
  cmp al, 'I'
  jz ItIsVowel
  cmp al, 'O'
  jz ItIsVowel
  cmp al, 'U'
  jz ItIsVowel
  cmp al, 'Y'
  jz ItIsVowel

  mov bx, 0
  jmp EndVowel

ItIsVowel:
  mov bx, 1
EndVowel:
  ret
IsVowel endp


IsLetter proc
; Determines if al is a letter. Returns the result in bx
  cmp al, 'a'
  jc CheckBigLetter
  cmp al, '{'
  jnc ItIsNotLetter
  jmp ItIsLetter

CheckBigLetter:
  cmp al, 'A'
  jc ItIsNotLetter
  cmp al, '['
  jnc ItIsNotLetter
  jmp ItIsLetter

ItIsLetter:
  mov bx, 1
  jmp EndLetter

ItIsNotLetter:
  mov bx, 0
EndLetter:
  ret
IsLetter endp


DeleteVowels proc
; Deletes vowels from si and saves the result to di
CycleDeleteVowels:
  lodsb
  cmp al, '$'
  jz StopDeleteVowels

  call IsVowel
  cmp bx, 0
  jnz CycleDeleteVowels

  stosb
  jmp CycleDeleteVowels

StopDeleteVowels:
  stosb
  ret
DeleteVowels endp


ReverseWords proc
; Reverses words from si and saves the result to di
  mov cx, 0
ReverseCycle:
  lodsb
  call IsLetter
  cmp bx, 1
  jnz NotLetterBranch
  push ax
  inc cx
  jmp ReverseCycle

NotLetterBranch:
  cmp cx, 0
  jz CXZero
  mov dx, ax
CacheLoop:
  pop ax
  stosb
  loop CacheLoop
  mov ax, dx
CXZero:
  stosb
  cmp al, '$'
  jz ReturnReverse
  jmp ReverseCycle

ReturnReverse:
  ret
ReverseWords endp


start:
  mov ax, @data
  mov ds, ax
  mov es, ax
  cld

  lea di, Str1
  call PrintPrompt
  call ReadString

  lea si, Str1
  lea di, Str2
  call ReverseWords

  lea dx, Str2
  call PrintString

  lea si, Str2
  lea di, Str1
  call DeleteVowels

  lea dx, Str1
  call PrintString

  call Interrupt
end start
