vlib work

vcom -93 ../src/fdiv.vhd
vcom -93 ../src/tp_uart_rx.vhd
vcom -93 ../src/uart_tx.vhd
vcom -93 tp_uart_rx_tb.vhd

vsim tp_uart_rx_tb(Bench)

view signals
add wave *


run -all
wave zoom full