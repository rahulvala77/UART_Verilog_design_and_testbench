module uart_tx(
    input wire clk,          // Clock signal
    input wire reset,        // Reset signal
    input wire [7:0] data,   // Data byte to transmit
    input wire tx_start,     // Signal to start transmission
    output reg tx,           // Serial data output
    output reg tx_done       // Signal that transmission is done
);

   // parameter CLKS_PER_BIT = 868; // 115200 baud rate with 100MHz clock
    //CLKS_PER_BIT = (100 MHz) / (115200 baud) = 100,000,000 / 115200 ≈ 868
    parameter CLKS_PER_BIT = 10417; // For 9600 baud rate with 100 MHz clock 
    //CLKS_PER_BIT = (100 MHz) / (9600 baud) = 100,000,000 / 9600 = 10,416.67
  
    reg [15:0] counter = 0;
    reg [3:0] bit_counter = 0;
    reg [7:0] tx_data = 0;
    reg [1:0] state = 0;  // 0: Idle, 1: Start, 2: Data, 3: Stop

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            tx <= 1'b1;         // Idle state is high
            tx_done <= 1'b0;
            counter <= 0;
            bit_counter <= 0;
            state <= 0;
        end else begin
            case (state)
                0: // Idle State
                    if (tx_start) begin
                        tx_data <= data;
                        tx <= 1'b0; // Start bit
                        counter <= 0;
                        bit_counter <= 0;
                        state <= 1;
                        tx_done <= 1'b0;
                    end

                1: // Transmitting Data Bits
                    if (counter == CLKS_PER_BIT - 1) begin
                        counter <= 0;
                        if (bit_counter < 8) begin
                            tx <= tx_data[bit_counter];
                            bit_counter <= bit_counter + 1;
                        end else begin
                            tx <= 1'b1; // Stop bit
                            state <= 2;
                        end
                    end else begin
                        counter <= counter + 1;
                    end

                2: // Stop Bit
                    if (counter == CLKS_PER_BIT - 1) begin
                        counter <= 0;
                        state <= 0;
                        tx_done <= 1'b1;
                    end else begin
                        counter <= counter + 1;
                    end
            endcase
        end
    end
endmodule
