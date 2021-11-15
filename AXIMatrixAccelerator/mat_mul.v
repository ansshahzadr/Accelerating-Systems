`timescale 1ns / 1ps


module mat_mul #
    (
        parameter integer DIM_LOG = 1,     /* matrix dimension in log2; e.g. A[8][8] has the DIM of 8, DIM_LOG of 3, and SIZE of 64; change this as desired;
                                              you will need to set this parameter in the testbench and the ARM software in the SDK. */
        parameter integer DIM = 2**DIM_LOG,
        parameter integer SIZE = DIM*DIM,
        parameter integer SIZE_LOG = 2*DIM_LOG,
        parameter integer DATA_WIDTH = 32
    )
    (
        // Clock and Reset shared with the AXI-Lite Slave Port
        input wire  s00_axi_aclk,
        input wire  s00_axi_aresetn,
        
        // AXI-Stream Slave
        output wire  s00_axis_tready,
        input  wire  [DATA_WIDTH-1 : 0] s00_axis_tdata,
        input  wire  s00_axis_tlast,
        input  wire  s00_axis_tvalid,
        
        // AXI-Stream Master
        output wire  m00_axis_tvalid,
        output wire  [DATA_WIDTH-1 : 0] m00_axis_tdata,
        output wire  [(DATA_WIDTH/8)-1 : 0] m00_axis_tstrb,
        output wire  m00_axis_tlast,
        input  wire  m00_axis_tready,
        
        // Matrix-select and Start signals coming from the AXI-Lite Slave Port
        input wire sel,
        input wire start
    );
    assign m00_axis_tstrb = 4'hf;   // always f; byte-enable signal;
    
    wire [DATA_WIDTH-1:0] data_out_mat_A;
    wire [DATA_WIDTH-1:0] data_out_mat_B;
    wire [DATA_WIDTH-1:0] data_in_mat_R;
    
    wire en_A, rw_A;
    wire en_B, rw_B;
    wire en_R, rw_R;
    
    wire clear;
    assign clear = en_R_pipe_2 & rw_R_pipe_2;
    
    wire [SIZE_LOG-1 : 0] addr_A;
    wire [SIZE_LOG-1 : 0] addr_B;
    wire [SIZE_LOG-1 : 0] addr_R;
    
    reg en_R_pipe_1;
    reg rw_R_pipe_1;
    reg en_R_pipe_2;
    reg rw_R_pipe_2;
    reg [SIZE_LOG-1 : 0] addr_R_pipe_1;
    reg [SIZE_LOG-1 : 0] addr_R_pipe_2;
    
    wire m00_axis_tready_from_agu;
    reg m00_axis_tready_pipe_1;
    reg m00_axis_tready_pipe_2;
    reg m00_axis_tready_pipe_3;
    
    wire m00_axis_tlast_from_agu;
    reg m00_axis_tlast_pipe_1;
    reg m00_axis_tlast_pipe_2;
    reg m00_axis_tlast_pipe_3;
    
    assign m00_axis_tvalid = m00_axis_tready_pipe_3;
    assign m00_axis_tlast = m00_axis_tlast_pipe_3;
    
    AGU # (DIM_LOG, DIM, SIZE, SIZE_LOG, DATA_WIDTH) agu(s00_axi_aclk,
                                                         s00_axi_aresetn,
                                                         s00_axis_tready,           // output
                                                         s00_axis_tlast,            // input
                                                         s00_axis_tvalid,           // input
                                                         m00_axis_tready_from_agu,  // output
                                                         m00_axis_tlast_from_agu,   // output
                                                         m00_axis_tready,           // input
                                                         sel,
                                                         start,
                                                         en_A,
                                                         en_B,
                                                         en_R,
                                                         rw_A,
                                                         rw_B,
                                                         rw_R,
                                                         addr_A,
                                                         addr_B,
                                                         addr_R
                                                         );
                                                        
    bram # (DIM_LOG, DIM, SIZE, SIZE_LOG, DATA_WIDTH) matA(s00_axi_aclk, s00_axi_aresetn, en_A, rw_A, addr_A, s00_axis_tdata, data_out_mat_A);
    bram # (DIM_LOG, DIM, SIZE, SIZE_LOG, DATA_WIDTH) matB(s00_axi_aclk, s00_axi_aresetn, en_B, rw_B, addr_B, s00_axis_tdata, data_out_mat_B);
    
    MAC # (DIM_LOG, DIM, SIZE, SIZE_LOG, DATA_WIDTH) alu (s00_axi_aclk, s00_axi_aresetn, clear, data_out_mat_A, data_out_mat_B, data_in_mat_R);
    
    bram # (DIM_LOG, DIM, SIZE, SIZE_LOG, DATA_WIDTH) matR(s00_axi_aclk, s00_axi_aresetn, en_R_pipe_2, rw_R_pipe_2, addr_R_pipe_2, data_in_mat_R, m00_axis_tdata);
    
    // Glue logic: Align the control signal for matR by inserting FFs
        
    always @ (posedge s00_axi_aclk)
        if(!s00_axi_aresetn) begin
            en_R_pipe_1 <= 1'b0;
            en_R_pipe_2 <= 1'b0;
            rw_R_pipe_1 <= 1'b0;
            rw_R_pipe_2 <= 1'b0;
            addr_R_pipe_1 <= 'b0;
            addr_R_pipe_2 <= 'b0;
            m00_axis_tready_pipe_1 <= 1'b0;
            m00_axis_tready_pipe_2 <= 1'b0;
            m00_axis_tready_pipe_3 <= 1'b0;
            m00_axis_tlast_pipe_1 <= 1'b0;
            m00_axis_tlast_pipe_2 <= 1'b0;
            m00_axis_tlast_pipe_3 <= 1'b0;
        end else begin
            en_R_pipe_1 <= en_R;
            en_R_pipe_2 <= en_R_pipe_1;
            rw_R_pipe_1 <= rw_R;
            rw_R_pipe_2 <= rw_R_pipe_1;
            addr_R_pipe_1 <= addr_R;
            addr_R_pipe_2 <= addr_R_pipe_1;
            m00_axis_tready_pipe_1 <= m00_axis_tready_from_agu;
            m00_axis_tready_pipe_2 <= m00_axis_tready_pipe_1;
            m00_axis_tready_pipe_3 <= m00_axis_tready_pipe_2;
            m00_axis_tlast_pipe_1 <= m00_axis_tlast_from_agu;
            m00_axis_tlast_pipe_2 <= m00_axis_tlast_pipe_1;
            m00_axis_tlast_pipe_3 <= m00_axis_tlast_pipe_2;
        end
        
endmodule

module bram #
(
    parameter integer DIM_LOG = 1,
    parameter integer DIM = 2**DIM_LOG,
    parameter integer SIZE = DIM*DIM,
    parameter integer SIZE_LOG = 2*DIM_LOG,
    parameter integer DATA_WIDTH = 32
)
(
    input wire s00_axi_aclk,
    input wire s00_axi_aresetn,  
    input wire en,
    input wire rw,
    input wire [SIZE_LOG-1 : 0] addr,
    input wire [DATA_WIDTH-1 : 0] data_in,
    output reg [DATA_WIDTH-1 : 0] data_out
);

    // TODO
    reg [DATA_WIDTH - 1 : 0] internal [SIZE-1 : 0];		//memory for matrices
    integer i;											//for parsing the matrix, int, reg gives an error

    always @ (posedge s00_axi_aclk) begin
        if(!s00_axi_aresetn) begin
			data_out <= 'b0;
			for (i = 0; i < SIZE; i = i + 1)
				internal[i] <= 'b0;	
		end else if (en) begin		
			if (!rw) begin	
				data_out <= internal[addr];
				//$display ("data_out_and_addr_BRAM data_out = %0d, addr = %0d",data_out, addr);				
			end else begin	
				internal[addr] <= data_in;
				//$display ("data_in _and_addr_BRAM data_in = %0d, addr = %0d",data_in, addr);				
			end
		end else begin
			data_out <= 'b0;
		end
    end
endmodule

module MAC #
(
    parameter integer DIM_LOG = 1,
    parameter integer DIM = 2**DIM_LOG,
    parameter integer SIZE = DIM*DIM,
    parameter integer SIZE_LOG = 2*DIM_LOG,
    parameter integer DATA_WIDTH = 32
)
(
    input wire s00_axi_aclk,
    input wire s00_axi_aresetn,
    input wire clear, 
    input wire [DATA_WIDTH-1 : 0] data_A,
    input wire [DATA_WIDTH-1 : 0] data_B,
    output wire [DATA_WIDTH-1 : 0] data_R
);

    // TODO
    
    reg [DATA_WIDTH-1 : 0] reg_A, reg_B;
    reg [DATA_WIDTH-1 : 0] pre_result, cur_result;
    assign data_R = cur_result;
    

    always @ (posedge s00_axi_aclk) begin
        if (!s00_axi_aresetn) begin
            reg_A <= 'b0;
            reg_B <= 'b0;
            cur_result <= 'b0;
            pre_result <= 'b0;         
        end else begin
            reg_A <= data_A;
            reg_B <= data_B;
            //is_clear <= clear;
        end
    end
    
    always @ (reg_A, reg_B, pre_result) begin
        cur_result = reg_A * reg_B + pre_result;
		//uncomment to see partial and final results out of MAC
        //$display ("IN_MAC_BLOCK_OUTPUT data_R = %0d, cur_result = %0d, pre_result = %0d",data_R, cur_result, pre_result );				

    end 
        
    always @ (posedge s00_axi_aclk) begin
        
        if (clear) begin
		//uncomment to see when partial result gets cleared
        //$display ("-----------------------------CLEAN-----------------------------------");			        
            pre_result <= 'b0;
        end else begin
            pre_result <= cur_result;
        end
    end
endmodule

module AGU #
(
    parameter integer DIM_LOG = 1,
    parameter integer DIM = 2**DIM_LOG,
    parameter integer SIZE = DIM*DIM,
    parameter integer SIZE_LOG = 2*DIM_LOG,
    parameter integer DATA_WIDTH = 32
)
(
    input wire  s00_axi_aclk,
    input wire  s00_axi_aresetn,
    
    // AXI-Stream Slave
    output reg  s00_axis_tready,
    input wire  s00_axis_tlast,
    input wire  s00_axis_tvalid,
        
    // AXI-Stream Master
    output reg  m00_axis_tvalid,
    output reg  m00_axis_tlast,
    input wire  m00_axis_tready,
    
    input wire sel,
    input wire start,
    
    output reg en_A,
    output reg en_B,
    output reg en_R,
    output reg rw_A,
    output reg rw_B,
    output reg rw_R,
    output reg [SIZE_LOG-1 : 0] addr_A,
    output reg [SIZE_LOG-1 : 0] addr_B,
    output reg [SIZE_LOG-1 : 0] addr_R
);

    // TODO
    localparam
    	S_IDLE      = 5'b00001,
    	S_LOAD_A    = 5'b00010,
    	S_LOAD_B    = 5'b00100,
    	S_CALCULATE = 5'b01000,
    	S_OUTPUT    = 5'b10000;

	reg [4:0] curr_state, next_state;
    reg [SIZE_LOG-1 : 0] addr_A_internal, addr_B_internal, addr_R_internal;
	reg calc_done_internal;
	integer row, col, tmp;

	initial begin
		s00_axis_tready	= 1'b0;
		calc_done_internal = 1'b0;
		addr_R_internal = 'b0;
		addr_A_internal = 'b0;
		addr_B_internal = 'b0;
		row = 'b0;
		tmp = 'b0;
		col = 'b0;

	end

	always @ (curr_state, s00_axis_tvalid, s00_axis_tlast, m00_axis_tready, calc_done_internal, sel, m00_axis_tlast, start) begin 		
		case (curr_state)
			//start from IDLE state to avoid redundant state declarations	
			S_IDLE: begin
				if (s00_axis_tvalid == 1 && sel == 0) begin
					next_state = S_LOAD_A;
				end else if (s00_axis_tvalid == 1 && sel == 1) begin
					next_state = S_LOAD_B;
				end else if (start == 1) begin
					next_state = S_CALCULATE;
				end else if (m00_axis_tready == 1) begin
					next_state = S_OUTPUT;
					addr_R_internal = 'b0;
				end else begin
					next_state = curr_state;
				end
			end

			S_LOAD_A: begin
				if (s00_axis_tlast) begin
					next_state = S_IDLE;
				end else begin
					next_state = curr_state;
				end
	
			 end
		
			S_LOAD_B: begin
				if (s00_axis_tlast) begin
					next_state = S_IDLE;
				end else begin
					next_state = curr_state;
				end
			 end

			S_CALCULATE: begin
				if (calc_done_internal == 1) begin
					next_state = S_IDLE;		
				end else begin
					next_state = curr_state;
				end	
			end

			S_OUTPUT: begin
				if (m00_axis_tlast == 1) begin // go back to IDLE when last bit of data is sent out
					next_state = S_IDLE;
				end else begin
					next_state = curr_state;
				end
			end
		endcase
	end

	always @ (posedge s00_axi_aclk) begin
        	if(!s00_axi_aresetn) begin
				//$display ("Initialization	time = %0t",$time);									
				curr_state <= S_IDLE;
		end else begin
			curr_state <= next_state;
		end
	end

	always @ (posedge s00_axi_aclk) begin		//address gen and state implementation
		case (curr_state)
			S_IDLE: begin
				en_A <= 1'b0;
				en_B <= 1'b0;
				en_R <= 1'b0;				
				addr_A <= 'b0;
				addr_B <= 'b0;
				addr_R <= 'b0;
				s00_axis_tready <= 1'b0;
				m00_axis_tvalid <= 1'b0;
				m00_axis_tlast <= 1'b0;
			end
			S_LOAD_A: begin
				en_B <= 1'b0;
				en_R <= 1'b0;				
				en_A <= 1'b1;
				rw_A <= 1'b1;		//implies write
				m00_axis_tvalid <= 1'b0;
				m00_axis_tlast <= 1'b0;
				s00_axis_tready <= 1'b1;
				addr_A <= addr_A_internal;
				addr_A_internal <= addr_A_internal + 1;
			end
			S_LOAD_B: begin
				en_A <= 1'b0;
				en_R <= 1'b0;
				en_B <= 1'b1;
				rw_B <= 1'b1;		//implies write
				s00_axis_tready <= 1'b1;
				m00_axis_tvalid <= 1'b0;
				m00_axis_tlast <= 1'b0;
				addr_B <= addr_B_internal;
				addr_B_internal <= addr_B_internal + 1;	
			end
			S_CALCULATE: begin
				if (!calc_done_internal) begin
					s00_axis_tready <= 1'b0; 
					en_A <= 1'b1;
					en_B <= 1'b1;
					en_R <= 1'b1;
					rw_A <= 1'b0;
					rw_B <= 1'b0;
					rw_R <= 1'b1;			// implies read
					s00_axis_tready <= 1'b0;
					m00_axis_tvalid <= 1'b0;
					m00_axis_tlast <= 1'b0;
					
					
					if (tmp == DIM - 1) begin
						if (col == DIM - 1) begin
							if (row == DIM-1) begin
								calc_done_internal <= 1'b1; //when all adderresess are send 
								en_A <= 1'b0;
								en_B <= 1'b0;
								en_R <= 1'b0;
							end else begin
								col <= 'b0;
								tmp <= 'b0;
								row <= row + 1;
							end
						end else begin
							tmp <= 'b0;
							col <= col + 1;
						end
					end else begin
						tmp <= tmp + 1;
					end
					addr_A <= (DIM * row) + tmp;
					addr_B <= (DIM * tmp) + col;
					addr_R <= (DIM * row) + col;
				end else begin
					en_A <= 1'b0;	
					en_B <= 1'b0;
					en_R <= 1'b0;
				end
			end
			S_OUTPUT: begin
				en_A <= 1'b0;
				en_B <= 1'b0;
				en_R <= 1'b1;
				rw_A <= 1'b0;
				rw_B <= 1'b0;
				rw_R <= 1'b0;			// implies read
				s00_axis_tready <= 1'b0;
				m00_axis_tvalid <= 1'b1;
				addr_R <= addr_R_internal;
				addr_R_internal <= addr_R_internal + 1;
				
				if (addr_R_internal == SIZE-1) begin
					//$display ("IN addr_R_internal_SIZE -1");								
					m00_axis_tlast <= 1'b1;
				end else begin
				    m00_axis_tlast <= 1'b0;
				end
				//$display ("IN OUTPUT_BLOCK_addr_R = %0d  addr_R_internal = %0d ",addr_R, addr_R_internal);				
			end
		endcase
	end
endmodule
