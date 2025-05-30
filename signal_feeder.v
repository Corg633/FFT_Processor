module signal_feeder (
    input wire clk,
    output reg [11:0] out_signal
);
    reg [11:0] mem [0:16384];//[0:10243];  // Memory array for up to 1024x10 values
    integer idx;

    initial begin
        $readmemh("input_mem.hex", mem);  // Read from .hex file
        idx = 0;
    end

    always @(posedge clk) begin
        out_signal <= mem[idx];
        idx <= idx + 1;
    end
endmodule

//module signal_feeder (
//    input wire clk,
//    output reg [13:0] out_signal
//);
//
//    reg [13:0] mem [0:2499];  // Match number of samples in input_mem.hex
//    integer i;
//
//    initial begin
//        $readmemh("input_mem.hex", mem);  // Load sine wave
//        i = 0;
//    end
//
//    always @(posedge clk) begin
//        out_signal <= mem[i];
//        if (i < 2499)
//            i <= i + 1;
//        else
//            i <= 0;  // Loop or hold at end (depends on design)
//    end
//
//endmodule