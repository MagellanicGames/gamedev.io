
#!/bin/bash
ffmpeg -i runeaugur_gif.mp4 -vf "fps=15,scale=384:216:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" -loop 0 output.gif
