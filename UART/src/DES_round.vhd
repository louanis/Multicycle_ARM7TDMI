-- DES_round.vhd
----------------------------------------------------------------------------
--  The Free IP Project
--  VHDL DES Core
--  (c) 1999, The Free IP Project and David Kessner
--
--
--  Warning:  This software probably falls under the jurisdiction of some
--            cryptography import/export laws.  Don't import/export this
--            file (or products that use this file) unless you've worked
--            out all the legal issues.  Don't say we didn't warn you!
--
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
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;
  use work.des_lib.all;

entity des_round is
  port (clk   : in std_logic;
        reset : in std_logic;
        stall : in std_logic;

        encrypt_in    : in std_logic;
        encrypt_shift : in std_logic_vector (4 downto 0);
        decrypt_shift : in std_logic_vector (4 downto 0);
        key_in        : in std_logic_vector (55 downto 0);
        din           : in std_logic_vector (63 downto 0);
        din_valid     : in std_logic;


        encrypt_out : out std_logic;
        key_out     : out std_logic_vector (55 downto 0);
        dout        : out std_logic_vector (63 downto 0);
        dout_valid  : out std_logic
        );
end des_round;


architecture arch_des_round of des_round is
begin

  process (clk, reset)
    variable key       : std_logic_vector (47 downto 0);
    variable data_ep   : std_logic_vector (47 downto 0);
    variable data_sbox : std_logic_vector (31 downto 0);
    variable data_pbox : std_logic_vector (31 downto 0);
  begin
    if reset = '1' then
      key_out     <= (others=>'0');
      dout        <= (others=>'0');
      dout_valid  <= '0';
      encrypt_out <= '0';
    elsif rising_edge(clk) then
      if stall = '0' then
        -- Handle the key
        encrypt_out <= encrypt_in;
        key_out     <= key_in;
        if encrypt_in = '1' then
          key := des_cp(des_keyshift(key_in, encrypt_shift));
        else
          key := des_cp(des_keyshift(key_in, decrypt_shift));
        end if;

        -- Handle the data
        data_ep   := des_ep(din(31 downto 0)) xor key;
        data_sbox := des_sbox(data_ep);
        data_pbox := des_pbox(data_sbox) xor din(63 downto 32);
        dout      <= din(31 downto 0) & data_pbox;

        dout_valid <= din_valid;
      end if;
    end if;
  end process;

end arch_des_round;

