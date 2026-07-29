`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.07.2026 10:33:15
// Design Name: 
// Module Name: priority_reg_sf
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module priority_reg_sf( 
    input clk, 
    input reset, 
    input any_r, 
    input [1:0] next_g, 
    output reg [1:0] priority_out 
); 
    always @(posedge clk or posedge reset) begin 
        if (reset) 
            priority_out <= 2'b00; 
        else if (any_r) 
            priority_out <= next_g; 
        else 
            priority_out <= priority_out; 
    end 
endmodule 
module irr_index_logic( 
    input [3:0] request, 
    input [1:0] priority_in, 
    output reg [1:0] g_id 
); 
    always @(*) begin 
        case (priority_in) 
            2'd0: begin 
                if      (request[0]) g_id = 2'd0; 
                else if (request[1]) g_id = 2'd1; 
                else if (request[2]) g_id = 2'd2; 
                else                 g_id = 2'd3; 
            end 
            2'd1: begin 
                if      (request[1]) g_id = 2'd1; 
                else if (request[2]) g_id = 2'd2; 
                else if (request[3]) g_id = 2'd3; 
                else                 g_id = 2'd0; 
            end 
            2'd2: begin 
                if      (request[2]) g_id = 2'd2; 
                else if (request[3]) g_id = 2'd3; 
                else if (request[0]) g_id = 2'd0; 
                else                 g_id = 2'd1; 
            end 
            2'd3: begin 
                if      (request[3]) g_id = 2'd3; 
                else if (request[0]) g_id = 2'd0; 
                else if (request[1]) g_id = 2'd1; 
                else                 g_id = 2'd2; 
            end 
            default: g_id = 2'd0; 
        endcase 
    end 
endmodule 
module irr_arbiter_top( 
    input clk, 
    input reset, 
    input [3:0] request, 
    output [3:0] grant, 
    output [1:0] g_id 
); 
    wire [1:0] current_priority; 
    wire [1:0] next_g; 
    wire any_r; 
    assign any_r = |request; 
    priority_reg_sf PR_INST ( 
        .clk(clk), 
        .reset(reset), 
        .any_r(any_r), 
        .next_g(next_g), 
        .priority_out(current_priority) 
    ); 
    irr_index_logic INDEX_LOGIC ( 
        .request(request), 
        .priority_in(current_priority), 
        .g_id(g_id) 
    ); 
    assign grant = (any_r) ? (4'b0001 << g_id) : 4'b0000; 
    assign next_g = g_id + 1'b1; 
endmodule 
module transaction_store; 
    reg [3:0] req; 
    reg [3:0] gnt; 
    reg [1:0] gid; 
endmodule 
module generator( 
    output reg [3:0] gen_request, 
    output reg       gen_valid, 
    input wire       clk 
); 
    initial begin 
        gen_valid   = 0; 
        gen_request = 4'b0000; 
    end 
endmodule 

