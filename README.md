# Leap O' Fate
Leap O' Fate is a short original platformer for the Nintendo Game Boy, made by [Jun Seo](https://github.com/jun0032) and [Pan Pov](https://github.com/panpov) for CPSCI-240: Computer Architecture in the fall of 2024 at Hamilton College. 

<p align="center">
  <img src="https://github.com/panpov/leap-o-fate/blob/main/preview.gif" alt="game preview">
</p>

This was run and recorded with [Emulicious](https://emulicious.net/).

## Gameplay
- You are a ghost trapped inside a dungeon, and you need to escape.
- Move with the left and right d-pad buttons.
- You have 4 hearts and a bar that displays how much mana you have, which you can use by pressing the A button.
  - Press A to float/stop falling.
  - Press A and the up d-pad button simultaneously to levitate upwards.
- Ladders can be climbed/held onto by pressing A. Doing so will not consume mana.
- Open doors with the B button.

## Build Instructions
You need have to `make` and `RGBDS` installed. Instructions for installing `RGBDS` can be found [here](https://rgbds.gbdev.io/install). If you are on a linux distribution that uses `apt` (such as Ubuntu), you can use it to install `make` by typing the following into your terminal:
```
sudo apt-get install make
```
First, clone the repository:
```
git clone https://github.com/panpov/leap-o-fate.git
```
Change into the game's directory and make the game:
```
cd leap-o-fate
make
```
After this, you should see `game.gb` in the directory.

## Acknowledgements
- Thanks to Maximilien Dagois's [Game Boy Coding Adventure](https://mdagois.gumroad.com/l/CODQn), we were able to easily and effectively learn how to develop Game Boy games.
- Thanks to Professor Darren Strash for his incredible instruction in CPSCI-240 and feedback on this game.
- Assets from [8x8 1bit Dungeon Tilemap](https://pixelhole.itch.io/8x8dungeontilemap) by PixelHole and [Paper Pixels](https://v3x3d.itch.io/paper-pixels) by VEXED were used in the making of this game.
