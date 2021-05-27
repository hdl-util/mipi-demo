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

    // HDMI output
    output [2:0] HDMI_TX,
    output HDMI_CLK,
    inout HDMI_SDA,
    inout HDMI_SCL,

    input HDMI_HPD,

    // MIPI input
    input [1:0] MIPI_D,
    input MIPI_CLK,
    inout MIPI_SDA,
    inout MIPI_SCL,
    inout [1:0] MIPI_GP

);

// internal oscillator
wire OSC_CLK;
cyclone10lp_oscillator osc ( 
    .clkout(OSC_CLK),
    .oscena(1'b1)
);

mem_pll mem_pll(.inclk0(CLK_48MHZ), .c0(SDRAM_CLK));

wire clk_pixel_x5;
wire clk_pixel;
wire clk_audio;
hdmi_pll hdmi_pll(.inclk0(CLK_48MHZ), .c0(clk_pixel), .c1(clk_pixel_x5), .c2(clk_audio));

localparam AUDIO_BIT_WIDTH = 16;
localparam AUDIO_RATE = 48000;
localparam WAVE_RATE = 240;

logic [AUDIO_BIT_WIDTH-1:0] audio_sample_word;
sawtooth #(.BIT_WIDTH(AUDIO_BIT_WIDTH), .SAMPLE_RATE(AUDIO_RATE), .WAVE_RATE(WAVE_RATE)) sawtooth (.clk_audio(clk_audio), .level(audio_sample_word));

logic [23:0] rgb;
logic [9:0] cx, cy, screen_width, screen_height;
hdmi #(.VIDEO_ID_CODE(1), .AUDIO_RATE(AUDIO_RATE), .AUDIO_BIT_WIDTH(AUDIO_BIT_WIDTH)) hdmi(
    .clk_pixel_x5(clk_pixel_x5),
    .clk_pixel(clk_pixel),
    .clk_audio(clk_audio),
    .rgb(rgb),
    .audio_sample_word('{audio_sample_word >> 9, audio_sample_word >> 9}),
    .tmds(HDMI_TX),
    .tmds_clock(HDMI_CLK),
    .cx(cx),
    .cy(cy),
    .screen_width(screen_width),
    .screen_height(screen_height)
);

logic [1:0] mode = 2'd0;
logic [1:0] resolution = 2'd3; // 640x480 @ 30FPS
logic format = 1'd0; // RAW8
logic ready;
logic model_err;
logic nack_err;

ov5647 #(.INPUT_CLK_RATE(48_000_000), .TARGET_SCL_RATE(100_000)) ov5647 (
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

logic [7:0] image_data [3:0];
logic [5:0] image_data_type;
logic image_data_enable;
logic [15:0] word_count;
logic frame_start, line_start, interrupt, frame_end;
camera #(.NUM_LANES(2)) camera (
    .clock_p(MIPI_CLK),
    .data_p(MIPI_D),
    .image_data(image_data),
    .image_data_type(image_data_type),
    .image_data_enable(image_data_enable),
    .word_count(word_count),
    .frame_start(frame_start),
    .frame_end(frame_end),
    .line_start(line_start),
    .interrupt(interrupt)
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
    else if (ready && mode == 2'd1 && camera_counter + 1'd1 == 26'd0)
        mode <= 2'd2;

logic pixel_enable;
assign pixel_enable = cx < screen_width && cy < screen_height;
logic [7:0] pixel;

arbiter arbiter (
    .pixel_clk(clk_pixel),
    .pixel_enable(pixel_enable),
    .pixel(pixel),
    .mipi_clk(MIPI_CLK),
    .mipi_data_enable(image_data_enable),
    .mipi_data(image_data),
    .frame_start(frame_start),
    .line_start(line_start),
    .interrupt(interrupt),
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
    rgb <= {pixel, pixel, pixel};

endmodule
