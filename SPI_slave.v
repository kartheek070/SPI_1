`timescale 1ns / 1ps
//SPI slave RX+SPI slave TX= SPI slave
module spi_slave(
    input sclk,cs,rst,mosi,
    input  [7:0] tx_data,   //data to transmit read from sensors
    output reg [7:0] rx_data,
    output reg miso,
    output reg rx_valid
);

reg [7:0] shift_tx; //data to be transmitted from slave to master via miso
reg [7:0] shift_rx; //data received from master mosi aligned into 8 bits
reg [2:0] bit_cnt;



always @(negedge cs or posedge rst) begin
    if (rst) begin
        shift_tx <= 8'd0;
    end else begin
        shift_tx <= tx_data;
    end
end


always @(negedge sclk or posedge rst) begin
    if (rst) begin
        miso <= 1'b0;
    end else if (!cs) begin
        miso     <= shift_tx[7];
        shift_tx <= {shift_tx[6:0], 1'b0};
    end else begin
        miso <= 1'b0;
    end
end

always @(posedge sclk or posedge rst) begin
    if (rst) begin
        shift_rx <= 8'd0;
        bit_cnt  <= 3'd7;
        rx_valid <= 1'b0;
        rx_data  <= 8'd0;
    end else if (!cs) begin
        shift_rx <= {shift_rx[6:0], mosi};

        if (bit_cnt == 0) begin
            rx_data  <= {shift_rx[6:0], mosi};
            rx_valid <= 1'b1;
            bit_cnt  <= 3'd7;
        end else begin
            bit_cnt <= bit_cnt - 1;
            rx_valid <= 1'b0;
        end
    end
end

endmodule



/*module spi_slave(
   input sclk,cs,rst,mosi,
   input [7:0]tx_data, //data to transmit read from sensors
   output reg  [7:0]rx_data,
   output reg miso,
   output reg rx_valid
    );
reg [7:0]shift_tx; //data to be transmitted from slave to master via miso
reg [7:0]shift_rx; //data received from master mosi aligned into 8 bits
reg [2:0]bit_cnt; 
reg cs_d; //for negedge detection    
 
 //cs edge tracker
 always@(posedge sclk or posedge rst)
 begin
 if (rst)
  cs_d<=1'b1;
  else
  cs_d<=cs;
 end
 
//receiver of slave (MOSI)

 always @(posedge sclk or posedge rst or posedge cs) begin
    if (rst) begin
        bit_cnt  <= 3'd7;
        rx_valid <= 1'b0;
        shift_rx <= 8'd0;
        rx_data  <= 8'd0;
    end
    else if (cs) begin
        // end of frame
        bit_cnt  <= 3'd7;
        rx_valid <= 1'b0;
    end
    else begin
        if (bit_cnt == 0) begin
            rx_data  <= {shift_rx[7:1], mosi};
            rx_valid <= 1'b1;   // HOLD until CS goes HIGH
            bit_cnt  <= 3'd7;
        end
        else begin
            shift_rx[bit_cnt] <= mosi;
            bit_cnt <= bit_cnt - 1;
        end
    end
end


 //transmitter part of slave (MISO)
 always@(negedge sclk or posedge rst)
 begin
    if(rst)begin
       shift_tx<=8'd0;
       miso<=0;
    end
    else if(cs_d && !cs)
     begin               //falling edge load tx_data
       shift_tx<=tx_data;
       miso<=tx_data[7];
    end
    else if(!cs)
    begin         //transmit the remaining bits
    shift_tx<={shift_tx[6:0],1'b0};
    miso<=shift_tx[6];
    end
    else
     miso<=1'b0; //idle
 
 end
endmodule*/

/*
//testbench
module tb_spi_slave;


    reg        sclk;
    reg        cs;
    reg        rst;
    reg        mosi;
    reg [7:0]  tx_data;

    wire       miso;
    wire [7:0] rx_data;
    wire       rx_valid;

    spi_slave dut (
        .sclk(sclk),
        .cs(cs),
        .rst(rst),
        .mosi(mosi),
        .miso(miso),
        .tx_data(tx_data),
        .rx_data(rx_data),
        .rx_valid(rx_valid)
    );
    always #5 sclk = ~sclk;
    initial begin
    sclk=0;
    rst=1;
    cs=1;
    mosi=0;
    tx_data=8'hCC;
    #20 rst=0;
    #20 cs=0;
    //sending data master-->slave
    send_data(8'hA5); //1010_0101
    #10 cs=1;
    #50 $finish; 
    end
task send_data(input [7:0]data);
integer i;
begin 
for(i=7;i>=0;i=i-1)
begin
@(negedge sclk);//@negeative edge of clock load mosi
mosi<=data[i];
@(posedge sclk); //Wait here until the next rising edge of sclk. prevents mosi changing too early
//msoi <=1'b0; this drives output of DUT by TB,TB should never drive output of DUT
end
end
endtask
endmodule */
/*module spi_tb;

    reg  CS, SCLK, MOSI;
    reg  rst;
    wire MISO;

    reg  [7:0] tx_data;
    reg  [7:0] rx_shift;

    // Instantiate ONLY the slave
    spi_slave dut (
        .sclk   (SCLK),
        .cs     (CS),
        .rst    (rst),
        .mosi   (MOSI),
        .tx_data(8'hCC),   // slave sends CC
        .rx_data(),
        .miso   (MISO),
        .rx_valid()
    );

    initial begin
        // init
        CS = 1;
        SCLK = 0;
        MOSI = 0;
        rst = 1;
        tx_data = 8'hA5;    // master sends A5
        rx_shift = 0;

        #20 rst = 0;

        // start SPI frame
        CS = 0;
        MOSI = tx_data[7];

        repeat (8) begin
            #10 SCLK = 0;               // falling edge
            MOSI = tx_data[7];
            tx_data = {tx_data[6:0],1'b0};

            #10 SCLK = 1;               // rising edge
            rx_shift = {rx_shift[6:0], MISO};
        end

        #10 SCLK = 0;
        CS = 1;                         // end frame

        #50 $stop;
    end

endmodule
*/