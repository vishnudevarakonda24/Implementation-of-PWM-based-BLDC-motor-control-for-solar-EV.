module bldc_controller (
    input wire clk, rst_n, fault,
    input wire [2:0] hall,
    input wire [7:0] pwm_duty,
    output reg [5:0] gates // [5:4]=Leg3(H,L), [3:2]=Leg2(H,L), [1:0]=Leg1(H,L)
);
    reg [5:0] raw_g;
    reg [7:0] pwm_cnt;
    reg [5:0] dt_cnt [0:2]; // Array of 3 dead-time counters
    wire pwm = (pwm_cnt < pwm_duty);
    integer i;

    // 1. PWM & Global Counter
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) pwm_cnt <= 0; else pwm_cnt <= pwm_cnt + 1;
    end

    // 2. Compressed 6-Step Lookup Table
    always @(*) begin
        case (hall) // Mapped as: {Q3H,Q3L, Q2H,Q2L, Q1H,Q1L}
            3'b101: raw_g = {2'b00,  2'b01,  1'b1, 1'b0 & pwm}; // Step 1: Q1H active
            3'b001: raw_g = {2'b01,  2'b00,  1'b1, 1'b0 & pwm}; // Step 2
            3'b011: raw_g = {2'b01,  1'b1, 1'b0 & pwm,  2'b00}; // Step 3
            3'b010: raw_g = {2'b00,  1'b1, 1'b0 & pwm,  2'b10}; // Step 4
            3'b110: raw_g = {1'b1, 1'b0 & pwm,  2'b00,  2'b10}; // Step 5
            3'b100: raw_g = {1'b1, 1'b0 & pwm,  2'b01,  2'b00}; // Step 6
            default: raw_g = 6'b000000;
        endcase
    end

    // 3. Compressed Parallel Protection Loop (All 3 Legs)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || fault) begin
            gates <= 0;
            for (i=0; i<3; i=i+1) dt_cnt[i] <= 0;
        end else begin
            for (i=0; i<3; i=i+1) begin
                if (raw_g[2*i+1] == raw_g[2*i]) begin
                    gates[2*i+1 : 2*i] <= 2'b00; dt_cnt[i] <= 0;
                end else if (raw_g[2*i+1] && !gates[2*i+1]) begin
                    gates[2*i] <= 0; // Drop Low Side immediately
                    if (dt_cnt[i] < 50) dt_cnt[i] <= dt_cnt[i] + 1; else gates[2*i+1] <= 1;
                end else if (raw_g[2*i] && !gates[2*i]) begin
                    gates[2*i+1] <= 0; // Drop High Side immediately
                    if (dt_cnt[i] < 50) dt_cnt[i] <= dt_cnt[i] + 1; else gates[2*i] <= 1;
                end else begin
                    gates[2*i+1 : 2*i] <= raw_g[2*i+1 : 2*i]; dt_cnt[i] <= 0;
                end
            end
        end
    end
endmodule


