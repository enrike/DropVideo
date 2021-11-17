# DropVideo

www.ixi-audio.net
license: GPL

DropVideo is just a simple video player developed in Processing

Install:
To run it you need to install Processing and sdd Video and Drop libraries.

Usage:
Drop video files on the window
Select a video by clicking on it
Click and drag to move a video 
Control+click to resize a video

Shortcuts:
(only affects to the selected video)
- Arrow up: speed up 
- Arrow down: slow down 
- Arrow left: jump -10s in time 
- Arrow right: jump +10s in time 
- p: play/pause 
- r: reset to start
- a: bring to front one level
- s: bring to back one level
- x: remove video

Preferences:
In data/prefs.json file
Edit the file to change the default values for
"window_width": 800,
"window_height": 600,
"window_x": 0,
"window_y": 0,
"color": 0

FULLSCREEN
 If you want fullscreen just tweak the data/prefs.json to match your displays size set window_x and window_y to 0 and run the sketch in PRESENT mode. (This is because in fullscreen the Drop library won't work)

enjoy


