module arbiter #(
    parameter VIDEO_END = (640 * 480) / 2
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
logic [21:0] data_address = 22'dx;
logic [15:0] data_write = 16'dx;
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

logic [15:0] mipi_buff_data;
logic [4:0] mipi_buff_used;
logic mipi_buff_read = 1'b0;
dcfifo_mixed_widths mipi_dcfifo (
            .data ({mipi_data[3], mipi_data[2], mipi_data[1], mipi_data[0]}),
            .wrclk (mipi_clk),
            .wrreq (mipi_data_enable),
            .rdclk (sdram_clk),
            .rdreq (mipi_buff_read),
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
    mipi_dcfifo.lpm_type = "dcfifo_mixed_widths",
    mipi_dcfifo.lpm_width = 32,
    mipi_dcfifo.lpm_widthu = 4,
    mipi_dcfifo.lpm_widthu_r = 5,
    mipi_dcfifo.lpm_width_r = 16,
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

always_ff @(posedge sdram_clk)
    pixel_buff_data <= data_read;

always @(posedge sdram_clk)
begin
    if (command == 2'd0)
    begin
        pixel_buff_write <= 1'b0;
        if (!pixel_buff_used[4]) // Read burst possible
        begin
            mipi_buff_read <= 1'b0;
            data_write <= 16'dx;

            command <= 2'd2;
            data_address <= pixel_address;
            sdram_countup <= 1'd0;
        end
        else if (mipi_buff_used[4]) // Write burst possible
        begin
            command <= 2'd1;
            data_address <= mipi_address;
            sdram_countup <= 1'd1;
            mipi_buff_read <= 1'b1;
            data_write <= mipi_buff_data;
        end
        else // Idle
        begin
            command <= 2'd0;
            data_address <= 22'dx;
            sdram_countup <= 3'dx;
            mipi_buff_read <= 1'b0;
            data_write <= 16'dx;
        end
    end
    else if (command == 2'd2) // Reading
    begin
        mipi_buff_read <= 1'b0;
        data_write <= 16'dx;

        if (data_read_valid)
        begin
            pixel_buff_write <= 1'b1;
            sdram_countup <= sdram_countup + 1'd1;
            if (sdram_countup == 3'd7) // Last read
            begin
                command <= 2'd0;
                pixel_address <= pixel_address + 22'd8 == 22'(VIDEO_END) ? 22'd0 : pixel_address + 22'd8;
            end
        end
        else
        begin
            pixel_buff_write <= 1'b0;
        end
    end
    else if (command == 2'd1) // Writing
    begin
        pixel_buff_write <= 1'b0;

        if (data_write_done)
        begin
            mipi_buff_read <= 1'b1;
            data_write <= mipi_buff_data;
            sdram_countup <= sdram_countup + 1'd1;
            if (sdram_countup == 3'd7) // Last write
            begin
                command <= 2'd0;
                mipi_address <= mipi_address + 22'd8 == 22'(VIDEO_END) ? 22'd0 : mipi_address + 22'd8;
            end
        end
        else
        begin
            mipi_buff_read <= 1'b0;
        end
    end
end

dcfifo_mixed_widths pixel_dcfifo (
            .data (pixel_buff_data),
            .wrclk (sdram_clk),
            .wrreq (pixel_buff_write),
            .rdclk (pixel_clk),
            .rdreq (pixel_enable),
            .q (pixel),
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
    pixel_dcfifo.lpm_type = "dcfifo_mixed_widths",
    pixel_dcfifo.lpm_width = 16,
    pixel_dcfifo.lpm_widthu = 5,
    pixel_dcfifo.lpm_widthu_r = 6,
    pixel_dcfifo.lpm_width_r = 8,
    pixel_dcfifo.overflow_checking = "ON",
    pixel_dcfifo.rdsync_delaypipe = 4,
    pixel_dcfifo.underflow_checking = "ON",
    pixel_dcfifo.use_eab = "ON",
    pixel_dcfifo.wrsync_delaypipe = 4;

endmodule
