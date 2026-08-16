`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.03.2026 02:02:42
// Design Name: 
// Module Name: cf_axi_lite_if
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
// File Name : cf_axi_lite_if.sv
// Description : AXI-Lite Interface Definition
//==================================================

interface cf_axi_lite_if (
    input  logic ACLK,
    input  logic ARESETn
);

    // Write Address Channel
    logic [31:0] AWADDR;
    logic        AWVALID;
    logic        AWREADY;

    // Write Data Channel
    logic [31:0] WDATA;
    logic        WVALID;
    logic        WREADY;

    // Write Response Channel
    logic [1:0]  BRESP;
    logic        BVALID;
    logic        BREADY;

    // Read Address Channel
    logic [31:0] ARADDR;
    logic        ARVALID;
    logic        ARREADY;

    // Read Data Channel
    logic [31:0] RDATA;
    logic [1:0]  RRESP;
    logic        RVALID;
    logic        RREADY;

endinterface