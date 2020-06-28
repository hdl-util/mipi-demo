module arbiter #(
    parameter VIDEO_END = (640 * 480) / 2 // RAW8 --> 2 pixels per 16-bit memory address
) (
    input logic pixel_clk,
    input logic pixel_enable,
    output logic [7:0] pixel,

    input logic mipi_clk,
    input logic mipi_data_enable,
    input logic [7:0] mipi_data [3:0],
    input logic frame_start,
    input logic line_start,
    input logic interrupt,

    input logic sdram_clk,
	output logic clock_enable,
	output logic [1:0] bank_activate,
	output logic [11:0] address,
	output logic chip_select,
	output logic row_address_strobe,
	output logic column_address_strobe,
	output logic write_enable,
	output logic [1:0] dqm,
	inout wire [15:0] dq
);

logic [1:0] command = 2'd0;
logic [21:0] data_address = 22'd0;
logic [15:0] data_write = 16'd0;
logic [15:0] data_read;
logic data_read_valid;
logic data_write_done;

localparam READ_BURST_LENGTH = 8;

as4c4m16sa_controller #(
    .CLK_RATE(140_000_000),
    .SPEED_GRADE(7),
    .READ_BURST_LENGTH(READ_BURST_LENGTH),
    .WRITE_BURST(1),
    .CAS_LATENCY(3)
) as4c4m16sa (
    .clk(sdram_clk),
    .command(command),
    .data_address(data_address),
    .data_write(data_write),
    .data_read(data_read),
    .data_read_valid(data_read_valid),
    .data_write_done(data_write_done),
    .clock_enable(clock_enable),
    .bank_activate(bank_activate),
    .address(address),
    .chip_select(chip_select),
    .row_address_strobe(row_address_strobe),
    .column_address_strobe(column_address_strobe),
    .write_enable(write_enable),
    .dqm(dqm),
    .dq(dq)
);

localparam MIPI_POINTER_WIDTH = 8;
logic [MIPI_POINTER_WIDTH-1:0] mipi_data_out_used;
logic mipi_data_out_acknowledge, mipi_data_in_enable;
logic [15:0] mipi_data_in, mipi_data_out;

fifo #(.DATA_WIDTH(16), .POINTER_WIDTH(MIPI_POINTER_WIDTH), .SENDER_DELAY_CHAIN_LENGTH(2)) mipi_write_fifo(
    .sender_clock(mipi_clk),
    .data_in_enable(mipi_data_in_enable),
    .data_in_used(),
    .data_in(mipi_data_in),
    .receiver_clock(sdram_clk),
    .data_out_used(mipi_data_out_used),
    .data_out_acknowledge(mipi_data_out_acknowledge),
    .data_out(mipi_data_out)
);

logic mipi_data_in_countdown = 1'b0;
assign mipi_data_in = mipi_data_in_countdown ? mipi_data_holding : {mipi_data[1], mipi_data[0]};
assign mipi_data_in_enable = mipi_data_enable || mipi_data_in_countdown;
logic [15:0] mipi_data_holding = 16'd0;
always_ff @(posedge mipi_clk)
    mipi_data_holding <= {mipi_data[3], mipi_data[2]};
always_ff @(posedge mipi_clk)
    if (interrupt && mipi_data_enable)
        mipi_data_in_countdown <= 1'b1;
    else
        mipi_data_in_countdown <= 1'b0;

localparam PIXEL_POINTER_WIDTH = 8;
logic [PIXEL_POINTER_WIDTH-1:0] pixel_data_in_used;
logic [15:0] pixel_data_in, pixel_data_out;
logic pixel_data_out_acknowledge, pixel_data_in_enable;
fifo #(.DATA_WIDTH(16), .POINTER_WIDTH(PIXEL_POINTER_WIDTH), .RECEIVER_DELAY_CHAIN_LENGTH(1)) pixel_read_fifo(
    .sender_clock(sdram_clk),
    .data_in_enable(pixel_data_in_enable),
    .data_in_used(pixel_data_in_used),
    .data_in(pixel_data_in),
    .receiver_clock(pixel_clk),
    .data_out_used(),
    .data_out_acknowledge(pixel_data_out_acknowledge),
    .data_out(pixel_data_out)
);
logic pixel_data_out_countdown = 1'b0;
assign pixel = pixel_data_out_countdown ? pixel_data_out[15:8] : pixel_data_out[7:0];
assign pixel_data_out_acknowledge = pixel_data_out_countdown && pixel_enable; // Increment after both bytes are read
always_ff @(posedge pixel_clk)
    pixel_data_out_countdown <= pixel_enable ? !pixel_data_out_countdown : pixel_data_out_countdown;


logic [21:0] mipi_address = 22'd0;
logic [21:0] pixel_address = 22'd0;
logic [2:0] sdram_countup = 3'd0;

assign mipi_data_out_acknowledge = (command == 2'd0 && mipi_data_out_used[3]) || (command == 2'd1 && data_write_done);
assign pixel_data_in_enable = command == 2'd2 && data_read_valid;
assign pixel_data_in = data_read;

assign data_address = command == 2'd2 ? pixel_address : command == 2'd1 ? mipi_address : 22'dx;
always_ff @(posedge sdram_clk)
    data_write <= mipi_data_out;

always_ff @(posedge sdram_clk)
begin
    // TODO: merge this into the fifo
    // all the data should've reached the SDRAM by the time it triggers, but just for clock domain crossing safety, it should be moved back
    if (interrupt && frame_start)
        mipi_address <= 22'd0;
    if (command == 2'd0)
    begin
        if (mipi_data_out_used[3]) // Write burst possible (prioritized over read burst)
        begin
            command <= 2'd1;
            sdram_countup <= 1'd1;
        end
        else if (!pixel_data_in_used[PIXEL_POINTER_WIDTH-1]) // Read burst possible
        begin
            command <= 2'd2;
            sdram_countup <= 3'd0;
        end
        else // Idle
        begin
            command <= 2'd0;
            sdram_countup <= 3'dx;
        end
    end
    else if (command == 2'd2) // Reading
    begin
        if (data_read_valid)
        begin
            sdram_countup <= sdram_countup + 1'd1;
            if (sdram_countup == 3'd7) // Last read
            begin
                command <= 2'd0;
                pixel_address <= pixel_address + 22'(READ_BURST_LENGTH) == 22'(VIDEO_END) ? 22'd0 : pixel_address + 22'(READ_BURST_LENGTH);
            end
        end
    end
    else if (command == 2'd1) // Writing
    begin
        if (data_write_done)
        begin
            sdram_countup <= sdram_countup + 1'd1;
            if (sdram_countup == 3'd7) // Last write
            begin
                command <= 2'd0;
                mipi_address <= mipi_address + 22'(READ_BURST_LENGTH) == 22'(VIDEO_END) ? 22'd0 : mipi_address + 22'(READ_BURST_LENGTH);
            end
        end
    end
end

endmodule
