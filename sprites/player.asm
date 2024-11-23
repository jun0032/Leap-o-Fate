; CS-240 Project 5: Final Game Draft
; @file player.asm
; @author Pan Pov and Jun Seo
; @date November 20, 2024

include "game/game.inc"
include "joypad/joypad.inc"
include "sprites/sprites.inc"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

section "player", rom0

update_player:
    call check_damage

    ; check if [B] is pressed
    ld a, [JOYPAD_PRESSED_ADDRESS]
    and PADF_B
    jr nz, .b_not_pressed

    call check_door
    .b_not_pressed

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

    ; check if player has mana points
    ld a, [MANA_POINTS]
    cp a, 0
    jr z, .a_not_pressed

    ; if player is on ladder, don't use mana
    ld a, [PLAYER_CURR_TILE]
    cp a, LADDER_TILE_INDEX
    jr z, .climb_ladder

    call use_mana
    .climb_ladder

    ; check if UP is pressed
    ld a, [JOYPAD_CURRENT_ADDRESS]
    and PADF_UP
    jr nz, .up_not_pressed

    call move_up
    .up_not_pressed

    ; no gravity and mana regen while hovering
    jr .no_gravity

    .a_not_pressed
        call gravity
        call regen_mana
        
    .no_gravity

    ; if player on ladder, regen mana
    ld a, [PLAYER_CURR_TILE]
    cp a, LADDER_TILE_INDEX
    jr nz, .no_ladder_mana_regen

    call regen_mana
    .no_ladder_mana_regen

    call mana_cooldown
    
    ; get center of player
    GetPlayerTileIndex PLAYER_CENTER_X, PLAYER_CENTER_Y

    .done
    ret

gravity:
    ; check bottom-side collision
    CheckCollisionDirection UD_LEFT_HITBOX, UD_BOTTOM_HITBOX, UD_RIGHT_HITBOX, UD_BOTTOM_HITBOX

    .no_collision
        ; move sprite up if went from no hold to hold
        AddBetter [SPRITE_0_ADDRESS + OAMA_Y], GRAVITY_SPD_Y
        AddBetter [ABSOLUTE_COORDINATE_Y], GRAVITY_SPD_Y
        call player_move_animation

    .collision
    ret

check_damage:
    ; check if damage cooldown is off
    ld a, [DAMAGE_COOLDOWN]
    cp a, 0
    jr nz, .in_damage_cooldown

    ; check spike collision -> sets z flag when damaged
    call spike_collision
    jr z, .collision_checked

    ; check player collision with enemy sprites
    call sprite_collision
    jr .collision_checked

    ; decrease damage cooldown and make player blink
    .in_damage_cooldown
        dec a
        ld [DAMAGE_COOLDOWN], a
        ld a, [SPRITE_0_ADDRESS + OAMA_FLAGS]
        xor OAMF_PAL1
        ld [SPRITE_0_ADDRESS + OAMA_FLAGS], a

    .collision_checked
    ret

spike_collision:
    ld a, [PLAYER_CURR_TILE]

    ; check if the tile index is below the range of the spikes' tile index
    cp a, TILEMAP_SPIKES_START
    jr c, .not_spike

    ; check if the tile index is above the range of the spikes' tile index
    cp a, TILEMAP_SPIKES_END + 1
    jr nc, .not_spike

    ; damage and reset damage cooldown
    call damage_player
    Copy [DAMAGE_COOLDOWN], DMG_CD
    xor a

    .not_spike
    ret

sprite_collision:
    ; get player's center
    ld a, [SPRITE_0_ADDRESS + OAMA_X]
    add a, PLAYER_CENTER_X
    ld b, a
    ld a, [SPRITE_0_ADDRESS + OAMA_Y]
    add a, PLAYER_CENTER_Y
    ld c, a
    ld d, b
    ld e, c

    ; check collision w/ sprite 1 (bat) against player's center
    CheckEnemySpriteCollision [SPRITE_1_ADDRESS + OAMA_X], [SPRITE_1_ADDRESS + OAMA_Y]
    
    ; get player's center
    ld b, d
    ld c, e

    ; check collision w/ sprite 2 (dinosaur) against player's center
    CheckEnemySpriteCollision [SPRITE_2_ADDRESS + OAMA_X], [SPRITE_2_ADDRESS + OAMA_Y]

    .collision_checked
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
        CheckCollisionDirection LR_RIGHT_HITBOX, LR_TOP_HITBOX, LR_RIGHT_HITBOX, LR_BOTTOM_HITBOX

    .no_collision
        ; move sprite right if RIGHT is held
        AddBetter [SPRITE_0_ADDRESS + OAMA_X], SPRITE_0_SPDX
        AddBetter [ABSOLUTE_COORDINATE_X], SPRITE_0_SPDX
        call player_move_animation

    .collision
    .right_not_pressed
    ret

move_left:
    ; flip sprite in x-direction if sprite is facing opposite direction
    ld a, [SPRITE_0_ADDRESS + OAMA_FLAGS]
    bit OAMB_XFLIP, a
    jr nz, .dont_flip

    xor a, OAMF_XFLIP
    ld [SPRITE_0_ADDRESS + OAMA_FLAGS], a

    .dont_flip
        ; check left-side collision
        CheckCollisionDirection LR_LEFT_HITBOX, LR_TOP_HITBOX, LR_LEFT_HITBOX, LR_BOTTOM_HITBOX

    .no_collision
        ; move sprite left if LEFT is held
        AddBetter [SPRITE_0_ADDRESS + OAMA_X], -SPRITE_0_SPDX
        AddBetter [ABSOLUTE_COORDINATE_X], -SPRITE_0_SPDX
        call player_move_animation

    .collision
    .left_not_pressed
    ret

move_up:
    ; check top-side collision
    CheckCollisionDirection UD_LEFT_HITBOX, UD_TOP_HITBOX, UD_RIGHT_HITBOX, UD_TOP_HITBOX
    
    .no_collision
        ; move sprite up if UP is held
        AddBetter [SPRITE_0_ADDRESS + OAMA_Y], SPRITE_0_UP_SPD
        AddBetter [ABSOLUTE_COORDINATE_Y], SPRITE_0_UP_SPD
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

export update_player