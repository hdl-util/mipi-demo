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

as4c4m16sa_controller #(
    .CLK_RATE(100_000_000),
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

logic [31:0] mipi_buff_data;
logic [3:0] mipi_buff_used;
logic mipi_buff_read = 1'b0;
dcfifo mipi_dcfifo (
            .data ({mipi_data[3], mipi_data[2], mipi_data[1], mipi_data[0]}),
            .rdclk (sdram_clk),
            .rdreq (mipi_buff_read),
            .wrclk (mipi_clk),
            .wrreq (mipi_data_enable),
            .q (mipi_buff_data),
            .rdempty (),
            .wrusedw (),
            .aclr (),
            .eccstatus (),
            .rdfull (),
            .rdusedw (mipi_buff_used),
            .wrempty (),
            .wrfull ());
defparam
    mipi_dcfifo.intended_device_family = "Cyclone 10 LP",
    mipi_dcfifo.lpm_numwords = 16,
    mipi_dcfifo.lpm_showahead = "ON",
    mipi_dcfifo.lpm_type = "dcfifo",
    mipi_dcfifo.lpm_width = 32,
    mipi_dcfifo.lpm_widthu = 4,
    mipi_dcfifo.overflow_checking = "ON",
    mipi_dcfifo.rdsync_delaypipe = 4,
    mipi_dcfifo.underflow_checking = "ON",
    mipi_dcfifo.use_eab = "ON",
    mipi_dcfifo.wrsync_delaypipe = 4;


logic [21:0] mipi_address = 22'd0;
logic [21:0] pixel_address = 22'd0;
logic [2:0] sdram_countup = 3'd0;

logic pixel_buff_write = 1'b0;
logic [15:0] pixel_buff_data = 16'd0;
logic [4:0] pixel_buff_used;

always @(posedge sdram_clk)
begin
    mipi_buff_read <= 1'b0;
    pixel_buff_write <= 1'b0;
    pixel_buff_data <= 16'dx;
    if (command == 2'd0)
    begin
        if (!pixel_buff_used[4]) // Read burst possible
        begin
            command <= 2'd2;
            data_write <= 16'dx;
            data_address <= pixel_address;
            sdram_countup <= 1'd0;
        end
        else if (mipi_buff_used[3]) // Write burst possible
        begin
            command <= 2'd1;
            data_write <= mipi_buff_data[15:0];
            data_address <= mipi_address;
            sdram_countup <= 1'd1;
        end
        else // Idle
        begin
            command <= 2'd0;
            data_write <= 16'dx;
            data_address <= 22'dx;
            sdram_countup <= 3'dx;
        end
    end
    else if (command == 2'd2 && data_read_valid)
    begin
        pixel_buff_data <= data_read;
        pixel_buff_write <= 1'b1;
        sdram_countup <= sdram_countup + 1'd1;
        if (sdram_countup == 3'd7) // Last read
        begin
            command <= 2'd0;
            pixel_address <= pixel_address + 22'd8 == 22'(VIDEO_END) ? 22'd0 : pixel_address + 22'd8;
        end
    end
    else if (command == 2'd1 && data_write_done)
    begin
        sdram_countup <= sdram_countup + 1'd1;
        if (sdram_countup[0])
        begin
            data_write <= mipi_buff_data[31:16];
            mipi_buff_read <= 1'b1;
        end
        else
        begin
            data_write <= mipi_buff_data[15:0];
            mipi_buff_read <= 1'b0;
        end

        if (sdram_countup == 3'd7) // Last write
        begin
            command <= 2'd0;
            mipi_address <= mipi_address + 22'd8 == 22'(VIDEO_END) ? 22'd0 : mipi_address + 22'd8;
        end
    end
end


logic [15:0] internal_pixel;
logic pixel_countup = 1'd0;
assign pixel = pixel_countup ? internal_pixel[15:8] : internal_pixel[7:0];
always @(posedge pixel_clk)
begin
    if (pixel_enable) 
        pixel_countup <= !pixel_countup;
end

dcfifo pixel_dcfifo (
            .data (pixel_buff_data),
            .rdclk (pixel_clk),
            .rdreq (pixel_enable && pixel_countup == 1'b1),
            .wrclk (sdram_clk),
            .wrreq (pixel_buff_write),
            .q (internal_pixel),
            .rdempty (),
            .wrusedw (pixel_buff_used),
            .aclr (),
            .eccstatus (),
            .rdfull (),
            .rdusedw (),
            .wrempty (),
            .wrfull ());
defparam
    pixel_dcfifo.intended_device_family = "Cyclone 10 LP",
    pixel_dcfifo.lpm_numwords = 32,
    pixel_dcfifo.lpm_showahead = "ON",
    pixel_dcfifo.lpm_type = "dcfifo",
    pixel_dcfifo.lpm_width = 16,
    pixel_dcfifo.lpm_widthu = 5,
    pixel_dcfifo.overflow_checking = "ON",
    pixel_dcfifo.rdsync_delaypipe = 4,
    pixel_dcfifo.underflow_checking = "ON",
    pixel_dcfifo.use_eab = "ON",
    pixel_dcfifo.wrsync_delaypipe = 4;

endmodule
