module mkrvidor4000_top
(
  // system signals
  input CLK_48MHZ,
  input RESETn,
  input SAM_INT_IN,
  output SAM_INT_OUT,
  
  // SDRAM
  output SDRAM_CLK,
  output [11:0] SDRAM_ADDR,
  output [1:0] SDRAM_BA,
  output SDRAM_CASn,
  output SDRAM_CKE,
  output SDRAM_CSn,
  inout [15:0] SDRAM_DQ,
  output [1:0] SDRAM_DQM,
  output SDRAM_RASn,
  output SDRAM_WEn,

  // SAM D21 PINS
  inout MKR_AREF,
  inout [6:0] MKR_A,
  inout [14:0] MKR_D,
  
  // Mini PCIe
  inout PEX_RST,
  inout PEX_PIN6,
  inout PEX_PIN8,
  inout PEX_PIN10,
  input PEX_PIN11,
  inout PEX_PIN12,
  input PEX_PIN13,
  inout PEX_PIN14,
  inout PEX_PIN16,
  inout PEX_PIN20,
  input PEX_PIN23,
  input PEX_PIN25,
  inout PEX_PIN28,
  inout PEX_PIN30,
  input PEX_PIN31,
  inout PEX_PIN32,
  input PEX_PIN33,
  inout PEX_PIN42,
  inout PEX_PIN44,
  inout PEX_PIN45,
  inout PEX_PIN46,
  inout PEX_PIN47,
  inout PEX_PIN48,
  inout PEX_PIN49,
  inout PEX_PIN51,

  // NINA interface
  inout WM_PIO1,
  inout WM_PIO2,
  inout WM_PIO3,
  inout WM_PIO4,
  inout WM_PIO5,
  inout WM_PIO7,
  inout WM_PIO8,
  inout WM_PIO18,
  inout WM_PIO20,
  inout WM_PIO21,
  inout WM_PIO27,
  inout WM_PIO28,
  inout WM_PIO29,
  inout WM_PIO31,
  input WM_PIO32,
  inout WM_PIO34,
  inout WM_PIO35,
  inout WM_PIO36,
  input WM_TX,
  inout WM_RX,
  inout WM_RESET,

  // HDMI output
  output [2:0] HDMI_TX,
  output [2:0] HDMI_TX_N,
  output HDMI_CLK,
  output HDMI_CLK_N,
  inout HDMI_SDA,
  inout HDMI_SCL,
  
  input HDMI_HPD,
  
  // MIPI input
  input [1:0] MIPI_D,
//   input [1:0] MIPI_D_N,
  input MIPI_CLK,
//   input MIPI_CLK_N,
  inout MIPI_SDA,
  inout MIPI_SCL,
  inout [1:0] MIPI_GP,

  // Q-SPI Flash interface
  output FLASH_SCK,
  output FLASH_CS,
  inout FLASH_MOSI,
  inout FLASH_MISO,
  inout FLASH_HOLD,
  inout FLASH_WP

);

// signal declaration
wire OSC_CLK;

wire [31:0] JTAG_ADDRESS, JTAG_READ_DATA, JTAG_WRITE_DATA, DPRAM_READ_DATA;
wire JTAG_READ, JTAG_WRITE, JTAG_WAIT_REQUEST, JTAG_READ_DATAVALID;
wire [4:0] JTAG_BURST_COUNT;
wire DPRAM_CS;

wire [7:0] DVI_RED,DVI_GRN,DVI_BLU;
wire DVI_HS, DVI_VS, DVI_DE;

wire MEM_CLK;
wire FLASH_CLK;

// internal oscillator
cyclone10lp_oscillator osc ( 
    .clkout(OSC_CLK),
    .oscena(1'b1)
);

mem_pll mem_pll (
    .inclk0(CLK_48MHZ),
    .c0(MEM_CLK),
    .c1(SDRAM_CLK),
    .c2(FLASH_CLK)
);

wire clk_pixel_x5;
wire clk_pixel;
wire clk_audio;
hdmi_pll hdmi_pll(.inclk0(CLK_48MHZ), .c0(clk_pixel), .c1(clk_pixel_x5), .c2(clk_audio));

localparam AUDIO_BIT_WIDTH = 16;
localparam AUDIO_RATE = 48000;
localparam WAVE_RATE = 480;

logic [AUDIO_BIT_WIDTH-1:0] audio_sample_word;
sawtooth #(.BIT_WIDTH(AUDIO_BIT_WIDTH), .SAMPLE_RATE(AUDIO_RATE), .WAVE_RATE(WAVE_RATE)) sawtooth (.clk_audio(clk_audio), .level(audio_sample_word));

logic [23:0] rgb;
logic [9:0] cx, cy;
hdmi #(.VIDEO_ID_CODE(4), .DDRIO(1), .AUDIO_RATE(AUDIO_RATE), .AUDIO_BIT_WIDTH(AUDIO_BIT_WIDTH)) hdmi(.clk_pixel_x10(clk_pixel_x5), .clk_pixel(clk_pixel), .clk_audio(clk_audio), .rgb(rgb), .audio_sample_word('{audio_sample_word, audio_sample_word}), .tmds_p(HDMI_TX), .tmds_clock_p(HDMI_CLK), .tmds_n(HDMI_TX_N), .tmds_clock_n(HDMI_CLK_N), .cx(cx), .cy(cy));


logic [1:0] mode = 2'd2; // Immediately enter streaming
logic [1:0] resolution = 2'd3; // 640x480 @ 30FPS
logic format = 1'd1;
logic ready;
logic model_err;
logic nack_err;

imx219 imx219 (
    .clk_in(CLK_48MHZ),
    .scl(MIPI_SCL),
    .sda(MIPI_SDA),
    .mode(mode),
    .resolution(resolution),
    .format(format),
    .ready(ready),
    .power_enable(MIPI_GP[0]),
    // IMX219 Model ID did not match
    .model_err(model_err),
    .nack_err(nack_err)
);

camera #(.NUM_LANES(2)) camera (
    .clock_p(MIPI_CLK),
    .data_p(MIPI_D)
);

endmodule
