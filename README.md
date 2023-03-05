# CRTVI
CRT Video Interface

This project is currently in development. It's meant to serve as a Video Interface for CRT monitors and TVs. This would replace a video card in circumstances where the user would
prefer to use this solution. Why this over a video card? Video cards are complex devices that aren't meant to interface with CRT monitors and displays. Additionally, there are
all sort of trickeries that old consoles and arcades did that would not be possible with a GPU. The GPUs are designed around modern usecases, not around machines that had a low-level
interface to the display. Things like seamlessly switching between interlaced and progressive video just isn't possible with GPUs and displaying low resolutions require all
sort of hacks (not that GPUs themselves wouldn't be able to, I don't know, but there are several factors that interfere with the objective, drivers being the biggest one).

This repository only contains part of the eventual solution I intend to implement. The other half is, of course, software.

As I said above, this is incomplete and not functional as is. It will eventually require a board, though [this one](http://land-boards.com/blwiki/index.php?title=QMTECH_EP4CE15_FPGA_Starter_Kit) 
is what I'm using for development.

Wish me luck! :D
