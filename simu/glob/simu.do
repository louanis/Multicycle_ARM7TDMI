vlib work
vcom -93 ../../src/ALU.vhd
vcom -93 ../../src/Memoire_data.vhd
vcom -93 ../../src/Decoder.vhd 
vcom -93 ../../src/Mux2v1.vhd
vcom -93 ../../src/Reg.vhd
vcom -93 ../../src/RegisterARM.vhd
vcom -93 ../../src/Extend.vhd
vcom -93 ../../src/Unite_traitement.vhd
vcom -93 ../../src/Unite_controle.vhd
vcom -93 ../../src/instruction_memory.vhd
vcom -93 ../../src/instruction_unit.vhd
vcom -93 ../../src/proco.vhd

vcom -93 tb_proco.vhd
vsim tb_proco

add wave *
add wave /tb_proco/proco_inst/Unit_controle/decod/instr_courante 
add wave -hex /tb_proco/proco_inst/Unit_trait/banc_reg/Banc
add wave -hex /tb_proco/proco_inst/Unit_trait/mem_dat/memoire 
add wave -hex -position end /tb_proco/proco_inst/instr_unit/PC
add wave -position end  sim:/tb_proco/proco_inst/Unit_controle/decod/RegAff

add wave -position end  sim:/tb_proco/proco_inst/Unit_controle/instruction(25)
add wave -hex -position end  sim:/tb_proco/proco_inst/Unit_trait/alu_cabl_mux/B
add wave -hex -position end  sim:/tb_proco/proco_inst/Unit_trait/alu_cabl_mux/A
add wave -position end  sim:/tb_proco/proco_inst/Unit_controle/decod/regpsrin
add wave -position end  sim:/tb_proco/proco_inst/Unit_controle/regist/Din


run -all