if !def(SPRITES_RGBINC)
def SPRITES_RGBINC equ 1
include "inc/utils.inc"

; sprite addresses
def SPRITE_0_ADDRESS equ            (_OAMRAM)
def SPRITE_1_ADDRESS equ            (_OAMRAM + sizeof_OAM_ATTRS)
def SPRITE_2_ADDRESS equ            (SPRITE_1_ADDRESS + sizeof_OAM_ATTRS)

; key positions for sprites
def SPRITE_0_INIT_X                 equ (24)
def SPRITE_0_INIT_Y                 equ (40)

def SPRITE_1_INIT_X                 equ (80)
def SPRITE_1_INIT_Y                 equ (104)
def SPRITE_1_END_X                  equ (160)
def SPRITE_1_WIN_LVL_Y              equ (104)

def SPRITE_2_INIT_X                 equ (128)
def SPRITE_2_INIT_Y                 equ (80)
def SPRITE_2_END_X                  equ (184)
def SPRITE_2_WIN_LVL_Y              equ (120)

; player attributes
def SPRITE_0_DEFAULT_ANIMATION      equ (8)
def SPRITE_0_MOVE_ANIMATION         equ (10)
def SPRITE_0_SPDX                   equ (1)
def SPRITE_0_FREQ                   equ (3)

; absolute coordinates
RSSET _RAM + 32
def ABSOLUTE_COORDINATE_X           rb 1
def ABSOLUTE_COORDINATE_Y           rb 1
def PLAYER_CURR_TILE                rb 1

; sprite 1 attributes
def SPRITE_1_DEFAULT_ANIMATION      equ (11)
def SPRITE_1_MOVE_ANIMATION         equ (12)
def SPRITE_1_SPDX                   equ (1)
def SPRITE_1_FREQ                   equ (2)

; sprite 2 attributes
def SPRITE_2_DEFAULT_ANIMATION      equ (6)
def SPRITE_2_MOVE_ANIMATION         equ (7)
def SPRITE_2_SPDX                   equ (1)
def SPRITE_2_FREQ                   equ (3)

; clear the OAM
macro InitOAM
    ld c, OAM_COUNT
    ld hl, _OAMRAM + OAMA_Y
    ld de, sizeof_OAM_ATTRS
    .init_oam\@
        ld [hl], 0
        add hl, de
        dec c
        jr nz, .init_oam\@
endm

; calculates the player's tile index and puts it into (a) and [PLAYER_CURR_TILE]
; \1: player x-coord offset    \2: player y-coord offset
; if \1 and \2 are 0 -> gets the tile index of the top left corner of the player
macro GetPlayerTileIndex
    ; divide absolute x coordinate by 8 to get player tilemap column
    ld a, [ABSOLUTE_COORDINATE_X]
    add a, \1
    srl a
    srl a
    srl a
    ld b, 0
    ld c, a

    ; divide absolute y coordinate by 8 to get player tilemap row
    ld a, [ABSOLUTE_COORDINATE_Y]
    add a, \2
    srl a
    srl a
    srl a

    ; prepare hl for 16-bit "multiplication" and set counter (b)
    ld h, 0
    ld l, a
    
    ; multiply tilemap row by 32
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl

    ; add column to get tilemap index
    add hl, bc

    ; add $9800 + index to get index address in VRAM to compare the tile index
    ld de, _SCRN0
    add hl, de
    ld a, [hl]
    ld [PLAYER_CURR_TILE], a
endm

; checks two corners 
; first corner: x: \1 and y: \2
; second corner: x: \1 and y: \2
macro CheckCollisionDirection
    ; check first corner
    GetPlayerTileIndex \1, \2

    cp a, TILEMAP_SOLID_START 
    jr c, .second_check

    cp a, TILEMAP_SOLID_END + 1
    jr c, .collision

    .second_check
        ; check second corner
        GetPlayerTileIndex \3, \4

        cp a, TILEMAP_SOLID_START
        jr c, .no_collision

        cp a, TILEMAP_SOLID_END + 1
        jr c, .collision
endm

; checks if player is colliding with an enemy sprite
; \1: enemy sprite x-pos       \2: enemy sprite y-pos
macro CheckEnemySpriteCollision
    ; check left bounding box of enemy sprite
    ld a, \1
    cp a, b
    jr nc, .no_sprite_collision\@

    ; check right bounding box of enemy sprite
    add a, 7
    cp a, b
    jr c, .no_sprite_collision\@

    ; check top bounding box of enemy sprite
    ld a, \2
    cp a, c
    jr nc, .no_sprite_collision\@

    ; check bottom bounding box of enemy sprite
    add a, 7
    cp a, c
    jr c, .no_sprite_collision\@

    ; damage and reset damage cooldown
    call damage_player
    Copy [DAMAGE_COOLDOWN], DMG_CD
    jr .collision_checked

    .no_sprite_collision\@
endm

endc