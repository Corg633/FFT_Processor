module fft_result_rom #(
    parameter DATA_WIDTH = 26,
    parameter ADDR_WIDTH = 13, // 2^13 = 8192 locations
    parameter INIT_FILE = "fft_magnitude_output.hex"
)(
    input wire clk,
    input wire [ADDR_WIDTH-1:0] addr,
    output reg [DATA_WIDTH-1:0] data_out
);

    // Declare ROM
    reg [DATA_WIDTH-1:0] rom [(2**ADDR_WIDTH)-1:0];

    // Load ROM contents from hex file at start
    initial begin
        $readmemh(INIT_FILE, rom);
    end

    // Synchronous read
    always @(posedge clk) begin
        data_out <= rom[addr];
    end

endmodule
