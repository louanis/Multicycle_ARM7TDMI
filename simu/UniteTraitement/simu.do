vlib work
vcom ../../src/ALU.vhd
vcom ../../src/Mux2v1.vhd
vcom ../../src/Extend.vhd
vcom ../../src/RegisterARM.vhd
vcom ../../src/Memoire_data.vhd
vcom ../../src/Unite_traitement.vhd


vcom tb_Unite_traitement.vhd
vsim tb_Unite_traitement
add wave *
run -all