if !def(SPRITES_RGBINC)
def SPRITES_RGBINC equ 1
include "inc/utils.inc"

; absolute coordinate
RSSET _RAM + 8 ; $C008
def ABSOLUTE_COORDINATE_X           rb 1
def ABSOLUTE_COORDINATE_Y           rb 1

; sprite addresses
def SPRITE_0_ADDRESS equ            (_OAMRAM)
def SPRITE_1_ADDRESS equ            (_OAMRAM + sizeof_OAM_ATTRS)
def SPRITE_2_ADDRESS equ            (SPRITE_1_ADDRESS + sizeof_OAM_ATTRS)

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
def DMG_CD                          equ (2)
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

endc