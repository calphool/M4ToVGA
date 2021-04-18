/**************************************************************************************************
**
** HSYNC Generator for 640 x 480 resolution.  Produces horizontal and vertical counters based on 
** input clock (25MHZ clock produced by PLL and on-board oscillator)
**
**************************************************************************************************/

module hvsync_generator(
    input  i_clk,
    output o_vga_h_sync,
    output o_vga_v_sync,
    output reg o_inDisplayArea,
    output reg [9:0] o_HCounterX,
    output reg [9:0] o_HCounterY
  );
    reg vga_HS, vga_VS;

    wire w_CounterXmaxed = (o_HCounterX == 800); // 16 + 48 + 96 + 640
    wire w_CounterYmaxed = (o_HCounterY == 525); // 10 + 2 + 33 + 480

 always @(posedge i_clk)
	 begin
    if (w_CounterXmaxed)
      o_HCounterX <= 0;
    else
      o_HCounterX <= (o_HCounterX + 1'b1);
    end
		
 always @(posedge i_clk)
    begin
      if (w_CounterXmaxed)
      begin
        if(w_CounterYmaxed)
          o_HCounterY <= 0;
        else
          o_HCounterY <= (o_HCounterY + 1'b1);
      end
    end

 always @(posedge i_clk)
    begin
      vga_HS <= (o_HCounterX > (640 + 16) && (o_HCounterX < (640 + 16 + 96)));   // active for 96 clocks
      vga_VS <= (o_HCounterY > (480 + 10) && (o_HCounterY < (480 + 10 + 2)));   // active for 2 clocks
    end

 always @(posedge i_clk)
    begin
        o_inDisplayArea <= (o_HCounterX < 640) && (o_HCounterY < 480);
    end

	 
    assign o_vga_h_sync = ~vga_HS;
    assign o_vga_v_sync = ~vga_VS;

endmodule