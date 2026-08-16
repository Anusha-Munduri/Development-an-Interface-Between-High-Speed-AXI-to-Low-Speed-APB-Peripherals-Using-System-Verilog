module cf_axi_lite_to_apb_bridge (

    input  logic ACLK,
    input  logic ARESETn,

    // AXI WRITE ADDRESS CHANNEL
    input  logic [31:0] AWADDR,
    input  logic        AWVALID,
    output logic        AWREADY,

    // AXI WRITE DATA CHANNEL
    input  logic [31:0] WDATA,
    input  logic        WVALID,
    output logic        WREADY,

    // AXI WRITE RESPONSE
    output logic [1:0]  BRESP,
    output logic        BVALID,
    input  logic        BREADY,

    // AXI READ ADDRESS CHANNEL
    input  logic [31:0] ARADDR,
    input  logic        ARVALID,
    output logic        ARREADY,

    // AXI READ DATA CHANNEL
    output logic [31:0] RDATA,
    output logic [1:0]  RRESP,
    output logic        RVALID,
    input  logic        RREADY,

    // APB INTERFACE
    output logic [31:0] PADDR,
    output logic [31:0] PWDATA,
    output logic        PWRITE,
    output logic        PSEL,
    output logic        PENABLE,
    input  logic        PREADY,
    input  logic [31:0] PRDATA,
    input  logic        PSLVERR
);

    // ============================
    // INTERNAL REGISTERS
    // ============================
    logic [31:0] addr_reg, data_reg;
    logic write_req, read_req;

    // AXI capture flags
    logic aw_done, w_done;

    // ============================
    // FSM STATES
    // ============================
    typedef enum logic [1:0] {
        IDLE,
        SETUP,
        ACCESS,
        RESP
    } state_t;

    state_t state, next_state;

    // ============================
    // AXI HANDSHAKE CAPTURE
    // ============================
    always_ff @(posedge ACLK or negedge ARESETn) begin
        if (!ARESETn) begin
            aw_done <= 0;
            w_done  <= 0;
            ARREADY <= 0;
        end else begin
            // Capture write address
            if (AWVALID && !aw_done) begin
                addr_reg <= AWADDR;
                aw_done  <= 1;
            end

            // Capture write data
            if (WVALID && !w_done) begin
                data_reg <= WDATA;
                w_done   <= 1;
            end

            // Capture read address
            if (ARVALID && !ARREADY) begin
                addr_reg <= ARADDR;
                ARREADY  <= 1;
            end

            // Reset flags after transaction
            if (state == RESP) begin
                aw_done <= 0;
                w_done  <= 0;
                ARREADY <= 0;
            end
        end
    end

    assign write_req = aw_done & w_done;
    assign read_req  = ARVALID;

    assign AWREADY = !aw_done;
    assign WREADY  = !w_done;

    // ============================
    // FSM
    // ============================
    always_ff @(posedge ACLK or negedge ARESETn) begin
        if (!ARESETn)
            state <= IDLE;
        else
            state <= next_state;
    end

    always_comb begin
        next_state = state;

        case (state)
            IDLE:
                if (write_req || read_req)
                    next_state = SETUP;

            SETUP:
                next_state = ACCESS;

            ACCESS:
                if (PREADY)
                    next_state = RESP;

            RESP:
                next_state = IDLE;
        endcase
    end

    // ============================
    // OUTPUT LOGIC
    // ============================
    always_comb begin
        // Defaults
        PSEL    = 0;
        PENABLE = 0;
        PWRITE  = 0;
        PADDR   = addr_reg;
        PWDATA  = data_reg;

        BVALID = 0;
        RVALID = 0;
        BRESP  = 2'b00;
        RRESP  = 2'b00;
        RDATA  = PRDATA;

        case (state)

            SETUP: begin
                PSEL = 1;
                PWRITE = write_req;
            end

            ACCESS: begin
                PSEL = 1;
                PENABLE = 1;
                PWRITE = write_req;
            end

            RESP: begin
                if (write_req) begin
                    BVALID = 1;
                    BRESP = PSLVERR ? 2'b10 : 2'b00;
                end else begin
                    RVALID = 1;
                    RDATA  = PRDATA;
                    RRESP  = PSLVERR ? 2'b10 : 2'b00;
                end
            end
        endcase
    end

endmodule