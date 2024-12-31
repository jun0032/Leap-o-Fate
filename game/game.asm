; CS-240 Project 5: Final Game
; @file game.asm
; @author Pan Pov and Jun Seo
; @date November 20, 2024

include "game/game.inc"
include "joypad/joypad.inc"
include "graphics/graphics.inc"
include "sprites/sprites.inc"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

section "game", rom0

init_game_states:
    Copy [GAME_COUNTER], 0
    Copy [GAME_STATE], $FF
    Copy [DAMAGE_COOLDOWN], 0
    Copy [MANA_USE_COOLDOWN], 0
    Copy [MANA_REGEN], MANA_REGEN_CD
    ret

check_start:
    ; check if game is on start screen
    ld a, [GAME_STATE]
    bit GAMEB_START_SCREEN, a
    jr z, .done

    ; check if game is starting
    bit GAMEB_STARTING, a
    jr z, .start

    ; check if start button is pressed
    ld a, [JOYPAD_PRESSED_ADDRESS]
    and PADF_START
    jr nz, .done

    ; toggle game starting if start button is pressed
    ld a, [GAME_STATE]
    xor GAMEF_STARTING
    ld [GAME_STATE], a

    .start
        call start

    .done
    ret

start:
    ; pull window down
    AddBetter [rWY], START_PULL_DOWN_SPEED

    ; initalize sprite positions and reset lives when window is pulled all the way down
    cp a, WINDOW_GAME_Y
    jr c, .continue_pulling

    ; set game start screen on, game starting off
    ld a, [GAME_STATE]
    xor GAMEF_START_SCREEN
    xor GAMEF_STARTING
    ld [GAME_STATE], a

    ; set initial sprite positions
    call init_sprites_pos
    Copy [HEART_COUNT], MAX_HEARTS
    Copy [MANA_POINTS], MAX_MANA_POINTS
    
    ; load next level window
    DisableLCD
    UpdateTilemap NEXT_LEVEL_WINDOW, _SCRN1
    EnableLCD
    halt
    
    .continue_pulling
    ret

damage_player:
    ; get location index of one tile left of heart and current heart count
    ld hl, HEART_LOCATION_ADDRESS 
    ld a, [HEART_COUNT]

    ; get location index of the heart to erase
    .find_curr_heart
        inc hl
        dec a
        jr nz, .find_curr_heart

    ; break the heart
    ld a, BROKEN_HEART_TILE_INDEX
    ld [hl], a

    ; decrement heart count and check if game is over
    ld a, [HEART_COUNT]
    dec a
    jr nz, .not_game_over

    call game_over
    .not_game_over
        ld [HEART_COUNT], a
    ret

use_mana:
    ; if mana use is on cooldown, skip
    ld a, [MANA_USE_COOLDOWN]
    cp a, 0
    jr nz, .no_use
    
    ; get tile left of first mana point in window
    ld hl, MANA_LOCATION_ADDRESS
    ld a, [MANA_POINTS]

    .find_curr_point
        inc hl
        dec a
        jr nz, .find_curr_point
    
    ; delete the point
    ld a, BLANK_TILE_INDEX
    ld [hl], a

    ; decrease mana points and put mana use on cooldown
    ld a, [MANA_POINTS]
    dec a
    ld [MANA_POINTS], a
    Copy [MANA_USE_COOLDOWN], MANA_USE_COOLDOWN_TIME

    .no_use
    ret

mana_cooldown:
    ; only decrease cooldown if on cooldown
    ld a, [MANA_USE_COOLDOWN]
    cp a, 0
    jr z, .no_cooldown

    dec a
    ld [MANA_USE_COOLDOWN], a

    .no_cooldown
    ret

regen_mana:
    ; only regen mana points if less than MAX_MANA_POINTS
    ld a, [MANA_POINTS]
    cp a, MAX_MANA_POINTS
    jr nc, .no_regen

    ; only decrease cooldown if on cooldown
    ld a, [MANA_REGEN]
    cp a, 0
    jr nz, .dec_regen_cd

    ; increase mana points
    ld a, [MANA_POINTS]
    inc a
    ld [MANA_POINTS], a

    ; display regenerated mana points
    ld b, 0
    ld c, a
    ld hl, MANA_LOCATION_ADDRESS
    add hl, bc
    ld [hl], MANA_TILE_INDEX

    ; put mana regen on cooldown
    Copy [MANA_REGEN], MANA_REGEN_CD

    .dec_regen_cd
        dec a
        ld [MANA_REGEN], a

    .no_regen
    ret

game_over:
    ; reset window and background
    xor a
    ld [rWY], a
    ld [rSCX], a
    ld [rSCY], a

    ; re-initializes game
    call init_sprites

    ; set starting screen on
    ld a, [GAME_STATE]
    xor GAMEF_START_SCREEN
    ld [GAME_STATE], a

    DisableLCD

    ; check if level 3
    ld a, [LVL_NUM_LOCATION]
    cp a, THREE_TILE_INDEX
    jp nz, .no_background_reload

    UpdateTilemap GAME_BACKGROUND, _SCRN0

    .no_background_reload

    ; load game over window
    UpdateTilemap GAME_OVER_WINDOW, _SCRN1
    EnableLCD
    halt
    ret

check_door:
    ; load player current tile index and see if it is the door
    ld a, [PLAYER_CURR_TILE]

    ; check level 1 end
    cp a, LVL_2_DOOR_INDEX
    jr nz, .no_lvl_1_end

    ; move to level 2 entrance door and switch level from 1 -> 2
    MovePlayer LVL_2_DOOR_X_OFFSET, LVL_2_DOOR_Y_OFFSET
    ld hl, LVL_NUM_LOCATION
    ld a, TWO_TILE_INDEX
    ld [hl], a

    jp .entered_door
    .no_lvl_1_end

    ; door 2 check
    cp a, DOOR_2_INDEX
    jr nz, .no_door_2

    MovePlayer DOOR_2_X_OFFSET, DOOR_2_Y_OFFSET
    ld hl, LVL_NUM_LOCATION
    ld a, ONE_TILE_INDEX
    ld [hl], a
    jr .entered_door
    .no_door_2

    ; door 3 check
    cp a, DOOR_3_INDEX
    jr nz, .no_door_3

    MovePlayer DOOR_3_X_OFFSET, DOOR_3_Y_OFFSET
    ld hl, LVL_NUM_LOCATION
    ld a, ONE_TILE_INDEX
    ld [hl], a
    jr .entered_door
    .no_door_3

    ; door 4 check
    cp a, DOOR_4_INDEX
    jr nz, .not_door_4

    MovePlayer DOOR_4_X_OFFSET, DOOR_4_Y_OFFSET
    jr .entered_door
    .not_door_4

    ; check door to win level
    cp a, WIN_DOOR_INDEX
    jr nz, .no_win_level_door

    call get_win_level
    jr .entered_door
    .no_win_level_door

    ; check door to finish and restart game
    cp a, FINISH_GAME_DOOR_INDEX
    jr nz, .no_finish_game_door

    call finish_game    
    .no_finish_game_door

    .entered_door
    ret

get_win_level:
    ; move sprites
    Copy [SPRITE_1_ADDRESS + OAMA_Y], SPRITE_1_WIN_LVL_Y
    Copy [SPRITE_2_ADDRESS + OAMA_Y], SPRITE_2_WIN_LVL_Y
    
    ; move player to door
    MovePlayer SPRITE_0_WIN_LVL_X_OFFSET, SPRITE_0_WIN_LVL_Y_OFFSET

    ; load win level tilemap 
    DisableLCD
    UpdateTilemap WIN_LEVEL, _SCRN0
    EnableLCD
    halt

    ; update level to 3
    ld hl, LVL_NUM_LOCATION
    ld a, THREE_TILE_INDEX
    ld [hl], a
    ret

finish_game:
    ; reset window and background
    xor a
    ld [rWY], a
    ld [rSCX], a
    ld [rSCY], a

    ; re-initializes game
    call init_sprites

    ; set starting screen on
    ld a, [GAME_STATE]
    xor GAMEF_START_SCREEN
    ld [GAME_STATE], a

    ; load start screen and game background
    DisableLCD
    UpdateTilemap START_SCREEN, _SCRN1
    UpdateTilemap GAME_BACKGROUND, _SCRN0
    EnableLCD
    halt
    ret

export init_game_states, check_start, damage_player, check_door, use_mana, mana_cooldown, regen_mana