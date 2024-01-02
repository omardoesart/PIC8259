module IRR (
    // inputs from control logic
    input Level_Edge_flag,    // Configuration signal (0: Level Sensitive | 1: Edge Sensitive)
    input [7:0] IRR_MASK,      // Interrupt mask from IMR module
    // input pins
    input [7:0] I_WIRES,       // 8-bit bus representing individual interrupt signals

    //output
    output reg [7:0] IRR        // Masked Interrupt request to priority resolver
);
/*
Documentation

This module is responsible for storing the requesting interrupts.

Inputs:
    Level_Edge_flag: Configuration signal (0: Level Sensitive | 1: Edge Sensitive)
    IRR_MASK: Interrupt mask from IMR module
    I_WIRES: 8-bit bus representing individual interrupt signals

Outputs:
    IRR: Masked Interrupt request to be sent to the priority resolver

Behavior:
- If Level_Edge_flag is 0 (Level Sensitive):
  - IRR[i] is set to (I_WIRES[i] & ~IRR_MASK[i]) for each bit i.
- If Level_Edge_flag is 1 (Edge Sensitive):
  - IRR[i] is set to (I_WIRES[i] & ~I_WIRES_PREV[i]) for each bit i.
- I_WIRES_PREV is used to store the previous values of I_WIRES.
*/

    reg [7:0] I_WIRES_PREV;

    initial begin
        // Initialize the previous interrupt values to zero
        I_WIRES_PREV = 0;
    end

    always @* begin
        // Update IRR based on the configuration signal Level_Edge_flag
        if (!Level_Edge_flag) begin
            // Level Sensitive: Update IRR with masked interrupt values
            IRR[0] <= (I_WIRES[0] & ~IRR_MASK[0]);
            IRR[1] <= (I_WIRES[1] & ~IRR_MASK[1]);
            IRR[2] <= (I_WIRES[2] & ~IRR_MASK[2]);
            IRR[3] <= (I_WIRES[3] & ~IRR_MASK[3]);
            IRR[4] <= (I_WIRES[4] & ~IRR_MASK[4]);
            IRR[5] <= (I_WIRES[5] & ~IRR_MASK[5]);
            IRR[6] <= (I_WIRES[6] & ~IRR_MASK[6]);
            IRR[7] <= (I_WIRES[7] & ~IRR_MASK[7]);
        end
        else begin
            // Edge Sensitive: Update IRR with edge-triggered interrupt values
            IRR[0] <= (I_WIRES[0] & ~I_WIRES_PREV[0]);
            IRR[1] <= (I_WIRES[1] & ~I_WIRES_PREV[1]);
            IRR[2] <= (I_WIRES[2] & ~I_WIRES_PREV[2]);
            IRR[3] <= (I_WIRES[3] & ~I_WIRES_PREV[3]);
            IRR[4] <= (I_WIRES[4] & ~I_WIRES_PREV[4]);
            IRR[5] <= (I_WIRES[5] & ~I_WIRES_PREV[5]);
            IRR[6] <= (I_WIRES[6] & ~I_WIRES_PREV[6]);
            IRR[7] <= (I_WIRES[7] & ~I_WIRES_PREV[7]);
        end

        // Update Previous Input values for the next iteration
        I_WIRES_PREV <= I_WIRES;
    end

endmodule
