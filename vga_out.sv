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
	 reg [31:0] clkCtr;
	 reg [24:0] QSecCtr;
	 reg bShowLogo;
	 reg [0:`LOGOW-1] logo [16];
	 reg [5:0] logo_rgb;

	 
// registers
    wire inDisplayArea;
    wire [9:0] CounterX;
	 wire [9:0] CounterY;
	 
	 
initial
begin
    clkCtr <= 0;
	 QSecCtr <= 0;
	 logo_rgb <= 1;
	 bShowLogo = 1;
	 
    logo[0] <= `LOGOW'b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;

	 logo[1] <= `LOGOW'b0010001010001011111001110010001001110000100000000010001000010000000000010000000001110000110001110000110000010000;
	 logo[2] <= `LOGOW'b0011011010001000100010001010001010000001010000000010001000110000000000110000000010101001001010001001001000110000;
	 logo[3] <= `LOGOW'b0010101010001000100010001010001010000010001000000010001000010000000000010000000011001000010010001000010000010000;
	 logo[4] <= `LOGOW'b0010001011111000100010001001010010111011111000000001010000010000000000010000000011001000100010001000100000010000;
	 logo[5] <= `LOGOW'b0010001000001000100010001000100010001010001000000001010000010000110000010000000010101001000010001001000000010000;
	 logo[6] <= `LOGOW'b0010001000001000100001110000100001110010001000000000100000010000110000010000000001110001111001110001111000010000;

    logo[7] <= `LOGOW'b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
    logo[8] <= `LOGOW'b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;

    logo[9] <= `LOGOW'b0011111000000000000000000011110000000000000000000000000000000000000000000000100000100000000000000000000000000000;
    logo[10]<= `LOGOW'b0000010000000000000000000010001000000000000000000000000000000000000000100000100000100000000000000000000000000000;
    logo[11]<= `LOGOW'b0000010001110001110000000010001001110010001011110001111001110010001000000000100000100001110000000000000000000000;
    logo[12]<= `LOGOW'b0010010010001011111000000011110010001010001010001010000011111010001000100000100000100011111000000000000000000000;
    logo[13]<= `LOGOW'b0010010010001010000000000010001010001010001010001010000010000001010000100000100000100010000000000000000000000000;
    logo[14]<= `LOGOW'b0001100001110001110000000010001001110001111010001001111001110000100000100000100000100001111000000000000000000000;

	 logo[15]<= `LOGOW'b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;

end

	 
	 
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
	  			
	  clkCtr <= clkCtr + 1;
	  if(bShowLogo == 1)
	  begin
		  if(clkCtr > 250000000)
			  begin
				  bShowLogo = 0;
			  end
	  end
end



function void drawFG;
begin
			  vr[0] = fg_r0_ff2;
			  vr[1] = fg_r1_ff2;
			  vg[0] = fg_g0_ff2;
			  vg[1] = fg_g1_ff2;
			  vb[0] = fg_b0_ff2;
			  vb[1] = fg_b1_ff2;
			  raddr[17:0] = TRUNC' (((CounterY / 2) * 800) + CounterX);
end
endfunction



function void drawWhite;
begin
			  vr[0] = 1;
			  vr[1] = 1;
			  vg[0] = 1;
			  vg[1] = 1;
			  vb[0] = 1;
			  vb[1] = 1;
			  raddr[17:0] = TRUNC' (((CounterY / 2) * 800) + CounterX);
end
endfunction



function void drawRotatingBG;
begin
			  vr[0] = logo_rgb[0];
			  vr[1] = logo_rgb[1];
			  vg[0] = logo_rgb[2];
			  vg[1] = logo_rgb[3];
			  vb[0] = logo_rgb[4];
			  vb[1] = logo_rgb[5];			  
end
endfunction


function void drawBG;
begin
			  vr[0] = bg_r0_ff2;
			  vr[1] = bg_r1_ff2;
			  vg[0] = bg_g0_ff2;
			  vg[1] = bg_g1_ff2;
			  vb[0] = bg_b0_ff2;
			  vb[1] = bg_b1_ff2;
			  raddr[17:0] = TRUNC' (((CounterY / 2) * 800) + CounterX);
end
endfunction



function void drawFromRAM;
begin
	 if(bit_from_ram)
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
	 
	 if(CounterX == `LOGOXLOC)
	 begin
			logo_rgb = logo_rgb << 1;
			if(logo_rgb == 0)
				 logo_rgb = 1;
	 end

	 
    if(CounterY+0 == `LOGOYLOG+0 && (CounterX >= `LOGOXLOC && CounterX <= `LOGOXLOC+(`LOGOW-1)))
		 begin
		     if(logo[0][CounterX-`LOGOXLOC] == 1)
						  drawWhite();
			  else
						  drawRotatingBG();
		 end
	 else
    if(CounterY == `LOGOYLOG+1 && (CounterX >= `LOGOXLOC && CounterX <= `LOGOXLOC+(`LOGOW-1)))
       begin
		     if(logo[1][CounterX-`LOGOXLOC] == 1)
						  drawWhite();
			  else
						  drawRotatingBG();
	    end
	 else
    if(CounterY == `LOGOYLOG+2 && (CounterX >= `LOGOXLOC && CounterX <= `LOGOXLOC+(`LOGOW-1)))
       begin
		     if(logo[2][CounterX-`LOGOXLOC] == 1)
						  drawWhite();
			  else
						  drawRotatingBG();
	    end
	 else
    if(CounterY == `LOGOYLOG+3 && (CounterX >= `LOGOXLOC && CounterX <= `LOGOXLOC+(`LOGOW-1)))
       begin
		     if(logo[3][CounterX-`LOGOXLOC] == 1)
						  drawWhite();
			  else
						  drawRotatingBG();
	    end
	 else
    if(CounterY == `LOGOYLOG+4 && (CounterX >= `LOGOXLOC && CounterX <= `LOGOXLOC+(`LOGOW-1)))
       begin
		     if(logo[4][CounterX-`LOGOXLOC] == 1)
						  drawWhite();
			  else
						  drawRotatingBG();
	    end
	 else
	 if(CounterY == `LOGOYLOG+5 && (CounterX >= `LOGOXLOC && CounterX <= `LOGOXLOC+(`LOGOW-1)))
       begin
		     if(logo[5][CounterX-`LOGOXLOC] == 1)
						  drawWhite();
			  else
						  drawRotatingBG();
	    end
	 else
	 if(CounterY == `LOGOYLOG+6 && (CounterX >= `LOGOXLOC && CounterX <= `LOGOXLOC+(`LOGOW-1)))
       begin
		     if(logo[6][CounterX-`LOGOXLOC] == 1)
						  drawWhite();
			  else
						  drawRotatingBG();
	    end
	 else
	 if(CounterY == `LOGOYLOG+7 && (CounterX >= `LOGOXLOC && CounterX <= `LOGOXLOC+(`LOGOW-1)))
       begin
		     if(logo[7][CounterX-`LOGOXLOC] == 1)
						  drawWhite();
			  else
						  drawRotatingBG();
	    end
	 else
	 if(CounterY == `LOGOYLOG+8 && (CounterX >= `LOGOXLOC && CounterX <= `LOGOXLOC+(`LOGOW-1)))
       begin
		     if(logo[8][CounterX-`LOGOXLOC] == 1)
						  drawWhite();
			  else
						  drawRotatingBG();
	    end
	 else
	 if(CounterY == `LOGOYLOG+9 && (CounterX >= `LOGOXLOC && CounterX <= `LOGOXLOC+(`LOGOW-1)))
       begin
		     if(logo[9][CounterX-`LOGOXLOC] == 1)
						  drawWhite();
			  else
						  drawRotatingBG();
	    end
	 else
	 if(CounterY == `LOGOYLOG+10 && (CounterX >= `LOGOXLOC && CounterX <= `LOGOXLOC+(`LOGOW-1)))
       begin
		     if(logo[10][CounterX-`LOGOXLOC] == 1)
						  drawWhite();
			  else
						  drawRotatingBG();
	    end
	 else
	 if(CounterY == `LOGOYLOG+11 && (CounterX >= `LOGOXLOC && CounterX <= `LOGOXLOC+(`LOGOW-1)))
       begin
		     if(logo[11][CounterX-`LOGOXLOC] == 1)
						  drawWhite();
			  else
						  drawRotatingBG();
	    end
	 else
	 if(CounterY == `LOGOYLOG+12 && (CounterX >= `LOGOXLOC && CounterX <= `LOGOXLOC+(`LOGOW-1)))
       begin
		     if(logo[12][CounterX-`LOGOXLOC] == 1)
						  drawWhite();
			  else
						  drawRotatingBG();
	    end
	 else
	 if(CounterY == `LOGOYLOG+13 && (CounterX >= `LOGOXLOC && CounterX <= `LOGOXLOC+(`LOGOW-1)))
       begin
		     if(logo[13][CounterX-`LOGOXLOC] == 1)
						  drawWhite();
			  else
						  drawRotatingBG();
	    end
	 else
	 if(CounterY == `LOGOYLOG+14 && (CounterX >= `LOGOXLOC && CounterX <= `LOGOXLOC+(`LOGOW-1)))
       begin
		     if(logo[14][CounterX-`LOGOXLOC] == 1)
						  drawWhite();
			  else
						  drawRotatingBG();
	    end
	 else
	 if(CounterY == `LOGOYLOG+15 && (CounterX >= `LOGOXLOC && CounterX <= `LOGOXLOC+(`LOGOW-1)))
       begin
		     if(logo[15][CounterX-`LOGOXLOC] == 1)
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

	  QSecCtr <= QSecCtr + 1'b1;
	  if(QSecCtr >= 6250000)
	  begin
	      QSecCtr <= 0;
			logo_rgb = logo_rgb << 1;
			if(logo_rgb == 0)
			    logo_rgb = 1;
	  end

    begin
		 if(inDisplayArea)
		     begin
			     // draw a border around the screen
				  if(bShowLogo == 1)
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
