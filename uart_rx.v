module uart_rx(
    input wire clk,          // Clock signal
    input wire reset,        // Reset signal
    input wire rx,           // Serial data input
    output reg [7:0] data,   // Received data byte
    output reg rx_done       // Signal that reception is done
);

    //parameter CLKS_PER_BIT = 868; // 115200 baud rate with 100MHz clock
    //CLKS_PER_BIT = (100 MHz) / (115200 baud) = 100,000,000 / 115200 ≈ 868
    parameter CLKS_PER_BIT = 10417; // For 9600 baud rate with 100 MHz clock
    //CLKS_PER_BIT = (100 MHz) / (9600 baud) = 100,000,000 / 9600 = 10,416.67

    reg [15:0] counter = 0;
    reg [3:0] bit_counter = 0;
    reg [1:0] state = 0;  // 0: Idle, 1: Start, 2: Data, 3: Stop

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            data <= 8'b0;
            rx_done <= 1'b0;
            counter <= 0;
            bit_counter <= 0;
            state <= 0;
        end else begin
            case (state)
                0: // Idle State - Wait for Start Bit
                    if (~rx) begin  // Detect Start Bit (low)
                        counter <= 0;
                        state <= 1;
                        rx_done <= 1'b0;
                    end

                1: // Start Bit Detection
                    if (counter == (CLKS_PER_BIT / 2)) begin
                        if (~rx) begin
                            counter <= 0;
                            bit_counter <= 0;
                            state <= 2;
                        end else begin
                            state <= 0; // False start bit detected
                        end
                    end else begin
                        counter <= counter + 1;
                    end

                2: // Receiving Data Bits
                    if (counter == CLKS_PER_BIT - 1) begin
                        counter <= 0;
                        data[bit_counter] <= rx;
                        if (bit_counter < 7) begin
                            bit_counter <= bit_counter + 1;
                        end else begin
                            state <= 3; // Move to stop bit check
                        end
                    end else begin
                        counter <= counter + 1;
                    end

                3: // Stop Bit Check
                    if (counter == CLKS_PER_BIT - 1) begin
                        if (rx) begin  // Stop bit should be high
                            rx_done <= 1'b1;
                        end
                        state <= 0;
                        counter <= 0;
                    end else begin
                        counter <= counter + 1;
                    end
            endcase
        end
    end
endmodule
