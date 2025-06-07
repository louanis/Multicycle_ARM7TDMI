vlib work
vcom ../../src/Extend.vhd
vcom ../../src/instruction_memory.vhd
vcom ../../src/instruction_unit.vhd
vcom tb_instruction_unit.vhd
vsim tb_instruction_unit
add wave *
run -all