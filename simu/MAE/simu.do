# simu.do - Script to compile and simulate MAE FSM in ModelSim

# Clear previous work
vlib work
vmap work work

# Compile design and testbench
vcom -93 ../../src/MAE.vhd
vcom -93 tb_MAE.vhd

# Launch simulation
vsim -voptargs=+acc work.tb_MAE

# Add signals to waveform window
add wave -divider "Clocks & Reset"
add wave sim:/tb_MAE/clk
add wave sim:/tb_MAE/rst

add wave -divider "Inputs"
add wave sim:/tb_MAE/UUT/IRQ
add wave sim:/tb_MAE/UUT/inst_register
add wave sim:/tb_MAE/UUT/inst_memory
add wave sim:/tb_MAE/UUT/CPSR

add wave -divider "Outputs"
add wave sim:/tb_MAE/UUT/IRQServ
add wave sim:/tb_MAE/UUT/PCSel
add wave sim:/tb_MAE/UUT/PCWrEn
add wave sim:/tb_MAE/UUT/LRWrEn
add wave sim:/tb_MAE/UUT/AdrSel
add wave sim:/tb_MAE/UUT/MemRden
add wave sim:/tb_MAE/UUT/MemWrEn
add wave sim:/tb_MAE/UUT/IRWrEn
add wave sim:/tb_MAE/UUT/WSel
add wave sim:/tb_MAE/UUT/RegWrEn
add wave sim:/tb_MAE/UUT/ALUSelA
add wave sim:/tb_MAE/UUT/ALUSelB
add wave sim:/tb_MAE/UUT/ALUOP
add wave sim:/tb_MAE/UUT/CPSRSel
add wave sim:/tb_MAE/UUT/CPSRWrEn
add wave sim:/tb_MAE/UUT/SPSRWrEn
add wave sim:/tb_MAE/UUT/ResWrEn
add wave sim:/tb_MAE/UUT/RbSel

add wave -divider "FSM Internals"
add wave sim:/tb_MAE/UUT/curr_state
add wave sim:/tb_MAE/UUT/instr_courante
add wave sim:/tb_MAE/UUT/isr

# Run simulation
run 2000 ns
view wave