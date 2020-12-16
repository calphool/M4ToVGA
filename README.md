# M4ToVGA

![TRS80 VGA Screen](img/TRS80VGAScreen.jpg?raw=true "TRS80 VGA Screen")

M4ToVGA is an FPGA hardware project that allows you to connect your TRS-80 Model 4 or TRS-80 Model 3 to a VGA monitor.  

Although everyone loves the warm glow of a 1980s CRT, these devices are slowly dying (or in my case I received a vintage TRS-80 Model 4 in the mail with a crushed CRT and needed an alternative.)

This project is built around the Cyclone IV FPGA, and more specifically the Core EP4CE6 board that is super cheap (around $20) and contains more than enough logic fabric to do the job.

## Theory of Operation

Although you can find composite boards that will convert the video signals from a TRS-80 Model 3/4 to a composite video signal that can be used with an NTSC television, most of these are based on the video output circuitry of the TRS-80 Model 1, which contains a video mixing circuit capable of mixing vsync, hsync, and video out into a *roughly* conforming NTSC composite signal.  Unfortunately, the timing of the Model 3/4 video output is a little bit different than the Model 1, and thus many people struggle to use these composite boards successfully unless their television has a means of shifting and stretching the video signal.

Although I was able to get one of these circuits to work *more or less*, I was unsatisfied with the results, and I wanted to learn how to code Verilog for FPGAs anyway, so I thought this would be a good time to learn.

The code has five main blocks (or modules).  

* It has a "top" module whose job is to stitch all the submodules together into a meaningful circuit.  
* The submodules include a PLL based clock for the VGA signal (25.17MHZ for a conformant 640x480 resolution).  
* The next submodule is a framebuffer that is 153,600 x 1 bits, which works to store a 640 x 240 array of pixels, the maximum resolution of a TRS-80 Model 3/4.  Those two submodules were generated in Quartus II using wizards.  
* Next is a VGA output module whose job is to take in the VGA clock and continuously scan through the framebuffer and display what it sees there.  It has a sub-sub-module whose job is to produce vga hsync and vsync as well as inform the VGA output module when the signal is "in the display zone," as opposed to one of the vertical or horizontal blank areas.
* Finally is the m4_input module, whose job is to monitor the Model 3/Model 4 hsync, vsync, dot clock, and video signals, interpret them, and turn them into bits (pixels) in the dual port frame buffer.

## Details

Below you will see oscilloscope pictures showing the hsync, vsync, and video traces from a TRS-80 Model 4.  

![Oscilloscope Screen 1](img/OscilloscopeScreen1.jpg?raw=true "Oscilloscope Screen 1")

![Oscilloscope Screen 2](img/OscilloscopeScreen2.jpg?raw=true "Oscilloscope Screen 2")

![Oscilloscope Screen 3](img/OscilloscopeScreen3.jpg?raw=true "Oscilloscope Screen 3")

These signals are all driven and synchronized by an underlying "dot clock."

These signals are what we needed to transform into a VGA signal, and what the m4_input submodule contends with.

Below you see a graphic of the top module that ties together all the submodules.

![Top Module](img/TopModule.pdf?raw=true "Top Module")

## Status

2020, December 15

I did eventually figure out how to clear the BRAM when the mode switches from 80 to 64 column mode.  It took way more work than I expected.  The solution was 
relatively simple, but getting there was not.

Got the PCB, populated it.  Worked as intended.  I'm working on another revision though because I don't care for a few of the placement decisions I made.
I also need to add a pin header so that the board can be used on something other than the Model 3/4 AMP connector.  I also realized that soldering 0603 LEDs 
is a pain in the neck, so I switched all those out of small through-hole LEDs.

I don't care for the DOT CLK situation.  I'd like to get rid of the dot clock, but I haven't come up with a solution yet.

I've also been digging into DVI/HDMI via FPGA.  There is apparently an open source HDMI implementation now, so the question is will it work for a Cyclone IV
board?  It looks like it might.  How cool would it be to have simultaneous VGA and HDMI out?  Might be a pipe dream, but it's something I'll keep digging into.
We'll see...

![Version 1 PCB](img/M4ToVGA_BoardPic.jpg?raw=true "Version 1 PCB")

2020, November 26

Happy Thanksgiving for those in the USA!  It's not exactly a pleasant one for most folks as the "human-malware" continues to spread and 
most folks are limiting their get-togethers in one form or another.

Well, I made some tweaks to the code to deal with the fact that 80-column mode on the TRS-80 Model 4 has a different dot clock than 
64 column mode.  Without these changes the right side of 80 column mode was chopped off.  At vertical blank, the code resets the 
counter it uses to count how many dots there were per horizontal line, which allows the code to switch back and forth between modes.

There's one remaining issue, which is that since 80 column mode uses the entire screen worth of pixels, when you switch back to 
64 column mode there is sometimes garbage left on the right and left sides of the screen.  I'll have to work some kind of "one frame of 
clearing the dual port ram" when a change is detected into the design.

I also think I'd like to have some way to change the amount that the screen shifts left/right and maybe top/bottom.  Ideally it would 
be a potentiometer or rotational encoder, though I'm not sure how you interface either of them to an FPGA and I'd rather not have to 
introduce an ADC to the design if I can help it.  Ideally two additional pots/encoders would let you shrink or expand the screen as well,
but that will probably have to wait a bit.  In any event, I'll be digging into how to potentiometers/encoders these into the design shortly.

2020, November 23

The current version works, but isn't complete.  I'll need to design a PCB next and finish its testing to produce a version 1.0.


## License
[MIT](https://choosealicense.com/licenses/mit/)
