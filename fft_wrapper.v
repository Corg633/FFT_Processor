//module fft_wrapper(clk,in_signal,real_power,imag_power,fft_source_sop,sink_sop,sink_eop,sink_valid,reset_n,fft_magnitude);
//
//// PERFORM INCOMING SIGNAL (50HZ gain)
//input clk; 
//input wire [11:0] in_signal;
//wire [31:0] short_in_signal;
//
//output wire [19:0] real_power; 
//output wire [19:0] imag_power;
//output wire [20:0] fft_magnitude; // <== Output magnitude
//
////fft signals 
// 
//output wire sink_valid;
//wire sink_ready;
//output wire sink_sop;
//output wire sink_eop;
//wire [10:0] fft_pts;
//output wire fft_source_sop;
//wire fft_source_eop;
//
//wire [11:0] real_to_fft_p;
//wire [11:0] imag_to_fft_p;
//reg [4:0] count;
//output reg reset_n;
//reg eop2,sop2,eop5;
//
//initial
//begin
//	reset_n=0;
//	count = 5'd0;
//end
//
//always @(posedge clk)
//begin
//	count = count+5'd1;
//	if (count == 5'd10)
//	begin 
//		reset_n = 1;
//	end
//end
//
//// INST SIGNALS FOR FFT MEGAFUNCTION
////control_for_fft(clk,insignal,sink_valid,sink_ready,sink_error,sink_sop,sink_eop,inverse,outreal,outimag,fft_pts)
////fft_wrapper(clk,in_signal,real_power,imag_power,fft_source_sop,sink_sop,sink_eop,sink_valid,reset_n);
//
//control_for_fft control_for_fft_longer_inst (.clk(clk), .insignal(in_signal), .sink_valid(sink_valid), .sink_ready(sink_ready), .sink_error(), .sink_sop(sink_sop), .sink_eop(sink_eop), .inverse(inverse), .outreal(real_to_fft_p), .outimag(imag_to_fft_p), .fft_pts(fft_pts) );
//
////INST FFT MEGAFUNCTION
//	sim_FFT fft_inst (
//		.clk          (clk),          //    clk.clk
//		.reset_n      (reset_n),      //    rst.reset_n
//		.sink_valid   (sink_valid),   //   sink.sink_valid
//		.sink_ready   (sink_ready),   //       .sink_ready
//		.sink_error   (2'b00),   //       .sink_error
//		.sink_sop     (sink_sop),     //       .sink_sop
//		.sink_eop     (sink_eop),     //       .sink_eop
//		.sink_real    (real_to_fft_p),    //       .sink_real
//		.sink_imag    (imag_to_fft_p),    //       .sink_imag
//		.fftpts_in    (fft_pts),    //       .fftpts_in
//		.inverse      (1'b0),      //       .inverse
//		.source_valid (), // source.source_valid
//		.source_ready (1'b1), //       .source_ready
//		.source_error (), //       .source_error
//		.source_sop   (fft_source_sop),   //       .source_sop
//		.source_eop   (fft_source_eop),   //       .source_eop
//		.source_real  (real_power),  //       .source_real
//		.source_imag  (imag_power),  //       .source_imag
//		.fftpts_out   ()    //       .fftpts_out
//	);
//	
//	// === Magnitude Calculation ===
//magnitude_approx mag_calc (
//    .real_in(real_power),
//    .imag_in(imag_power),
//    .magnitude_out(fft_magnitude)
//);
//	
//endmodule

`timescale 1ns / 1ps

module fft_wrapper (
    input  wire        clk,               // Clock input
    input  wire [11:0] in_signal,         // 13-bit signed input from ADC after offset correction
    output wire [19:0] real_power,        // FFT real output
    output wire [19:0] imag_power,        // FFT imag output
    output wire [20:0] fft_magnitude,     // 21-bit magnitude output
    output wire        fft_source_sop,    // FFT output start-of-packet
    output wire        sink_sop,          // FFT input start-of-packet
    output wire        sink_eop,          // FFT input end-of-packet
    output wire        sink_valid,        // FFT input valid
    output reg         reset_n            // Active-low reset for FFT and control
);

    // Internal FFT control signals
    wire sink_ready;
    wire [13:0] fft_pts;                 // Matches sim_FFT .fftpts_in width
    wire [11:0] real_to_fft_p, imag_to_fft_p;
    wire [19:0] real_from_fft, imag_from_fft;
    wire        source_valid;

    // === Reset delay logic (10 cycles after startup) ===
    reg [4:0] count;
    initial begin
        reset_n = 0;
        count   = 5'd0;
    end

    always @(posedge clk) begin
        if (!reset_n)
            count <= count + 5'd1;
        if (count == 5'd10)
            reset_n <= 1;
    end

    // === FFT Input Control ===
    control_for_fft control_for_fft_inst (
        .clk        (clk),
        .rst_n      (reset_n),
        .insignal   (in_signal),
        .sink_valid (sink_valid),
        .sink_ready (sink_ready),
        .sink_error (),              // Not used
        .sink_sop   (sink_sop),
        .sink_eop   (sink_eop),
        .inverse    (),              // Not used
        .outreal    (real_to_fft_p),
        .outimag    (imag_to_fft_p),
        .fft_pts    (fft_pts)
    );

    // === FFT IP Core ===
    sim_FFT fft_inst (
        .clk           (clk),
        .reset_n       (reset_n),
        .sink_valid    (sink_valid),
        .sink_ready    (sink_ready),
        .sink_error    (2'b00),
        .sink_sop      (sink_sop),
        .sink_eop      (sink_eop),
        .sink_real     (real_to_fft_p),
        .sink_imag     (imag_to_fft_p),
        .fftpts_in     (fft_pts),
        .inverse       (1'b0),
        .source_valid  (source_valid),
        .source_ready  (1'b1),             // Always ready
        .source_error  (),
        .source_sop    (fft_source_sop),
        .source_eop    (),
        .source_real   (real_from_fft),
        .source_imag   (imag_from_fft),
        .fftpts_out    ()
    );

    assign real_power = real_from_fft;
    assign imag_power = imag_from_fft;

    // === Magnitude Calculation ===
    fft_magnitude_21bit_out mag_calc_inst (
        .clk           (clk),
        .rst           (~reset_n),
        .real_in       (real_from_fft),
        .imag_in       (imag_from_fft),
        .valid_in      (source_valid),   // ✅ Use output-valid from FFT
        .magnitude_out (fft_magnitude),
        .valid_out     ()
    );

endmodule


