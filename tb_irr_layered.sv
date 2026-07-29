`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.07.2026 10:36:42
// Design Name: 
// Module Name: tb_irr_layered
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

module tb_irr_layered; 
    reg        clk; 
    reg        reset; 
    reg  [3:0] request; 
    wire [3:0] grant; 
    wire [1:0] g_id; 
    integer pass_count; 
    integer fail_count; 
    irr_arbiter_top DUT ( 
        .clk    (clk), 
        .reset  (reset), 
        .request(request), 
        .grant  (grant), 
        .g_id   (g_id) 
    ); 
    initial clk = 0; 
    always #5 clk = ~clk; 
    task driver; 
        input [3:0] req; 
        begin 
            @(posedge clk); 
            #1; 
            request = req; 
        end 
    endtask 
    task monitor_check; 
        input [3:0] req; 
        reg grant_ok; 
        reg gid_ok; 
        reg req_ok; 
        begin 
            #2; // wait for outputs to settle after clock edge 
            if (req == 4'b0000) begin 
                if (grant == 4'b0000) begin 
                    $display("[PASS] Time=%0t | Req=%b | Grant=%b | g_id=%0d | idle -> zero grant", 
                             $time, req, grant, g_id); 
                    pass_count = pass_count + 1; 
                end else begin 
                    $display("[FAIL] Time=%0t | Req=%b | Grant=%b | g_id=%0d | expected 0000", 
                             $time, req, grant, g_id); 
                    fail_count = fail_count + 1; 
                end 
            end else begin 
                grant_ok = (grant != 0) && ((grant & (grant - 1)) == 0); 
                gid_ok   = (grant == (4'b0001 << g_id)); 
                req_ok   = req[g_id]; 
                if (grant_ok && gid_ok && req_ok) begin 
                    $display("[PASS] Time=%0t | Req=%b | Grant=%b | g_id=%0d", 
                             $time, req, grant, g_id); 
                    pass_count = pass_count + 1; 
                end else begin 
                    $display("[FAIL] Time=%0t | Req=%b | Grant=%b | g_id=%0d | one_hot=%b gid_ok=%b 
req_ok=%b", 
                             $time, req, grant, g_id, grant_ok, gid_ok, req_ok); 
                    fail_count = fail_count + 1; 
                end 
            end 
        end 
    endtask 
    task run_env; 
        integer i; 
        begin 
            $display("--------------------------------------"); 
            $display(" Scenario 1: Req=1111 | 6 cycles"); 
            $display(" Expected  : 0001->0010->0100->1000"); 
            $display("--------------------------------------"); 
            for (i = 0; i < 6; i = i + 1) begin 
                driver(4'b1111); 
                monitor_check(4'b1111); 
            end 
            $display("--------------------------------------"); 
            $display(" Scenario 2: Req=0000 | 2 cycles"); 
            $display(" Expected  : Grant=0000, priority held"); 
            $display("--------------------------------------"); 
            for (i = 0; i < 2; i = i + 1) begin 
                driver(4'b0000); 
                monitor_check(4'b0000); 
            end 
            $display("--------------------------------------"); 
            $display(" Scenario 3: Req=1001 | 6 cycles"); 
            $display(" Expected  : resumes from stored priority"); 
            $display("--------------------------------------"); 
            for (i = 0; i < 6; i = i + 1) begin 
                driver(4'b1001); 
                monitor_check(4'b1001); 
            end 
            $display("--------------------------------------"); 
            $display(" Scenario 4: Single requests"); 
            $display("--------------------------------------"); 
            driver(4'b0001); monitor_check(4'b0001); 
            driver(4'b0010); monitor_check(4'b0010); 
            driver(4'b0100); monitor_check(4'b0100); 
            driver(4'b1000); monitor_check(4'b1000); 
            $display("--------------------------------------"); 
            $display(" Scenario 5: Alternating 0101/1010"); 
            $display("--------------------------------------"); 
            for (i = 0; i < 4; i = i + 1) begin 
                driver(4'b0101); monitor_check(4'b0101); 
                driver(4'b1010); monitor_check(4'b1010); 
            end 
        end 
    endtask 
    initial begin 
        pass_count = 0; 
        fail_count = 0; 
        reset   = 1; 
        request = 4'b0000; 
        @(posedge clk); #1; 
        @(posedge clk); #1; 
        reset = 0; 
        run_env; 
        $display("======================================"); 
        $display("  SCOREBOARD FINAL REPORT"); 
        $display("  PASS  : %0d", pass_count); 
        $display("  FAIL  : %0d", fail_count); 
        $display("  TOTAL : %0d", pass_count + fail_count); 
        if (fail_count == 0) 
            $display("  STATUS: ALL TESTS PASSED"); 
        else 
            $display("  STATUS: SOME TESTS FAILED"); 
        $display("======================================"); 
        $finish; 
    end 
endmodule
