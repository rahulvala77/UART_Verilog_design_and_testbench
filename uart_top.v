`include "uart_tx.v"
`include "uart_rx.v"
module uart_top(
    input wire clk,
    input wire reset,
	input wire [7:0] tx_data,
	input wire tx_start,
	input wire rx,
	output wire tx,
	output wire [7:0] rx_data,
	output wire rx_done,
	output wire tx_done
	);

    uart_tx TX(.clk(clk),
	           .reset(reset),
		       .data(tx_data),
			   .tx_start(tx_start),
			   .tx(tx),
			   .tx_done(tx_done));

    uart_rx RX(.clk(clk),
		       .reset(reset),
			   .rx(rx),
			   .data(rx_data),
			   .rx_done(rx_done));

endmodule
