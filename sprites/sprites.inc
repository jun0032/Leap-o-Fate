if !def(SPRITES_RGBINC)
def SPRITES_RGBINC equ 1
include "inc/utils.inc"

; absolute coordinate
RSSET _RAM + 8 ; $C008
def ABSOLUTE_COORDINATE_X           rb 1
def ABSOLUTE_COORDINATE_Y           rb 1
def TOP_LEFT_PLAYER_TILE            rb 1

; sprite addresses
def SPRITE_0_ADDRESS equ            (_OAMRAM)
def SPRITE_1_ADDRESS equ            (_OAMRAM + sizeof_OAM_ATTRS)
def SPRITE_2_ADDRESS equ            (SPRITE_1_ADDRESS + sizeof_OAM_ATTRS)

; tilemap top left corner
def TOP_LEFT_CORNER_X               equ (8)
def TOP_LEFT_CORNER_Y               equ (16)

def TILE_IN_ROW_FACTOR              equ (5)

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
def DMG_CD                          equ ($FF)
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

; 
macro PlayerTileCorner
    ; divide absolute x coordinate by 8 to get player tilemap column
    ld a, [ABSOLUTE_COORDINATE_X]
    add a, \1
    sub a, TOP_LEFT_CORNER_X
    srl a
    srl a
    srl a
    ld c, a

    ; divide absolute y coordinate by 8 to get player tilemap row
    ld a, [ABSOLUTE_COORDINATE_Y]
    add a, \2
    sub a, TOP_LEFT_CORNER_Y
    srl a
    srl a
    srl a

    ; prepare hl for 16-bit multiplication and set counter (b)
    ld h, 0
    ld l, a
    ld b, TILE_IN_ROW_FACTOR

    ; multiply absolute x coordinate by 32
    .multiply_by_two\@
        sla h
        sla l
        jp nc, .dont_carry\@
        inc h
        
        .dont_carry\@
            dec b

        jp nz, .multiply_by_two\@

    ; add column to get tilemap index
    add hl, bc
endm

macro CheckTileCollision
    ld de, \1

    ; check higher byte
    ld a, h
    cp a, d
    jp nz, .safe\@

    ; check lower byte
    ld a, l
    cp a, e
    jp nz, .safe\@

    ; set z flag
    xor a
    .safe\@
endm

endc