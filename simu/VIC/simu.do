vlib work
vcom ../../src/VIC.vhd
vcom tb_VIC.vhd
vsim tb_VIC
add wave /tb_vic/clk
add wave /tb_vic/reset 
add wave /tb_vic/irq0 
add wave /tb_vic/irq1
add wave /tb_vic/irq_serv
add wave /tb_vic/irq
add wave -hex /tb_vic/VICPC
run -all