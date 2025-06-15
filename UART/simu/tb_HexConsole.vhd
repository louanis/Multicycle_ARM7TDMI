-- tb_hexconsole.vhd
-- ---------------------------
--  Testbench for HexConsole
-- ---------------------------


library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;

entity TB_HEXCONSOLE is
end;

architecture TEST of TB_HEXCONSOLE is

  signal Cts  : std_logic := '0';
  signal Rx   : std_logic := '0';
  signal Endf : boolean;

begin

CTS <= '1';

UUT : entity work.HexConsole
  Generic map ( BaudRate => 19200,
                filename => "test.hex")
  Port map    ( RX => Rx,
                CTS => Cts,
                ENDF=> Endf );

end architecture Test;
