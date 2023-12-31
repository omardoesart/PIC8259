
// testbench
module ISR_tb;

    // Inputs
    reg INT_DONE;
    reg [7:0] interrupt;

    // Outputs
    wire [7:0] ISR;

    // Instantiate the module
    ISR uut_isr (
        .INT_DONE(INT_DONE),
        .interrupt(interrupt),
        .ISR(ISR)
    );

    // Testbench initialization
    initial begin
        // Initialize inputs
        INT_DONE = 1'b0;
        interrupt = 8'b00000000;
        ISR = 8'b11001100;

        // Apply some test vectors
        #10 INT_DONE = 1'b1; // Set INT_DONE to 1
        #10 INT_DONE = 1'b0; // Set INT_DONE back to 0

        // Add more test vectors as needed

        #100 $finish;
    end

endmodule
