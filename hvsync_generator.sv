/**************************************************************************************************
**
** HSYNC Generator for 640 x 480 resolution.  Produces horizontal and vertical counters based on 
** input clock (25.17MHZ clock produced by PLL and on-board oscillator)
**
**************************************************************************************************/

module hvsync_generator(
    input clk,
    output vga_h_sync,
    output vga_v_sync,
    output reg inDisplayArea,
    output reg [9:0] HCounterX,
    output reg [9:0] HCounterY
  );
    reg vga_HS, vga_VS;

    wire CounterXmaxed = (HCounterX == 800); // 16 + 48 + 96 + 640
    wire CounterYmaxed = (HCounterY == 525); // 10 + 2 + 33 + 480

 always @(posedge clk)
	 begin
    if (CounterXmaxed)
      HCounterX <= 0;
    else
      HCounterX <= (HCounterX + 1'b1);
    end
		
 always @(posedge clk)
    begin
      if (CounterXmaxed)
      begin
        if(CounterYmaxed)
          HCounterY <= 0;
        else
          HCounterY <= (HCounterY + 1'b1);
      end
    end

 always @(posedge clk)
    begin
      vga_HS <= (HCounterX > (640 + 16) && (HCounterX < (640 + 16 + 96)));   // active for 96 clocks
      vga_VS <= (HCounterY > (480 + 10) && (HCounterY < (480 + 10 + 2)));   // active for 2 clocks
    end

 always @(posedge clk)
    begin
        inDisplayArea <= (HCounterX < 640) && (HCounterY < 480);
    end

	 
    assign vga_h_sync = ~vga_HS;
    assign vga_v_sync = ~vga_VS;

endmodule