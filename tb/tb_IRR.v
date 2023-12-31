
// testbench 
module IRR_tb;

    // Inputs
    reg Level_Edge_flag;
    reg [7:0] Mask;
    reg [7:0] I_WIRES;

    // Outputs
    wire [7:0] IRR;

    // Instantiate the module
    IRR uut (
        .Level_Edge_flag(Level_Edge_flag),
        .Mask(Mask),
        .I_WIRES(I_WIRES),
        .IRR(IRR)
    );

    // Testbench initialization
    initial begin
        // Initialize inputs
        Level_Edge_flag = 0;
        Mask = 8'b00000000;
        I_WIRES = 8'b01010101;

        // Apply some test vectors
        #10 Level_Edge_flag = 1;
        #10 I_WIRES = 8'b10101010;
        #10 Level_Edge_flag = 0;
        #10 I_WIRES = 8'b11001100;

        // Add more test vectors as needed

        #100 $finish;
    end

endmodule