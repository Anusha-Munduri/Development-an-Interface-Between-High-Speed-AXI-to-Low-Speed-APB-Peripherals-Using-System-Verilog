`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.03.2026 02:03:56
// Design Name: 
// Module Name: cf_apb_if
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
// File Name : cf_apb_if.sv
// Description : APB Interface Definition
//==================================================

interface cf_apb_if (
    input  logic PCLK,
    input  logic PRESETn
);

    logic [31:0] PADDR;
    logic        PSEL;
    logic        PENABLE;
    logic        PWRITE;
    logic [31:0] PWDATA;
    logic [31:0] PRDATA;
    logic        PREADY;
    logic        PSLVERR;

endinterface