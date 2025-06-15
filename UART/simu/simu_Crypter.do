puts "\n=== Simulation Script for ModelSim. - ALSE ===\n"
vlib work

vcom -93 ../src/DES_lib.vhd
vcom -93 ../src/DES_round.vhd
vcom -93 ../src/DES_small.vhd
vcom -93 ../src/fifo8x64.vhd
vcom -93 ../src/decomp64x8.vhd
vcom -93 ../src/crypter.vhd
vcom -93 Crypter_tb.vhd

vsim Crypter_tb(test1)

view structure
view signals

puts "\n=== Simulation starting now ===\n"
run -a

vsim Crypter_tb(test2)

view structure
view signals

add wave *


puts "\n=== Simulation starting now ===\n"
run -a
