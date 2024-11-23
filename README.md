# Leap 'O Fate

# 11/15
- Updated absolute coordinate in graphics.asm, sprites.asm, and sprites.inc
- Worked on absolute coordinate with potential collision in player.asm

# 11/16
- Realized that I (Jun) don't have to update absolute coordinate when the background moves
  but only when the player moves
- Got collision with first spike! @ Index: $6D
- Now to compare with tile index
- Finished GetPlayerTileIndex to be able to compare tile indices

# 11/19
- Reorganized collision and spike collision 

# 11/20
- Implemented a ghost mode
  - While pressing [A], gravity turns off and you can press UP to hover

# 11/21
- Added sprite collision
- Player can now press [B] when on a door to go through it
- Refined ghost mode
- Drafted mana system

# 11/22
- Finished mana system
- Ladders now work:
    - Press [A] and UP to use them
    - Similar to ghost mode but with no mana use
- Player can now go through all doors
- Going through the final door restarts the game
- Basically done with everything