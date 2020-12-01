typedef logic [17:0] TRUNC;



/*******************************************************************************************************
**                                     VGA Output Module
**                                     -----------------
**
** This module outputs VGA signals by reading a dual port RAM and generating a 640x480 VGA screen.
**
********************************************************************************************************/

module vga_out(
    vr,
	 vg,
	 vb,
	 vsync,
	 hsync,
	 vgaclk,
	 raddr,
	 bit_from_ram);
	 
//inputs and outputs
    output [1:0] vr;
	 output [1:0] vg;
	 output [1:0] vb;
	 output vsync;
	 output hsync;
	 input vgaclk;
	 output [17:0] raddr;
	 input bit_from_ram;
	 
// registers
    wire inDisplayArea;
    wire [9:0] CounterX;
	 wire [9:0] CounterY;

// module that produces VGA sync signals and produces a "inDisplayArea" flag (VGA clock is 25.17MHZ) 
hvsync_generator hvsync(
      .clk(vgaclk),
      .vga_h_sync(hsync),
      .vga_v_sync(vsync),
      .HCounterX(CounterX),
      .HCounterY(CounterY),
      .inDisplayArea(inDisplayArea)
    );

// every pixel clock, pull a byte from the dual port RAM
always @(posedge vgaclk) 
begin
    begin
		 if(inDisplayArea)
		     begin
			     // draw a border around the screen
				  if(CounterY < 2 || CounterY > 478)
				      begin
						    vr[0] <= 1;
							 vg[0] <= 1;
							 vb[0] <= 1;
							 vr[1] <= 1;
							 vg[1] <= 1;
							 vb[1] <= 1;
				          raddr[17:0] = TRUNC' (((CounterY / 2) * 800) + CounterX);
						 end
				  else
				       // light pixel based on what's in RAM
						 begin
						    vr[0] <= 0;
						    vg[0] <= bit_from_ram;
						    vb[0] <= bit_from_ram;
						    vr[1] <= 0;
						    vg[1] <= bit_from_ram;
						    vb[1] <= bit_from_ram;
				          raddr[17:0] = TRUNC' (((CounterY / 2) * 800) + CounterX);
						 end
				  end
		 else
			  // set RGB pixel to all zeroes if we're in a blanking area
			  begin
				  vr[0] <= 0;
				  vg[0] <= 0;
				  vb[0] <= 0;
				  vr[1] <= 0;
				  vg[1] <= 0;
				  vb[1] <= 0;
			  end
		 end
end
	 
	 
	 
	 
endmodule
