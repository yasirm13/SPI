module spi_slave(
    input wire sclk,       // SPI clock from master
    input wire ss,         // Slave Select (active low)
    input wire mosi,       // Master Out Slave In
    output reg miso,       // Master In Slave Out
    input wire [7:0] data_in, // data to send to master
    output reg [7:0] data_out // data received from master
);
    reg [7:0] shift_reg;
    reg [2:0] bit_cnt;

    always @(posedge sclk or posedge ss) begin
        if (ss) begin
            bit_cnt <= 0;
            shift_reg <= data_in;
        end else begin
            shift_reg <= {shift_reg[6:0], mosi}; // Shift in MOSI data
            miso <= shift_reg[7];               // Shift out MISO data
            bit_cnt <= bit_cnt + 1;
            if (bit_cnt == 7)
                data_out <= shift_reg;
        end
    end
endmodule
