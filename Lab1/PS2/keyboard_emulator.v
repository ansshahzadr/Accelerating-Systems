`timescale 1ns / 1ps
///////////////////////////////////////////////////////////////////////////////
// This module defines a `keyboard emulator` that generates and submits 
// “Accelerator – 1DT109�?. Each letter is sent in three lines, where the first
// line is always the start bit (kb_data = 0), the second line has the actual
// data (LSB first), and the last line always contains the parity and the stop
// bits. We discard the parity bit, so here it is always set as 0.
///////////////////////////////////////////////////////////////////////////////


module keyboard_emulator(
    output kb_clk,
    output kb_data
    );
    
    reg kb_clk, kb_data;
    
    always begin
        #10 kb_clk = ! kb_clk;
    end
    
    initial begin
        kb_clk = 1;
        kb_data = 1;
        
        #25 kb_data = 0;
        #20 kb_data = 1; #20 kb_data = 0; #20 kb_data = 0;  #20 kb_data = 0;  #20 kb_data = 0;  #20 kb_data = 0;  #20 kb_data = 1;  #20 kb_data = 0;  //ascii of A
        #20 kb_data = 0; #20 kb_data = 1;       // what this?

        #20 kb_data = 0;
        #20 kb_data = 1; #20 kb_data = 1; #20 kb_data = 0;  #20 kb_data = 0;  #20 kb_data = 0;  #20 kb_data = 1;  #20 kb_data = 1;  #20 kb_data = 0;  //ascii of c
        #20 kb_data = 0; #20 kb_data = 1; 
    
        #20 kb_data = 0;
        #20 kb_data = 1; #20 kb_data = 1; #20 kb_data = 0;  #20 kb_data = 0;  #20 kb_data = 0;  #20 kb_data = 1;  #20 kb_data = 1;  #20 kb_data = 0;  //ascii of c
        #20 kb_data = 0; #20 kb_data = 1; 

        #20 kb_data = 0;
        #20 kb_data = 1; #20 kb_data = 0; #20 kb_data = 1;  #20 kb_data = 0;  #20 kb_data = 0;  #20 kb_data = 1;  #20 kb_data = 1;  #20 kb_data = 0;  // ascii of e
        #20 kb_data = 0; #20 kb_data = 1; 
    
        #20 kb_data = 0;
        #20 kb_data = 0; #20 kb_data = 0; #20 kb_data = 1;  #20 kb_data = 1;  #20 kb_data = 0;  #20 kb_data = 1;  #20 kb_data = 1;  #20 kb_data = 0;  // ascii of l
        #20 kb_data = 0; #20 kb_data = 1; 
    
        #20 kb_data = 0;
        #20 kb_data = 1; #20 kb_data = 0; #20 kb_data = 1;  #20 kb_data = 0;  #20 kb_data = 0;  #20 kb_data = 1;  #20 kb_data = 1;  #20 kb_data = 0;  // ascii of e
        #20 kb_data = 0; #20 kb_data = 1; 
    
        #20 kb_data = 0;
        #20 kb_data = 0; #20 kb_data = 1; #20 kb_data = 0;  #20 kb_data = 0;  #20 kb_data = 1;  #20 kb_data = 1;  #20 kb_data = 1;  #20 kb_data = 0;  // ascii of r
        #20 kb_data = 0; #20 kb_data = 1; 
    
        #20 kb_data = 0;
        #20 kb_data = 1; #20 kb_data = 0; #20 kb_data = 0;  #20 kb_data = 0;  #20 kb_data = 0;  #20 kb_data = 1;  #20 kb_data = 1;  #20 kb_data = 0;  // ascii of a
        #20 kb_data = 0; #20 kb_data = 1; 
    
        #20 kb_data = 0;
        #20 kb_data = 0; #20 kb_data = 0; #20 kb_data = 1;  #20 kb_data = 0;  #20 kb_data = 1;  #20 kb_data = 1;  #20 kb_data = 1;  #20 kb_data = 0;  // ascii of t
        #20 kb_data = 0; #20 kb_data = 1; 
    
        #20 kb_data = 0;
        #20 kb_data = 1; #20 kb_data = 1; #20 kb_data = 1;  #20 kb_data = 1;  #20 kb_data = 0;  #20 kb_data = 1;  #20 kb_data = 1;  #20 kb_data = 0;  // ascii of o
        #20 kb_data = 0; #20 kb_data = 1; 
    
        #20 kb_data = 0;
        #20 kb_data = 0; #20 kb_data = 1; #20 kb_data = 0;  #20 kb_data =0;  #20 kb_data = 1;  #20 kb_data = 1;  #20 kb_data = 1;  #20 kb_data = 0;     // ascii of r
        #20 kb_data = 0; #20 kb_data = 1; 
                    
        #20 kb_data = 0;
        #20 kb_data = 0; #20 kb_data = 0; #20 kb_data = 0;  #20 kb_data =0;  #20 kb_data = 0;  #20 kb_data = 1;  #20 kb_data = 0;  #20 kb_data = 0;  // space
        #20 kb_data = 0; #20 kb_data = 1; 
                    
        #20 kb_data = 0;
        #20 kb_data = 1; #20 kb_data = 0; #20 kb_data = 1;  #20 kb_data =1;  #20 kb_data = 0;  #20 kb_data = 1;  #20 kb_data = 0;  #20 kb_data = 0;  // -
        #20 kb_data = 0; #20 kb_data = 1; 
                    
        #20 kb_data = 0;
        #20 kb_data = 0; #20 kb_data = 0; #20 kb_data = 0;  #20 kb_data =0;  #20 kb_data = 0;  #20 kb_data = 1;  #20 kb_data = 0;  #20 kb_data = 0;  //space
        #20 kb_data = 0; #20 kb_data = 1; 
                    
        #20 kb_data = 0;
        #20 kb_data = 1; #20 kb_data = 0; #20 kb_data = 0;  #20 kb_data =0;  #20 kb_data = 1;  #20 kb_data = 1;  #20 kb_data = 0;  #20 kb_data = 0;  // 00110001 = 1
        #20 kb_data = 0; #20 kb_data = 1; 
                    
        #20 kb_data = 0;
        #20 kb_data = 0; #20 kb_data = 0; #20 kb_data = 1;  #20 kb_data =0;  #20 kb_data = 0;  #20 kb_data = 0;  #20 kb_data = 1;  #20 kb_data = 0;   //01000100 = D 
        #20 kb_data = 0; #20 kb_data = 1; 
                    
        #20 kb_data = 0;
        #20 kb_data = 0; #20 kb_data = 0; #20 kb_data = 1;  #20 kb_data =0;  #20 kb_data = 1;  #20 kb_data = 0;  #20 kb_data = 1;  #20 kb_data = 0;  // T
        #20 kb_data = 0; #20 kb_data = 1; 
                    
        #20 kb_data = 0;
        #20 kb_data = 1; #20 kb_data = 0; #20 kb_data = 0;  #20 kb_data =0;  #20 kb_data = 1;  #20 kb_data = 1;  #20 kb_data = 0;  #20 kb_data = 0;  //1
        #20 kb_data = 0; #20 kb_data = 1; 
                    
        #20 kb_data = 0;
        #20 kb_data = 0; #20 kb_data = 0; #20 kb_data = 0;  #20 kb_data =0;  #20 kb_data = 1;  #20 kb_data = 1;  #20 kb_data = 0;  #20 kb_data = 0;  //00110000 = 0
        #20 kb_data = 0; #20 kb_data = 1; 
                    
        #20 kb_data = 0;
        #20 kb_data = 1; #20 kb_data = 0; #20 kb_data = 0;  #20 kb_data =1;  #20 kb_data = 1;  #20 kb_data = 1;  #20 kb_data = 0;  #20 kb_data = 0;  //00111001
        #20 kb_data = 0; #20 kb_data = 1; 
                    
    end
    
endmodule
