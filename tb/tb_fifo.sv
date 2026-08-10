// File: tb/tb_fifo.sv
// Description: Testbench for Parameterized FIFO and SystemVerilog Assertions (SVA) Verification

module tb_fifo;

    parameter int DATA_WIDTH = 16;
    parameter int DEPTH      = 8;

    logic clk;

    // Instantiate FIFO Interface
    fifo_if #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH),
        .ALMOST_FULL_THRESH(DEPTH - 2),
        .ALMOST_EMPTY_THRESH(2)
    ) tif (
        .clk(clk)
    );

    // Instantiate FIFO DUT connected to Interface
    fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH),
        .ALMOST_FULL_THRESH(DEPTH - 2),
        .ALMOST_EMPTY_THRESH(2)
    ) dut (
        .clk          (tif.clk),
        .rst_n        (tif.rst_n),
        .wr_en        (tif.wr_en),
        .wdata        (tif.wdata),
        .rd_en        (tif.rd_en),
        .rdata        (tif.rdata),
        .full         (tif.full),
        .empty        (tif.empty),
        .almost_full  (tif.almost_full),
        .almost_empty (tif.almost_empty),
        .count        (tif.count)
    );

    // Clock Generation (100MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test Sequence
    initial begin
        $display("==================================================");
        $display("      STARTING FIFO & SVA SIMULATION TEST        ");
        $display("==================================================");

        // Initialize signals
        tif.rst_n = 0;
        tif.wr_en = 0;
        tif.wdata = 0;
        tif.rd_en = 0;

        // Hold reset
        repeat (2) @(posedge clk);
        #1;
        tif.rst_n = 1;
        $display("[%0t] Reset released.", $time);

        // 1. Check initial empty state
        @(posedge clk);
        if (tif.empty !== 1'b1) $error("FIFO should be empty after reset!");

        // 2. Write data until full
        for (int i = 1; i <= DEPTH; i++) begin
            @(posedge clk);
            #1;
            tif.wr_en = 1;
            tif.wdata = i * 16'h1111;
            $display("[%0t] WRITE: data=0x%0h, count=%0d, full=%0b, empty=%0b", 
                     $time, tif.wdata, tif.count, tif.full, tif.empty);
        end

        @(posedge clk);
        #1;
        tif.wr_en = 0;
        if (tif.full !== 1'b1) $error("FIFO should be full!");
        $display("[%0t] FIFO successfully filled.", $time);

        // 3. Trigger Overflow condition to exercise SVA assertion
        $display("[%0t] Attempting Overflow Write...", $time);
        @(posedge clk);
        #1;
        tif.wr_en = 1;
        tif.wdata = 16'hDEAD;

        @(posedge clk);
        #1;
        tif.wr_en = 0;

        // 4. Read back all data until empty
        $display("[%0t] Starting Read operations...", $time);
        for (int i = 1; i <= DEPTH; i++) begin
            @(posedge clk);
            #1;
            tif.rd_en = 1;
            $display("[%0t] READ: data=0x%0h, count=%0d, full=%0b, empty=%0b", 
                     $time, tif.rdata, tif.count, tif.full, tif.empty);
        end

        @(posedge clk);
        #1;
        tif.rd_en = 0;
        if (tif.empty !== 1'b1) $error("FIFO should be empty!");

        // 5. Trigger Underflow condition to exercise SVA assertion
        $display("[%0t] Attempting Underflow Read...", $time);
        @(posedge clk);
        #1;
        tif.rd_en = 1;

        @(posedge clk);
        #1;
        tif.rd_en = 0;

        // 6. Test Simultaneous Read and Write
        $display("[%0t] Testing Simultaneous Read and Write...", $time);
        @(posedge clk);
        #1;
        tif.wr_en = 1;
        tif.wdata = 16'hBEEF;

        @(posedge clk);
        #1;
        tif.wr_en = 1;
        tif.rd_en = 1;
        tif.wdata = 16'hCAFE;

        @(posedge clk);
        #1;
        tif.wr_en = 0;
        tif.rd_en = 0;

        repeat (2) @(posedge clk);
        $display("==================================================");
        $display("      FIFO & SVA SIMULATION COMPLETED            ");
        $display("==================================================");
        $finish;
    end

endmodule
