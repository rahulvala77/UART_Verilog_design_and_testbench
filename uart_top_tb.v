`include "uart_top.v"

module uart_top_tb;

    reg clk;
    reg reset;
    reg [7:0] tx_data;
    reg tx_start;
    wire tx;
    wire rx;
    wire [7:0] rx_data;
    wire rx_done;
    wire tx_done;

    // Instantiate the UART Top Module
    uart_top uart_top_inst(
        .clk(clk),
        .reset(reset),
        .tx_data(tx_data),
        .tx_start(tx_start),
        .rx(rx),
        .tx(tx),
        .rx_data(rx_data),
        .rx_done(rx_done),
        .tx_done(tx_done)
    );

    // Connect TX to RX (Loopback)
    assign rx = tx;

    // Clock Generation
    always #5 clk = ~clk; // 100 MHz Clock (10 ns period)

    initial begin
        // Initialize Inputs
        clk = 0;
        reset = 1;
        tx_data = 8'h55;  // Transmit data: 0x55
        tx_start = 0;

        // Reset the Design
        #100 reset = 0;

        // Wait for Reset to Deassert
        #100;

        // Start Transmission
        tx_start = 1;
        #10 tx_start = 0;

        // Wait for TX and RX to Complete
        wait (tx_done);
        wait (rx_done);

        // Compare TX and RX Data
        if (tx_data == rx_data)
            $display("Test Passed: TX Data = %h, RX Data = %h", tx_data, rx_data);
        else
            $display("Test Failed: TX Data = %h, RX Data = %h", tx_data, rx_data);

        $finish;
    end

endmodule
