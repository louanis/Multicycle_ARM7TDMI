vlib work
vcom ../../src/Mux4v1.vhd
vcom tb_mux4v1.vhd
vsim tb_mux4v1
add wave *
run -all