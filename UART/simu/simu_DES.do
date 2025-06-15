vlib work

vcom -93 ../src/des_lib.vhd
vcom -93 ../src/des_round.vhd
vcom -93 ../src/des_small.vhd
vcom -93 des_small_tb.vhd

vsim des_small_tb

add wave clk
add wave reset
add wave -radix hexadecimal key
add wave -radix hexadecimal din
add wave din_valid
add wave busy1
add wave -radix hexadecimal dout1
add wave dout_valid1
add wave busy2
add wave -radix hexadecimal dout2
add wave dout_valid2

run -a
