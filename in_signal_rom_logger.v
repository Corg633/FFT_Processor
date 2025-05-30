module in_signal_rom_logger #(
    parameter DATA_WIDTH = 12,
    parameter ADDR_WIDTH = 13   // for 8192 entries
)(
    input wire clk,
    input wire valid,
    input wire [DATA_WIDTH-1:0] data,
    input wire reset_n,
    output reg [ADDR_WIDTH-1:0] write_count = 0
);

    reg [DATA_WIDTH-1:0] memory [0:(1<<ADDR_WIDTH)-1];

    always @(posedge clk) begin
        if (!reset_n)
            write_count <= 0;
        else if (valid) begin
            memory[write_count] <= data;
            write_count <= write_count + 1;
        end
    end

endmodule
