.data
extern returnAddress : qword
extern base : qword

MIN_VALID dq 10000h
MAX_VALID dq 07FFFFFFFFFFFh

.code

; Jump to _orig if pointer isn't in valid range
CheckPtr MACRO reg
    cmp       reg, MIN_VALID
    jb        _orig
    cmp       reg, MAX_VALID
    ja        _orig
ENDM

AddOffset MACRO reg, offset
    mov       reg, qword ptr [reg + offset]
    CheckPtr  reg
ENDM

RemoveCompass proc
    movups    xmmword ptr [rbx+80h], xmm6
    movaps    xmm6, xmmword ptr [rsp+80h]

    ; Calculate compass pointer = base + 3B42FB8 + 40 + 30 + 88 + D8 + 110 + D8 + 30 + 48 + 70 + 90
    mov       rax, qword ptr [base]
    add       rax, 3B42FB8h

    mov       rax, qword ptr [rax]
    CheckPtr  rax

    AddOffset rax, 40h
    AddOffset rax, 30h
    AddOffset rax, 88h
    AddOffset rax, 0D8h
    AddOffset rax, 110h
    AddOffset rax, 0D8h
    AddOffset rax, 30h
    AddOffset rax, 48h
    AddOffset rax, 70h

    lea       rdx, [rax+90h]
    CheckPtr  rdx

    ; Check if rbx+90 is a compass pointer 
    lea       rcx, [rbx+90h]
    cmp       rcx, rdx
    jne       _orig

_write_zero:
    xorps     xmm0, xmm0
    movsd     qword ptr [rbx+90h], xmm0
    jmp       _end

_orig:
    movsd     qword ptr [rbx+90h], xmm7

_end:
    movaps    xmm7, xmmword ptr [rsp+70h]
    lea       r11, [rsp+90h]
    jmp       qword ptr [returnAddress]
RemoveCompass endp
end