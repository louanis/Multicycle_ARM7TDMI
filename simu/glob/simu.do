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
vcom -93 ../../src/MAE.vhd
vcom -93 ../../src/proco.vhd


vcom -93 tb_proco.vhd


vsim work.proco_tb

# Add signals
add wave -divider "Global"
add wave clk
add wave rst
add wave IRQ0
add wave IRQ1

add wave -divider "CPU Output"
add wave -hex Affout

# Internals (if visible via hierarchy)
add wave -divider "Internal Signals"
add wave -hex uut/Chemin_donnee/PCOut
add wave -hex uut/Chemin_donnee/Mux_addr
add wave -hex uut/Chemin_donnee/Reg_IR_out
add wave -hex uut/Machine_AE/curr_state
add wave -hex uut/Chemin_donnee/IRQ

add wave -hex uut/Machine_AE/instr_courante

add wave -divider "MEMOIRE"
add wave -hex uut/Chemin_donnee/banc_Reg/Banc

add wave -divider "SIGNAUX INTERNE"
add wave -hex uut/Chemin_donnee/BusB
add wave -hex uut/Chemin_donnee/BusA
add wave -hex uut/Chemin_donnee/Mux_Reg_out
add wave -hex uut/Chemin_donnee/Reg_IR_outdownto

add wave -divider "ALUOUT"
add wave -hex uut/Chemin_donnee/ALU_out
add wave -hex uut/Chemin_donnee/Reg_ALU_out
add wave -hex uut/Machine_AE/inst_register
add wave -hex uut/Machine_AE/inst_memory
add wave -hex uut/Machine_AE/regwren

add wave -divider "FLAG"
add wave -hex uut/Machine_AE/CPSR
add wave -hex uut/Chemin_donnee/Flag_N



# Run the simulation
run 5000 ns