vlib work
vcom ../../src/Register.vhd
vcom tb_reg.vhd
vsim tb_reg
add wave *
run -all