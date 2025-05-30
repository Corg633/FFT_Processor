//`timescale 10ns/100ps
//module testbench;
//
//reg clk;
//
//wire [13:0] fsin_o,fcos_o;
//wire [24:0] real_power_sig, imag_power_sig;
//
//initial
//begin
//clk = 0;
//end
//
//always
//begin
//#10 clk = !clk;
//end
//
//wire reset_n;
//
//	sim_NCO nco_inst (
//		.clk       (clk),       // clk.clk
//		.reset_n   (reset_n),   // rst.reset_n
//		.clken     (1'b1),     //  in.clken
//		.phi_inc_i (32'd41943040), //    .phi_inc_i
//		.fsin_o    (fsin_o),    // out.fsin_o
//		.fcos_o    (fcos_o),    //    .fcos_o
//		.out_valid (out_valid)  //    .out_valid
//	);
//
//
//fft_wrapper fft_wrapper_inst
//(
//	.clk(clk),
//	.in_signal(fsin_o),
//	.real_power(real_power_sig),
//	.imag_power(imag_power_sig),
//	.fft_source_sop(fft_source_sop_sig),
//	.sink_sop(sink_sop_sig),
//	.sink_eop(sink_eop_sig),
//	.sink_valid(sink_valid_sig),
//	.reset_n(reset_n)
//);
//
//endmodule

`timescale 1ns/100ps

module testbench;

    reg clk;
    wire [11:0] in_signal;
	 wire [11:0] fsin_o;
    wire [19:0] real_power_sig, imag_power_sig;
    wire [20:0] fft_magnitude_sig;

    wire fft_source_sop_sig, sink_sop_sig, sink_eop_sig, sink_valid_sig;
    wire reset_n;

    wire [12:0] write_count;
    wire [12:0] input_write_count;

    // Clock generation
    initial clk = 0;
    always #10 clk = ~clk;  // 50MHz clock
	 

    // Simulation logging
    initial begin
        $dumpfile("fft_output.vcd");
        $dumpvars(0, testbench);
        #100000;

        // Write ROM contents to files
        $writememh("fft_magnitude_output.hex", fft_logger.memory);
        $writememh("input_signal_log.hex", input_logger.memory);

        $finish;
    end
	 
	 	reg nco_reset_n;

		always @(posedge clk) begin
			if (!reset_n)
        nco_reset_n <= 1'b0;
		else
        nco_reset_n <= 1'b1; // Deassert NCO reset after global reset
		end

	 	 sim_NCO nco_inst (
		.clk       (clk),       // clk.clk
		.reset_n   (nco_reset_n),   // rst.reset_n
		.clken     (1'b1),     //  in.clken
		.phi_inc_i (32'd17179869), //    .phi_inc_i
		.fsin_o    (fsin_o),    // out.fsin_o
		.fcos_o    (fcos_o),    //    .fcos_o
		.out_valid (out_valid)  //    .out_valid
	);
	
	assign in_signal = fsin_o;
	
//    // Feeder loads .hex into FFT input
//    signal_feeder feeder (
//        .clk(clk),
//        .out_signal(in_signal)
//    );

    // DUT: FFT Wrapper
    fft_wrapper fft_wrapper_inst (
        .clk(clk),
        .in_signal(in_signal),
        .real_power(real_power_sig),
        .imag_power(imag_power_sig),
        .fft_source_sop(fft_source_sop_sig),
        .sink_sop(sink_sop_sig),
        .sink_eop(sink_eop_sig),
        .sink_valid(sink_valid_sig),
        .reset_n(reset_n),
        .fft_magnitude(fft_magnitude_sig)
    );

    // Magnitude Logger
    fft_magnitude_rom_logger #(
        .DATA_WIDTH(21),
        .ADDR_WIDTH(13)
    ) fft_logger (
        .clk(clk),
        .valid(sink_valid_sig),
        .data(fft_magnitude_sig),
        .reset_n(reset_n),
        .write_count(write_count)
    );

    // Input Signal Logger
    in_signal_rom_logger #(
        .DATA_WIDTH(12),
        .ADDR_WIDTH(13)
    ) input_logger (
        .clk(clk),
        .valid(1'b1),  // Always log each clock cycle
        .data(in_signal),
        .reset_n(reset_n),
        .write_count(input_write_count)
    );

endmodule


