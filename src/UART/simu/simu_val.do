vlib work

vcom -93 ../src/fdiv.vhd
vcom -93 ../src/uart_rx.vhd
vcom -93 ../src/uart_tx.vhd
vcom -93 ../src/tp_uart_rx.vhd
vcom -93 ../src/tp_uart_tx.vhd
vcom -93 ../src/validation_uart.vhd
vcom -93 tb_validation.vhd

vsim tb_validation(Bench)

view signals
add wave *


run -all
wave zoom full