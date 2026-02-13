module spi_master (
    input        clk, rst, start,
    input  [7:0] tx_data,
    output reg [7:0] rx_data,
    output reg       busy,
    output reg       MOSI,
    input            MISO,
    output reg       SCLK,
    output reg       CS
);

reg [7:0] sh_tx;
reg [2:0] bit_cnt;
reg phase;   // 0 = drive, 1 = sample

always @(posedge clk or posedge rst) begin
    if (rst) begin
        CS <= 1; SCLK <= 0; MOSI <= 0; busy <= 0;
        rx_data <= 0; bit_cnt <= 0; phase <= 0;
    end else begin
        if (!busy) begin
            if (start) begin
                CS <= 0;
                sh_tx <= tx_data;
                MOSI <= tx_data[7];   // preload
                bit_cnt <= 3'd7;
                SCLK <= 0;
                phase <= 0;
                busy <= 1;
                rx_data <= 0;
            end
        end else begin
            if (phase == 0) begin
                // drive MOSI, then raise SCLK
                MOSI <= sh_tx[bit_cnt];
                SCLK <= 1;
                phase <= 1;
            end else begin
                // sample MISO, then lower SCLK
                rx_data[bit_cnt] <= MISO;
                SCLK <= 0;
                phase <= 0;
                if (bit_cnt == 0) begin
                    CS <= 1;
                    busy <= 0;
                end else begin
                    bit_cnt <= bit_cnt - 1;
                end
            end
        end
    end
end

endmodule

/*module tb_spi_master;

    // ===== TB Signals =====
    reg         clk;
    reg         rst;
    reg         start;
    reg  [7:0]  tx_data;
    reg         MISO;

    wire [7:0]  rx_data;
    wire        MOSI;
    wire        SCLK;
    wire        CS;
    wire        busy;

    // ===== DUT Instantiation =====
    spi_master dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .tx_data(tx_data),
        .rx_data(rx_data),
        .MOSI(MOSI),
        .MISO(MISO),
        .SCLK(SCLK),
        .CS(CS),
        .busy(busy)
    );

    // ===== Clock Generation =====
    always #5 clk = ~clk;
    reg [7:0] slave_data;
    integer i;
    always@(negedge SCLK)begin
    if(!CS)begin
     MISO<=slave_data[i];
     i<=i-1;
     end
    end
    initial begin
    clk=0;
    rst=1;
    start=0;
    tx_data=8'h00;
    MISO=1'b0;
    slave_data=8'b11001100;
    i=7;
    
    #20 rst=0;
     #20 tx_data = 8'b10101010;
      #10 start = 1;
        #10 start = 0;
          wait(busy == 1); //wait until busy becomes 1
                      //wait until SPI starts
        wait(busy == 0);//wait until busy becomes 0
                    //wait until SPI finishes
        #20 $finish;
    
    end
    endmodule*/