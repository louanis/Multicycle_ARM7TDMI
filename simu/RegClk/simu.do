vlib work
vcom ../../src/regclk.vhd
vcom tb_regclk.vhd
vsim tb_regclk
add wave *
run -all