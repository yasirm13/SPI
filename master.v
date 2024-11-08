module spi_master(
    input wire clk,         // system clock
    input wire rst,         // reset
    input wire [7:0] data_in, // data to send to slave
    input wire start,       // start transfer
    output reg [7:0] data_out, // data received from slave
    output reg done,        // transfer done flag
    output reg sclk,        // SPI clock
    output reg mosi,        // Master Out Slave In
    input wire miso,        // Master In Slave Out
    output reg ss           // Slave Select (active low)
);
    reg [2:0] bit_cnt;      // bit counter
    reg [7:0] shift_reg;    // shift register

    // SPI clock generation
    always @(posedge clk or posedge rst) begin
        if (rst)
            sclk <= 0;
        else
            sclk <= ~sclk;  // Toggle SPI clock on every clock cycle
    end

    // FSM for SPI Master
    typedef enum reg [1:0] {IDLE, START, TRANSFER, DONE} state_t;
    state_t state, next_state;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            bit_cnt <= 0;
            done <= 0;
            ss <= 1;
        end else begin
            state <= next_state;
            if (state == TRANSFER) begin
                if (sclk) begin
                    shift_reg <= {shift_reg[6:0], miso}; // Shift in MISO data
                    bit_cnt <= bit_cnt + 1;
                end else begin
                    mosi <= shift_reg[7]; // Shift out MOSI data
                    shift_reg <= {shift_reg[6:0], 1'b0};
                end
            end else if (state == DONE) begin
                data_out <= shift_reg;
                done <= 1;
            end
        end
    end

    always @(*) begin
        case (state)
            IDLE: begin
                if (start) begin
                    ss = 0;
                    next_state = START;
                end else
                    next_state = IDLE;
            end
            START: begin
                next_state = TRANSFER;
                shift_reg = data_in;
                done = 0;
                bit_cnt = 0;
            end
            TRANSFER: begin
                if (bit_cnt == 8)
                    next_state = DONE;
                else
                    next_state = TRANSFER;
            end
            DONE: begin
                ss = 1;
                next_state = IDLE;
            end
        endcase
    end
endmodule
