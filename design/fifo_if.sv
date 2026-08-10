// File: design/fifo_if.sv
// Description: SystemVerilog interface for parameterized FIFO with SystemVerilog Assertions (SVA)

interface fifo_if #(
    parameter int DATA_WIDTH          = 32,
    parameter int DEPTH               = 16,
    parameter int ALMOST_FULL_THRESH  = DEPTH - 1,
    parameter int ALMOST_EMPTY_THRESH = 1
)(
    input logic clk
);

    // Core FIFO Signals
    logic                    rst_n;
    logic                    wr_en;
    logic [DATA_WIDTH-1:0]   wdata;
    logic                    rd_en;
    logic [DATA_WIDTH-1:0]   rdata;
    logic                    full;
    logic                    empty;
    logic                    almost_full;
    logic                    almost_empty;
    logic [$clog2(DEPTH):0]  count;

    // Modport definitions
    modport DUT (
        input  clk, rst_n, wr_en, wdata, rd_en,
        output rdata, full, empty, almost_full, almost_empty, count
    );

    modport TB (
        input  clk, rdata, full, empty, almost_full, almost_empty, count,
        output rst_n, wr_en, wdata, rd_en
    );

    modport MONITOR (
        input  clk, rst_n, wr_en, wdata, rd_en, rdata, full, empty, almost_full, almost_empty, count
    );

    // =========================================================================
    // SYSTEMVERILOG ASSERTIONS (SVA) & CHECKS
    // =========================================================================

`ifndef VERILATOR
    // Standard IEEE 1800 SystemVerilog Assertions (SVA)

    // 1. Overflow Assertion: Write attempted when FIFO is full (without concurrent read)
    property p_overflow;
        @(posedge clk) disable iff (!rst_n)
        (full && wr_en && !rd_en) |=> $error("[SVA ERROR] FIFO Overflow: Write attempted when FIFO was full!");
    endproperty
    assert_overflow: assert property (p_overflow);

    // 2. Underflow Assertion: Read attempted when FIFO is empty (without concurrent write)
    property p_underflow;
        @(posedge clk) disable iff (!rst_n)
        (empty && rd_en && !wr_en) |=> $error("[SVA ERROR] FIFO Underflow: Read attempted when FIFO was empty!");
    endproperty
    assert_underflow: assert property (p_underflow);

    // 3. Full Flag Consistency Assertion
    property p_full_flag;
        @(posedge clk) disable iff (!rst_n)
        (count == ($clog2(DEPTH)+1)'(DEPTH)) |-> full;
    endproperty
    assert_full_flag: assert property (p_full_flag);

    // 4. Empty Flag Consistency Assertion
    property p_empty_flag;
        @(posedge clk) disable iff (!rst_n)
        (count == '0) |-> empty;
    endproperty
    assert_empty_flag: assert property (p_empty_flag);

    // 5. Almost Full Flag Consistency Assertion
    property p_almost_full_flag;
        @(posedge clk) disable iff (!rst_n)
        (count >= ($clog2(DEPTH)+1)'(ALMOST_FULL_THRESH)) |-> almost_full;
    endproperty
    assert_almost_full_flag: assert property (p_almost_full_flag);

    // 6. Almost Empty Flag Consistency Assertion
    property p_almost_empty_flag;
        @(posedge clk) disable iff (!rst_n)
        (count <= ($clog2(DEPTH)+1)'(ALMOST_EMPTY_THRESH)) |-> almost_empty;
    endproperty
    assert_almost_empty_flag: assert property (p_almost_empty_flag);

    // 7. Reset State Verification
    property p_reset_state;
        @(posedge clk) !rst_n |-> (count == '0 && empty == 1'b1 && full == 1'b0);
    endproperty
    assert_reset_state: assert property (p_reset_state);

    // =========================================================================
    // COVERAGE PROPERTIES
    // =========================================================================
    cover_fifo_full:        cover property (@(posedge clk) disable iff (!rst_n) full);
    cover_fifo_empty:       cover property (@(posedge clk) disable iff (!rst_n) empty);
    cover_fifo_overflow:    cover property (@(posedge clk) disable iff (!rst_n) full && wr_en && !rd_en);
    cover_fifo_underflow:   cover property (@(posedge clk) disable iff (!rst_n) empty && rd_en && !wr_en);
    cover_simultaneous_rw:  cover property (@(posedge clk) disable iff (!rst_n) wr_en && rd_en && !full && !empty);

`else
    // Immediate procedural assertions for Verilator compatibility
    always_ff @(posedge clk) begin
        if (rst_n) begin
            if (full && wr_en && !rd_en)
                $error("[VERILATOR ASSERT] FIFO Overflow: Write attempted when FIFO was full!");
            if (empty && rd_en && !wr_en)
                $error("[VERILATOR ASSERT] FIFO Underflow: Read attempted when FIFO was empty!");
            if (count == ($clog2(DEPTH)+1)'(DEPTH) && !full)
                $error("[VERILATOR ASSERT] Full flag inconsistency!");
            if (count == '0 && !empty)
                $error("[VERILATOR ASSERT] Empty flag inconsistency!");
        end
    end
`endif

endinterface : fifo_if
