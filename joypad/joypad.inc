if !def(JOYPAD_RGBINC)
def JOYPAD_RGBINC equ 1
include "inc/utils.inc"

rsset _RAM + 16 ; $C010
def JOYPAD_CURRENT_ADDRESS          rb 1
def JOYPAD_PREVIOUS_ADDRESS         rb 1
def JOYPAD_PRESSED_ADDRESS          rb 1
def JOYPAD_RELEASED_ADDRESS         rb 1

endc