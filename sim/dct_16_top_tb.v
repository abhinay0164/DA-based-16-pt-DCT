`timescale 1ns / 1ps


module dct_16_top_tb;
    reg clk, rst, start;
    reg [255:0] all_inputs;
//    wire [511:0] all_outputs;
    wire [31:0] out0, out1, out2, out3, out4, out5, out6, out7, out8, out9, out10, out11, out12, out13, out14, out15;
    wire done;
    
    
    dct_16_top dct(clk, rst, start, all_inputs, out0, out1, out2, out3, out4, out5, out6, out7, out8, out9, out10, out11, out12, out13, out14, out15, done);
    
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    task reset_dut;
    begin
        @(negedge clk);
            rst <= 1;
            start <= 0;
            all_inputs <= 0;
        repeat (10) @(negedge clk);
            rst <= 0;
    end
    endtask 
    
    task start_dut;
    begin
        @(negedge clk);
            start <= 1;
        @(negedge clk);
            start <= 0;
    end
    endtask
    
    task input_dut(input [255:0]a);
    begin
        @(negedge clk)
            all_inputs <= a;
    end
    endtask
    
    initial begin
        reset_dut;
        // TESTCASE 1: DC INPUT
        input_dut(256'h2710_2710_2710_2710_2710_2710_2710_2710_2710_2710_2710_2710_2710_2710_2710_2710); // x[i]=1000 where i=0 to 15
        start_dut;
        wait(done); // expected output is: y[0]!=0 and y[j]=0 where j=1 to 15 (i.e. only Y[0] is non zero, all other outputs are zero)
        repeat(5) @(negedge clk);
        
        // TESTCASE 2: IMPULSE INPUT
        input_dut(256'h0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_2710); // x[0]=1000 and x[j]=0 where j=1 to 15
        start_dut;
        wait(done);
        repeat(5) @(negedge clk); // expected output is: y[i]!=0 where i=0 to 15 (i.e. outputs are values of coefficients)
        
        // TESTCASE 3: ALTERNATING INPUT
        input_dut(256'hD8F0_2710_D8F0_2710_D8F0_2710_D8F0_2710_D8F0_2710_D8F0_2710_D8F0_2710_D8F0_2710); // x[i]=1000 if i is even, x[i]=-1000 if i is odd
        start_dut;
        wait(done);
        repeat(50) @(negedge clk); // expected output is: Magnitude increases with frequency i.e. Y1,Y0 are close to zero ; Y15,Y14 are very high magnitude
        $finish;
    end
endmodule
