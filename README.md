# AmigaDemo_the_crows
Simple and free demo written in ASM meant for all classic Amiga computers - features copperlist, blitter and mod playing instructions

The demos contain 3 different images, the first one is a static picture of a bleeding man, the second is a banner with "the crown" text on it moving endlessly up and down, the third is a skull wandering through a precalcuated path on the screen.

The scull is made of 2 sprites (SPRITES0 and SRITES1) side by side, this is mandatory since Amiga hardware allows sprites to have only 16 pixel width, if you want more you must combine more sprites.
During the demo a mod song is also playing.

### Versions (single playfield mode)
This demo comes in 2 different version, the first (file the_crows.s) uses a single playfield mode, the second (file the_crows_dual_pf.s) uses a dual playfield mode.
In the following paragraphs I will explain how I did it and the main the pros and cons of each version.

#### Single playfield mode
In single playfield mode the bleeding man is a 16 color image stored accross bitplanes 1,2,3 and 4.

The banner is stored on bitplane 5, for this reason it must be one color only (+ one color for transparency).

When the banner overlays the bleeding man a simple trick is performed to make feel it's going under: the palette from color 1-15 is replicated into the 17-31 palette registers.
In this way the same color is always applied, no matter if the banner is overlaying or not.
For example, assuming this palette:
- Color 0 - Background (whatever)
- Color 1 - Black (the bleeding man's hair)
- Color 16 - Red (the banner color)
- Color 17 - Black (the belleding man's hair replicated)

When the banner overlays the bleeding man's hair whe have bitplane 1 = 1, bitplanes from 2 to 4 = 0 and the fifth bitplane (the banner text) = 1, so we get this binary sequence:
"10001" that in decimal is 17.
- If the text is not overlaying, with the same calculation we get "00001" (decimal 1), so in both cases the black color is used, as a result, the bleeding man's hair will always be on top.
- If the text overlays an empty region of the bleeding man (where there is transparency), color 16 is used.
