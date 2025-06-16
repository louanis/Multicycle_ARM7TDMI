-- DES_small.vhd
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

  use work.des_lib.all;
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity des_small is
  port (clk   : in std_logic;
        reset : in std_logic;

        encrypt   : in std_logic;
        key_in    : in std_logic_vector (55 downto 0);
        din       : in std_logic_vector (63 downto 0);
        din_valid : in std_logic;

        busy       : buffer std_logic;
        dout       : out    std_logic_vector (63 downto 0);
        dout_valid : out    std_logic
        );
end des_small;


architecture arch_des_small of des_small is
  type   STATES is (IDLE, WORKING);
  signal state : STATES               ;--         := IDLE;
  signal round : unsigned (3 downto 0); --- := "0000";
  signal stall : std_logic            ;--         := '0';

  signal key          : std_logic_vector (55 downto 0);-- := (others=>'0');
  signal encrypt_flag : std_logic;--                      := '1';

  signal encrypt_in    : std_logic;--                      := '1';
  signal encrypt_shift : std_logic_vector (4 downto 0) ;-- := (others=>'0');
  signal decrypt_shift : std_logic_vector (4 downto 0) ;-- := (others=>'0');
  signal r_key_in      : std_logic_vector (55 downto 0);-- := (others=>'0');
  signal r_din         : std_logic_vector (63 downto 0);-- := (others=>'0');

  signal r_dout : std_logic_vector (63 downto 0);-- := (others=>'0');
  signal dummy1 : std_logic                     ;-- := '0';
  signal dummy2 : std_logic                     ;-- := '0';
  signal dummy3 : std_logic                     ;-- := '0';
  signal dummy4 : std_logic_vector (55 downto 0);-- := (others=>'0');
begin

  -- Manage the IDLE/WORKING state machine
  process (clk, reset)
  begin
    if reset = '1' then
      state <= IDLE;
    elsif rising_edge(clk) then
      case state is
        when IDLE =>
          if din_valid = '1' then
            state <= WORKING;
          end if;

        when WORKING =>
          if round = 15 then
            state <= IDLE;
          end if;
      end case;
    end if;
  end process;

  -- Track the current DES round
  process (clk, reset)
  begin
    if reset = '1' then
      round <= x"0";
    elsif rising_edge(clk) then
      if state /= IDLE then
        round <= round + 1;
      elsif din_valid = '1' then
        round <= round + 1;
      else
        round <= x"0";
      end if;
    end if;
  end process;

  -- Generate the busy signal
  process (clk, reset)
  begin
    if reset = '1' then
      busy <= '0';
    elsif rising_edge(clk) then
      if state = IDLE and din_valid = '0' then
        busy <= '0';
      elsif round = 15 then
        busy <= '0';
      else
        busy <= '1';
      end if;
    end if;
  end process;


  -- Latch the encrypt_flag, key
  process (clk, reset)
  begin
    if reset = '1' then
      encrypt_flag <= '0';
      key          <= (others=>'0');
    elsif rising_edge(clk) then
      if state = IDLE and din_valid = '1' then
        encrypt_flag <= encrypt;
        key          <= key_in;
      end if;
    end if;
  end process;

  -- Mux the inputs to des_round
  encrypt_in <= encrypt     when state = IDLE else encrypt_flag;
  r_key_in   <= key_in      when state = IDLE else key;
  r_din      <= des_ip(din) when state = IDLE else r_dout;
  dummy1     <= '0';
  stall      <= '0';

  -- Do the round
  ROUND0 : entity work.des_round port map (clk, reset, stall,
                              encrypt_in, encrypt_shift, decrypt_shift,
                              r_key_in, r_din, dummy1,
                              dummy2, dummy4, r_dout, dummy3);

  -- Generate the encrypt/decrypt key shift amounts:
  process (round)
  begin
    case to_integer(round) is
      when 0  => encrypt_shift <= "00001"; decrypt_shift <= "00000";
      when 1  => encrypt_shift <= "00010"; decrypt_shift <= "11011";
      when 2  => encrypt_shift <= "00100"; decrypt_shift <= "11001";
      when 3  => encrypt_shift <= "00110"; decrypt_shift <= "10111";
      when 4  => encrypt_shift <= "01000"; decrypt_shift <= "10101";
      when 5  => encrypt_shift <= "01010"; decrypt_shift <= "10011";
      when 6  => encrypt_shift <= "01100"; decrypt_shift <= "10001";
      when 7  => encrypt_shift <= "01110"; decrypt_shift <= "01111";
      when 8  => encrypt_shift <= "01111"; decrypt_shift <= "01110";
      when 9  => encrypt_shift <= "10001"; decrypt_shift <= "01100";
      when 10 => encrypt_shift <= "10011"; decrypt_shift <= "01010";
      when 11 => encrypt_shift <= "10101"; decrypt_shift <= "01000";
      when 12 => encrypt_shift <= "10111"; decrypt_shift <= "00110";
      when 13 => encrypt_shift <= "11001"; decrypt_shift <= "00100";
      when 14 => encrypt_shift <= "11011"; decrypt_shift <= "00010";
      when 15 => encrypt_shift <= "00000"; decrypt_shift <= "00001";
      when others
              => encrypt_shift <= "00001"; decrypt_shift <= "00000";
    end case;
  end process;

  -- Generate the dout_valid signal
  process (clk, reset)
  begin
    if reset = '1' then
      dout_valid <= '0';
    elsif rising_edge(clk) then
      if round = 15 then
        dout_valid <= '1';
      else
        dout_valid <= '0';
      end if;
    end if;
  end process;

  -- Output the data
  dout <= des_fp(r_dout(31 downto 0) & r_dout(63 downto 32));

end arch_des_small;
