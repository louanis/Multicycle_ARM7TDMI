vlib work

vcom -93 ../src/fdiv.vhd
vcom -93 ../src/uart_tx.vhd
vcom -93 uart_tx_tb.vhd

vsim uart_tx_tb(Bench)

view signals
add wave *


run -all
wave zoom full