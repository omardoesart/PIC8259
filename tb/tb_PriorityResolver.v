
module Priority_resolver_tb;

    // Inputs
    reg [2:0] priority_rotate;
    reg [7:0] IRR;
    reg [7:0] ISR;

    // Outputs
    wire [7:0] interrupt;

    // Instantiate the module
    Priority_resolver uut_resolver (
        .priority_rotate(priority_rotate),
        .IRR(IRR),
        .ISR(ISR),
        .interrupt(interrupt)
    );

    // Testbench initialization
    initial begin
        // Initialize inputs
        priority_rotate = 3'b001;
        IRR = 8'b11001100;
        ISR = 8'b00000000;

        // Apply some test vectors
        #10 ISR = 8'b11001100; // Set ISR to some value
        #10 IRR = 8'b10101010; // Set IRR to some value

        // Add more test vectors as needed

        #100 $finish;
    end

endmodule
