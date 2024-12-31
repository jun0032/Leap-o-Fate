if !def(GRAPHICS_RGBINC)
def GAME_RGBINC equ 1
include "inc/utils.inc"

rsset _RAM
def GAME_COUNTER                  rb 1
def GAME_STATE                    rb 1
def HEART_COUNT                   rb 1
def DAMAGE_COOLDOWN               rb 1
def MANA_POINTS                   rb 1
def MANA_USE_COOLDOWN             rb 1
def MANA_REGEN                    rb 1

; flags for game state
def GAMEF_STARTING                equ ($0002)
def GAMEF_START_SCREEN            equ ($0001)

; bit for game state
def GAMEB_STARTING                equ ($0001)
def GAMEB_START_SCREEN            equ ($0000)

def COUNTER_SPEED                 equ (%00000001)

; tilemap top left corner
def TOP_LEFT_CORNER_X             equ (8)
def TOP_LEFT_CORNER_Y             equ (16)

def TILEMAP_SPIKES_START          equ ($20)
def TILEMAP_SPIKES_END            equ ($27)
def TILEMAP_SOLID_START           equ ($80)
def TILEMAP_SOLID_END             equ ($AC)

def GRAVITY                       equ (1)

; hearts
def MAX_HEARTS                    equ (4)
def HEART_TILE_INDEX              equ ($0036)
def BROKEN_HEART_TILE_INDEX       equ ($0037)
def HEART_LOCATION_ADDRESS        equ ($9C20)
def BLANK_TILE_INDEX              equ ($000F)

def DMG_CD                        equ ($18)

def MANA_TILE_INDEX               equ ($004A)
def MAX_MANA_POINTS               equ (6)
def MANA_USE_COOLDOWN_TIME        equ (10)
def MANA_REGEN_CD                 equ (16)
def MANA_LOCATION_ADDRESS         equ ($9C26)

def LADDER_TILE_INDEX             equ ($1)

; level display
def ONE_TILE_INDEX                equ ($51)
def TWO_TILE_INDEX                equ ($52)
def THREE_TILE_INDEX              equ ($53)
def LVL_NUM_LOCATION              equ ($9C32)

; doors
def LVL_2_DOOR_INDEX              equ ($3)
def LVL_2_DOOR_X_OFFSET           equ (110)
def LVL_2_DOOR_Y_OFFSET           equ (24)

def DOOR_2_INDEX                  equ ($4)
def DOOR_2_X_OFFSET               equ (40)
def DOOR_2_Y_OFFSET               equ (16)

def DOOR_3_INDEX                  equ ($5)
def DOOR_3_X_OFFSET               equ (16)
def DOOR_3_Y_OFFSET               equ (-48)

def DOOR_4_INDEX                  equ ($6)
def DOOR_4_X_OFFSET               equ (16)
def DOOR_4_Y_OFFSET               equ (48)

def WIN_DOOR_INDEX                equ ($7)

def FINISH_GAME_DOOR_INDEX        equ ($8)
def SPRITE_0_WIN_LVL_X_OFFSET     equ (-64)
def SPRITE_0_WIN_LVL_Y_OFFSET     equ (8)

; Move player's x by \1 and y by \2
macro MovePlayer
    AddBetter [SPRITE_0_ADDRESS + OAMA_X], \1
    AddBetter [ABSOLUTE_COORDINATE_X], \1
    AddBetter [SPRITE_0_ADDRESS + OAMA_Y], \2
    AddBetter [ABSOLUTE_COORDINATE_Y], \2
endm

endc