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
    Copy [MANA_REGEN], 0
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
    dec hl
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

    ; load game over window
    DisableLCD
    UpdateTilemap GAME_OVER_WINDOW, _SCRN1
    EnableLCD
    halt

    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

check_door:
    ; load player current tile index and see if it is the door
    ld a, [hl]
    cp a, $3
    jr nz, .no_door

    ; add x position
    AddBetter [SPRITE_0_ADDRESS + OAMA_X], 112
    AddBetter [ABSOLUTE_COORDINATE_X], 112

    ; add y position
    AddBetter [SPRITE_0_ADDRESS + OAMA_Y], 24
    AddBetter [ABSOLUTE_COORDINATE_Y], 24

    .no_door
    ret

export init_game_states, check_start, damage_player, check_door