module IRR (
    // inputs from control logic
    input Level_Edge_flag,
    input [7:0] Mask,
    // input pins
    input [7:0] I_WIRES,

    //output
    output reg [7:0] IRR // to priority resolver
);
/*
Documentation

This Module is resposible foe storing the requesting interrupts
inputs :
    Interrupt pins : pins coming from the preferal
    Interrupt mask : to mask some interrupt lines from control
    level_edge_flag : configrational signal (0 : Level Sensitive | 1 : Edge Sensitive)

outputs :
    IRR : Masked Interrupt request
*/

    reg [7:0] I_WIRES_PREV;

    initial begin
        I_WIRES_PREV = 0;
    end

    always @* begin
        if (!Level_Edge_flag) begin
            IRR[0] <= (I_WIRES[0] & ~Mask[0]);
            IRR[1] <= (I_WIRES[1] & ~Mask[1]);
            IRR[2] <= (I_WIRES[2] & ~Mask[2]);
            IRR[3] <= (I_WIRES[3] & ~Mask[3]);
            IRR[4] <= (I_WIRES[4] & ~Mask[4]);
            IRR[5] <= (I_WIRES[5] & ~Mask[5]);
            IRR[6] <= (I_WIRES[6] & ~Mask[6]);
            IRR[7] <= (I_WIRES[7] & ~Mask[7]);
        end
        else begin
            IRR[0] <= (I_WIRES[0] & ~I_WIRES_PREV[0]);
            IRR[1] <= (I_WIRES[1] & ~I_WIRES_PREV[1]);
            IRR[2] <= (I_WIRES[2] & ~I_WIRES_PREV[2]);
            IRR[3] <= (I_WIRES[3] & ~I_WIRES_PREV[3]);
            IRR[4] <= (I_WIRES[4] & ~I_WIRES_PREV[4]);
            IRR[5] <= (I_WIRES[5] & ~I_WIRES_PREV[5]);
            IRR[6] <= (I_WIRES[6] & ~I_WIRES_PREV[6]);
            IRR[7] <= (I_WIRES[7] & ~I_WIRES_PREV[7]);
        end

        // Update Previous Input values
        I_WIRES_PREV <= I_WIRES;
    end

endmodule
