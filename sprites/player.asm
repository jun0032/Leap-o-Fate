include "game/game.inc"
include "joypad/joypad.inc"
include "sprites/sprites.inc"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

section "player", rom0

update_player:
    call spike_collision
    ; call sprite_collision

    ld a, [JOYPAD_CURRENT_ADDRESS]
    cp a, $FF
    jr nz, .move_player

    ; call check_door

    .move_player
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

        ; check if BTN_A is pressed
        ld a, [JOYPAD_CURRENT_ADDRESS]
        and PADF_A
        jr nz, .a_not_pressed

        ; check if UP is pressed
        ld a, [JOYPAD_CURRENT_ADDRESS]
        and PADF_UP
        jr nz, .up_not_pressed

        call move_up
        .up_not_pressed

        jr .no_gravity

        .a_not_pressed
            call gravity
        
        .no_gravity
    
    GetPlayerTileIndex 3, 3

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
        AddBetter [SPRITE_0_ADDRESS + OAMA_Y], -1
        AddBetter [ABSOLUTE_COORDINATE_Y], -1
        call player_move_animation

    .collision
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