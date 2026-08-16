`timescale 1ns/1ps

module cf_tb_axi_to_apb_bridge;

    //-------------------------
    // Clock & Reset
    //-------------------------
    logic ACLK;
    logic ARESETn;

    initial begin
        ACLK = 0;
        forever #5 ACLK = ~ACLK;   // 100 MHz
    end

    //-------------------------
    // AXI Signals
    //-------------------------
    logic [31:0] AWADDR;
    logic        AWVALID;
    logic        AWREADY;

    logic [31:0] WDATA;
    logic        WVALID;
    logic        WREADY;

    logic [1:0]  BRESP;
    logic        BVALID;
    logic        BREADY;

    logic [31:0] ARADDR;
    logic        ARVALID;
    logic        ARREADY;

    logic [31:0] RDATA;
    logic [1:0]  RRESP;
    logic        RVALID;
    logic        RREADY;

    //-------------------------
    // APB Signals
    //-------------------------
    logic [31:0] PADDR;
    logic        PSEL;
    logic        PENABLE;
    logic        PWRITE;
    logic [31:0] PWDATA;
    logic [31:0] PRDATA;
    logic        PREADY;

    //-------------------------
    // DUT
    //-------------------------
    cf_axi_to_apb_bridge dut (
        .ACLK(ACLK),
        .ARESETn(ARESETn),

        .AWADDR(AWADDR),
        .AWVALID(AWVALID),
        .AWREADY(AWREADY),

        .WDATA(WDATA),
        .WVALID(WVALID),
        .WREADY(WREADY),

        .BRESP(BRESP),
        .BVALID(BVALID),
        .BREADY(BREADY),

        .ARADDR(ARADDR),
        .ARVALID(ARVALID),
        .ARREADY(ARREADY),

        .RDATA(RDATA),
        .RRESP(RRESP),
        .RVALID(RVALID),
        .RREADY(RREADY),

        .PADDR(PADDR),
        .PSEL(PSEL),
        .PENABLE(PENABLE),
        .PWRITE(PWRITE),
        .PWDATA(PWDATA),
        .PRDATA(PRDATA),
        .PREADY(PREADY)
    );

    //-------------------------
    // RESET
    //-------------------------
    task reset_dut();
        begin
            ARESETn = 0;

            AWVALID = 0;
            WVALID  = 0;
            ARVALID = 0;
            BREADY  = 0;
            RREADY  = 0;
            PREADY  = 0;
            PRDATA  = 0;

            #20;
            ARESETn = 1;
            #10;
        end
    endtask

    //-------------------------
    // AXI WRITE
    //-------------------------
    task axi_write(input [31:0] addr, input [31:0] data);
        begin
            @(posedge ACLK);
            AWADDR  = addr;
            WDATA   = data;
            AWVALID = 1;
            WVALID  = 1;
            BREADY  = 1;
            PREADY  = 1;

            wait (BVALID);

            @(posedge ACLK);
            AWVALID = 0;
            WVALID  = 0;
            BREADY  = 0;
        end
    endtask

    //-------------------------
    // AXI READ
    //-------------------------
    task axi_read(input [31:0] addr);
        begin
            @(posedge ACLK);
            ARADDR  = addr;
            ARVALID = 1;
            RREADY  = 1;

            PRDATA  = 32'h1234_5678;
            PREADY  = 1;

            wait (RVALID);

            @(posedge ACLK);
            ARVALID = 0;
            RREADY  = 0;
        end
    endtask

    //-------------------------
    // MAIN TEST
    //-------------------------
    initial begin
        reset_dut();

        axi_write(32'h1000, 32'hA5A5A5A5);
        #20;

        axi_read(32'h1000);
        #50;

        $display("SIMULATION COMPLETED SUCCESSFULLY");
        $finish;
    end

endmodule