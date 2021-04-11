/*****************************************************************************************************
**
** m4_input monitor - watches hsync, vsync, video, dotclk from the TRS-80 Model 4 and puts pixels into
** the dual port RAM that is being monitored by by the vga_out module
**
*****************************************************************************************************/

// truncation typedefs
typedef logic [17:0] TRUNC17;
typedef logic [23:0] TRUNC23;
typedef logic [9:0] TRUNC9;


// module entry point
module m4_input (
              hsync,
				  vsync,
				  video,
				  waddr,
				  dotclk,
				  pixel_state,
				  wren,
				  leds0,leds1,leds2,leds3,
				  outputLEDA,
				  outputLEDB
				  );
				  
// inputs and outputs				  
		input hsync;
		input vsync;
		input video;
		output logic [17:0] waddr;
		input dotclk;
		output logic pixel_state;
		output logic wren;
		output logic leds0,leds1,leds2,leds3;
      output logic [9:0] outputLEDA;
		output logic [9:0] outputLEDB;
		
// registers
    reg [9:0] INCounterX;
    reg [9:0] INCounterY;
	 reg [23:0] ledsreg;
	 reg [31:0] calc;
	 reg dot_r;
	 reg dot_r2;
	 reg hsync_r;
	 reg hsync_r2;
	 reg vsync_r;
	 reg vsync_r2;
	 reg [31:0] nextline_r;
	 reg [31:0] nextline_r2;
	 reg [31:0] oldlinectr;
	 reg [1:0]  state_reg;
	 reg [23:0] memCtr;
	 reg [9:0]  highestDotCount;
	 reg screenMode;
	 reg [3:0] kitctr;


 // parms
 	 parameter NORMAL     = 2'b00;
	 parameter MEMCLEAR   = 2'b01;
	 parameter TRANSITION = 2'b10; 
	 
	 parameter SIXTYFOURCOLMODE = 1'b1;
	 parameter EIGHTYCOLMODE = 1'b0;

	 
  
 
initial
begin
    INCounterX <= 9'b0000000000;    // X counter for input dot clock
	 INCounterY <= 9'b0000000000;    // Y counter for input lines
	 ledsreg <= 0;                   // counter for register used to blink LED when dot clock is present
	 wren <= 1;                      // dual port ram write enable pin (just leave it on)
	 dot_r2 <= 1;                    // double flop register for video signal
	 waddr[17:0] <= 0;               // dual port write address
	 pixel_state <= 1;               // pixel state output that goes to D input on dual port ram
    leds2 <= 1;                     // turn off LED2 (it's wired backward on Core Cyclone IV board 1 = 0ff, 0 = on)
	 leds1 <= 1;                     // turn off LED1
	 leds0 <= 1;                     // turn off LED0
	 nextline_r <= 0;                // double flop register for counting horizontal lines
	 nextline_r2 <= 0;               // double flop register for countering horizontal lines
	 oldlinectr <= 0;                // control break register for horizontal lines
	 highestDotCount <= 0;           // counter for determining dots per row
	 state_reg <= NORMAL;            // are we in normal mode or memory clear mode?
	 memCtr <= 0;                    // counter for clearing ram
	 outputLEDA <= 0;                // LED A indicator (10 bits)
	 outputLEDB <= 0;                // LED B indicator (10 bits)
	 screenMode <= SIXTYFOURCOLMODE; // screen mode
	 kitctr <= 3'b0001;
end


// probably don't need this any more... double flopping of sync signals
always @(posedge dotclk)
begin
    hsync_r2 <= hsync;
	 hsync_r <= hsync_r2;
	 vsync_r2 <= vsync;
	 vsync_r <= vsync_r2;
	 
	 leds0 = hsync_r;
	 leds1 = vsync_r;
end


// on the negative edge of hsync, add one to our line counter and double flop it to manage metastability
always @(negedge hsync)
begin
    nextline_r <= nextline_r + 1;
	 nextline_r2 = nextline_r;
end


always @(posedge ledsreg[20]) begin
    
	 kitctr <= kitctr + 1;
	 if(kitctr > 9)
	     kitctr <= 0;
		  
	 outputLEDA <= TRUNC9'(1 << kitctr);
end



// this code handles 80/64 column mode switching, MEMCLEAR counter roll over, and setting indicator LEDs
always @(posedge dotclk)
begin
	 ledsreg = TRUNC23'(ledsreg + 1'b1);           // increment the LED counter
	 leds3 = ledsreg[20];                          // the 20th bit of the register seems to toggle about every half 
	                                               // second when the dot clock is around 10mhz	 
	 
	 //outputLEDB[9] = state_reg[0];                 // normal = off, memclear = on
	 outputLEDB = highestDotCount;
	 
	 // once memCtr clears all 192000 bytes, go back to normal mode
	 if(memCtr > 191999) 
	 begin
			 state_reg = NORMAL;
	 end
	 
	 //outputLEDA = TRUNC9'(memCtr);                 // put memCtr in LED A indicator (normally 0)
							
							
	 // this code turns on MEMCLEAR mode when we are switching between 64 and 80 column modes
	 if(highestDotCount > 320)                     // ignore weird glitchy stuff
	 begin
		 if(highestDotCount > 720)                  // dot count per line is higher than 1/2 way between 64 and 80 column
		     begin                                  // so we should be at 80 column mode
			     if(screenMode != EIGHTYCOLMODE)     // if we are _not_ currently in 80 col mode
				  begin
				      state_reg <= MEMCLEAR;          // turn on MEMCLEAR
                  screenMode <= EIGHTYCOLMODE;    // set current mode to 80 col
				  end
		     end
		 else                                       // we are less than half way between 80 and 64 column mode
		     begin                                  // so we should be in 64 column mode
			     if(screenMode != SIXTYFOURCOLMODE)  // if we are _not_ currently in 64 column mode
				  begin
				      state_reg <= MEMCLEAR;          // turn on MEMCLEAR
    				   screenMode <= SIXTYFOURCOLMODE; // set current mode to 64 column mode
				  end
			  end
	 end
	 
	 //outputLEDB[8] = screenMode;                   // 64 col mode = on, 80 col mode = off;	 
end



// main code block
always @(posedge dotclk, posedge video)
		 begin
			 if(video)                              // when video input shows a high signal, put a 1 in dot_r2 register
				 begin
						dot_r2 <= 1'b1;
				 end
			 else
			    if(state_reg == NORMAL)             // if we're in NORMAL mode
					 begin
						 pixel_state = dot_r2;         // output pin for dual port ram set to whatever is in dot_r2
						 leds2 <= 0;                   // set Core Board LED2 on to indicate we are running in NORMAL mode
						 memCtr<= 0;                   // set memCtr to 0 for later when we switch modes

						 if(~vsync_r)                  // if we are in the vsync period at the bottom of a frame, reset counters
							  begin		  		
								  highestDotCount = 1'b0;
								  INCounterY <= 1'b0;
								  INCounterX <= 1'b0;
							  end
						 else 
							  // if the nextline_r2 register has turned over increment INCounterY, reset InCounterX, and change oldlinectr
							  // this implements an "only once" reset for the end of each line
							  if(nextline_r2 != oldlinectr)
									begin
										 if(highestDotCount < INCounterX)
											  highestDotCount = INCounterX;
											  										 
										 INCounterX = 1'b0;
										 oldlinectr <= nextline_r2;						
										 INCounterY <= INCounterY + 1'b1;
								   end
							  else
									// if we're on the same line as last dot clock, calculate the address for the next pixel,
									// put it into the write address of the dual port ram, increment INCounterX for the next 
									// pixel, and reset the dot_r2 video register back to black
									begin
										if(highestDotCount < 720)   // appears that it's 639 and 799 technically (80 column mode vs 64 column mode)
											 calc = (800*INCounterY) + INCounterX + 16;       // 64 column mode shifting
										else 
											 calc = (800*(INCounterY-8)) + INCounterX - 71;   // 80 column mode shifting

										waddr[17:0] = TRUNC'(calc);                          // set write address in dual port ram
										INCounterX = INCounterX + 1'b1;                      // increment X counter
										dot_r2 <= 1'b0;                                      // set dot register to zero
									end		  
					 end
				 else 
				     if(state_reg == MEMCLEAR)                                         // we are in MEMCLEAR mode
					  begin
					      leds2 <= 1;                                                   // turn Core Board LED 2 off
					      pixel_state <= 0;                                             // set pixel going to RAM to off
							waddr[17:0] = TRUNC'(memCtr);                                 // set write address to memCtr
							memCtr = memCtr + 1'b1;                                       // increment memCtr
					  end
		  end
endmodule