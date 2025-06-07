vlib work
vcom ../../src/ALU.vhd
vcom ../../src/RegisterARM.vhd
vcom ALU_RegBench.vhd
vsim ALU_RegBench
add wave *
run -all