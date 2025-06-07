vlib work
vcom ../../src/alu.vhd
vcom tb_alu.vhd
vsim tb_alu
add wave *
run -all