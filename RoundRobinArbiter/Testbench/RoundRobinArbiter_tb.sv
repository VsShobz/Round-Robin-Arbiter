`timescale 1ps / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.07.2025 13:04:00
// Design Name: 
// Module Name: RoundRobinArbiter_tb
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


module RoundRobinArbiter_tb();

    parameter N=4, ts_width = 4;
    ///// input/output declaration
    logic clk,reset;
    logic [N-1:0] req , grant; 
    
    ////// DUT instantiation
    RoundRobinArbiter #(.N(N),.ts_width(ts_width)) dut (.clk(clk),.reset(reset),.req(req),.grant(grant));
//    initial $display("Instantiated");
    ///// clock generation
    always #5 clk = ~clk;
    ///// task for waiting cycles ( improves readability)
    task wait_cycles (input int n);
        repeat(n) @(posedge clk);
    endtask
    
    initial begin
        $display ("[TB] Simulation starts");
        clk = 0;
        reset = 1;
        req = 4'b0000;
        wait_cycles(2);
        $display ("[TB] Reset");
        reset = 0;
        wait_cycles(1);
        $display ("Test Starts");
        //// TEST 1 - only client 2 works
        $display ("[TB] Test 1");
        req = 4'b0100;
        wait_cycles (4);
        req = 4'b0000;
        wait_cycles(1);
        //// TEST 2 - multiple clients called
        $display ("[TB] Test 2");
        req = 4'b1011;
        
        wait_cycles(9);
        $display("Test complete");
        $finish;
        
    end
    
    always@(posedge clk) $display ( "time =%0t || req = %b || grant = %b ", $time, req,grant );

endmodule
