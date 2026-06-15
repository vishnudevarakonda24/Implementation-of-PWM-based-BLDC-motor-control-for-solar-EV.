`timescale 1ns/1ps
module tb_bldc_controller;
    reg clk, rst_n, fault; reg [2:0] hl; reg [7:0] dy; wire [5:0] gt;
    bldc_controller uut (clk, rst_n, fault, hl, dy, gt);
    always #10 clk = ~clk;
    initial begin
        {clk, rst_n, fault, hl, dy} = {3'b000, 3'b000, 8'd128}; #40 rst_n = 1;
        #100 hl = 3'b101; #1000 hl = 3'b001; #500 dy = 8'd200; #500 fault = 1; #200 $finish;
    end
endmodule

