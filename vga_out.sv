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
	 BG_B, BG_G, BG_R, 
	 FG_B, FG_G, FG_R);
	 
//inputs and outputs
    output [1:0] vr;
	 output [1:0] vg;
	 output [1:0] vb;
	 output vsync;
	 output hsync;
	 input vgaclk;
	 output [17:0] raddr;
	 input bit_from_ram;
	 input  BG_B, BG_G, BG_R, FG_B, FG_G, FG_R;
	 
	 
	 reg bg_b_ff, bg_r_ff, bg_g_ff, fg_b_ff, fg_r_ff, fg_g_ff;
	 reg bg_b_ff2, bg_r_ff2, bg_g_ff2, fg_b_ff2, fg_r_ff2, fg_g_ff2;

	 reg [2:0] tempFGReg;
	 reg [2:0] tempBGReg;

	 
// registers
    wire inDisplayArea;
    wire [9:0] CounterX;
	 wire [9:0] CounterY;
	 
	 
always @(posedge vgaclk)
begin
    bg_r_ff <= BG_R;
	 bg_g_ff <= BG_G;
	 bg_b_ff <= BG_B;
	 fg_r_ff <= FG_R;
	 fg_g_ff <= FG_G;
	 fg_b_ff <= FG_B;
	 
	 bg_r_ff2 = bg_r_ff;
	 bg_g_ff2 = bg_g_ff;
	 bg_b_ff2 = bg_b_ff;
	 
	 fg_r_ff2 = fg_r_ff;
	 fg_g_ff2 = fg_g_ff;
	 fg_b_ff2 = fg_b_ff;
	 	 
	 tempFGReg[0] = fg_r_ff2;
	 tempFGReg[1] = fg_g_ff2;
	 tempFGReg[2] = fg_b_ff2;
	 
	 tempBGReg[0] = bg_r_ff2;
	 tempBGReg[1] = bg_g_ff2;
	 tempBGReg[2] = bg_b_ff2;

	 if(tempFGReg == tempBGReg)
	 begin
	     bg_r_ff2 <= 0;
	     bg_g_ff2 <= 0;
	     bg_b_ff2 <= 0;

		  fg_r_ff2 <= 1;
		  fg_g_ff2 <= 1;
		  fg_b_ff2 <= 1;
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
								     vr[0] <= fg_r_ff2;
								     vr[1] <= fg_r_ff2;
								     vg[0] <= fg_g_ff2;
								     vg[1] <= fg_g_ff2;
								     vb[0] <= fg_b_ff2;
								     vb[1] <= fg_b_ff2;
				                 raddr[17:0] = TRUNC' (((CounterY / 2) * 800) + CounterX);
								  end
							 else
							     begin
								     vr[0] <= bg_r_ff2;
								     vr[1] <= bg_r_ff2;
								     vg[0] <= bg_g_ff2;
								     vg[1] <= bg_g_ff2;
								     vb[0] <= bg_b_ff2;
								     vb[1] <= bg_b_ff2;
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
