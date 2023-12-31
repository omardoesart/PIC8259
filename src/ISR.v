
module ISR(
    // from control logic
    input wire INT_DONE,
    // from Priority resolver
    input [7:0] interrupt,

    output reg [7:0] ISR
);

/*
Documentation

This module is responsible for handling Interrupt Service Routine (ISR) logic.

Inputs:
    - INT_DONE: Signal indicating that the interrupt processing is done.
    - interrupt: Interrupt signals received from the Priority Resolver.

Outputs:
    - ISR: Updated Interrupt Service Routine, excluding the serviced interrupts.

Behavior:
    The module updates the ISR based on the INT_DONE signal and the received interrupt signals.
    It clears the bits corresponding to serviced interrupts in the ISR.

*/

    reg [7:0] next_ISR;
    always @* begin
        next_ISR = (ISR & ~INT_DONE);
    end

    always @* begin
        ISR <= next_ISR;
    end

endmodule
