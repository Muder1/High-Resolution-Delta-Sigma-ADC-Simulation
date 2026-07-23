`timescale 1ns / 1ps
module cic_filter_4stage #(
    parameter R = 256  // Decimation factor
)(
    input wire clk,           // High-speed clock (Fs = 128 kHz)
    input wire rst,           // Active-high reset
    input wire bitstream_in,  // 1-bit input from the Delta-Sigma Modulator (0 or 1)
    output reg signed [19:0] final_adc_out, // 20-bit truncated final output
    output reg out_valid      // Pulses high when a new decimated sample is ready
);

    // -----------------------------------------------------------------
    // 1. Input Mapping binary 0/1 to signed 2's complement -1/+1
    // -----------------------------------------------------------------
    wire signed [32:0] din_signed = bitstream_in ? 33'sd1 : -33'sd1;

    // -----------------------------------------------------------------
    // 2. Integrator Section (Running at Fs)
    // -----------------------------------------------------------------
    reg signed [32:0] int1, int2, int3, int4;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            int1 <= 33'd0; 
            int2 <= 33'd0; 
            int3 <= 33'd0; 
            int4 <= 33'd0; 
        end else begin
            int1 <= int1 + din_signed;
            int2 <= int2 + int1;
            int3 <= int3 + int2;
            int4 <= int4 + int3;
        end
    end

    // -----------------------------------------------------------------
    // 3. Downsampler (Clock Divider)
    // -----------------------------------------------------------------
    reg [7:0] counter; // 8-bit counter handles up to R=256
    wire decimation_tick = (counter == R - 1);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= 8'd0;
        end else begin
            if (decimation_tick)
                counter <= 8'd0;
            else
                counter <= counter + 8'd1;
        end
    end

    // -----------------------------------------------------------------
    // 4. Comb Section (Running at Fs / R)
    // -----------------------------------------------------------------
    reg signed [32:0] comb1_d, comb2_d, comb3_d, comb4_d;
    reg signed [32:0] comb1,   comb2,   comb3,   comb4;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            comb1_d <= 33'd0; comb2_d <= 33'd0; comb3_d <= 33'd0; comb4_d <= 33'd0;
            comb1   <= 33'd0; comb2   <= 33'd0; comb3   <= 33'd0; comb4   <= 33'd0;
            final_adc_out <= 20'd0;
            out_valid <= 1'b0;
        end else begin
            out_valid <= 1'b0; // Default state: no valid output
            
            if (decimation_tick) begin
                // Stage 1
                comb1_d <= int4;
                comb1   <= int4 - comb1_d;
                
                // Stage 2
                comb2_d <= comb1;
                comb2   <= comb1 - comb2_d;
                
                // Stage 3
                comb3_d <= comb2;
                comb3   <= comb2 - comb3_d;
                
                // Stage 4
                comb4_d <= comb3;
                comb4   <= comb3 - comb4_d;
                
                // Output: Truncate 33 bits down to 20 bits (Drop the bottom 13 noise bits)
                final_adc_out <= comb4[32:13];
                out_valid <= 1'b1;
            end
        end
    end

endmodule