include "joypad/joypad.inc"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

section "joypad", rom0

init_joypad:
    Copy [JOYPAD_CURRENT_ADDRESS], $FF
    Copy [JOYPAD_PREVIOUS_ADDRESS], $FF
    Copy [JOYPAD_PRESSED_ADDRESS], $FF
    Copy [JOYPAD_RELEASED_ADDRESS], $FF
    ret

update_joypad:
    ; load previous joypad into (c)
    ld a, [JOYPAD_CURRENT_ADDRESS]
    ld [JOYPAD_PREVIOUS_ADDRESS], a
    ld c, a

    ; set button selector
    ld a, P1F_GET_BTN
    ld [rP1], a

    ; wait
    ld a, [rP1]
    ld a, [rP1]
    ld a, [rP1]
    ld a, [rP1]
    ld a, [rP1]

    ; read button poll result
    ld a, [rP1]

    ; save button result in (b)
    and $0F
    ld b, a

    ; set dpad selector
    ld a, P1F_GET_DPAD
    ld [rP1], a

    ; wait
    ld a, [rP1]

    ; read dpad poll result
    ld a, [rP1]

    ; move dpad result and load button result into (a)
    and $0F
    swap a
    or a, b

    ; store in our custom joypad byte
    ; (b) contains current joypad byte
    ld [JOYPAD_CURRENT_ADDRESS], a
    ld b, a

    ; update pressed
    ; for each bit: if 1 before, 0 now then it was pressed, set to 0
    ld a, c
    cpl
    or b
    
    ; now any that were previously held or are currently not held are 1s
    ; and all presses are 0s
    ld [JOYPAD_PRESSED_ADDRESS], a

    ; update released
    ; for each bit, if 0 before, and 1 now, then it was released
    ld a, b
    cpl 
    or c

    ; now any that were previously not held and are currently held are 1's
    ; and all releases are 0's
    ld [JOYPAD_RELEASED_ADDRESS], a

    ld a, P1F_GET_NONE
    ld [rP1], a
    ret

export init_joypad, update_joypad