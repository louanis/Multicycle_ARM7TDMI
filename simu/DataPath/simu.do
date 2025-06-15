# Create and open the work library
vlib work
vcom -93 ../../src/ALU.vhd
vcom -93 ../../src/DualPORTRAM.vhd
vcom -93 ../../src/Mux2v1.vhd
vcom -93 ../../src/Mux4v1.vhd
vcom -93 ../../src/Reg.vhd
vcom -93 ../../src/Regclk.vhd
vcom -93 ../../src/Extend.vhd
vcom -93 ../../src/VIC.vhd
vcom -93 ../../src/RegisterARM.vhd
vcom -93 ../../src/Data_path.vhd

# Compile testbench
vcom -93 tb_data_path.vhd

# Load simulation
vsim work.tb_data_path

# Add useful signals to waveform
add wave -divider "==== Clk / Rst ===="
add wave sim:/tb_data_path/clk
add wave sim:/tb_data_path/rst

add wave -divider "==== Control Signals ===="
add wave sim:/tb_data_path/PCSel
add wave sim:/tb_data_path/PCWrEn
add wave sim:/tb_data_path/LRWrEn
add wave sim:/tb_data_path/AdrSel
add wave sim:/tb_data_path/MemRdEn
add wave sim:/tb_data_path/MemWrEn
add wave sim:/tb_data_path/IRWrEn
add wave sim:/tb_data_path/RbSel
add wave sim:/tb_data_path/WSel
add wave sim:/tb_data_path/RegWrEn
add wave sim:/tb_data_path/ALUSelA
add wave sim:/tb_data_path/ALUSelB
add wave sim:/tb_data_path/ALUOP
add wave sim:/tb_data_path/ResWrEn
add wave sim:/tb_data_path/CPSRSel
add wave sim:/tb_data_path/CPSRWrEn
add wave sim:/tb_data_path/SPSRWrEn

add wave -divider "==== Interrupt ===="
add wave sim:/tb_data_path/IRQ0
add wave sim:/tb_data_path/IRQ1
add wave sim:/tb_data_path/IRQ
add wave sim:/tb_data_path/IRQ_serv

add wave -divider "==== Instruction & Output ===="
add wave sim:/tb_data_path/inst_mem
add wave sim:/tb_data_path/inst_reg
add wave sim:/tb_data_path/Resultat
add wave sim:/tb_data_path/CPSROUT

# Run simulation
run 1000 us
