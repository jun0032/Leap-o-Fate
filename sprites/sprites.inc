if !def(SPRITES_RGBINC)
def SPRITES_RGBINC equ 1
include "inc/utils.inc"

; absolute coordinate
RSSET _RAM + 8 ; $C008
def ABSOLUTE_COORDINATE_X           rb 1
def ABSOLUTE_COORDINATE_Y           rb 1
def PLAYER_CURR_TILE                rb 1

; sprite addresses
def SPRITE_0_ADDRESS equ            (_OAMRAM)
def SPRITE_1_ADDRESS equ            (_OAMRAM + sizeof_OAM_ATTRS)
def SPRITE_2_ADDRESS equ            (SPRITE_1_ADDRESS + sizeof_OAM_ATTRS)

; tilemap top left corner
def TOP_LEFT_CORNER_X               equ (8)
def TOP_LEFT_CORNER_Y               equ (16)

def TILEMAP_SPIKES_START            equ ($20)
def TILEMAP_SPIKES_END              equ ($27)
def TILEMAP_SOLID_START             equ ($80)
def TILEMAP_SOLID_END               equ ($AC)

; key positions for sprites
def SPRITE_0_INIT_X                 equ (24)
def SPRITE_0_INIT_Y                 equ (40)

def SPRITE_1_INIT_X                 equ (80)
def SPRITE_1_INIT_Y                 equ (104)
def SPRITE_1_END_X                  equ (144)

def SPRITE_2_INIT_X                 equ (128)
def SPRITE_2_INIT_Y                 equ (80)
def SPRITE_2_END_X                  equ (184)

; player attributes
def SPRITE_0_DEFAULT_ANIMATION      equ (8)
def SPRITE_0_MOVE_ANIMATION         equ (10)
def SPRITE_0_SPDX                   equ (1)
def SPRITE_0_FREQ                   equ (3)

def GRAVITY                         equ (1)
def JUMP_VERTICAL_VELOCITY          equ (-6)
def JUMP_COOLDOWN                   equ ($15)

rsset _RAM + 32
def GROUND                          rb 1
def JUMP_TOGGLE                     rb 1
def VERTICAL_VELOCITY               rb 1

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

; not currently using this DELETE THIS
; macro UpdateCurrTile
;     GetPlayerTileIndex \1, \2
;     ld a, [hl]
;     ld [PLAYER_CURR_TILE], a
; endm

; check if player is on a certain type of block
; NOTE: requires labels .no_collision and .collision
; params:
; \1 tileid of first tile of target block type
; \2 tileid of tile after last tile of target block type
; function: jump to .collision if player is on target block type
; jump to .no_collision otherwise
; macro CheckBlockCollision
;     cp a, TILEMAP_SOLID_START
;     jp c, .no_collision

;     cp a, TILEMAP_SOLID_END
;     jp c, .collision
; endm

macro CheckCollisionDirection
    ; check first corner
    GetPlayerTileIndex \1, \2
    ; call spike_collision

    cp a, TILEMAP_SOLID_START 
    jr c, .second_check

    cp a, TILEMAP_SOLID_END + 1
    jr c, .collision

    .second_check
        ; check second corner
        GetPlayerTileIndex \3, \4
        ; call spike_collision

        cp a, TILEMAP_SOLID_START
        jr c, .no_collision

        cp a, TILEMAP_SOLID_END + 1
        jr c, .collision
endm

endc