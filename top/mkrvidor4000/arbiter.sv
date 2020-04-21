module arbiter #(
    parameter VIDEO_END = 153600
) (
    input logic pixel_clk,
    input logic pixel_enable,
    output logic [7:0] pixel,

    input logic mipi_clk,
    input logic mipi_data_enable,
    input logic [7:0] mipi_data [0:3],

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
logic [21:0] data_address;
logic [15:0] data_write;
logic [15:0] data_read;
logic data_read_valid;
logic data_write_done;

as4c4m16sa #(
    .SPEED_GRADE(7),
    .READ_BURST_LENGTH(8),
    .WRITE_BURST(1),
    .CAS_LATENCY(2)
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
    .dq(dq),
);

logic [15:0] mipi_buffer [0:31];
logic [4:0] mipi_producer = 5'd0;
logic [4:0] mipi_consumer = 5'd0;

always @(posedge mipi_clk)
begin
    if (mipi_data_enable)
    begin
        mipi_buffer[mipi_producer] <= {mipi_data[0], mipi_data[1]};
        mipi_buffer[mipi_producer + 1'd1] <= {mipi_data[2], mipi_data[3]};
        mipi_producer <= mipi_producer + 5'd2;
    end
end


logic [15:0] pixel_buffer [0:31];
logic [4:0] pixel_producer = 5'd0;
logic [4:0] pixel_consumer = 5'd0;
logic pixel_countup = 1'd0;
assign pixel = pixel_countup ? pixel_buffer[pixel_consumer][15:8] : pixel_buffer[pixel_consumer][7:0];

always @(posedge pixel_clk)
begin
    if (pixel_enable)
    begin
        if (pixel_countup == 1'd1)
            pixel_consumer <= pixel_consumer + 1'd1;
        pixel_countup <= !pixel_countup;
    end
end

logic [4:0] mipi_diff;
assign mipi_diff = mipi_producer >= mipi_consumer ? mipi_producer - mipi_consumer : (~5'd0 - mipi_consumer) + mipi_producer;
logic [4:0] pixel_diff;
assign pixel_diff = pixel_producer >= pixel_consumer ? pixel_producer - pixel_consumer : (~5'd0 - pixel_consumer) + pixel_producer;

logic [17:0] mipi_address;
logic [17:0] pixel_address;

logic [2:0] sdram_countup = 3'd0;
always @(posedge sdram_clk)
begin
    if (command == 2'd0)
    begin
        if (pixel_diff < 5'd8) // Read is approaching starvation
        begin
            command <= 2'd2;
            data_address <= pixel_address;
        end
        else if (mipi_diff >= 5'd15) // Ready to write
        begin
            command <= 2'd1;
            data_write <= mipi_buffer[mipi_consumer];
            data_address <= mipi_address;
            mipi_consumer <= mipi_consumer + 1'd1;
            sdram_countup <= sdram_countup + 1'd1;
        end
    end
    else if (command == 2'd2 && data_read_valid)
    begin
        pixel_buffer[pixel_producer] <= data_read;
        pixel_producer <= pixel_producer + 1'd1;
        sdram_countup <= sdram_countup + 1'd1;
        if (sdram_countup == 3'd7) // Last read
        begin
            command <= 2'd0;
            pixel_address <= pixel_address + 8'd8 == 18'(VIDEO_END) ? 18'd0 : pixel_address + 18'd8;
        end
    end
    else if (command == 2'd1 && data_write_done)
    begin
        data_write <= mipi_buffer[mipi_consumer];
        mipi_consumer <= mipi_consumer + 1'd1;
        sdram_countup <= sdram_countup + 1'd1;
        if (sdram_countup == 3'd7) // Last write
        begin
            command <= 2'd0;
            mipi_address <= mipi_address + 8'd8 == 18'(VIDEO_END) ? 18'd0 : mipi_address + 18'd8;
        end
    end
end

endmodule
