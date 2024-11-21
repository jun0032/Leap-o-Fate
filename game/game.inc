if !def(GRAPHICS_RGBINC)
def GAME_RGBINC equ 1
include "inc/utils.inc"

rsset _RAM
def GAME_COUNTER                  rb 1
def GAME_STATE                    rb 1
def HEART_COUNT                   rb 1
def DAMAGE_COOLDOWN               rb 1
def MANA_POINTS                   rb 1
def MANA_REGEN                    rb 1

; flags for game state
def GAMEF_STARTING                equ ($0002)
def GAMEF_START_SCREEN            equ ($0001)

; bit for game state
def GAMEB_STARTING                equ ($0001)
def GAMEB_START_SCREEN            equ ($0000)

def COUNTER_SPEED                 equ (%00000001)

; tilemap top left corner
def TOP_LEFT_CORNER_X               equ (8)
def TOP_LEFT_CORNER_Y               equ (16)

def TILEMAP_SPIKES_START            equ ($20)
def TILEMAP_SPIKES_END              equ ($27)
def TILEMAP_SOLID_START             equ ($80)
def TILEMAP_SOLID_END               equ ($AC)

def GRAVITY                       equ (1)

; hearts
def MAX_HEARTS                    equ ($0003)
def HEART_TILE_INDEX              equ ($0036)
def BROKEN_HEART_TILE_INDEX       equ ($0037)
def HEART_LOCATION_ADDRESS        equ ($9C21)
def BLANK_TILE_INDEX              equ ($000F)

def DMG_CD                        equ ($18)

def MAX_MANA_POINTS               equ (6)
def MANA_REGEN_TIME               equ (20)


; level
def TWO_TILE_INDEX                equ ($52)
def LVL_NUM_LOCATION              equ ($9C32)

endc