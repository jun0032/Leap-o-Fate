include "game/game.inc"
include "joypad/joypad.inc"
include "sprites/sprites.inc"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

section "sprites", rom0

init_sprites:
    ; initialize the player
    Copy [SPRITE_0_ADDRESS + OAMA_X], 0
    Copy [SPRITE_0_ADDRESS + OAMA_Y], 0
    Copy [SPRITE_0_ADDRESS + OAMA_TILEID], SPRITE_0_DEFAULT_ANIMATION
    Copy [SPRITE_0_ADDRESS + OAMA_FLAGS], OAMF_PAL0
    Copy [GROUND], SPRITE_0_INIT_Y
    Copy [JUMP_TOGGLE], $FF
    Copy [VERTICAL_VELOCITY], 0

    ; set the second sprite
    Copy [SPRITE_1_ADDRESS + OAMA_Y], 0
    Copy [SPRITE_1_ADDRESS + OAMA_X], 0
    Copy [SPRITE_1_ADDRESS + OAMA_TILEID], SPRITE_1_DEFAULT_ANIMATION
    Copy [SPRITE_1_ADDRESS + OAMA_FLAGS], OAMF_PAL0

    ; set the second sprite
    Copy [SPRITE_2_ADDRESS + OAMA_Y], 0
    Copy [SPRITE_2_ADDRESS + OAMA_X], 0
    Copy [SPRITE_2_ADDRESS + OAMA_TILEID], SPRITE_2_DEFAULT_ANIMATION
    Copy [SPRITE_2_ADDRESS + OAMA_FLAGS], OAMF_PAL0
    ret

init_sprites_pos:
    Copy [SPRITE_0_ADDRESS + OAMA_X], SPRITE_0_INIT_X
    Copy [SPRITE_0_ADDRESS + OAMA_Y], SPRITE_0_INIT_Y

    Copy [SPRITE_1_ADDRESS + OAMA_X], SPRITE_1_INIT_X
    Copy [SPRITE_1_ADDRESS + OAMA_Y], SPRITE_1_INIT_Y

    Copy [SPRITE_2_ADDRESS + OAMA_X], SPRITE_2_INIT_X
    Copy [SPRITE_2_ADDRESS + OAMA_Y], SPRITE_2_INIT_Y
    ret

update_sprites:
    call update_player
    call update_npcs
    ret

update_npcs:
    call sprite_1_ai
    call sprite_2_ai
    ret

sprite_1_ai:
    ; check direction it is moving in
    ld a, [SPRITE_1_ADDRESS + OAMA_FLAGS]
    bit OAMB_XFLIP, a
    jp nz, .move_left
    
    ; move until x = right roaming endpoint
    .move_right
        Copy b, [rSCX]
        ld a, [SPRITE_1_ADDRESS + OAMA_X]
        add a, b
        ld b, SPRITE_1_END_X
        cp a, b
        jp nc, .swap_direction

    AddBetter [SPRITE_1_ADDRESS + OAMA_X], SPRITE_1_SPDX
    jp .move_done
    
    ; move until x = left roaming endpoint
    .move_left
        Copy b, [rSCX]
        ld a, [SPRITE_1_ADDRESS + OAMA_X]
        add a, b
        ld b, SPRITE_1_INIT_X
        cp a, b
        jp c, .swap_direction

    AddBetter [SPRITE_1_ADDRESS + OAMA_X], -SPRITE_1_SPDX
    jp .move_done

    .swap_direction
        ld a, [SPRITE_1_ADDRESS + OAMA_FLAGS]
        xor OAMF_XFLIP
        ld [SPRITE_1_ADDRESS + OAMA_FLAGS], a

    .move_done

    ; walking animation
    ld a, [GAME_COUNTER]
    and SPRITE_1_FREQ
    jp nz, .animate_done

    ld a, [SPRITE_1_ADDRESS + OAMA_TILEID]
    cp a, SPRITE_1_DEFAULT_ANIMATION
    jp z, .animate

    Copy [SPRITE_1_ADDRESS + OAMA_TILEID], SPRITE_1_DEFAULT_ANIMATION
    jp .animate_done

    .animate
        Copy [SPRITE_1_ADDRESS + OAMA_TILEID], SPRITE_1_MOVE_ANIMATION

    .animate_done
    ret

sprite_2_ai:
    ; walking animation
    ld a, [GAME_COUNTER]
    and SPRITE_2_FREQ
    jp nz, .animate_done
    
    ; check direction it is moving in
    ld a, [SPRITE_2_ADDRESS + OAMA_FLAGS]
    bit OAMB_XFLIP, a
    jp nz, .move_left
    
    ; move until x = right roaming endpoint
    .move_right
        Copy b, [rSCX]
        ld a, [SPRITE_2_ADDRESS + OAMA_X]
        add a, b
        ld b, SPRITE_2_END_X
        cp a, b
        jp nc, .swap_direction

    AddBetter [SPRITE_2_ADDRESS + OAMA_X], SPRITE_2_SPDX
    jp .move_done
    
    ; move until x = left roaming endpoint
    .move_left
        Copy b, [rSCX]
        ld a, [SPRITE_2_ADDRESS + OAMA_X]
        add a, b
        ld b, SPRITE_2_INIT_X
        cp a, b
        jp c, .swap_direction

    AddBetter [SPRITE_2_ADDRESS + OAMA_X], -SPRITE_2_SPDX
    jp .move_done

    .swap_direction
        ld a, [SPRITE_2_ADDRESS + OAMA_FLAGS]
        xor OAMF_XFLIP
        ld [SPRITE_2_ADDRESS + OAMA_FLAGS], a

    .move_done

    ld a, [SPRITE_2_ADDRESS + OAMA_TILEID]
    cp a, SPRITE_2_DEFAULT_ANIMATION
    jp z, .animate

    Copy [SPRITE_2_ADDRESS + OAMA_TILEID], SPRITE_2_DEFAULT_ANIMATION
    jp .animate_done

    .animate
        Copy [SPRITE_2_ADDRESS + OAMA_TILEID], SPRITE_2_MOVE_ANIMATION

    .animate_done
    ret

export init_sprites, init_sprites_pos, update_sprites
