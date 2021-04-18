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
              i_hsync,
				  i_vsync,
				  i_video,
				  o_waddr,
				  i_dotclk,
				  o_pixel_state,
				  o_wren,
				  o_leds0,o_leds1,o_leds2,o_leds3,
				  o_outputLEDA,
				  o_outputLEDB
				  );
				  
// inputs and outputs				  
		input               i_hsync;
		input               i_vsync;
		input               i_video;
		output logic [17:0] o_waddr;
		input               i_dotclk;
		output logic        o_pixel_state;
		output logic        o_wren;
		output logic        o_leds0,o_leds1,o_leds2,o_leds3;
      output logic [9:0]  o_outputLEDA;
		output logic [9:0]  o_outputLEDB;
		
// registers
      reg [9:0]           r_INCounterX;
      reg [9:0]           r_INCounterY;
	   reg [23:0]          r_ledsreg;
	   reg [31:0]          r_calc;
	   reg                 r_dot_r;
	   reg                 r_dot_r2;
	   reg                 r_hsync_r;
	   reg                 r_hsync_r2;
	   reg                 r_vsync_r;
	   reg                 r_vsync_r2;
	   reg [31:0]          r_nextline_r;
	   reg [31:0]          r_nextline_r2;
	   reg [31:0]          r_oldlinectr;
	   reg [1:0]           r_state_reg;
	   reg [23:0]          r_memCtr;
	   reg [9:0]           r_highestDotCount;
	   reg                 r_screenMode;
	   reg [3:0]           r_kitctr;
	   reg                 r_dot_r3;


 // parms
 	 parameter c_NORMAL     = 2'b00;
	 parameter c_MEMCLEAR   = 2'b01;
	 
	 parameter c_SIXTYFOURCOLMODE = 1'b1;
	 parameter c_EIGHTYCOLMODE = 1'b0;

	 
  
 
initial
begin
    r_INCounterX <= 9'b0000000000;      // X counter for input dot clock
	 r_INCounterY <= 9'b0000000000;      // Y counter for input lines
	 r_ledsreg <= 0;                     // counter for register used to blink LED when dot clock is present
	 o_wren <= 1;                        // dual port ram write enable pin (just leave it on)
	 r_dot_r2 <= 1;                      // double flop register for video signal
	 o_waddr[17:0] <= 0;                 // dual port write address
	 o_pixel_state <= 1;                 // pixel state output that goes to D input on dual port ram
    o_leds2 <= 1;                       // turn off LED2 (it's wired backward on Core Cyclone IV board 1 = 0ff, 0 = on)
	 o_leds1 <= 1;                       // turn off LED1
	 o_leds0 <= 1;                       // turn off LED0
	 r_nextline_r <= 0;                  // double flop register for counting horizontal lines
	 r_nextline_r2 <= 0;                 // double flop register for countering horizontal lines
	 r_oldlinectr <= 0;                  // control break register for horizontal lines
	 r_highestDotCount <= 0;             // counter for determining dots per row
	 r_state_reg <= c_NORMAL;            // are we in normal mode or memory clear mode?
	 r_memCtr <= 0;                      // counter for clearing ram
	 o_outputLEDA <= 0;                  // LED A indicator (10 bits)
	 o_outputLEDB <= 0;                  // LED B indicator (10 bits)
	 r_screenMode <= c_SIXTYFOURCOLMODE; // screen mode
	 r_kitctr <= 3'b0001;                // counter used for cycling LEDs
end


// probably don't need this any more... double flopping of sync signals
always @(posedge i_dotclk)
begin
    r_hsync_r2 <= i_hsync;
	 r_hsync_r <= r_hsync_r2;
	 r_vsync_r2 <= i_vsync;
	 r_vsync_r <= r_vsync_r2;
	 
	 o_leds0 = r_hsync_r;
	 o_leds1 = r_vsync_r;
end


// on the negative edge of hsync, add one to our line counter and double flop it to manage metastability
always @(negedge i_hsync)
begin
    r_nextline_r <= r_nextline_r + 1;
	 r_nextline_r2 = r_nextline_r;
end


always @(posedge r_ledsreg[20]) begin
    
	 r_kitctr <= r_kitctr + 1'b1;
	 if(r_kitctr > 9)
	     r_kitctr <= 0;
		  
	 o_outputLEDA <= TRUNC9'(1 << r_kitctr);
end



// this code handles 80/64 column mode switching, MEMCLEAR counter roll over, and setting indicator LEDs
always @(posedge i_dotclk)
begin
	 r_ledsreg = TRUNC23'(r_ledsreg + 1'b1);           // increment the LED counter
	 o_leds3 = r_ledsreg[20];                          // the 20th bit of the register seems to toggle about every half 
	                                                   // second when the dot clock is around 10mhz	 
	 
	 o_outputLEDB = r_highestDotCount;
	 
	 // once memCtr clears all 192000 bytes, go back to normal mode
	 if(r_memCtr > 191999) 
	 begin
			 r_state_reg = c_NORMAL;
	 end
	 							
							
	 // this code turns on MEMCLEAR mode when we are switching between 64 and 80 column modes
	 if(r_highestDotCount > 320)                       // ignore weird glitchy stuff
	 begin
		 if(r_highestDotCount > 720)                    // dot count per line is higher than 1/2 way between 64 and 80 column
		     begin                                      // so we should be at 80 column mode
			     if(r_screenMode != c_EIGHTYCOLMODE)     // if we are _not_ currently in 80 col mode
				  begin
				      r_state_reg <= c_MEMCLEAR;          // turn on MEMCLEAR
                  r_screenMode <= c_EIGHTYCOLMODE;    // set current mode to 80 col
				  end
		     end
		 else                                           // we are less than half way between 80 and 64 column mode
		     begin                                      // so we should be in 64 column mode
			     if(r_screenMode != c_SIXTYFOURCOLMODE)  // if we are _not_ currently in 64 column mode
				  begin
				      r_state_reg <= c_MEMCLEAR;          // turn on MEMCLEAR
    				   r_screenMode <= c_SIXTYFOURCOLMODE; // set current mode to 64 column mode
				  end
			  end
	 end
end



always @(posedge i_dotclk, posedge i_video)
begin
    if(i_video) 
         r_dot_r2 <= 1'b1;
	 else
	      r_dot_r2 <= 1'b0;
			
	 r_dot_r3 <= r_dot_r2;
end




// main code block
always @(posedge i_dotclk)
		 begin
			    if(r_state_reg == c_NORMAL)             // if we're in NORMAL mode
					 begin
						 o_pixel_state = r_dot_r3;         // output pin for dual port ram set to whatever is in dot_r2
						 o_leds2 <= 0;                     // set Core Board LED2 on to indicate we are running in NORMAL mode
						 r_memCtr<= 0;                     // set memCtr to 0 for later when we switch modes

						 if(~r_vsync_r)                    // if we are in the vsync period at the bottom of a frame, reset counters
							  begin		  		
								  r_highestDotCount = 1'b0;
								  r_INCounterY <= 1'b0;
								  r_INCounterX <= 1'b0;
							  end
						 else 
							  // if the nextline_r2 register has turned over increment INCounterY, reset InCounterX, and change oldlinectr
							  // this implements an "only once" reset for the end of each line
							  if(r_nextline_r2 != r_oldlinectr)
									begin
										 if(r_highestDotCount < r_INCounterX)
											  r_highestDotCount = r_INCounterX;
											  										 
										 r_INCounterX <= 1'b0;
										 r_oldlinectr <= r_nextline_r2;						
										 r_INCounterY <= r_INCounterY + 1'b1;
								   end
							  else
									// if we're on the same line as last dot clock, calculate the address for the next pixel,
									// put it into the write address of the dual port ram, increment INCounterX for the next 
									// pixel, and reset the dot_r2 video register back to black
									begin
										if(r_highestDotCount < 720)   // appears that it's 639 and 799 technically (80 column mode vs 64 column mode)
											 r_calc <= (800* r_INCounterY   ) + r_INCounterX + 16;       // 64 column mode shifting
										else 
											 r_calc <= (800*(r_INCounterY-8)) + r_INCounterX - 70;   // 80 column mode shifting

										o_waddr[17:0] <= TRUNC'(r_calc);                          // set write address in dual port ram
										r_INCounterX <= r_INCounterX + 1'b1;                      // increment X counter
									end		  
					 end
				 else 
				     if(r_state_reg == c_MEMCLEAR)                                         // we are in MEMCLEAR mode
					  begin
					      o_leds2 <= 1;                                                   // turn Core Board LED 2 off
					      o_pixel_state <= 0;                                             // set pixel going to RAM to off
							o_waddr[17:0] <= TRUNC'(r_memCtr);                                 // set write address to memCtr
							r_memCtr <= r_memCtr + 1'b1;                                       // increment memCtr
					  end
		  end
endmodule