`include "8259_Common_Package.v"

module control_logic (
  input  reg        reset,
  input  reg [7:0]  internal_data_bus ,
  input  reg        interrupt_Acknowledge,
  output reg        interrupt_to_cpu,
  input  reg        ICW_1,
  input  reg        ICW_2_4,
  input  reg        OCW_1,
  input  reg        OCW_2,
  input  reg        OCW_3,
  input  reg        read, 
  
  output reg        enable_read_register,
  output reg        read_register_isr_or_irr,
    
  output wire       slave_program_or_enable_buffer,
  
  input  reg [7:0]  highest_level_in_service,
  output reg [7:0]  interrupt_mask,
  output reg [7:0]  special_interrupt_mask,
  output reg [7:0]  end_of_interrupt,
  output reg [2:0]  priority_rotate
  
);

parameter CMD_READY  = 2'b00;
parameter WRITE_ICW2 = 2'b01;
parameter WRITE_ICW3 = 2'b10;
parameter WRITE_ICW4 = 2'b11;


parameter CTL_READY  = 2'b00;
parameter ACK1       = 2'b01;
parameter ACK2       = 2'b10;
parameter ACK3       = 2'b11;

// Registers


reg   [10:0]   interrupt_vector_address; 
reg            call_address_interval_4_or_8_config;
reg            level_or_edge_triggered;
reg            cascade_mode;
reg            ICW4_config;
reg   [7:0]    cascade_device_config;
reg            specially_fully_nested_mode;
reg            buffered_mode;
reg            buffered_master_or_slave_config;
reg            AEOI_config;
reg            u8086_or_mcs80_config;
reg            special_mask_mode;
reg   [7:0]    acknowledge_interrupt;
reg            auto_rotate_mode;

//
// Write command state
//
reg [1:0]  command_state;
reg [1:0]  next_command_state;

// State machine
always @* begin
      if (ICW_1 == 1'b1)
          next_command_state = WRITE_ICW2;
      else if (ICW_2_4 == 1'b1) begin
        
          case (command_state)
            
             WRITE_ICW2: begin                  
               if (cascade_mode == 1'b0)
                    next_command_state = WRITE_ICW3;
               else if (ICW4_config == 1'b1)
                    next_command_state = WRITE_ICW4;
               else
                    next_command_state = CMD_READY;
             end
             
             WRITE_ICW3: begin           
                if (ICW4_config == 1'b1)
                    next_command_state = WRITE_ICW4;
                else
                    next_command_state = CMD_READY;
             end
             
             WRITE_ICW4: begin            
                    next_command_state = CMD_READY;
             end
             
             default: begin
                    next_command_state = CMD_READY;
             end
             endcase
      end
      else
          next_command_state = command_state;
end

always @* begin
  
  if (reset == 1'b1)
      command_state <= CMD_READY;
  else
      command_state <= next_command_state;
end


// Writing registers/command signals
wire    write_ICW_2 = (command_state == WRITE_ICW2) & ICW_2_4;
wire    write_ICW_3 = (command_state == WRITE_ICW3) & ICW_2_4;
wire    write_ICW_4 = (command_state == WRITE_ICW4) & ICW_2_4;
wire    write_OCW_1 = (command_state == CMD_READY)  & OCW_1;
wire    write_OCW_2 = (command_state == CMD_READY)  & OCW_2;
wire    write_OCW_3 = (command_state == CMD_READY)  & OCW_3;

reg [1:0] next_control_state;
reg [1:0] control_state;

// Detect ACK edge
reg   prev_interrupt_acknowledge;

always @* begin
    if (reset)
         prev_interrupt_acknowledge <= 1'b1;
     else
         prev_interrupt_acknowledge <= interrupt_Acknowledge;
end
wire    nedge_interrupt_acknowledge =  prev_interrupt_acknowledge & ~interrupt_Acknowledge;
wire    pedge_interrupt_acknowledge = ~prev_interrupt_acknowledge &  interrupt_Acknowledge;

// Detect read signal edge
reg   prev_read_signal;

always @* begin
    if (reset)
        prev_read_signal <= 1'b0;
    else
        prev_read_signal <= read;
end
wire    nedge_read_signal = ~prev_read_signal & read;

    // State machine
always @* begin
    case(control_state)
        CTL_READY: begin
             if ( write_OCW_2 == 1'b1 || nedge_interrupt_acknowledge == 1'b0)
                 next_control_state = CTL_READY;          
             else
                 next_control_state = ACK1;
        end
        ACK1: begin
            if (pedge_interrupt_acknowledge == 1'b0)
                 next_control_state = ACK1;
            else
                 next_control_state = ACK2;
        end
        ACK2: begin
            if (pedge_interrupt_acknowledge == 1'b0)
                 next_control_state = ACK2;
            else if (u8086_or_mcs80_config == 1'b0)
                 next_control_state = ACK3;
            else
                 next_control_state = CTL_READY;
        end
        ACK3: begin
            if (pedge_interrupt_acknowledge == 1'b0)
                next_control_state = ACK3;
            else
                next_control_state = CTL_READY;
        end
        default: begin
                next_control_state = CTL_READY;
        end
    endcase
end

always @* begin
    if (reset || ICW_1 == 1'b1)
        control_state <= CTL_READY;
    else
        control_state <= next_control_state;
end

// End of acknowledge sequence
wire    end_of_acknowledge_sequence =   (control_state != CTL_READY) & (next_control_state == CTL_READY);

// Initialization command word 1
always @* begin
  if(reset == 1'b1) begin
    interrupt_vector_address[2:0] <= 3'b000;
    call_address_interval_4_or_8_config <= 1'b0 ;
    level_or_edge_triggered <= 1'b0;
    cascade_mode <= 1'b0;
    ICW4_config <= 1'b0;
  end
  else if (ICW_1 == 1'b1) begin
    interrupt_vector_address[2:0] <= internal_data_bus[7:5] ;
    level_or_edge_triggered <= internal_data_bus[3];
    call_address_interval_4_or_8_config <= internal_data_bus[2] ;
    cascade_mode  <= internal_data_bus[1];
    ICW4_config <= internal_data_bus[0];
  end
  else begin
    interrupt_vector_address[2:0] <= interrupt_vector_address[2:0] ;
    level_or_edge_triggered <= level_or_edge_triggered;
    call_address_interval_4_or_8_config <= call_address_interval_4_or_8_config ;
    cascade_mode <= cascade_mode;
    ICW4_config <= ICW4_config ;
  end
end


// Initialization command word 2
always @* begin 
  if(reset == 1'b1 || ICW_1 == 1'b1)
    interrupt_vector_address[10:3] <= 8'b00000000;
  else if(write_ICW_2 == 1'b1)
    interrupt_vector_address[10:3] <= internal_data_bus ;
  else
    interrupt_vector_address[10:3] <=interrupt_vector_address[10:3] ;
end


// Initialization command word 3
always @* begin 
  if(reset == 1'b1 || ICW_1 == 1'b1)
     cascade_device_config <= 8'b00000000;
  else if(write_ICW_3 == 1'b1)
     cascade_device_config <= internal_data_bus ;
  else
     cascade_device_config <= cascade_device_config ;
end


// Initialization command word 4
always @* begin 
  if(reset == 1'b1 || ICW_1 == 1'b1) begin
     specially_fully_nested_mode <= 1'b0;
     buffered_mode <= 1'b0;
     buffered_master_or_slave_config <= 1'b0;
     AEOI_config <= 1'b0;
     u8086_or_mcs80_config <= 1'b0;
  end 
  else if(write_ICW_4 == 1'b1) begin
     specially_fully_nested_mode <= internal_data_bus[4] ;
     buffered_mode <=  internal_data_bus[3];
     buffered_master_or_slave_config <= internal_data_bus[2];
     AEOI_config   <=  internal_data_bus[1];
     u8086_or_mcs80_config <= internal_data_bus[0];
  end
  else begin
     specially_fully_nested_mode <= specially_fully_nested_mode ;
     buffered_mode <= buffered_mode ;
     buffered_master_or_slave_config <= buffered_master_or_slave_config;
     AEOI_config   <= AEOI_config;
     u8086_or_mcs80_config <= u8086_or_mcs80_config;
  end
end

assign slave_program_or_enable_buffer = ~buffered_mode;

// Operation control word 1
// interrupt mask

always @* begin 
  if(reset == 1'b1 || ICW_1 == 1'b1)
    interrupt_mask <= 8'b11111111;
  else if(write_OCW_1 == 1'b1 && (special_mask_mode == 1'b0))
    interrupt_mask <= internal_data_bus ;
  else
    interrupt_mask <= interrupt_mask ;
end

//special interrupt mask
always @* begin 
  if(reset == 1'b1 || ICW_1 == 1'b1 || (special_mask_mode == 1'b0))
    special_interrupt_mask <= 8'b00000000;
  else if(write_OCW_1 == 1'b1 )
    special_interrupt_mask  <= internal_data_bus ;
  else
    special_interrupt_mask  <= special_interrupt_mask ;
end

// Operation control word 2
// ...........EOI..........
always @* begin
    if (ICW_1 == 1'b1)
        end_of_interrupt = 8'b11111111;
    else if ((AEOI_config == 1'b1) && (end_of_acknowledge_sequence == 1'b1))
        end_of_interrupt = acknowledge_interrupt;
    else if (write_OCW_2 == 1'b1 && internal_data_bus[6:5] == 2'b01)
        end_of_interrupt = highest_level_in_service;
    else
        end_of_interrupt = 8'b00000000;
end

// .......Auto_Rotate......
always@* begin
    if (reset || ICW_1 == 1'b1)
        auto_rotate_mode <= 1'b0;
    else if (write_OCW_2 == 1'b1) begin
        case (internal_data_bus[7:5])
            3'b000:  auto_rotate_mode <= 1'b0;
            3'b100:  auto_rotate_mode <= 1'b1;
            default: auto_rotate_mode <= auto_rotate_mode;
        endcase
    end
    else
        auto_rotate_mode <= auto_rotate_mode;
end

// .......Rotate......
always @* begin
    if (reset || ICW_1 == 1'b1)
        priority_rotate <= 3'b111;
    else if ((auto_rotate_mode == 1'b1) && (end_of_acknowledge_sequence == 1'b1))
        priority_rotate <= bit2num(acknowledge_interrupt);
    else if (write_OCW_2 == 1'b1 && internal_data_bus[7:5] ==  3'b101)
        priority_rotate <= bit2num(highest_level_in_service);
    else
        priority_rotate <= priority_rotate;
end


// Operation control word 3

// ESMM / SMM
always @* begin
    if (reset || ICW_1 == 1'b1)
        special_mask_mode <= 1'b0;
    else if ((write_OCW_3 == 1'b1) && (internal_data_bus[6] == 1'b1))
        special_mask_mode <= internal_data_bus[5];
    else
        special_mask_mode <= special_mask_mode;
end

// RR/RIS
always @* begin
    if (reset || ICW_1 == 1'b1) begin
        enable_read_register     <= 1'b1;
        read_register_isr_or_irr <= 1'b0;
    end
    else if (write_OCW_3 == 1'b1) begin
        enable_read_register     <= internal_data_bus[1];
        read_register_isr_or_irr <= internal_data_bus[0];
    end
    else begin
        enable_read_register     <= enable_read_register;
        read_register_isr_or_irr <= read_register_isr_or_irr;
    end
end

endmodule  
