`timescale 1ns / 1ps

module dct_16_top(
    input clk, rst, start,
    input [255:0] all_inputs,
//    output reg [511:0] all_outputs,
    output reg [31:0] out0, out1, out2, out3, out4, out5, out6, out7, out8, out9, out10, out11, out12, out13, out14, out15,
    output reg done
    );
    
    // Addresses for the ROMS
    wire [7:0] addr_A, addr_B;
    
    // Output data signals from ROMS
    wire signed [15:0] data_00a, data_00b;
    wire signed [15:0] data_01a, data_01b;
    wire signed [15:0] data_02a, data_02b;
    wire signed [15:0] data_03a, data_03b;
    wire signed [15:0] data_04a, data_04b;
    wire signed [15:0] data_05a, data_05b;
    wire signed [15:0] data_06a, data_06b;
    wire signed [15:0] data_07a, data_07b;
    wire signed [15:0] data_08a, data_08b;
    wire signed [15:0] data_09a, data_09b;
    wire signed [15:0] data_10a, data_10b;
    wire signed [15:0] data_11a, data_11b;
    wire signed [15:0] data_12a, data_12b;
    wire signed [15:0] data_13a, data_13b;
    wire signed [15:0] data_14a, data_14b;
    wire signed [15:0] data_15a, data_15b;
    
    // ROM instantiations
    // ROM 0
    rom_k00_A BRAM_00A (.clka(clk), .addra(addr_A), .douta(data_00a));
    rom_k00_B BRAM_00B (.clka(clk), .addra(addr_B), .douta(data_00b));

    // ROM 1
    rom_k01_A BRAM_01A (.clka(clk), .addra(addr_A), .douta(data_01a));
    rom_k01_B BRAM_01B (.clka(clk), .addra(addr_B), .douta(data_01b));

    // ROM 2
    rom_k02_A BRAM_02A (.clka(clk), .addra(addr_A), .douta(data_02a));
    rom_k02_B BRAM_02B (.clka(clk), .addra(addr_B), .douta(data_02b));

    // ROM 3
    rom_k03_A BRAM_03A (.clka(clk), .addra(addr_A), .douta(data_03a));
    rom_k03_B BRAM_03B (.clka(clk), .addra(addr_B), .douta(data_03b));

    // ROM 4
    rom_k04_A BRAM_04A (.clka(clk), .addra(addr_A), .douta(data_04a));
    rom_k04_B BRAM_04B (.clka(clk), .addra(addr_B), .douta(data_04b));

    // ROM 5
    rom_k05_A BRAM_05A (.clka(clk), .addra(addr_A), .douta(data_05a));
    rom_k05_B BRAM_05B (.clka(clk), .addra(addr_B), .douta(data_05b));

    // ROM 6
    rom_k06_A BRAM_06A (.clka(clk), .addra(addr_A), .douta(data_06a));
    rom_k06_B BRAM_06B (.clka(clk), .addra(addr_B), .douta(data_06b));

    // ROM 7
    rom_k07_A BRAM_07A (.clka(clk), .addra(addr_A), .douta(data_07a));
    rom_k07_B BRAM_07B (.clka(clk), .addra(addr_B), .douta(data_07b));

    // ROM 8
    rom_k08_A BRAM_08A (.clka(clk), .addra(addr_A), .douta(data_08a));
    rom_k08_B BRAM_08B (.clka(clk), .addra(addr_B), .douta(data_08b));

    // ROM 9
    rom_k09_A BRAM_09A (.clka(clk), .addra(addr_A), .douta(data_09a));
    rom_k09_B BRAM_09B (.clka(clk), .addra(addr_B), .douta(data_09b));

    // ROM 10
    rom_k10_A BRAM_10A (.clka(clk), .addra(addr_A), .douta(data_10a));
    rom_k10_B BRAM_10B (.clka(clk), .addra(addr_B), .douta(data_10b));

    // ROM 11
    rom_k11_A BRAM_11A (.clka(clk), .addra(addr_A), .douta(data_11a));
    rom_k11_B BRAM_11B (.clka(clk), .addra(addr_B), .douta(data_11b));

    // ROM 12
    rom_k12_A BRAM_12A (.clka(clk), .addra(addr_A), .douta(data_12a));
    rom_k12_B BRAM_12B (.clka(clk), .addra(addr_B), .douta(data_12b));

    // ROM 13
    rom_k13_A BRAM_13A (.clka(clk), .addra(addr_A), .douta(data_13a));
    rom_k13_B BRAM_13B (.clka(clk), .addra(addr_B), .douta(data_13b));

    // ROM 14
    rom_k14_A BRAM_14A (.clka(clk), .addra(addr_A), .douta(data_14a));
    rom_k14_B BRAM_14B (.clka(clk), .addra(addr_B), .douta(data_14b));

    // ROM 15
    rom_k15_A BRAM_15A (.clka(clk), .addra(addr_A), .douta(data_15a));
    rom_k15_B BRAM_15B (.clka(clk), .addra(addr_B), .douta(data_15b));
    
    
    // STATE PARAMETERS & REGISTERS
    localparam IDLE=4'd0;
    localparam READ_INPUT=4'd1;
    localparam BIT_SLICE=4'd2;
    localparam READ_ROM=4'd3;
    localparam WAIT1=4'd4;
    localparam WAIT2=4'd5;
    localparam ACCUMULATE=4'd6;
    localparam DONE=4'd7;
    reg [3:0] state, next_state;
    
    // LOCAL VARIABLES
    reg [4:0] count;
    reg signed [15:0] in0, in1, in2, in3, in4, in5, in6, in7, in8, in9, in10, in11, in12, in13, in14, in15;
    reg signed [31:0] acc0, acc1, acc2, acc3, acc4, acc5, acc6, acc7, acc8, acc9, acc10, acc11, acc12, acc13, acc14, acc15;
//    reg [31:0] out0, out1, out2, out3, out4, out5, out6, out7, out8, out9, out10, out11, out12, out13, out14, out15;
    
    // BIT_SLICE STATE COMBINATAIONAL LOGIC
    assign addr_A = {in7[count],in6[count],in5[count],in4[count],in3[count],in2[count],in1[count],in0[count]};
    assign addr_B = {in15[count],in14[count],in13[count],in12[count],in11[count],in10[count],in9[count],in8[count]};
    
    // STATE UPDATE LOGIC
    always@(posedge clk or posedge rst)
    begin
        if(rst) state <= IDLE;
        else state <= next_state;
    end
    
    // STATE TRANSITION LOGIC
    always@(*)
    begin
        next_state = state;
        case(state)
            IDLE: if(start) next_state = READ_INPUT;
            READ_INPUT: next_state = BIT_SLICE;
            BIT_SLICE: next_state = READ_ROM;
            READ_ROM: next_state = WAIT1;
            WAIT1: next_state = WAIT2;
            WAIT2: next_state = ACCUMULATE;
            ACCUMULATE: if(count >=15) next_state = DONE;
                        else next_state = READ_ROM;
            DONE: next_state = IDLE;
            default: next_state = IDLE;
        endcase
    end
    
    // DATAPATH & OUTPUT REGISTERING
    always@(posedge clk or posedge rst)
    begin
        if(rst) begin
            count <= 0;
            done <= 0;
            {in0, in1, in2, in3, in4, in5, in6, in7, in8, in9, in10, in11, in12, in13, in14, in15} <= 0;
            {acc0, acc1, acc2, acc3, acc4, acc5, acc6, acc7, acc8, acc9, acc10, acc11, acc12, acc13, acc14, acc15} <= 0;
//            {out0, out1, out2, out3, out4, out5, out6, out7, out8, out9, out10, out11, out12, out13, out14, out15} <= 0;
//            all_outputs <= 0;
        end
        else begin
            case(state)
            IDLE: begin
                count <= 0;
                done <= 0;
                {acc0, acc1, acc2, acc3, acc4, acc5, acc6, acc7, acc8, acc9, acc10, acc11, acc12, acc13, acc14, acc15} <= 0;
//                {out0, out1, out2, out3, out4, out5, out6, out7, out8, out9, out10, out11, out12, out13, out14, out15} <= 0;
//                all_outputs <= 0;
            end
            
            READ_INPUT: begin
                {in15, in14, in13, in12, in11, in10, in9, in8, in7, in6, in5, in4, in3, in2, in1, in0} <= all_inputs;
            end
            
            BIT_SLICE: ;
            READ_ROM: ;
            WAIT1: ;
            WAIT2: ;
            ACCUMULATE: begin
                if(count == 15) begin
                    acc0 <= (acc0 >>> 1) - (data_00a + data_00b);
                    acc1 <= (acc1 >>> 1) - (data_01a + data_01b);
                    acc2 <= (acc2 >>> 1) - (data_02a + data_02b);
                    acc3 <= (acc3 >>> 1) - (data_03a + data_03b);
                    acc4 <= (acc4 >>> 1) - (data_04a + data_04b);
                    acc5 <= (acc5 >>> 1) - (data_05a + data_05b);
                    acc6 <= (acc6 >>> 1) - (data_06a + data_06b);
                    acc7 <= (acc7 >>> 1) - (data_07a + data_07b);
                    acc8 <= (acc8 >>> 1) - (data_08a + data_08b);
                    acc9 <= (acc9 >>> 1) - (data_09a + data_09b);
                    acc10 <= (acc10 >>> 1) - (data_10a + data_10b);
                    acc11 <= (acc11 >>> 1) - (data_11a + data_11b);
                    acc12 <= (acc12 >>> 1) - (data_12a + data_12b);
                    acc13 <= (acc13 >>> 1) - (data_13a + data_13b);
                    acc14 <= (acc14 >>> 1) - (data_14a + data_14b);
                    acc15 <= (acc15 >>> 1) - (data_15a + data_15b);
                end
                else begin
                    acc0 <= (data_00a + data_00b) + (acc0 >>> 1);
                    acc1 <= (data_01a + data_01b) + (acc1 >>> 1);
                    acc2 <= (data_02a + data_02b) + (acc2 >>> 1);
                    acc3 <= (data_03a + data_03b) + (acc3 >>> 1);
                    acc4 <= (data_04a + data_04b) + (acc4 >>> 1);
                    acc5 <= (data_05a + data_05b) + (acc5 >>> 1);
                    acc6 <= (data_06a + data_06b) + (acc6 >>> 1);
                    acc7 <= (data_07a + data_07b) + (acc7 >>> 1);
                    acc8 <= (data_08a + data_08b) + (acc8 >>> 1);
                    acc9 <= (data_09a + data_09b) + (acc9 >>> 1);
                    acc10 <= (data_10a + data_10b) + (acc10 >>> 1);
                    acc11 <= (data_11a + data_11b) + (acc11 >>> 1);
                    acc12 <= (data_12a + data_12b) + (acc12 >>> 1);
                    acc13 <= (data_13a + data_13b) + (acc13 >>> 1);
                    acc14 <= (data_14a + data_14b) + (acc14 >>> 1);
                    acc15 <= (data_15a + data_15b) + (acc15 >>> 1);
                end
                count <= count + 1;
            end
            
            DONE: begin
                done <= 1;
//                all_outputs <= {acc15, acc14, acc13, acc12, acc11, acc10, acc9, acc8, acc7, acc6, acc5, acc4, acc3, acc2, acc1, acc0};
                out0 <= acc0;
                out1 <= acc1;
                out2 <= acc2;
                out3 <= acc3;
                out4 <= acc4;
                out5 <= acc5;
                out6 <= acc6;
                out7 <= acc7;
                out8 <= acc8;
                out9 <= acc9;
                out10 <= acc10;
                out11 <= acc11;
                out12 <= acc12;
                out13 <= acc13;
                out14 <= acc14;
                out15 <= acc15;
            end
            endcase
        end
    end
endmodule
