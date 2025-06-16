-------------------------------------------------------------------------------

  use std.textio.all;
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.std_logic_textio.all;

entity CRYPTER_tb is
end;

-- =====================================================================
--  This architecture does ENCRYPT a fixed string into an Hex file
-- =====================================================================
architecture TEST1 of CRYPTER_tb is

  constant Period : time := 100 ns; -- 10 MHz
  subtype  Byte is std_logic_vector(7 downto 0);

  signal Clk      : std_logic := '0';
  signal Rst      : std_logic;
  signal Encrypt  : std_logic := '1';  -- <<<< ENCODER
  signal RTS      : std_logic := '1';
  signal RxRDY    : std_logic := '0';
  signal SDin     : std_logic_vector (7 downto 0) := x"00";
  signal TxBusy   : std_logic := '0';
  signal LD_SDout : std_logic := '0';
  signal SDout    : std_logic_vector (7 downto 0);
  signal Done     : boolean;
  file   F        : text;

  constant MyText : string := "Polytech est bien la meilleure solution pour les formations et les developpements ASIC & FPGA !        ";

begin  -- TEST1

-- Component instantiation
DUT: entity work.CRYPTER
  port map (Clk      => Clk,
            Rst1      => Rst,
            Encrypt  => Encrypt,
            RTS      => RTS,
            RxRDY    => RxRDY,
            SDin     => SDin,
            TxBusy   => TxBusy,
            LD_SDout => LD_SDout,
            SDout    => SDout );

-- Clock generation
  Clk <= '0' when Done else not Clk after Period / 2;
  Rst <= '1', '0' after Period;

-- Emit Chars to Crypter
process
  variable c : Byte;
  variable i : integer;
begin
  i := 1;
  wait for 10 * Period; -- Get away from reset
  while i < MyText'length loop
    c := std_logic_vector(to_unsigned(character'pos(MyText(i)),8));
    i := i+1;
    SDin <= c;
    --while TxBusy='1' loop wait until Clk='0'; end loop;
    RxRdy <= '1', '0' after Period + 1 ns;
    wait for 50 * Period;
  end loop;
  wait for 50 * Period;
  file_close(F);
  Done <= true;
  wait;
end process;

-- Receive chars from crypter and store to hex file
process
  variable L : line;
  variable i : integer;
begin
  file_open (F,"fout.txt",write_mode);
  wait for 4 * Period;
  i:=0;
  loop
    wait until LD_SDout='1';
    hwrite(L,SDout);
    i:=i+1;
    if i=8 then
      i:=0;
      writeline(F,L);
    end if;
  end loop;
end process;

end TEST1;

-- =====================================================================
--  This one does DECRYPT the data stored in the Hex file by TEST1
-- =====================================================================

architecture TEST2 of CRYPTER_tb is

  constant Period : time := 100 ns; -- 10 MHz
  subtype  Byte is std_logic_vector(7 downto 0);

  signal Clk      : std_logic := '0';
  signal Rst      : std_logic;
  signal Encrypt  : std_logic := '0';  -- <<<<< DECODER
  signal RTS      : std_logic := '1';
  signal RxRDY    : std_logic := '0';
  signal SDin     : std_logic_vector (7 downto 0) := x"00";
  signal TxBusy   : std_logic := '0';
  signal LD_SDout : std_logic := '0';
  signal SDout    : std_logic_vector (7 downto 0);
  signal Done     : boolean;
  file   F, Fin   : text;

begin  -- TEST2

-- Component instantiation

DUT: entity work.CRYPTER
  port map( Clk      => Clk,
            Rst1      => Rst,
            Encrypt  => Encrypt,
            RTS      => RTS,
            RxRDY    => RxRDY,
            SDin     => SDin,
            TxBusy   => TxBusy,
            LD_SDout => LD_SDout,
            SDout    => SDout);

-- Clock & Reset Generation

Clk <= '0' when Done else not Clk after Period / 2;
Rst <= '1', '0' after Period;


-- Send Chars to Crypter like crazy !!! (there is a fifo ...)

process
  variable c : Byte;
  variable i : positive; -- initial value is 1
  variable L : line;
begin
  file_open (Fin,"fout.txt");
  wait for 10 * Period; -- get away from reset
  while not endfile (Fin) loop
    readline (Fin,L);
    if L'length < 16 then next; end if;
    while L'length > 1 loop
      hread (L,c);
      SDin <= c;
      RxRdy <= '1', '0' after Period + 1 ns;
      --while TxBusy='1' loop wait until Clk='0'; end loop;
      wait for 2 * Period;  -- Stress the Fifo !
    end loop;
  end loop;
  wait for 700 * Period;
  file_close(Fin);
  Done <= true;
  wait;
end process;

-- Receive chars from crypter and store to decoded.txt

process
  variable L : line;
  variable i : integer;
begin
  file_open (F,"decoded.txt",write_mode);
  wait for 4 * Period;
  i:=0;
  loop
    wait until LD_SDout='1' or Done;
    if Done then
      writeline(F,l); -- flush
      file_close(F);
      wait; -- kill this process
    end if;
    write(L,character'val(to_integer(unsigned(SDout))));
    i:=i+1;
    -- if i=8 then i:=0; writeline(F,L); end if;
  end loop;
end process;

end TEST2;
