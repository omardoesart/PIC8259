//
// KF8259_Bus_Control_Logic
// Data Bus Buffer & Read/Write Control Logic
//
// Written by Kitune-san
//
module Bus_Control_Logic (
    input   wire           reset,

    input   wire           chip_select_n,
    input   wire           read_enable_n,
    input   wire           write_enable_n,
    input   wire           address,
    input   wire   [7:0]   data_bus_in,

    // Internal Bus
    output  reg   [7:0]   internal_data_bus,
    output  wire           ICW_1,
    output  wire           ICW_2_4,
    output  wire           OCW_1,
    output  wire           OCW_2,
    output  wire           OCW_3,
    output  wire           read
);


    // Internal Signals
    reg   prev_write_enable_n;
    wire   write_flag;
    reg   stable_address;


    // Write Control
    always@(posedge reset) begin
        if (reset == 1'b1)
            internal_data_bus <= 8'b00000000;
        else if (~write_enable_n & ~chip_select_n)
            internal_data_bus <= data_bus_in;
        else
            internal_data_bus <= internal_data_bus;
    end

    always@(posedge reset) begin
        if (reset == 1'b1)
            prev_write_enable_n <= 1'b1;
        else if (chip_select_n)
            prev_write_enable_n <= 1'b1;
        else
            prev_write_enable_n <= write_enable_n;
    end
    
    assign write_flag = (~prev_write_enable_n) & (~write_enable_n);
    
    always@(posedge reset) begin
        if (reset == 1'b1)
            stable_address <= 1'b0;
        else
            stable_address <= address;              // address = A0 ;
    end


    // Generate write request flags
    assign ICW_1   = write_flag & ~stable_address & internal_data_bus[4];
    assign ICW_2_4 = write_flag & stable_address;
    assign OCW_1   = write_flag & stable_address;
    assign OCW_2   = write_flag & ~stable_address & ~internal_data_bus[4] & ~internal_data_bus[3];
    assign OCW_3   = write_flag & ~stable_address & ~internal_data_bus[4] & internal_data_bus[3];


    // Read Control
    assign read = ~read_enable_n  & ~chip_select_n;

endmodule
