module fft_magnitude_21bit_out (
    input  wire         clk,
    input  wire         rst,             // async reset
    input  wire [19:0]  real_in,         // 20-bit signed fixed-point
    input  wire [19:0]  imag_in,         // 20-bit signed fixed-point
    input  wire         valid_in,
    output wire [20:0]  magnitude_out,   // 21-bit unsigned integer
    output wire         valid_out
);

    wire [31:0] real_flt, imag_flt;
    wire [31:0] real_sq, imag_sq;
    wire [31:0] mag_squared, mag_float;
    wire [31:0] mag_int32;

    // === 1. Fixed to Float Conversion ===
    fp_fixed_to_float_0001 real_conv (
        .clk    (clk),
        .areset (rst),
        .a      ({{12{real_in[19]}}, real_in}), // Sign-extend 20-bit to 32-bit
        .q      (real_flt)
    );

    fp_fixed_to_float_0002 imag_conv (
        .clk    (clk),
        .areset (rst),
        .a      ({{12{imag_in[19]}}, imag_in}),
        .q      (imag_flt)
    );

    // === 2. Floating Point Multiplication ===
    fp_mult_0001 square_real (
        .clk    (clk),
        .areset (rst),
        .a      (real_flt),
        .b      (real_flt),
        .q      (real_sq)
    );

    fp_mult_0002 square_imag (
        .clk    (clk),
        .areset (rst),
        .a      (imag_flt),
        .b      (imag_flt),
        .q      (imag_sq)
    );

    // === 3. Floating Point Addition ===
    fp_add_0001 add_sq (
        .clk    (clk),
        .areset (rst),
        .a      (real_sq),
        .b      (imag_sq),
        .q      (mag_squared)
    );

    // === 4. Floating Point Square Root ===
    fp_sqrt_0001 sqrt_mag (
        .clk    (clk),
        .areset (rst),
        .a      (mag_squared),
        .q      (mag_float)
    );

    // === 5. Float to Fixed (truncate to 21-bit unsigned) ===
    fp_float_to_fixed_0001 float_to_int (
        .clk    (clk),
        .areset (rst),
        .a      (mag_float),
        .q      (mag_int32)
    );

    assign magnitude_out = mag_int32[20:0];
    assign valid_out = valid_in;  // Optional: delay pipeline to align

endmodule

