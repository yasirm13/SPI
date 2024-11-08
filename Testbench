module spi_tb();
    reg clk;
    reg rst;
    reg [7:0] master_data;
    reg start;
    wire [7:0] slave_data;
    wire [7:0] master_received;
    wire done;
    wire sclk;
    wire mosi;
    wire miso;
    wire ss;

    // Instantiate SPI Master
    spi_master master (
        .clk(clk),
        .rst(rst),
        .data_in(master_data),
        .start(start),
        .data_out(master_received),
        .done(done),
        .sclk(sclk),
        .mosi(mosi),
        .miso(miso),
        .ss(ss)
    );

    // Instantiate SPI Slave
    spi_slave slave (
        .sclk(sclk),
        .ss(ss),
        .mosi(mosi),
        .miso(miso),
        .data_in(8'hA5), // Data in slave to be sent to master
        .data_out(slave_data)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        // Test sequence
        rst = 1;
        start = 0;
        master_data = 8'h3C; // Data to send from master to slave

        #10 rst = 0;         // Release reset
        #20 start = 1;       // Start SPI transfer

        #10 start = 0;       // Clear start signal after starting transfer
        wait(done);          // Wait for transfer to complete

        // Display results
        $display("Master sent: %h, Slave received: %h", master_data, slave_data);
        $display("Slave sent: %h, Master received: %h", 8'hA5, master_received);

        // End simulation
        #20 $finish;
    end
endmodule
