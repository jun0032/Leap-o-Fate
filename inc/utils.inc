if !def(UTILS_RGBINC)
def UTILS_RGBINC equ 1

include "inc/hardware.inc"

def INVERT_BITS                     equ ($FF)

; copy \2 into \1 through (a)
; example: copy [$FF84], 10
macro Copy
    ld a, \2
    ld \1, a
endm

; adds \2 to \1, (a) is now \2
; example: add_better [$FF84], c
macro AddBetter
    ld a, \1
    add a, \2
    ld \1, a
endm

; inverts the bits of \1
macro Invert
    ld a, \1
    xor INVERT_BITS
endm

endc

