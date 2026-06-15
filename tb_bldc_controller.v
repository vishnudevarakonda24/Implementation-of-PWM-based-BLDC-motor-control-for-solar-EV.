`timescale 1ns/1ps

module tb_bldc_controller;
    reg clk;
    reg rst_n;
    reg [2:0] hall;
    reg [7:0] pwm_duty;
    reg fault;
    wire Q1H, Q1L, Q2H, Q2L, Q3H, Q3L;

    bldc_controller uut (
        .clk(clk), .rst_n(rst_n), .hall(hall), .pwm_duty(pwm_duty), .fault(fault),
        .Q1H(Q1H), .Q1L(Q1L), .Q2H(Q2H), .Q2L(Q2L), .Q3H(Q3H), .Q3L(Q3L)
    );

    always #10 clk = ~clk; // 50MHz

    initial begin
        clk = 0; rst_n = 0; fault = 0; hall = 3'b000;
        pwm_duty = 8'd128; // Set 50% Duty Cycle speed
        #40 rst_n = 1;

        // Run through motor commutation steps
        #100 hall = 3'b101; // Step 1 (Observe chopped PWM on Q1H)
        #1000 hall = 3'b001; // Step 2
        
        // Increase speed dynamically
        #500 pwm_duty = 8'd200; // Change to ~78% Duty Cycle
        #500 hall = 3'b011; // Step 3
        
        // Trigger Overcurrent Fault Condition
        #500 fault = 1; // Instant system-wide hardware shutdown
        
        #200 $finish;
    end

    initial begin
        $dumpfile("bldc_sim.vcd");
        $dumpvars(0, tb_bldc_controller);
    end
endmodule
