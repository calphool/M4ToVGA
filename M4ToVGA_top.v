// Copyright (C) 2020  Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions 
// and other software and tools, and any partner logic 
// functions, and any output files from any of the foregoing 
// (including device programming or simulation files), and any 
// associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License 
// Subscription Agreement, the Intel Quartus Prime License Agreement,
// the Intel FPGA IP License Agreement, or other applicable license
// agreement, including, without limitation, that your use is for
// the sole purpose of programming logic devices manufactured by
// Intel and sold by Intel or its authorized distributors.  Please
// refer to the applicable agreement for further details, at
// https://fpgasoftware.intel.com/eula.

// PROGRAM		"Quartus Prime"
// VERSION		"Version 20.1.0 Build 711 06/05/2020 SJ Lite Edition"
// CREATED		"Mon Nov 23 00:30:42 2020"

module M4ToVGA_top(
	external_clock,
	m4_hsync,
	m4_vsync,
	m4_video,
	m4_dotclk,
	vga_vsync,
	vga_hsync,
	LEDS0,
	LEDS1,
	LEDS2,
	LEDS3,
	PIXSTATE_PIN59,
	DOTCLKP2_PIN64,
	WADDR0_PIN66,
	WADDR1_PIN68,
	WADDR2_PIN70,
	WADDR3_PIN72,
	FB_DATAOUT_PIN74,
	VGA_CLKOUT_PIN76,
	vb,
	vg,
	vr
);


input wire	external_clock;
input wire	m4_hsync;
input wire	m4_vsync;
input wire	m4_video;
input wire	m4_dotclk;
output wire	vga_vsync;
output wire	vga_hsync;
output wire	LEDS0;
output wire	LEDS1;
output wire	LEDS2;
output wire	LEDS3;
output wire	PIXSTATE_PIN59;
output wire	DOTCLKP2_PIN64;
output wire	WADDR0_PIN66;
output wire	WADDR1_PIN68;
output wire	WADDR2_PIN70;
output wire	WADDR3_PIN72;
output wire	FB_DATAOUT_PIN74;
output wire	VGA_CLKOUT_PIN76;
output wire	[1:0] vb;
output wire	[1:0] vg;
output wire	[1:0] vr;

wire	50MHZ_CLK_WIRE;
wire	c0_vgaclk;
wire	[17:0] rdaddress;
wire	rdclock;
wire	[1:0] vb_ALTERA_SYNTHESIZED;
wire	[1:0] vg_ALTERA_SYNTHESIZED;
wire	[1:0] vr_ALTERA_SYNTHESIZED;
wire	w_bit_from_framebuffer;
wire	w_pixel_state;
wire	w_vga_hsync;
wire	w_vga_vsync;
wire	w_wren;
wire	[17:0] waddr;

assign	DOTCLKP2_PIN64 = m4_dotclk;




vgaclk	b2v_inst(
	.inclk0(50MHZ_CLK_WIRE),
	.c0(c0_vgaclk));


framebuffer	b2v_inst1(
	.wren(w_wren),
	.wrclock(m4_dotclk),
	.rdclock(rdclock),
	.data(w_pixel_state),
	.rdaddress(rdaddress),
	.wraddress(waddr),
	.q(w_bit_from_framebuffer));


vga_out	b2v_inst2(
	.vgaclk(c0_vgaclk),
	.bit_from_ram(w_bit_from_framebuffer),
	.vsync(w_vga_vsync),
	.hsync(w_vga_hsync),
	.raddr(rdaddress),
	.vb(vb_ALTERA_SYNTHESIZED),
	.vg(vg_ALTERA_SYNTHESIZED),
	.vr(vr_ALTERA_SYNTHESIZED));


m4_input	b2v_inst5(
	.hsync(m4_hsync),
	.vsync(m4_vsync),
	.video(m4_video),
	.dotclk(m4_dotclk),
	.pixel_state(w_pixel_state),
	.wren(w_wren),
	.leds0(LEDS0),
	.leds1(LEDS1),
	.leds2(LEDS2),
	.leds3(LEDS3),
	.waddr(waddr));

assign	rdclock =  ~c0_vgaclk;

assign	vga_vsync = w_vga_vsync;
assign	50MHZ_CLK_WIRE = external_clock;
assign	vga_hsync = w_vga_hsync;
assign	PIXSTATE_PIN59 = w_pixel_state;
assign	WADDR0_PIN66 = waddr[0];
assign	WADDR1_PIN68 = waddr[1];
assign	WADDR2_PIN70 = waddr[2];
assign	WADDR3_PIN72 = waddr[3];
assign	FB_DATAOUT_PIN74 = w_bit_from_framebuffer;
assign	VGA_CLKOUT_PIN76 = c0_vgaclk;
assign	vb = vb_ALTERA_SYNTHESIZED;
assign	vg = vg_ALTERA_SYNTHESIZED;
assign	vr = vr_ALTERA_SYNTHESIZED;

endmodule
