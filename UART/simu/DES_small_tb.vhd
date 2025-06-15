-- des_small_tb.vhd
----------------------------------------------------------------------------
--  The Free IP Project
--  VHDL DES Core
--  (c) 1999, The Free IP Project and David Kessner
--
--  Revisited and enhanced by B. Cuzeau - ALSE - http://www.alse-fr.com
--  -------------------------------------------------------------------
--
--  Warning:  This software probably falls under the jurisdiction of some
--            cryptography import/export laws.  Don't import/export this
--            file (or products that use this file) unless you've worked
--            out all the legal issues.  Don't say we didn't warn you!
--
--  FREE IP GENERAL PUBLIC LICENSE
--  TERMS AND CONDITIONS FOR USE, COPYING, DISTRIBUTION, AND MODIFICATION
--
--  1.  You may copy and distribute verbatim copies of this core, as long
--      as this file, and the other associated files, remain intact and
--      unmodified.  Modifications are outlined below.  Also, see the
--      import/export warning above for further restrictions on
--      distribution.
--  2.  You may use this core in any way, be it academic, commercial, or
--      military.  Modified or not.  See, again, the import/export warning
--      above.
--  3.  Distribution of this core must be free of charge.  Charging is
--      allowed only for value added services.  Value added services
--      would include copying fees, modifications, customizations, and
--      inclusion in other products.
--  4.  If a modified source code is distributed, the original unmodified
--      source code must also be included (or a link to the Free IP web
--      site).  In the modified source code there must be clear
--      identification of the modified version.
--  5.  Visit the Free IP web site for additional information.
--
----------------------------------------------------------------------------

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

  use work.des_lib.all;

entity des_small_tb is
end;


architecture TEST of des_small_tb is
  function random56 (din : std_logic_vector(55 downto 0))
    return std_logic_vector is
    variable val : std_logic_vector (55 downto 0);
  begin
    val := (din(55) xor din(6) xor din(3) xor din(1)) & din(55 downto 1);
    return (val);
  end random56;

  function random64 (din : std_logic_vector(63 downto 0))
    return std_logic_vector is
    variable val : std_logic_vector (63 downto 0);
  begin
    val := (din(63) xor din(3) xor din(2) xor din(0)) & din(63 downto 1);
    return (val);
  end random64;

  constant Period : time := 40 ns;

  subtype Key_t  is std_logic_vector (55 downto 0);
  subtype Data_t is std_logic_vector (63 downto 0);

  signal clk         : std_logic := '1';
  signal reset       : std_logic := '1';
  signal key         : Key_t     := (others=>'0');
  signal din         : Data_t    := (others=>'0');
  signal din_valid   : std_logic := '0';
  signal dout1       : Data_t    := (others=>'0');
  signal dout2       : Data_t    := (others=>'0');
  signal dout_valid1 : std_logic := '0';
  signal dout_valid2 : std_logic := '0';
  signal busy1       : std_logic := '1';
  signal busy2       : std_logic := '1';
  signal Done        : boolean;

  constant Seed       : Data_t  := x"293625B3CB262519";
  constant The_Key    : Key_t := x"A5494A8D456F87";

  constant encrypt_flag : std_logic := '1';
  constant decrypt_flag : std_logic := '0';

begin

-- Clock, Reset and Simulation control :
Clk   <= '0' when Done else not Clk after Period / 2;
Reset <= '1', '0' after Period;
Done  <= true after 500 * Period;

-- Generate the random key's and random data
process
  variable i : natural;
begin
  Din_valid <= '0';
  Din       <= Seed;
  Key       <= The_Key;
  loop
    wait until Clk='0';
    -- create and send another set of data
    if din_valid = '0' and busy1 = '0' and busy2 = '0' and dout_valid1 = '0' and dout_valid2 = '0' then
      din <= random64(din);
      -- change the key every 5 data sets
      if i = 5 then
        i := 0;
        key <= random56(key);
      else
        i := i + 1;
      end if;
      din_valid <= '1';
      wait until Clk='0';
      din_valid <= '0';
    end if;
  end loop;
end process;

-- Do the DES encryption/decryption blocks

-- encryption
DES0: entity work.des_small port map (
    clk=> clk , reset=>reset, 
    encrypt=>encrypt_flag, 
    key_in=>key, 
    din => din, 
    din_valid => din_valid, 
    busy =>busy1, 
    dout =>dout1, 
    dout_valid=>dout_valid1);

-- decryption
DES1: entity work.des_small port map (
  clk=> clk , reset=>reset, 
  encrypt =>decrypt_flag, 
  key_in => key, 
  din => dout1, 
  din_valid=>dout_valid1, 
  busy =>busy2, 
  dout =>dout2, 
  dout_valid => dout_valid2);

-- Verify the 2nd output = Initial data, and that 1st output is different from data
process
begin
  wait until Clk ='0';
  if dout_valid2 = '1' then
    assert din = dout2  report "DES_Small data mismatch !" severity failure;
    assert din /= dout1 report "DES_Small error: lack of encryption !" severity failure;
  end if;
end process;

end TEST;
