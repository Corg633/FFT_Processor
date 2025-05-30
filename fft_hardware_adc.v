`timescale 1us / 10ns /// 1us

module fft_hardware_adc (
    input wire clk,        // 50 MHz clock input from FPGA board
    input wire adc_clk_10, // 10 MHz external ADC clock from PIN_N5
    input wire reset_n,    // Active-low system reset input
    output reg nco_reset_n,

    // SignalTap observables
    output wire [11:0] signal_tap_in_signal,
    output wire [19:0] signal_tap_real_power,
    output wire [19:0] signal_tap_imag_power,
    output wire [20:0] signal_tap_fft_magnitude,
    output wire        signal_tap_sink_sop,
    output wire        signal_tap_sink_valid
);

// Internal wires and registers
wire [11:0] fsin_o;
reg  [11:0] adc_sample_sync1, adc_sample_sync2;

wire signed [12:0] in_signal_signed;
wire signed [11:0] in_signal_to_fft; // ✅ Final 12-bit signed input to FFT
wire [11:0] in_signal;

wire [19:0] real_power_sig, imag_power_sig;
wire [20:0] fft_magnitude_sig;

wire fft_source_sop_sig, sink_sop_sig, sink_eop_sig, sink_valid_sig;
wire [12:0] write_count;
wire [12:0] input_write_count;

// ADC offset parameters
localparam integer OFFSET_BASELINE     = 12'd2048;
localparam integer OFFSET_EXPERIMENTAL = 12'd740;
localparam integer ADC_OFFSET          = OFFSET_BASELINE + OFFSET_EXPERIMENTAL;

// Reset delay logic for NCO
reg [4:0] count;

initial begin
    nco_reset_n = 0;
    count = 5'd0;
end

always @(posedge clk) begin
    count <= count + 5'd1;
    if (count == 5'd10)
        nco_reset_n <= 1;
end

//------NCO------

//	 // 20Khz sine wave
//	 sim_NCO nco_inst (
//		.clk       (clk),       // clk.clk
//		.reset_n   (nco_reset_n),   // rst.reset_n
//		.clken     (1'b1),     //  in.clken
//		.phi_inc_i (32'd17179869), // - 200 kHz // (32'd8589935),// - 100 kHz //(32'd858993),// - 10 kHz//(32'd1717987),// - 20kHz//(32'd42949673), // - 500 khZ //(32'd4294967),// - 50kHz(32'd17179869), //    .phi_inc_i
//		.fsin_o    (fsin_o),    // out.fsin_o
//		.fcos_o    (fcos_o),    //    .fcos_o
//		.out_valid (out_valid)  //    .out_valid
//	);
//	
//
//assign in_signal_to_fft = fsin_o;

//-------ADC-----

// Simulated ADC signal source
adc_test adc_inst (
    .CLOCK(adc_clk_10),
    .CH0  (fsin_o),
    .RESET(~nco_reset_n)
);


// Double-register for clock domain crossing
always @(posedge clk) begin
    if (!nco_reset_n) begin
        adc_sample_sync1 <= 12'd0;
        adc_sample_sync2 <= 12'd0;
    end else begin
        adc_sample_sync1 <= fsin_o;
        adc_sample_sync2 <= adc_sample_sync1;
    end
end

assign in_signal = adc_sample_sync2;

// ✅ Offset correction and truncation to 12-bit signed for FFT
assign in_signal_signed = $signed({1'b0, in_signal}) - $signed(ADC_OFFSET);
assign in_signal_to_fft = in_signal_signed[11:0]; // Truncate or clip as needed

//---------------

// SignalTap observable assignments
assign signal_tap_in_signal     = in_signal_to_fft;
assign signal_tap_real_power    = real_power_sig;
assign signal_tap_imag_power    = imag_power_sig;
assign signal_tap_fft_magnitude = fft_magnitude_sig;
assign signal_tap_sink_sop      = sink_sop_sig;
assign signal_tap_sink_valid    = sink_valid_sig;

// FFT Wrapper instance
fft_wrapper fft_wrapper_inst (
    .clk(clk),
    .in_signal(in_signal_to_fft), // ✅ Use properly formatted input
    .real_power(real_power_sig),
    .imag_power(imag_power_sig),
    .fft_source_sop(fft_source_sop_sig),
    .sink_sop(sink_sop_sig),
    .sink_eop(sink_eop_sig),
    .sink_valid(sink_valid_sig),
    .reset_n(reset_n),
    .fft_magnitude(fft_magnitude_sig)
);

// FFT magnitude ROM logger
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

// ADC input signal ROM logger
in_signal_rom_logger #(
    .DATA_WIDTH(12),
    .ADDR_WIDTH(13)
) input_logger (
    .clk(clk),
    .valid(1'b1), // Always log ADC samples
    .data(in_signal),
    .reset_n(reset_n),
    .write_count(input_write_count)
);

endmodule



