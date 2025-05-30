//`timescale 1ns / 1ps
//
//module control_for_fft (
//    input clk,
//    input [11:0] insignal,
//
//    output reg sink_valid,
//    output reg sink_sop,
//    output reg sink_eop,
//    output reg inverse,
//    output reg sink_ready,
//    output reg [1:0] sink_error,
//    output reg [10:0] fft_pts,
//
//    output [11:0] outreal,
//    output [11:0] outimag
//);
//
//    reg [9:0] count;
//
//    // Combinational assignments
//    assign outreal = insignal;
//    assign outimag = 12'd0;
//
//    // Initialization
//    initial begin
//        count       = 10'd1;
//        inverse     = 1'b0;
//        sink_valid  = 1'b0;
//        sink_ready  = 1'b1;
//        sink_error  = 2'b00;
//        fft_pts     = 11'd1024;
//        sink_sop    = 1'b0;
//        sink_eop    = 1'b0;
//    end
//
//    // Main sequential logic
//    always @(posedge clk) begin
//        count <= count + 1'b1;
//
//        // Manage sink_valid (active during data transmission)
//        sink_valid <= 1'b1;
//
//        // Manage start of packet
//        if (count == 10'd1)
//            sink_sop <= 1'b1;
//        else
//            sink_sop <= 1'b0;
//
//        // Manage end of packet
//        if (count == 10'd1023)
//            sink_eop <= 1'b1;
//        else
//            sink_eop <= 1'b0;
//
//        // Optional: Reset count for continuous streaming
//        if (count == 10'd1024)
//            count <= 10'd0;
//    end
//
//endmodule

`timescale 1ns / 1ps

module control_for_fft #(
    parameter FFT_POINTS = 14'd8192//12'd2048//14'd8192
)(
    input  wire        clk,
    input  wire        rst_n,
    input  wire        sink_ready,
    input  wire [11:0] insignal,

    output reg         sink_valid,
    output reg         sink_sop,
    output reg         sink_eop,
    output reg         inverse,
    output reg [1:0]   sink_error,
    output reg [13:0]  fft_pts,

    output reg [11:0] outreal,
    output reg [11:0] outimag
);

    // Corrected counter width
    reg [$clog2(FFT_POINTS)-1:0] count;

    always @(posedge clk) begin
        if (!rst_n) begin
            count       <= 0;
            sink_valid  <= 1'b0;
            sink_sop    <= 1'b0;
            sink_eop    <= 1'b0;
            inverse     <= 1'b0;
            sink_error  <= 2'b00;
            fft_pts     <= FFT_POINTS;
            outreal     <= 12'd0;
            outimag     <= 12'd0;
        end else begin
            if (sink_ready) begin
                sink_valid <= 1'b1;

                sink_sop <= (count == 0);
                sink_eop <= (count == FFT_POINTS - 1);

                outreal  <= insignal;
                outimag  <= 12'd0;

                if (count == FFT_POINTS - 1)
                    count <= 0;
                else
                    count <= count + 1;
            end else begin
                sink_valid <= 1'b0;
                sink_sop   <= 1'b0;
                sink_eop   <= 1'b0;
            end
        end
    end

endmodule




