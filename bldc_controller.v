// Advanced BLDC Controller with PWM Speed Control and Fault Protection
module bldc_controller (
    input wire clk,             // System Clock (e.g., 50MHz)
    input wire rst_n,           // Active Low Reset
    input wire [2:0] hall,      // Hall Sensors {Hall3, Hall2, Hall1}
    input wire [7:0] pwm_duty,  // Speed control: 0 (0%) to 255 (100%)
    input wire fault,           // Overcurrent Trip (Active High)
    output reg Q1H, output reg Q1L,
    output reg Q2H, output reg Q2L,
    output reg Q3H, output reg Q3L
);

    // Internal Registers
    reg raw_Q1H, raw_Q1L, raw_Q2H, raw_Q2L, raw_Q3H, raw_Q3L;
    reg [7:0] pwm_cnt;
    wire pwm_out;
    
    // Dead-time counters
    reg [5:0] dt_cnt1, dt_cnt2, dt_cnt3;
    parameter DT_VAL = 6'd50;

    // 1. Hardware PWM Generator (Free-running 8-bit counter)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) pwm_cnt <= 8'd0;
        else pwm_cnt <= pwm_cnt + 1'b1;
    end
    assign pwm_out = (pwm_cnt < pwm_duty);

    // 2. 6-Step Commutation with High-Side PWM Chopping
    always @(*) begin
        case (hall)
            3'b101: begin // Step 1
                raw_Q1H = pwm_out; raw_Q1L = 0; raw_Q2H = 0; raw_Q2L = 1; raw_Q3H = 0; raw_Q3L = 0;
            end
            3'b001: begin // Step 2
                raw_Q1H = pwm_out; raw_Q1L = 0; raw_Q2H = 0; raw_Q2L = 0; raw_Q3H = 0; raw_Q3L = 1;
            end
            3'b011: begin // Step 3
                raw_Q1H = 0; raw_Q1L = 0; raw_Q2H = pwm_out; raw_Q2L = 0; raw_Q3H = 0; raw_Q3L = 1;
            end
            3'b010: begin // Step 4
                raw_Q1H = 0; raw_Q1L = 1; raw_Q2H = pwm_out; raw_Q2L = 0; raw_Q3H = 0; raw_Q3L = 0;
            end
            3'b110: begin // Step 5
                raw_Q1H = 0; raw_Q1L = 1; raw_Q2H = 0; raw_Q2L = 0; raw_Q3H = pwm_out; raw_Q3L = 0;
            end
            3'b100: begin // Step 6
                raw_Q1H = 0; raw_Q1L = 0; raw_Q2H = 0; raw_Q2L = 1; raw_Q3H = pwm_out; raw_Q3L = 0;
            end
            default: begin // Safe State
                raw_Q1H = 0; raw_Q1L = 0; raw_Q2H = 0; raw_Q2L = 0; raw_Q3H = 0; raw_Q3L = 0;
            end
        endcase
    end

    // 3. Leg 1 Output Stage with Dead-Time and Asynchronous Fault Trip
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || fault) begin
            dt_cnt1 <= 0; Q1H <= 0; Q1L <= 0;
        end else begin
            if (raw_Q1H == raw_Q1L) begin
                Q1H <= 0; Q1L <= 0; dt_cnt1 <= 0;
            end else if (raw_Q1H && !Q1H) begin
                Q1L <= 0;
                if (dt_cnt1 < DT_VAL) dt_cnt1 <= dt_cnt1 + 1;
                else Q1H <= 1;
            end else if (raw_Q1L && !Q1L) begin
                Q1H <= 0;
                if (dt_cnt1 < DT_VAL) dt_cnt1 <= dt_cnt1 + 1;
                else Q1L <= 1;
            end else begin
                Q1H <= raw_Q1H; Q1L <= raw_Q1L; dt_cnt1 <= 0;
            end
        end
    end

    // 4. Leg 2 Output Stage with Dead-Time and Asynchronous Fault Trip
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || fault) begin
            dt_cnt2 <= 0; Q2H <= 0; Q2L <= 0;
        end else begin
            if (raw_Q2H == raw_Q2L) begin
                Q2H <= 0; Q2L <= 0; dt_cnt2 <= 0;
            end else if (raw_Q2H && !Q2H) begin
                Q2L <= 0;
                if (dt_cnt2 < DT_VAL) dt_cnt2 <= dt_cnt2 + 1;
                else Q2H <= 1;
            end else if (raw_Q2L && !Q2L) begin
                Q2H <= 0;
                if (dt_cnt2 < DT_VAL) dt_cnt2 <= dt_cnt2 + 1;
                else Q2L <= 1;
            end else begin
                Q2H <= raw_Q2H; Q2L <= raw_Q2L; dt_cnt2 <= 0;
            end
        end
    end

    // 5. Leg 3 Output Stage with Dead-Time and Asynchronous Fault Trip
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || fault) begin
            dt_cnt3 <= 0; Q3H <= 0; Q3L <= 0;
        end else begin
            if (raw_Q3H == raw_Q3L) begin
                Q3H <= 0; Q3L <= 0; dt_cnt3 <= 0;
            end else if (raw_Q3H && !Q3H) begin
                Q3L <= 0;
                if (dt_cnt3 < DT_VAL) dt_cnt3 <= dt_cnt3 + 1;
                else Q3H <= 1;
            end else if (raw_Q3L && !Q3L) begin
                Q3H <= 0;
                if (dt_cnt3 < DT_VAL) dt_cnt3 <= dt_cnt3 + 1;
                else Q3L <= 1;
            end else begin
                Q3H <= raw_Q3H; Q3L <= raw_Q3L; dt_cnt3 <= 0;
            end
        end
    end
endmodule
