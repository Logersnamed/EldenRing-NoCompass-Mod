.data
extern returnAddress : qword
extern refreshRate   : qword
extern base          : qword

MIN_VALID          dq 10000h
MAX_VALID          dq 07FFFFFFFFFFFh

removeCompassCalls dq 0
compassPtrCached   dq 0

.code
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

        ; If xmm7 is already 0 => skip
        ptest     xmm7, xmm7
        jz        _orig

        ; Check if need recalc this call
        mov       rcx, qword ptr [removeCompassCalls]
        mov       rdx, qword ptr [refreshRate]

        inc       rcx
        cmp       rcx, rdx
        jb        _use_cached

        xor       rcx, rcx     ; set removeCompassCalls to 0
        mov       qword ptr [removeCompassCalls], rcx
        jmp       _recalc

    _use_cached:
        mov       qword ptr [removeCompassCalls], rcx
        mov       rdx, qword ptr [compassPtrCached]
        CheckPtr  rdx
        jmp       _compare_ptr

    ; Calculate compass pointer = base + 3B42FB8 + 40 + 30 + 88 + D8 + 110 + D8 + 30 + 48 + 70 + 90
    _recalc:
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

        ; Cache compass pointer
        mov       qword ptr [compassPtrCached], rdx

    ; If rbx+90 is not a compass pointer => skip
    _compare_ptr:
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