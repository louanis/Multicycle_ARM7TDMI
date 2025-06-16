puts "\n=== Simulation Script for ModelSim. - ALSE ===\n"
vlib work

vcom -93 ../src/DES_lib.vhd
vcom -93 ../src/DES_round.vhd
vcom -93 ../src/DES_small.vhd
vcom -93 ../src/crypter.vhd
vcom -93 ../src/uarts.vhd
vcom -93 ../src/DE_top.vhd
vcom -93 hexconsole.vhd
vcom -93 DE_top_tb.vhd

vsim top_tb

view structure
view signals

add wave rx
add wave tx
#add wave -radix hexadecimal -expand uut/i_crypt/memory
#add wave -radix ascii uut/i_crypt/sdout

puts "\n=== Simulation starting now ===\n"
run -all
