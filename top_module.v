`timescale 1ns / 1ps
module top_module(
        input clk,rst,start,
        input [7:0]master_tx_data,
        input [7:0]slave_tx_data,
        
        output wire [7:0]master_rx_data,
        output wire [7:0]slave_rx_data,
        output wire slave_rx_valid,
        output wire busy);
        
  wire sclk;
  wire cs;
  wire miso;
  wire mosi;
  
  //spi_master
  spi_master master(
           .clk(clk),
           .rst(rst),
           .start(start),
           .tx_data(master_tx_data),
           .MISO(miso),
           .CS(cs),
           .SCLK(sclk),
           .MOSI(mosi),
           .busy(busy),
           .rx_data(master_rx_data));
  //spi slave
  spi_slave slave(
            .sclk(sclk),
            .cs(cs),
            .rst(rst),
            .mosi(mosi),
            .tx_data(slave_tx_data),
            .miso(miso),
            .rx_valid(slave_rx_valid),
            .rx_data(slave_rx_data)
            );
  
endmodule

//testbench

module tb_spi_master_slave_top;

    
    reg clk;
    reg rst;
    reg start;

    reg [7:0] master_tx_data;
    reg [7:0] slave_tx_data;

    wire [7:0] master_rx_data;
    wire [7:0] slave_rx_data;
    wire       slave_rx_valid;
    wire       busy;

    // -------- DUT --------
    top_module DUT (
        .clk            (clk),
        .rst            (rst),
        .start          (start),
        .master_tx_data (master_tx_data),
        .slave_tx_data  (slave_tx_data),
        .master_rx_data (master_rx_data),
        .slave_rx_data  (slave_rx_data),
        .slave_rx_valid (slave_rx_valid),
        .busy           (busy)
    );

   
    always #5 clk = ~clk;   // 100 MHz system clock

   
    initial begin
        // Init
        clk = 0;
        rst = 1;
        start = 0;
        master_tx_data = 8'h00;
        slave_tx_data  = 8'h00;

        // Reset
        #20;
        rst = 0;

        // Load data
        master_tx_data = 8'hA5;   // Master ? Slave
        slave_tx_data  = 8'hCC;   // Slave ? Master

        // Start SPI transfer
        #20;
        start = 1;
        #10;
        start = 0;

        // Wait for transfer to complete
        wait (busy == 1);
        wait (busy == 0);

        
        #50;
        $finish;
    end

endmodule
