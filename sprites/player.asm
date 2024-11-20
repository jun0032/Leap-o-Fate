include "game/game.inc"
include "joypad/joypad.inc"
include "sprites/sprites.inc"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

section "player", rom0

update_player:
    call spike_collision
    call sprite_collision

    ; check if RIGHT is pressed
    ld a, [JOYPAD_CURRENT_ADDRESS]
    and PADF_RIGHT
    jr nz, .right_not_pressed

    call move_right
    .right_not_pressed
    
    ; check if LEFT is pressed
    ld a, [JOYPAD_CURRENT_ADDRESS]
    and PADF_LEFT
    jr nz, .left_not_pressed
    
    call move_left
    .left_not_pressed

    ; check if UP is pressed
    ld a, [JOYPAD_CURRENT_ADDRESS]
    and PADF_UP
    jr nz, .up_not_pressed

    call move_up
    .up_not_pressed

    ; check if DOWN is pressed
    ld a, [JOYPAD_CURRENT_ADDRESS]
    and PADF_DOWN
    jr nz, .down_not_pressed

    call move_down
    .down_not_pressed

    call gravity
    
    GetPlayerTileIndex 3, 3


    ; ; JUMP [A] and RIGHT is pressed
    ; ld a, [JOYPAD_CURRENT_ADDRESS]
    ; and PADF_A | PADF_RIGHT
    ; jr nz, .jump_and_right_not_pressed
    
    ; call check_jump
    ; call move_right
    ; .jump_and_right_not_pressed

    ; ; JUMP [A] and LEFT is pressed
    ; ld a, [JOYPAD_CURRENT_ADDRESS]
    ; and PADF_A | PADF_LEFT
    ; jr nz, .jump_and_left_not_pressed
    
    ; call check_jump
    ; call move_left
    ; .jump_and_left_not_pressed

    ; ; check if JUMP [A] is pressed
    ; ld a, [JOYPAD_CURRENT_ADDRESS]
    ; and PADF_A
    ; jr nz, .jump_not_pressed
    
    ; call check_jump
    ; .jump_not_pressed

    ; call jump
    ; call b_button
    .done
    ret

gravity:
    ; check bottom-side collision
    CheckCollisionDirection 2, 8, 5, 8

    .no_collision
        ; move sprite up if went from no hold to hold
        AddBetter [SPRITE_0_ADDRESS + OAMA_Y], 1
        AddBetter [ABSOLUTE_COORDINATE_Y], 1
        call player_move_animation

    .collision

    ret

spike_collision:
    push af
    ; check if damage cooldown is off
    ld a, [DAMAGE_COOLDOWN]
    cp a, 0
    jr nz, .in_damage_cooldown

    ; [hl] is the address of the current tile in consideration
    ld a, [hl]

    ; check if the tile index is below the range of the spikes' tile index
    cp a, TILEMAP_SPIKES_START
    jr c, .not_spike

    ; check if the tile index is above the range of the spikes' tile index
    cp a, TILEMAP_SPIKES_END + 1
    jr nc, .not_spike

    ; damage and reset damage cooldown
    call damage_player
    Copy [DAMAGE_COOLDOWN], DMG_CD
    jr .not_spike

    .in_damage_cooldown
        dec a
        ld [DAMAGE_COOLDOWN], a
        ld a, [SPRITE_0_ADDRESS + OAMA_FLAGS]
        xor OAMF_PAL1
        ld [SPRITE_0_ADDRESS + OAMA_FLAGS], a

    .not_spike
    pop af
    ret

sprite_collision:
    ret

move_right:
    ; flip sprite in x-direction if sprite is facing opposite direction
    ld a, [SPRITE_0_ADDRESS + OAMA_FLAGS]
    bit OAMB_XFLIP, a
    jr z, .dont_flip

    xor a, OAMF_XFLIP
    ld [SPRITE_0_ADDRESS + OAMA_FLAGS], a
    
    .dont_flip
        ; check right-side collision
        CheckCollisionDirection 6, 2, 6, 7

    .no_collision
        ; move sprite right if went from no hold to hold
        AddBetter [SPRITE_0_ADDRESS + OAMA_X], SPRITE_0_SPDX
        AddBetter [ABSOLUTE_COORDINATE_X], SPRITE_0_SPDX
        call player_move_animation

    .collision
    ret

move_left:
    ld a, [SPRITE_0_ADDRESS + OAMA_FLAGS]
    bit OAMB_XFLIP, a
    jr nz, .dont_flip

    xor a, OAMF_XFLIP
    ld [SPRITE_0_ADDRESS + OAMA_FLAGS], a

    .dont_flip
        ; check left-side collision
        CheckCollisionDirection 1, 2, 1, 7

    .no_collision
        ; move sprite left if went from no hold to hold
        AddBetter [SPRITE_0_ADDRESS + OAMA_X], -SPRITE_0_SPDX
        AddBetter [ABSOLUTE_COORDINATE_X], -SPRITE_0_SPDX
        call player_move_animation

    .collision
    ret

move_up:
    ; check top-side collision
    CheckCollisionDirection 2, 0, 5, 0

    .no_collision
        ; move sprite up if went from no hold to hold
        AddBetter [SPRITE_0_ADDRESS + OAMA_Y], -2
        AddBetter [ABSOLUTE_COORDINATE_Y], -2
        call player_move_animation

    .collision
    ret

move_down:
    ; check bottom-side collision
    CheckCollisionDirection 2, 8, 5, 8

    .no_collision
        ; move sprite up if went from no hold to hold
        AddBetter [SPRITE_0_ADDRESS + OAMA_Y], SPRITE_0_SPDX
        AddBetter [ABSOLUTE_COORDINATE_Y], SPRITE_0_SPDX
        call player_move_animation

    .collision
    ret

check_jump:
    ; check if currently jumping
    ld a, [JUMP_TOGGLE]
    cp a, $FF
    jr nz, .currently_jumping

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
    jr z, .done

    ; check if done jumping
    ld a, [JUMP_TOGGLE]
    cp a, 0
    jr z, .start_jump

    Copy b, [GROUND]
    ld a, [SPRITE_0_ADDRESS + OAMA_Y]
    cp a, b
    jr z, .jump_cooldown

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
        jr c, .done
        Copy [JUMP_TOGGLE], $FF

    .done
    ret

player_move_animation:
    ld a, [GAME_COUNTER]
    and SPRITE_0_FREQ
    jr nz, .done

    ld a, [SPRITE_0_ADDRESS + OAMA_TILEID]
    cp a, SPRITE_0_DEFAULT_ANIMATION
    jr z, .move_animate

    Copy [SPRITE_0_ADDRESS + OAMA_TILEID], SPRITE_0_DEFAULT_ANIMATION
    jr .done

    .move_animate
        Copy [SPRITE_0_ADDRESS + OAMA_TILEID], SPRITE_0_MOVE_ANIMATION

    .done
    ret

; temporary test for taking damage
; will implement into collision for next project
b_button:
    ; check if B_BUTTON is held
    ld a, [JOYPAD_PRESSED_ADDRESS]
    and PADF_B
    jr nz, .b_not_pressed

    ; lose heart when B_BUTTON is held
    call damage_player

    .b_not_pressed
    ret

export update_player