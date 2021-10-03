`timescale 1ns / 1ps

module lab1(
    sys_clk,
    reset, 
    kb_clk, 
    kb_data, 
    display_o );

input sys_clk, reset, kb_clk, kb_data;
output [7:0] display_o; 

wire kb_negedge;
wire [7:0] char;
wire valid;

kb_sync mod_1(sys_clk, reset, kb_clk, kb_negedge);
s2p mod_2 (reset, kb_negedge, kb_data, char, valid);
display mod_3 (valid, reset, char, display_o);

endmodule 

module kb_sync(
    sys_clk,
    reset, 
    kb_clk,
    kb_negedge_o
);

input sys_clk, reset, kb_clk;
output kb_negedge_o;
reg kb_negedge_o;

wire current_value;
assign current_value = kb_clk;
reg previous_value;

always @ (posedge sys_clk, negedge reset) //what is the role of rest
    if (!reset) begin       //if reset = 0
        previous_value <= 1'b0;
    end else begin          //if reset = 1
        previous_value <= current_value;
    end
end

always @ (previous_value, current_value)
    case ({previous_value, current_value})      //concatenation of values
    2'b10:
        kb_negedge_o <= 1'b1;
    default:
        kb_negedge_o <= 1'b0;
    endcase
endmodule

module s2p (
    reset,
    kb_clk, 
    //kb_negedge_o,
    kb_data,
    char_o,
    valid_o
);

input reset;
input kb_clk, kb_data;
//input kb_negedge_o, kb_data;

output [7:0] char_o;
output valid_o;
reg valid_o;

localparam 
    S_1 = 3'b001, // Idle waiting for start singnal
    S_2 = 3'b010, // Taking in data
    S_3 = 3'b100; // Waiting for finish signal

reg [10:0] char_buffer;     //11 bits
assign char_o = char_buffer[8:1]; //exclude start, stop and parity

reg kb_data_sample;     
always @ (posedge kb_clk, negedge reset) begin      //sample 1 bit of input data when clock is rising and 
    if (!reset)         //reset = 0
        kb_data_sample <= 1'b1;
    else
        kb_data_sample <= kb_data;
end

reg [2:0] cur_state;
reg [2:0] next_state;
integer counter;
reg counter_enable;
always@(cur_state, kb_data_sample, counter) begin
    case(cur_state)
    S_1:                             //if current state is idling, next state would be taking in data (s2)
        if (kb_data_sample == 1'b0) begin       //start is logic 0 for one clock cycle
            next_state = S_2;
            counter_enable = 1'b1; 
        end else begin
            next_state = cur_state;
            counter_enable = 1'b0;  
                                    //if its idling and data bit recieved in non zero then keep idling and counter is not incresease
        end
    S_2:
        if(counter == 9) begin
            next_state = S_3;
        end else begin
            next_state = cur_state;
        end
    S_3: 
        if(kb_data_sample == 1'b1) begin        //stop bit
            next_state = S_1;
        end else begin
            next_state = cur_state;
        end
    endcase
end

always@(posedge kb_clk, negedge reset) begin
    if (!reset) begin
        counter <= 0;
        char_buffer <= 'b0;
    end else begin
        if(counter_enable) begin
            counter <= (counter + 1) % 11;
            char_buffer <= {kb_data_sample, char_buffer[10:1]}; //how are the 8 bits being mapped in char
        end else begin
            if(counter !=  0)
                counter <= 0;
        end
    end
end

always@(posedge kb_clk, negedge reset) begin        //why?
    if (!reset) begin
        cur_state <= S_1;
    end else begin
        cur_state <= next_state;
    end
end


always@(posedge kb_clk, negedge reset) begin        //asserting valid bit if current state is S3
    if (!reset) begin
        valid_o <= 1'b0;
    end else begin
        case(cur_state)
        S_1: begin
            valid_o <= 1'b0;
        end
        S_2: begin
            valid_o <= 1'b0;
        end
        S_3: begin
            valid_o <= 1'b1;
        end
        endcase
    end
end

endmodule

module display(valid, reset, char, display);

input valid, reset;
input [7:0] char;
output [7:0] display;
reg [7:0] display;

always @ (posedge valid, negedge reset)begin
    if (!reset)
        display <= 'b0;
    else 
        display <= char;
end

endmodule