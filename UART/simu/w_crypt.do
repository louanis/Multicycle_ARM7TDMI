
add wave -noupdate -format Logic /crypter_tb/rxrdy
add wave -noupdate -format Literal -radix ascii /crypter_tb/sdin
add wave -noupdate -format Logic /crypter_tb/txbusy
add wave -noupdate -format Logic /crypter_tb/ld_sdout
add wave -noupdate -format Literal /crypter_tb/sdout
add wave -noupdate -format Literal /crypter_tb/dut/state
add wave -noupdate -format Literal /crypter_tb/dut/wpointer
add wave -noupdate -format Literal /crypter_tb/dut/rpointer
add wave -noupdate -divider FIFO
add wave -noupdate -format Logic /crypter_tb/dut/fifo_empty
add wave -noupdate -format Literal -radix hexadecimal /crypter_tb/dut/fifo_dout
add wave -noupdate -format Literal -radix unsigned /crypter_tb/dut/fifo_i/usedw

