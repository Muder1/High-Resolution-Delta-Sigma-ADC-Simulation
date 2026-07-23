`timescale 1ns / 1ps

module tb_cic_filter;
    // -----------------------------------------------------------------
    // Signals
    // -----------------------------------------------------------------
    reg clk;
    reg rst;
    reg bitstream_in;
    wire signed [19:0] final_adc_out;
    wire out_valid;

    // File I/O Variables
    integer file_in;
    integer file_out;
    integer scan_file;
    integer raw_bit;

    // -----------------------------------------------------------------
    // Instantiate the Design Under Test (DUT)
    // -----------------------------------------------------------------
  cic_filter_4stage #(.R(256)) dut (
        .clk(clk),
        .rst(rst),
        .bitstream_in(bitstream_in),
        .final_adc_out(final_adc_out),
        .out_valid(out_valid)
    );

    // -----------------------------------------------------------------
    // Clock Generation
    // -----------------------------------------------------------------
    always #5 clk = ~clk;

    // -----------------------------------------------------------------
    // Main Simulation Block
    // -----------------------------------------------------------------
    initial begin
        // Initialize Signals
        clk = 0; 
        rst = 1; 
        bitstream_in = 0;
        
        // 1. Open Input File with Strict Error Checking
        file_in = $fopen("bitstream_in.txt", "r");
        if (file_in == 0) begin
            $display("=================================================");
            $display("FATAL ERROR: Cannot find bitstream_in.txt!");
            $display("Ensure you are running 'vvp sim' in the exact same");
            $display("directory where the MATLAB text file is located.");
            $display("=================================================");
            $finish;
        end
        
        // 2. Open Output File
        file_out = $fopen("rtl_output.txt", "w");
        if (file_out == 0) begin
            $display("FATAL ERROR: Cannot create rtl_output.txt!");
            $finish;
        end

        // 3. Release Reset
        #100;
        rst = 0; 

        // 4. Read the input file synchronously
        while (!$feof(file_in)) begin
            @(posedge clk);
            scan_file = $fscanf(file_in, "%d\n", raw_bit);
            
            // Only assign if a value was successfully read 

            if (scan_file == 1) begin
                bitstream_in = raw_bit[0]; 
            end
        end
        
        // 5. Clean up and Exit
        $display("=================================================");
        $display("Simulation Complete! Check rtl_output.txt");
        $display("=================================================");
        $fclose(file_in); 
        $fclose(file_out); 
        $finish;
    end

    // -----------------------------------------------------------------
    // Write Valid Outputs to File
    // -----------------------------------------------------------------
    always @(posedge clk) begin
        // Whenever the CIC filter pulses 'out_valid', write the 20-bit output
        if (!rst && out_valid) begin
            $fdisplay(file_out, "%d", final_adc_out);
        end
    end

endmodule