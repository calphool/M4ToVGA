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
	 bit_from_ram,
	 BG_R1, BG_R0, BG_G1, BG_G0, BG_B1, BG_B0,
	 FG_R1, FG_R0, FG_G1, FG_G0, FG_B1, FG_B0);
	 
//inputs and outputs
    output [1:0] vr;
	 output [1:0] vg;
	 output [1:0] vb;
	 output vsync;
	 output hsync;
	 input vgaclk;
	 output [17:0] raddr;
	 input bit_from_ram;
	 input  BG_R1, BG_R0, BG_G1, BG_G0, BG_B1, BG_B0, FG_R1, FG_R0, FG_G1, FG_G0, FG_B1, FG_B0;
	 
	 reg bg_r1_ff1, bg_r0_ff1, bg_g1_ff1, bg_g0_ff1, bg_b1_ff1, bg_b0_ff1;
	 reg fg_r1_ff1, fg_r0_ff1, fg_g1_ff1, fg_g0_ff1, fg_b1_ff1, fg_b0_ff1;
	 reg bg_r1_ff2, bg_r0_ff2, bg_g1_ff2, bg_g0_ff2, bg_b1_ff2, bg_b0_ff2;
	 reg fg_r1_ff2, fg_r0_ff2, fg_g1_ff2, fg_g0_ff2, fg_b1_ff2, fg_b0_ff2;
	 reg [5:0] tempFGReg;
	 reg [5:0] tempBGReg;

	 
// registers
    wire inDisplayArea;
    wire [9:0] CounterX;
	 wire [9:0] CounterY;
	 
	 
always @(posedge vgaclk)
begin
    bg_r1_ff1 <= BG_R1;
    bg_r0_ff1 <= BG_R0;
    bg_g1_ff1 <= BG_G1;
    bg_g0_ff1 <= BG_G0;
    bg_b1_ff1 <= BG_B1;
    bg_b0_ff1 <= BG_B0;

    fg_r1_ff1 <= FG_R1;
    fg_r0_ff1 <= FG_R0;
    fg_g1_ff1 <= FG_G1;
    fg_g0_ff1 <= FG_G0;
    fg_b1_ff1 <= FG_B1;
    fg_b0_ff1 <= FG_B0;
	 
	 bg_r1_ff2 = bg_r1_ff1;
	 bg_r0_ff2 = bg_r0_ff1;
	 bg_g1_ff2 = bg_g1_ff1;
	 bg_g0_ff2 = bg_g0_ff1;
	 bg_b1_ff2 = bg_b1_ff1;
	 bg_b0_ff2 = bg_b0_ff1;

	 fg_r1_ff2 = fg_r1_ff1;
	 fg_r0_ff2 = fg_r0_ff1;
	 fg_g1_ff2 = fg_g1_ff1;
	 fg_g0_ff2 = fg_g0_ff1;
	 fg_b1_ff2 = fg_b1_ff1;
	 fg_b0_ff2 = fg_b0_ff1;
	 
	 tempFGReg[0] = fg_r1_ff2;
	 tempFGReg[1] = fg_r0_ff2;
	 tempFGReg[2] = fg_g1_ff2;
	 tempFGReg[3] = fg_g0_ff2;
	 tempFGReg[4] = fg_b1_ff2;
	 tempFGReg[5] = fg_b0_ff2;
	 
	 tempBGReg[0] = bg_r1_ff2;
	 tempBGReg[1] = bg_r0_ff2;
	 tempBGReg[2] = bg_g1_ff2;
	 tempBGReg[3] = bg_g0_ff2;
	 tempBGReg[4] = bg_b1_ff2;
	 tempBGReg[5] = bg_b0_ff2;

	 if(tempFGReg == tempBGReg)
	 begin
	     bg_r1_ff2 <= 0;
	     bg_r0_ff2 <= 0;
	     bg_g1_ff2 <= 0;
	     bg_g0_ff2 <= 0;
	     bg_b1_ff2 <= 0;
	     bg_b0_ff2 <= 0;

		  fg_r1_ff2 <= 1;
	     fg_r0_ff2 <= 1;
	     fg_g1_ff2 <= 1;
	     fg_g0_ff2 <= 1;
	     fg_b1_ff2 <= 1;
	     fg_b0_ff2 <= 1;
	 end
	 
end


	 

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
						 begin
							 if(bit_from_ram)
							     begin
								     vr[0] <= fg_r0_ff2;
								     vr[1] <= fg_r1_ff2;
								     vg[0] <= fg_g0_ff2;
								     vg[1] <= fg_g1_ff2;
								     vb[0] <= fg_b0_ff2;
								     vb[1] <= fg_b1_ff2;
				                 raddr[17:0] = TRUNC' (((CounterY / 2) * 800) + CounterX);
								  end
							 else
							     begin
								     vr[0] <= bg_r0_ff2;
								     vr[1] <= bg_r1_ff2;
								     vg[0] <= bg_g0_ff2;
								     vg[1] <= bg_g1_ff2;
								     vb[0] <= bg_b0_ff2;
								     vb[1] <= bg_b1_ff2;
				                 raddr[17:0] = TRUNC' (((CounterY / 2) * 800) + CounterX);
								  end
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
