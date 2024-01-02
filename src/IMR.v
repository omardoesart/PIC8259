module IMR (
    // Inputs
    input [7:0] interruptMaskIn,  // Interrupt lines to be masked/unmasked

    // Outputs
    output reg [7:0] interruptMaskOut,  // Current interrupt mask status
    output reg [7:0] IRR_MASK               // Interrupt Request Register
);
/*
Documentation

This module represents the Interrupt Mask Register (IMR) of a PIC8259A-like interrupt controller.

Inputs:
    interruptMaskIn: 8-bit input to set/clear individual interrupt lines in the mask

Outputs:
    interruptMaskOut: 8-bit output representing the current interrupt mask status
    IRR: 8-bit output representing the Interrupt Request Register

Behavior:
    - Mask/Unmask: Each bit in interruptMaskIn corresponds to an interrupt line. If a bit is set (1), the corresponding interrupt line is masked. If a bit is clear (0), the corresponding interrupt line is unmasked.
    - IRR: Reflects the interrupt lines that are not masked (interruptMaskOut complemented).
*/

    always @* begin
        // Mask/Unmask: Update interrupt mask based on interruptMaskIn
        interruptMaskOut = interruptMaskIn;

        // IRR: Reflects the interrupt lines that are not masked (interruptMaskOut complemented)
        IRR_MASK = ~interruptMaskOut;
    end

endmodule

