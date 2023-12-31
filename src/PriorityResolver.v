
module Priority_resolver(
    // input from control logic
    input [2:0] priority_rotate,

    input [7:0] IRR,
    input [7:0] ISR,

    output reg [7:0] interrupt
);
/*
Documentation

This module is responsible for prioritizing and resolving interrupt requests.

Inputs:
    - priority_rotate: Priority rotation configuration.
    - IRR: Interrupt Request Register, representing incoming interrupt requests.
    - ISR: Interrupt Service Routine, indicating already serviced interrupts.

Outputs:
    - interrupt: Resolved interrupt signals, taking priority and rotation into account.

Behavior:
    The module prioritizes interrupt requests based on priority rotation.
    It generates a masked interrupt signal after considering the Interrupt Service Routine (ISR).
    The resolved interrupt is then output.

*/



    reg [7:0] rotated_IRR;
    reg [7:0] rotated_ISR;
    
    reg [7:0] priority_mask;
    reg [7:0] rotated_interrupt;

    // we are working on one request, 
    // and the rest of the functionality is upon this one
    // that's why we used assign with IRR and always with ISR
    assign rotated_IRR = rotate_right(IRR, priority_rotate);
    always @* begin
        rotated_ISR = rotate_right(ISR, priority_rotate);
        if      (rotated_ISR[0] == 1'b1) priority_mask = 8'b00000000;
        else if (rotated_ISR[1] == 1'b1) priority_mask = 8'b00000001;
        else if (rotated_ISR[2] == 1'b1) priority_mask = 8'b00000011;
        else if (rotated_ISR[3] == 1'b1) priority_mask = 8'b00000111;
        else if (rotated_ISR[4] == 1'b1) priority_mask = 8'b00001111;
        else if (rotated_ISR[5] == 1'b1) priority_mask = 8'b00011111;
        else if (rotated_ISR[6] == 1'b1) priority_mask = 8'b00111111;
        else if (rotated_ISR[7] == 1'b1) priority_mask = 8'b01111111;
        else                             priority_mask = 8'b11111111;
    end
    
    assign rotated_interrupt = resolv_priority(rotated_IRR) & priority_mask;
    always @* begin
        interrupt = rotate_left(rotated_interrupt, priority_rotate);
    end

endmodule
