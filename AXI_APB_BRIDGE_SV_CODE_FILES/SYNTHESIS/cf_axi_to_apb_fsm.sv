`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.03.2026 02:04:50
// Design Name: 
// Module Name: cf_axi_to_apb_fsm
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


//==================================================
// File Name : cf_axi_to_apb_fsm.sv
// Description : AXI to APB FSM Controller
//==================================================

module cf_axi_to_apb_fsm (
    input  logic        clk,
    input  logic        resetn,

    // AXI side control
    input  logic        axi_wr_req,
    input  logic        axi_rd_req,
    input  logic [31:0] axi_addr,
    input  logic [31:0] axi_wdata,

    // APB side
    output logic        PSEL,
    output logic        PENABLE,
    output logic        PWRITE,
    output logic [31:0] PADDR,
    output logic [31:0] PWDATA,
    input  logic        PREADY,
    input  logic [31:0] PRDATA,

    // AXI read data
    output logic [31:0] axi_rdata,
    output logic        done
);

    // FSM States
    typedef enum logic [1:0] {
        IDLE,
        SETUP,
        ACCESS
    } state_t;

    state_t state, next_state;

    // State Register
    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn)
            state <= IDLE;
        else
            state <= next_state;
    end

    // Next State Logic
    always_comb begin
        next_state = state;
        case (state)
            IDLE: begin
                if (axi_wr_req || axi_rd_req)
                    next_state = SETUP;
            end

            SETUP: begin
                next_state = ACCESS;
            end

            ACCESS: begin
                if (PREADY)
                    next_state = IDLE;
            end
        endcase
    end

    // Output Logic
    always_comb begin
        // Defaults
        PSEL       = 0;
        PENABLE    = 0;
        PWRITE     = 0;
        PADDR      = axi_addr;
        PWDATA     = axi_wdata;
        axi_rdata  = PRDATA;
        done       = 0;

        case (state)
            SETUP: begin
                PSEL   = 1;
                PWRITE = axi_wr_req;
            end

            ACCESS: begin
                PSEL    = 1;
                PENABLE = 1;
                PWRITE  = axi_wr_req;
                if (PREADY)
                    done = 1;
            end
        endcase
    end

endmodule
