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

    ; call jump
    call b_button

    ; moving up/down will not be in the actual game
    call check_up
    call check_down

    .done
    ret

update_player_current_tile:
    ld a, [SPRITE_0_ADDRESS + OAMA_FLAGS]
    bit OAMB_XFLIP, a
    jp z, .check_right

    ; check left side of player
    PlayerTileCorner 2, 3
    jp .done

    ; check right side of player
    .check_right
        PlayerTileCorner 4, 3

    .done

    ld a, [hl]
    ld [PLAYER_CURR_TILE], a
    call spike_collision

    ret

spike_collision:
    ; check if damage cooldown is off
    ld a, [DAMAGE_COOLDOWN]
    cp a, 0
    jp nz, .in_damage_cooldown

    ; check if the player's current tile is a spike
    ld a, [PLAYER_CURR_TILE]

    ; check if the tile index is below the range of the spikes' tile index
    cp a, TILEMAP_SPIKES_START
    jp c, .not_spike

    ; check if the tile index is above the range of the spikes' tile index
    cp a, TILEMAP_SPIKES_END + 1
    jp nc, .not_spike

    ; damage and reset damage cooldown
    call damage_player
    Copy [DAMAGE_COOLDOWN], DMG_CD
    jp .not_spike

    .in_damage_cooldown
        dec a
        ld [DAMAGE_COOLDOWN], a
        ; ld a, [SPRITE_0_ADDRESS + OAMA_FLAGS]
        ; xor OAMF_PAL1
        ; ld [SPRITE_0_ADDRESS + OAMA_FLAGS], a

    .not_spike
    ret

move_right:
    ; move sprite right if went from no hold to hold
    AddBetter [SPRITE_0_ADDRESS + OAMA_X], SPRITE_0_SPDX
    AddBetter [ABSOLUTE_COORDINATE_X], SPRITE_0_SPDX
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
    AddBetter [ABSOLUTE_COORDINATE_X], -SPRITE_0_SPDX
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
    ld a, [JOYPAD_PRESSED_ADDRESS]
    and PADF_B
    jp nz, .b_not_pressed

    ; lose heart when B_BUTTON is held
    call damage_player

    .b_not_pressed
    ret

; NOTE: moving up and down will not be in the actual game
check_up:
    ; UP is pressed
    ld a, [JOYPAD_CURRENT_ADDRESS]
    and PADF_UP
    jp nz, .up_not_pressed

    ; move sprite up if went from no hold to hold
    AddBetter [SPRITE_0_ADDRESS + OAMA_Y], -SPRITE_0_SPDX
    AddBetter [ABSOLUTE_COORDINATE_Y], -SPRITE_0_SPDX
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
    AddBetter [ABSOLUTE_COORDINATE_Y], SPRITE_0_SPDX
    call player_move_animation

    .down_not_pressed
    ret

export update_player