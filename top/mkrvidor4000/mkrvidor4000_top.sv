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
    input MIPI_CLK,
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

wire FLASH_CLK;

// internal oscillator
cyclone10lp_oscillator osc ( 
    .clkout(OSC_CLK),
    .oscena(1'b1)
);

mem_pll mem_pll (
    .inclk0(CLK_48MHZ),
    .c0(SDRAM_CLK)
);

wire clk_pixel_x5;
wire clk_pixel;
wire clk_audio;
hdmi_pll hdmi_pll(.inclk0(CLK_48MHZ), .c0(clk_pixel), .c1(clk_pixel_x5), .c2(clk_audio));

localparam AUDIO_BIT_WIDTH = 16;
localparam AUDIO_RATE = 48000;
localparam WAVE_RATE = 480;

logic [AUDIO_BIT_WIDTH-1:0] audio_sample_word;
// sawtooth #(.BIT_WIDTH(AUDIO_BIT_WIDTH), .SAMPLE_RATE(AUDIO_RATE), .WAVE_RATE(WAVE_RATE)) sawtooth (.clk_audio(clk_audio), .level(audio_sample_word));

logic [23:0] rgb;
logic [9:0] cx, cy, screen_start_x, screen_start_y;
hdmi #(.VIDEO_ID_CODE(1),
.DDRIO(1), .AUDIO_RATE(AUDIO_RATE), .AUDIO_BIT_WIDTH(AUDIO_BIT_WIDTH)) hdmi(.clk_pixel_x10(clk_pixel_x5), .clk_pixel(clk_pixel), .clk_audio(clk_audio), .rgb(rgb), .audio_sample_word('{audio_sample_word, audio_sample_word}), .tmds_p(HDMI_TX), .tmds_clock_p(HDMI_CLK), .tmds_n(HDMI_TX_N), .tmds_clock_n(HDMI_CLK_N), .cx(cx), .cy(cy), .screen_start_x(screen_start_x), .screen_start_y(screen_start_y));

logic [1:0] mode = 2'd0;
logic [1:0] resolution = 2'd3; // 640x480 @ 30FPS
logic format = 1'd0;
logic ready;
logic model_err;
logic nack_err;

ov5647 #(.TARGET_SCL_RATE(100000)) ov5647 (
    .clk_in(CLK_48MHZ),
    .scl(MIPI_SCL),
    .sda(MIPI_SDA),
    .mode(mode),
    .resolution(resolution),
    .format(format),
    .ready(ready),
    .power_enable(MIPI_GP[0]),
    .model_err(model_err),
    .nack_err(nack_err)
);

logic [7:0] image_data [0:3];
logic [5:0] image_data_type;
logic image_data_enable;
logic [15:0] word_count;
logic frame_start, frame_end;
logic [1:0] enable;
camera #(.NUM_LANES(2)) camera (
    .clock_p(MIPI_CLK),
    .data_p(MIPI_D),
    .image_data(image_data),
    .image_data_type(image_data_type),
    .image_data_enable(image_data_enable),
    .word_count(word_count),
    .frame_start(frame_start),
    .frame_end(frame_end)
);

// logic [7:0] raw [3:0];
// logic raw_enable;
// raw8 raw8 (.image_data(image_data), .image_data_enable(image_data_enable), .raw(raw), .raw_enable(raw_enable));

logic [25:0] camera_counter = 26'd0;
always @(posedge CLK_48MHZ)
    camera_counter <= camera_counter + 1'd1;

always @(posedge CLK_48MHZ)
    if (ready && mode == 2'd0)
        mode <= 2'd1;
    else if (ready && mode == 2'd1 && camera_counter == 26'd67108863)
        mode <= 2'd2;

logic pixel_enable;
assign pixel_enable = cx >= screen_start_x && cy >= screen_start_y;
logic [7:0] pixel;
arbiter arbiter (
    .pixel_clk(clk_pixel),
    .pixel_enable(pixel_enable),
    .pixel(pixel),
    .mipi_clk(MIPI_CLK),
    .mipi_data_enable(image_data_enable),
    .mipi_data(image_data),
    .sdram_clk(SDRAM_CLK),
    .clock_enable(SDRAM_CKE),
    .bank_activate(SDRAM_BA),
    .address(SDRAM_ADDR),
    .chip_select(SDRAM_CSn),
    .row_address_strobe(SDRAM_RASn),
    .column_address_strobe(SDRAM_CASn),
    .write_enable(SDRAM_WEn),
    .dqm(SDRAM_DQM),
    .dq(SDRAM_DQ)
);

always @(posedge clk_pixel)
begin
    if (pixel_enable)
        rgb <= {pixel, pixel, pixel};
end

// logic [7:0] codepoints [0:3];
// always @(posedge SDRAM_CLK) if (image_data_enable) codepoints <= '{pixel_producer + 8'h30, mipi_consumer + 8'h30, 8'h30 + 8'(command), 8'h29};//'{image_data[1][7:4] + 8'h30, image_data[1][7:4] + 8'h30, image_data[0][7:4] + 8'h30, image_data[0][3:0] + 8'h30};

// logic [1:0] counter = 2'd0;
// logic [5:0] prevcy = 6'd0;
// always @(posedge clk_pixel)
// begin
//     if (cy == 10'd0)
//     begin
//         prevcy <= 6'd0;
//     end
//     else if (prevcy != cy[9:4])
//     begin
//         counter <= counter + 1'd1;
//         prevcy <= cy[9:4];
//     end
// end

// console console(.clk_pixel(clk_pixel), .codepoint(codepoints[counter]), .attribute({cx[9], cy[8:6], cx[8:5]}), .cx(cx), .cy(cy), .rgb(rgb));

endmodule
