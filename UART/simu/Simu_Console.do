puts "\n=== Simulation Script for ModelSim. - ALSE ===\n"
vlib work

vcom -93 ../src/uarts.vhd
vcom -93 hexconsole.vhd
vcom -93 tb_hexconsole.vhd

vsim tb_hexconsole

view structure
view signals
add wave *
run -all
