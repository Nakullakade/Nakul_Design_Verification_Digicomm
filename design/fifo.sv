// File: design/fifo.sv
// Description: Parameterized Synchronous FIFO Memory Module

module fifo #(
    parameter int DATA_WIDTH          = 32,
    parameter int DEPTH               = 16,
    parameter int ALMOST_FULL_THRESH  = DEPTH - 1,
    parameter int ALMOST_EMPTY_THRESH = 1,
    localparam int ADDR_WIDTH         = $clog2(DEPTH)
)(
    input  logic                    clk,
    input  logic                    rst_n,
    input  logic                    wr_en,
    input  logic [DATA_WIDTH-1:0]   wdata,
    input  logic                    rd_en,
    output logic [DATA_WIDTH-1:0]   rdata,
    output logic                    full,
    output logic                    empty,
    output logic                    almost_full,
    output logic                    almost_empty,
    output logic [ADDR_WIDTH:0]     count
);

    // Internal Memory Array
    logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    // Read and Write Pointers
    logic [ADDR_WIDTH-1:0] wr_ptr;
    logic [ADDR_WIDTH-1:0] rd_ptr;
    logic [ADDR_WIDTH:0]   count_q;

    // Operation status flags
    assign full         = (count_q == (ADDR_WIDTH+1)'(DEPTH));
    assign empty        = (count_q == '0);
    assign almost_full  = (count_q >= (ADDR_WIDTH+1)'(ALMOST_FULL_THRESH));
    assign almost_empty = (count_q <= (ADDR_WIDTH+1)'(ALMOST_EMPTY_THRESH));
    assign count        = count_q;

    // Write Operations
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr <= '0;
        end else if (wr_en && (!full || rd_en)) begin
            mem[wr_ptr] <= wdata;
            if (wr_ptr == ADDR_WIDTH'(DEPTH - 1))
                wr_ptr <= '0;
            else
                wr_ptr <= wr_ptr + 1'b1;
        end
    end

    // Read Operations
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_ptr <= '0;
            rdata  <= '0;
        end else if (rd_en && (!empty || wr_en)) begin
            rdata <= mem[rd_ptr];
            if (rd_ptr == ADDR_WIDTH'(DEPTH - 1))
                rd_ptr <= '0;
            else
                rd_ptr <= rd_ptr + 1'b1;
        end
    end

    // FIFO Counter Tracking Logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count_q <= '0;
        end else begin
            case ({wr_en && (!full || rd_en), rd_en && (!empty || wr_en)})
                2'b10:   count_q <= count_q + 1'b1; // Write only
                2'b01:   count_q <= count_q - 1'b1; // Read only
                2'b11:   count_q <= count_q;        // Simultaneous Write & Read
                default: count_q <= count_q;        // No Op
            endcase
        end
    end

endmodule : fifo
