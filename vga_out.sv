typedef logic [17:0] TRUNC;

`define LOGOXLOC 500
`define LOGOYLOG 400
`define LOGOW 112


/*******************************************************************************************************
**                                     VGA Output Module
**                                     -----------------
**
** This module outputs VGA signals by reading a dual port RAM and generating a 640x480 VGA screen.
**
********************************************************************************************************/

module vga_out(
    o_vr,
	 o_vg,
	 o_vb,
	 o_vsync,
	 o_hsync,
	 i_vgaclk,
	 o_raddr,
	 i_bit_from_ram,
	 i_BG_R1, i_BG_R0, i_BG_G1, i_BG_G0, i_BG_B1, i_BG_B0,
	 i_FG_R1, i_FG_R0, i_FG_G1, i_FG_G0, i_FG_B1, i_FG_B0);
	 
//inputs and outputs
    output [1:0]     o_vr;
	 output [1:0]     o_vg;
	 output [1:0]     o_vb;
	 output           o_vsync;
	 output           o_hsync;
	 input            i_vgaclk;
	 output [17:0]    o_raddr;
	 input            i_bit_from_ram;
	 input            i_BG_R1, i_BG_R0, i_BG_G1, i_BG_G0, i_BG_B1, i_BG_B0;
	 input            i_FG_R1, i_FG_R0, i_FG_G1, i_FG_G0, i_FG_B1, i_FG_B0;
	 
	 reg              r_bg_r1_ff1, r_bg_r0_ff1, r_bg_g1_ff1, r_bg_g0_ff1, r_bg_b1_ff1, r_bg_b0_ff1;
	 reg              r_fg_r1_ff1, r_fg_r0_ff1, r_fg_g1_ff1, r_fg_g0_ff1, r_fg_b1_ff1, r_fg_b0_ff1;
	 reg              r_bg_r1_ff2, r_bg_r0_ff2, r_bg_g1_ff2, r_bg_g0_ff2, r_bg_b1_ff2, r_bg_b0_ff2;
	 reg              r_fg_r1_ff2, r_fg_r0_ff2, r_fg_g1_ff2, r_fg_g0_ff2, r_fg_b1_ff2, r_fg_b0_ff2;
	 reg [5:0]        r_tempFGReg;
	 reg [5:0]        r_tempBGReg;
	 reg [31:0]       r_clkCtr;
	 reg [24:0]       r_QSecCtr;
	 reg              r_bShowLogo;
	 reg [0:`LOGOW-1] r_logo [16];
	 reg [5:0]        r_logo_rgb;

	 
// registers
    wire             w_inDisplayArea;
    wire [9:0]       w_CounterX;
	 wire [9:0]       w_CounterY;
	 
	 
initial
begin
    r_clkCtr <= 0;
	 r_QSecCtr <= 0;
	 r_logo_rgb <= 1;
	 r_bShowLogo = 1;
	 
    r_logo[0] <= `LOGOW'b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;

	 r_logo[1] <= `LOGOW'b0010001010001011111001110010001001110000100000000010001000010000000000010000000001110000110001110000110000010000;
	 r_logo[2] <= `LOGOW'b0011011001010000100010001010001010000001010000000010001000110000000000110000000010101001001010001001001000110000;
	 r_logo[3] <= `LOGOW'b0010101000100000100010001010001010000010001000000010001000010000000000010000000011001000010010001000010000010000;
	 r_logo[4] <= `LOGOW'b0010001000100000100010001001010010111011111000000001010000010000000000010000000011001000100010001000100000010000;
	 r_logo[5] <= `LOGOW'b0010001001010000100010001000100010001010001000000001010000010000110000010000000010101001000010001001000000010000;
	 r_logo[6] <= `LOGOW'b0010001010001000100001110000100001110010001000000000100000010000110000010000000001110001111001110001111000010000;

    r_logo[7] <= `LOGOW'b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
    r_logo[8] <= `LOGOW'b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;

    r_logo[9] <= `LOGOW'b0011111000000000000000000011110000000000000000000000000000000000000000000000100000100000000000000000000000000000;
    r_logo[10]<= `LOGOW'b0000010000000000000000000010001000000000000000000000000000000000000000100000100000100000000000000000000000000000;
    r_logo[11]<= `LOGOW'b0000010001110001110000000010001001110010001011110001111001110010001000000000100000100001110000000000000000000000;
    r_logo[12]<= `LOGOW'b0010010010001011111000000011110010001010001010001010000011111010001000100000100000100011111000000000000000000000;
    r_logo[13]<= `LOGOW'b0010010010001010000000000010001010001010001010001010000010000001010000100000100000100010000000000000000000000000;
    r_logo[14]<= `LOGOW'b0001100001110001110000000010001001110001111010001001111001110000100000100000100000100001111000000000000000000000;

	 r_logo[15]<= `LOGOW'b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
end

	 
	 
always @(posedge i_vgaclk)
begin
    r_bg_r1_ff1 <= i_BG_R1;
    r_bg_r0_ff1 <= i_BG_R0;
    r_bg_g1_ff1 <= i_BG_G1;
    r_bg_g0_ff1 <= i_BG_G0;
    r_bg_b1_ff1 <= i_BG_B1;
    r_bg_b0_ff1 <= i_BG_B0;

    r_fg_r1_ff1 <= i_FG_R1;
    r_fg_r0_ff1 <= i_FG_R0;
    r_fg_g1_ff1 <= i_FG_G1;
    r_fg_g0_ff1 <= i_FG_G0;
    r_fg_b1_ff1 <= i_FG_B1;
    r_fg_b0_ff1 <= i_FG_B0;
	 
	 r_bg_r1_ff2 = r_bg_r1_ff1;
	 r_bg_r0_ff2 = r_bg_r0_ff1;
	 r_bg_g1_ff2 = r_bg_g1_ff1;
	 r_bg_g0_ff2 = r_bg_g0_ff1;
	 r_bg_b1_ff2 = r_bg_b1_ff1;
	 r_bg_b0_ff2 = r_bg_b0_ff1;

	 r_fg_r1_ff2 = r_fg_r1_ff1;
	 r_fg_r0_ff2 = r_fg_r0_ff1;
	 r_fg_g1_ff2 = r_fg_g1_ff1;
	 r_fg_g0_ff2 = r_fg_g0_ff1;
	 r_fg_b1_ff2 = r_fg_b1_ff1;
	 r_fg_b0_ff2 = r_fg_b0_ff1;
	 
	 r_tempFGReg[0] = r_fg_r1_ff2;
	 r_tempFGReg[1] = r_fg_r0_ff2;
	 r_tempFGReg[2] = r_fg_g1_ff2;
	 r_tempFGReg[3] = r_fg_g0_ff2;
	 r_tempFGReg[4] = r_fg_b1_ff2;
	 r_tempFGReg[5] = r_fg_b0_ff2;
	 
	 r_tempBGReg[0] = r_bg_r1_ff2;
	 r_tempBGReg[1] = r_bg_r0_ff2;
	 r_tempBGReg[2] = r_bg_g1_ff2;
	 r_tempBGReg[3] = r_bg_g0_ff2;
	 r_tempBGReg[4] = r_bg_b1_ff2;
	 r_tempBGReg[5] = r_bg_b0_ff2;

	 if(r_tempFGReg == r_tempBGReg)
	 begin
	     r_bg_r1_ff2 <= 0;
	     r_bg_r0_ff2 <= 0;
	     r_bg_g1_ff2 <= 0;
	     r_bg_g0_ff2 <= 0;
	     r_bg_b1_ff2 <= 0;
	     r_bg_b0_ff2 <= 0;

		  r_fg_r1_ff2 <= 1;
	     r_fg_r0_ff2 <= 1;
	     r_fg_g1_ff2 <= 1;
	     r_fg_g0_ff2 <= 1;
	     r_fg_b1_ff2 <= 1;
	     r_fg_b0_ff2 <= 1;
	 end
	  			
	  r_clkCtr <= r_clkCtr + 1;
	  if(r_bShowLogo == 1)
	  begin
		  if(r_clkCtr > 250000000)
			  begin
				  r_bShowLogo = 0;
			  end
	  end
end



function void drawFG;
begin
			  o_vr[0] = r_fg_r0_ff2;
			  o_vr[1] = r_fg_r1_ff2;
			  o_vg[0] = r_fg_g0_ff2;
			  o_vg[1] = r_fg_g1_ff2;
			  o_vb[0] = r_fg_b0_ff2;
			  o_vb[1] = r_fg_b1_ff2;
			  o_raddr[17:0] = TRUNC' (((w_CounterY / 2) * 800) + w_CounterX);
end
endfunction



function void drawWhite;
begin
			  o_vr[0] = 1;
			  o_vr[1] = 1;
			  o_vg[0] = 1;
			  o_vg[1] = 1;
			  o_vb[0] = 1;
			  o_vb[1] = 1;
			  o_raddr[17:0] = TRUNC' (((w_CounterY / 2) * 800) + w_CounterX);
end
endfunction



function void drawRotatingBG;
begin
			  o_vr[0] = r_logo_rgb[0];
			  o_vr[1] = r_logo_rgb[1];
			  o_vg[0] = r_logo_rgb[2];
			  o_vg[1] = r_logo_rgb[3];
			  o_vb[0] = r_logo_rgb[4];
			  o_vb[1] = r_logo_rgb[5];			  
end
endfunction


function void drawBG;
begin
			  o_vr[0] = r_bg_r0_ff2;
			  o_vr[1] = r_bg_r1_ff2;
			  o_vg[0] = r_bg_g0_ff2;
			  o_vg[1] = r_bg_g1_ff2;
			  o_vb[0] = r_bg_b0_ff2;
			  o_vb[1] = r_bg_b1_ff2;
			  o_raddr[17:0] = TRUNC' (((w_CounterY / 2) * 800) + w_CounterX);
end
endfunction



function void drawFromRAM;
begin
	 if(i_bit_from_ram)
		  begin
		      drawFG();
		  end
	 else
		  begin
		      drawBG();
		  end
end
endfunction





function void drawLogo;
begin
    integer i;
	 
	 if(w_CounterX == `LOGOXLOC)
	 begin
			r_logo_rgb = r_logo_rgb << 1;
			if(r_logo_rgb == 0)
				 r_logo_rgb = 1;
	 end

	 
    if(w_CounterY+0 == `LOGOYLOG+0 && (w_CounterX >= `LOGOXLOC && w_CounterX <= `LOGOXLOC+(`LOGOW-1)))
		 begin
		     if(r_logo[0][w_CounterX-`LOGOXLOC] == 1)
						  drawWhite();
			  else
						  drawRotatingBG();
		 end
	 else
    if(w_CounterY == `LOGOYLOG+1 && (w_CounterX >= `LOGOXLOC && w_CounterX <= `LOGOXLOC+(`LOGOW-1)))
       begin
		     if(r_logo[1][w_CounterX-`LOGOXLOC] == 1)
						  drawWhite();
			  else
						  drawRotatingBG();
	    end
	 else
    if(w_CounterY == `LOGOYLOG+2 && (w_CounterX >= `LOGOXLOC && w_CounterX <= `LOGOXLOC+(`LOGOW-1)))
       begin
		     if(r_logo[2][w_CounterX-`LOGOXLOC] == 1)
						  drawWhite();
			  else
						  drawRotatingBG();
	    end
	 else
    if(w_CounterY == `LOGOYLOG+3 && (w_CounterX >= `LOGOXLOC && w_CounterX <= `LOGOXLOC+(`LOGOW-1)))
       begin
		     if(r_logo[3][w_CounterX-`LOGOXLOC] == 1)
						  drawWhite();
			  else
						  drawRotatingBG();
	    end
	 else
    if(w_CounterY == `LOGOYLOG+4 && (w_CounterX >= `LOGOXLOC && w_CounterX <= `LOGOXLOC+(`LOGOW-1)))
       begin
		     if(r_logo[4][w_CounterX-`LOGOXLOC] == 1)
						  drawWhite();
			  else
						  drawRotatingBG();
	    end
	 else
	 if(w_CounterY == `LOGOYLOG+5 && (w_CounterX >= `LOGOXLOC && w_CounterX <= `LOGOXLOC+(`LOGOW-1)))
       begin
		     if(r_logo[5][w_CounterX-`LOGOXLOC] == 1)
						  drawWhite();
			  else
						  drawRotatingBG();
	    end
	 else
	 if(w_CounterY == `LOGOYLOG+6 && (w_CounterX >= `LOGOXLOC && w_CounterX <= `LOGOXLOC+(`LOGOW-1)))
       begin
		     if(r_logo[6][w_CounterX-`LOGOXLOC] == 1)
						  drawWhite();
			  else
						  drawRotatingBG();
	    end
	 else
	 if(w_CounterY == `LOGOYLOG+7 && (w_CounterX >= `LOGOXLOC && w_CounterX <= `LOGOXLOC+(`LOGOW-1)))
       begin
		     if(r_logo[7][w_CounterX-`LOGOXLOC] == 1)
						  drawWhite();
			  else
						  drawRotatingBG();
	    end
	 else
	 if(w_CounterY == `LOGOYLOG+8 && (w_CounterX >= `LOGOXLOC && w_CounterX <= `LOGOXLOC+(`LOGOW-1)))
       begin
		     if(r_logo[8][w_CounterX-`LOGOXLOC] == 1)
						  drawWhite();
			  else
						  drawRotatingBG();
	    end
	 else
	 if(w_CounterY == `LOGOYLOG+9 && (w_CounterX >= `LOGOXLOC && w_CounterX <= `LOGOXLOC+(`LOGOW-1)))
       begin
		     if(r_logo[9][w_CounterX-`LOGOXLOC] == 1)
						  drawWhite();
			  else
						  drawRotatingBG();
	    end
	 else
	 if(w_CounterY == `LOGOYLOG+10 && (w_CounterX >= `LOGOXLOC && w_CounterX <= `LOGOXLOC+(`LOGOW-1)))
       begin
		     if(r_logo[10][w_CounterX-`LOGOXLOC] == 1)
						  drawWhite();
			  else
						  drawRotatingBG();
	    end
	 else
	 if(w_CounterY == `LOGOYLOG+11 && (w_CounterX >= `LOGOXLOC && w_CounterX <= `LOGOXLOC+(`LOGOW-1)))
       begin
		     if(r_logo[11][w_CounterX-`LOGOXLOC] == 1)
						  drawWhite();
			  else
						  drawRotatingBG();
	    end
	 else
	 if(w_CounterY == `LOGOYLOG+12 && (w_CounterX >= `LOGOXLOC && w_CounterX <= `LOGOXLOC+(`LOGOW-1)))
       begin
		     if(r_logo[12][w_CounterX-`LOGOXLOC] == 1)
						  drawWhite();
			  else
						  drawRotatingBG();
	    end
	 else
	 if(w_CounterY == `LOGOYLOG+13 && (w_CounterX >= `LOGOXLOC && w_CounterX <= `LOGOXLOC+(`LOGOW-1)))
       begin
		     if(r_logo[13][w_CounterX-`LOGOXLOC] == 1)
						  drawWhite();
			  else
						  drawRotatingBG();
	    end
	 else
	 if(w_CounterY == `LOGOYLOG+14 && (w_CounterX >= `LOGOXLOC && w_CounterX <= `LOGOXLOC+(`LOGOW-1)))
       begin
		     if(r_logo[14][w_CounterX-`LOGOXLOC] == 1)
						  drawWhite();
			  else
						  drawRotatingBG();
	    end
	 else
	 if(w_CounterY == `LOGOYLOG+15 && (w_CounterX >= `LOGOXLOC && w_CounterX <= `LOGOXLOC+(`LOGOW-1)))
       begin
		     if(r_logo[15][w_CounterX-`LOGOXLOC] == 1)
						  drawWhite();
			  else
						  drawRotatingBG();
	    end
	 else
	    begin
	        drawFromRAM();
		 end
	
end
endfunction



	 

// module that produces VGA sync signals and produces a "inDisplayArea" flag (VGA clock is 25.17MHZ) 
hvsync_generator hvsync(
      .i_clk(i_vgaclk),
      .o_vga_h_sync(o_hsync),
      .o_vga_v_sync(o_vsync),
      .o_HCounterX(w_CounterX),
      .o_HCounterY(w_CounterY),
      .o_inDisplayArea(w_inDisplayArea)
    );

// every pixel clock, pull a byte from the dual port RAM
always @(posedge i_vgaclk) 
begin

	  r_QSecCtr <= r_QSecCtr + 1'b1;
	  if(r_QSecCtr >= 6250000)
	  begin
	      r_QSecCtr <= 0;
			r_logo_rgb = r_logo_rgb << 1;
			if(r_logo_rgb == 0)
			    r_logo_rgb = 1;
	  end

    begin
		 if(w_inDisplayArea)
		     begin
			     // draw a border around the screen
				  if(r_bShowLogo == 1)
				       begin
								drawLogo();
						 end
				  else
						 begin
						      drawFromRAM();
						 end
				  end
		 else
			  // set RGB pixel to all zeroes if we're in a blanking area
			  begin
				  o_vr[0] <= 0;
				  o_vg[0] <= 0;
				  o_vb[0] <= 0;
				  o_vr[1] <= 0;
				  o_vg[1] <= 0;
				  o_vb[1] <= 0;
			  end
		 end
end
	 
	 
	 
	 
endmodule
