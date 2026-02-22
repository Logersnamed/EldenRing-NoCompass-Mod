.data
extern returnAddress : qword
extern g_isAlone : byte

f_minus_10292       REAL4 -10292.0
f_minus_9885        REAL4 -9885.0
f_minus_8293_208984 REAL4 -8293.208984
f_minus_8763        REAL4 -8763.0
f_minus_8306        REAL4 -8306.0

.code
    IsFEqualToAny2 MACRO reg, offset, val1, val2, label_match
        movss   xmm0, dword ptr [reg + offset]
        movss   xmm1, dword ptr [val1]
        ucomiss xmm0, xmm1
        je      label_match
        movss   xmm1, dword ptr [val2]
        ucomiss xmm0, xmm1
    ENDM

    IsFEqualToAny3 MACRO reg, offset, val1, val2, val3, label_match
        movss   xmm0, dword ptr [reg + offset]

        movss   xmm1, dword ptr [val1]
        ucomiss xmm0, xmm1
        je      label_match

        movss   xmm1, dword ptr [val2]
        ucomiss xmm0, xmm1
        je      label_match

        movss   xmm1, dword ptr [val3]
        ucomiss xmm0, xmm1
    ENDM


    RemoveCompass proc
        movups    xmmword ptr [rbx+80h], xmm6
        movaps    xmm6, xmmword ptr [rsp+80h]

        ; If multiplayer => skip
        cmp     byte ptr [g_isAlone], 0
        je      _orig

        ; If xmm7 is already 0 => skip
        ptest     xmm7, xmm7
        jz        _orig

        IsFEqualToAny2 rbx, 64h, f_minus_10292, f_minus_9885, _check_second_value
        jne     _orig

    _check_second_value:
        IsFEqualToAny3 rbx, 6Ch, f_minus_8293_208984, f_minus_8763, f_minus_8306, _write_zero
        jne     _orig

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