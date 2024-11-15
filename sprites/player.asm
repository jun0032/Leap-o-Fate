include "game/game.inc"
include "joypad/joypad.inc"
include "sprites/sprites.inc"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

section "player", rom0

update_player:
    call update_player_current_tile

    ; check if RIGHT is pressed
    ld a, [JOYPAD_CURRENT_ADDRESS]
    and PADF_RIGHT
    jp nz, .right_not_pressed

    call move_right
    .right_not_pressed
    
    ; check if LEFT is pressed
    ld a, [JOYPAD_CURRENT_ADDRESS]
    and PADF_LEFT
    jp nz, .left_not_pressed
    
    call move_left
    .left_not_pressed

    ; JUMP [A] and RIGHT is pressed
    ld a, [JOYPAD_CURRENT_ADDRESS]
    and PADF_A | PADF_RIGHT
    jp nz, .jump_and_right_not_pressed
    
    call check_jump
    call move_right
    .jump_and_right_not_pressed

    ; JUMP [A] and LEFT is pressed
    ld a, [JOYPAD_CURRENT_ADDRESS]
    and PADF_A | PADF_LEFT
    jp nz, .jump_and_left_not_pressed
    
    call check_jump
    call move_left
    .jump_and_left_not_pressed

    ; check if JUMP [A] is pressed
    ld a, [JOYPAD_CURRENT_ADDRESS]
    and PADF_A
    jp nz, .jump_not_pressed
    
    call check_jump
    .jump_not_pressed

    call jump
    call b_button

    ; moving up/down will not be in the actual game
    call check_up
    call check_down

    .done
    ret

move_right:
    ; move sprite right if went from no hold to hold
    AddBetter [SPRITE_0_ADDRESS + OAMA_X], SPRITE_0_SPDX
    call player_move_animation

    ld a, [SPRITE_0_ADDRESS + OAMA_FLAGS]
    bit OAMB_XFLIP, a
    jp z, .dont_flip

    xor a, OAMF_XFLIP
    Copy [SPRITE_0_ADDRESS + OAMA_FLAGS], a

    .dont_flip
    ret

move_left:
    ; move sprite left if went from no hold to hold
    AddBetter [SPRITE_0_ADDRESS + OAMA_X], -SPRITE_0_SPDX
    call player_move_animation

    ; flip sprite in x-direction if sprite is facing opposite direction
    ld a, [SPRITE_0_ADDRESS + OAMA_FLAGS]
    bit OAMB_XFLIP, a
    jp nz, .dont_flip

    xor a, OAMF_XFLIP
    Copy [SPRITE_0_ADDRESS + OAMA_FLAGS], a

    .dont_flip
    ret

check_jump:
    ; check if currently jumping
    ld a, [JUMP_TOGGLE]
    cp a, $FF
    jp nz, .currently_jumping

    ; Initialize Jump Settings
    Copy [JUMP_TOGGLE], 0
    Copy [VERTICAL_VELOCITY], JUMP_VERTICAL_VELOCITY
    Copy [GROUND], [SPRITE_0_ADDRESS + OAMA_Y]

    .currently_jumping
    ret

jump:
    ; if not jumping skip
    ld a, [JUMP_TOGGLE]
    cp a, $FF
    jp z, .done

    ; check if done jumping
    ld a, [JUMP_TOGGLE]
    cp a, 0
    jp z, .start_jump

    Copy b, [GROUND]
    ld a, [SPRITE_0_ADDRESS + OAMA_Y]
    cp a, b
    jp z, .jump_cooldown

    .start_jump
        ; add character y-position with current vertical velocity
        Copy b, [VERTICAL_VELOCITY]
        AddBetter [SPRITE_0_ADDRESS + OAMA_Y], b

        ; decrease vertical velocity
        AddBetter [VERTICAL_VELOCITY], GRAVITY

    .jump_cooldown
        ; increment the jump counter
        ld a, [JUMP_TOGGLE]
        inc a
        ld [JUMP_TOGGLE], a

        ; reset jump counter if done waiting
        cp a, JUMP_COOLDOWN
        jp c, .done
        Copy [JUMP_TOGGLE], $FF

    .done
    ret

player_move_animation:
    ld a, [GAME_COUNTER]
    and SPRITE_0_FREQ
    jp nz, .done

    ld a, [SPRITE_0_ADDRESS + OAMA_TILEID]
    cp a, SPRITE_0_DEFAULT_ANIMATION
    jp z, .move_animate

    Copy [SPRITE_0_ADDRESS + OAMA_TILEID], SPRITE_0_DEFAULT_ANIMATION
    jp .done

    .move_animate
        Copy [SPRITE_0_ADDRESS + OAMA_TILEID], SPRITE_0_MOVE_ANIMATION

    .done
    ret

; temporary test for taking damage
; will implement into collision for next project
b_button:
    ; check if B_BUTTON is held
    ld a, [JOYPAD_CURRENT_ADDRESS]
    and PADF_B
    jp nz, .b_not_pressed

    ; damage cooldown
    ld a, [GAME_COUNTER]
    and DMG_CD
    jp nz, .b_not_pressed

    ; lose heart when B_BUTTON is held
    call lose_heart

    .b_not_pressed
    ret

update_player_current_tile:
    ; Divide absolute x coordinate by 8 to get player tilemap column
    ld a, [ABSOLUTE_COORDINATE_X]
    srl a
    srl a
    srl a
    ld b, a

    ; Divide absolute x coordinate by 8, multiply by 32 and add column to get tilemap index
    ; ld a, [ABSOLUTE_COORDINATE_Y]
    ; ld h, 0
    ; ld l, a

    ; srl hl
    ; sla hl
    ; sla hl
    ; sla hl

    ; ; make a hl
    ; add a, b

    ; ; subtract by 65 to correct for the tilemap pixel indexing top left corner starting at (8,16)
    ; sub a, 65

    ; ld [TOP_LEFT_PLAYER_TILE], a
    ; cp a, $6D
    ; jp nz, .done

    ; call lose_heart

    ; .done
    ret

; NOTE: moving up and down will not be in the actual game
check_up:
    ; UP is pressed
    ld a, [JOYPAD_CURRENT_ADDRESS]
    and PADF_UP
    jp nz, .up_not_pressed

    ; move sprite up if went from no hold to hold
    AddBetter [SPRITE_0_ADDRESS + OAMA_Y], -SPRITE_0_SPDX
    call player_move_animation

    .up_not_pressed
    ret

check_down:
    ; DOWN is pressed
    ld a, [JOYPAD_CURRENT_ADDRESS]
    and PADF_DOWN
    jp nz, .down_not_pressed

    ; move sprite down if went from no hold to hold
    AddBetter [SPRITE_0_ADDRESS + OAMA_Y], SPRITE_0_SPDX
    call player_move_animation

    .down_not_pressed
    ret

export update_player