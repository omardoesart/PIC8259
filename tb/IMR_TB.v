module IMR_tb;

  // Inputs
  reg [7:0] interruptMaskIn;

  // Outputs
  wire [7:0] interruptMaskOut;
  wire [7:0] IRR;

  // Instantiate the IMR module
  IMR imr_instance (
    .interruptMaskIn(interruptMaskIn),
    .interruptMaskOut(interruptMaskOut),
    .IRR(IRR)
  );

  // Initial block to apply inputs and monitor outputs
  initial begin
    $monitor("Time=%0t: interruptMaskIn=%h, interruptMaskOut=%h, IRR=%h", $time, interruptMaskIn, interruptMaskOut, IRR);

    // Test 1: Set some interrupt lines in interruptMaskIn
    interruptMaskIn = 8'b11001100;
    #10;

    // Test 2: Clear some interrupt lines in interruptMaskIn
    interruptMaskIn = 8'b00110011;
    #10;

    // Add more tests as needed

    // Finish simulation
    $stop;
  end

endmodule

