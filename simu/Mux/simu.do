vlib work
vcom ../../src/Mux2v1.vhd
vcom tb_mux.vhd
vsim tb_mux
add wave *
run -all