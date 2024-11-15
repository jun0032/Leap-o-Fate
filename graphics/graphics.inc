if !def(GRAPHICS_RGBINC)
def GRAPHICS_RGBINC equ 1
include "inc/hardware.inc"

def TILE_SIDE_LENGTH                equ (8)
def TILES_COUNT                     equ (384)
def BYTES_PER_TILE                  equ (16)
def TILES_BYTE_SIZE                 equ (TILES_COUNT * BYTES_PER_TILE)

def TILEMAPS_COUNT                  equ (2)
def BYTES_PER_TILEMAP               equ (1024)
def TILEMAPS_BYTE_SIZE              equ (TILEMAPS_COUNT * BYTES_PER_TILEMAP)

def GRAPHICS_DATA_SIZE              equ (TILES_BYTE_SIZE + TILEMAPS_BYTE_SIZE)
def GRAPHICS_DATA_ADDRESS_END       equ ($4000)
def GRAPHICS_DATA_ADDRESS_START     equ (GRAPHICS_DATA_ADDRESS_END - GRAPHICS_DATA_SIZE)

def DEFAULT_PALETTE                 equ (%11100100)

; window constants
def WINDOW_X                        equ (7)
def WINDOW_START_Y                  equ (0)
def WINDOW_GAME_Y                   equ (120)

def WINDOW_LEFT_EDGE                equ (0)
def WINDOW_RIGHT_EDGE               equ (96)
def WINDOW_TOP_EDGE                 equ (0)
def WINDOW_BOTTOM_EDGE              equ (136)

; if player's x-value < the scroll value (for left and top)
; or player's x-value > the scroll value (for right and bottom)
; then scroll in that direction
def WINDOW_LEFT_SCROLL              equ (56)
def WINDOW_RIGHT_SCROLL             equ (120)
def WINDOW_TOP_SCROLL               equ (48)
def WINDOW_BOTTOM_SCROLL            equ (120)

; animation constants
def START_PULL_DOWN_SPEED           equ (8)
def WINDOW_SCROLL_SPEED             equ (1)

; for printing text
def ASCII_OFFSET                    equ ($20)
def NULL                            equ (0)

; load the graphics data from ROM to VRAM
macro LoadGraphicsDataIntoVRAM
    ld de, GRAPHICS_DATA_ADDRESS_START
    ld hl, _VRAM8000
    .load_tile\@
        ld a, [de]
        inc de
        ld [hli], a
        ld a, d
        cp a, high(GRAPHICS_DATA_ADDRESS_END)
        jr nz, .load_tile\@
endm

macro DisableLCD
    ; wait for the vblank
    .wait_vblank\@
        ld a, [rLY]
        cp a, SCRN_Y
        jr nz, .wait_vblank\@

    ; turn the LCD off
    xor a
    ld [rLCDC], a
endm

; set the graphics parameters and turn back LCD on
macro EnableLCD
    ld a, LCDCF_ON | LCDCF_WIN9C00 | LCDCF_WINON | LCDCF_BG8800 | LCDCF_BG9800 | LCDCF_OBJON | LCDCF_OBJ8 | LCDCF_BGON
    ld [rLCDC], a
endm

; prints text, \1: address of text and \2: address of location to print
macro PrintText
    ; load address of start of text in ROM to (de)
    ; and load the value in that address to (a)
    ld de, \1
    ld a, [de]

    ; load address in the tilemap to (hl)
    ld hl, \2

    .print_next_character\@
        ; increment current character and location to write
        add a, ASCII_OFFSET
        ld [hli], a
        inc de
        ld a, [de]

        ; repeat until null
        cp a, NULL
        jp nz, .print_next_character\@
endm
   
endc
