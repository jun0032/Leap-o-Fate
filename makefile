
.PHONY: all

all: game.gb clean

game.gb: game.o joypad.o player.o sprites.o graphics.o main.o makefile
	rgblink --dmg --map game.map --sym game.sym -o game.gb main.o graphics.o sprites.o player.o joypad.o game.o
	rgbfix -v -p 0xFF game.gb

main.o: main.asm joypad/*.inc tiles/*.tlm tiles/*.chr makefile
	rgbasm -o main.o main.asm

graphics.o: graphics/graphics.asm graphics/*.inc tiles/*.tlm tiles/*.chr makefile
	rgbasm -o graphics.o graphics/graphics.asm

sprites.o: sprites/sprites.asm sprites/*.inc tiles/*.tlm tiles/*.chr makefile
	rgbasm -o sprites.o sprites/sprites.asm

player.o: sprites/player.asm sprites/*.inc tiles/*.tlm tiles/*.chr makefile
	rgbasm -o player.o sprites/player.asm

joypad.o: joypad/joypad.asm joypad/*.inc tiles/*.tlm tiles/*.chr makefile
	rgbasm -o joypad.o joypad/joypad.asm

game.o: game/game.asm game/*.inc tiles/*.tlm tiles/*.chr makefile
	rgbasm -o game.o game/game.asm

clean:
	rm *.o *.map *.sym