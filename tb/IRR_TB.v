module IRR_tb;

  // Inputs
  reg Level_Edge_flag;
  reg [7:0] Mask;
  reg [7:0] I_WIRES;

  // Outputs
  wire [7:0] IRR;

  // Instantiate the IRR module
  IRR ir_instance (
    .Level_Edge_flag(Level_Edge_flag),
    .Mask(Mask),
    .I_WIRES(I_WIRES),
    .IRR(IRR)
  );

  // Initial block to apply inputs and monitor outputs
  initial begin
    $monitor("Time=%0t: Level_Edge_flag=%b, Mask=%h, I_WIRES=%h, IRR=%h", $time, Level_Edge_flag, Mask, I_WIRES, IRR);

    // Test 1: Level Sensitive
    Level_Edge_flag = 0;
    Mask = 8'b11001100;
    I_WIRES = 8'b10101010;
    #10;

    // Test 2: Edge Sensitive
    Level_Edge_flag = 1;
    Mask = 8'b00110011;
    I_WIRES = 8'b11001100;
    #10;

    // Add more tests as needed

    // Finish simulation
    $stop;
  end

endmodule

