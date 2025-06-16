-- DES_LIB.vhd
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


package des_lib is

  -- Inital permutation
  function des_ip(din : std_logic_vector(63 downto 0))
    return std_logic_vector;

  -- Final permutation
  function des_fp(din : std_logic_vector(63 downto 0))
    return std_logic_vector;

  -- Key permutation, converts a 64 bit key into a 56 bit key, ignoring parity
  function des_kp(din : std_logic_vector (63 downto 0))
    return std_logic_vector;

  -- Compression Permutation, converts a 56 bit key into a 48 bits.
  function des_cp(din : std_logic_vector (55 downto 0))
    return std_logic_vector;

  -- Expansion permutation
  function des_ep(din : std_logic_vector (31 downto 0))
    return std_logic_vector;

  -- S-Box Substitution, 48 bits in, 32 bits out.
  function des_sbox(din : std_logic_vector (47 downto 0))
    return std_logic_vector;

  -- P-Box Permutation
  function des_pbox(din : std_logic_vector (31 downto 0))
    return std_logic_vector;

  -- Key Shift
  function des_keyshift (din : std_logic_vector (55 downto 0);
                         n   : std_logic_vector (4 downto 0))
    return std_logic_vector;

end des_lib;


----------------------------------------------------------------------------
----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library work;
use work.des_lib.all;

package body des_lib is
  --------------------------------------------------------
  -- Inital permutation
  function des_ip(din : std_logic_vector(63 downto 0))
    return std_logic_vector is
    variable val : std_logic_vector (63 downto 0);
  begin
    val := din(64-58) & din(64-50) & din(64-42) & din(64-34) & din(64-26) & din(64-18) & din(64-10) & din(64- 2) &
           din(64-60) & din(64-52) & din(64-44) & din(64-36) & din(64-28) & din(64-20) & din(64-12) & din(64- 4) &
           din(64-62) & din(64-54) & din(64-46) & din(64-38) & din(64-30) & din(64-22) & din(64-14) & din(64- 6) &
           din(64-64) & din(64-56) & din(64-48) & din(64-40) & din(64-32) & din(64-24) & din(64-16) & din(64- 8) &

           din(64-57) & din(64-49) & din(64-41) & din(64-33) & din(64-25) & din(64-17) & din(64- 9) & din(64- 1) &
           din(64-59) & din(64-51) & din(64-43) & din(64-35) & din(64-27) & din(64-19) & din(64-11) & din(64- 3) &
           din(64-61) & din(64-53) & din(64-45) & din(64-37) & din(64-29) & din(64-21) & din(64-13) & din(64- 5) &
           din(64-63) & din(64-55) & din(64-47) & din(64-39) & din(64-31) & din(64-23) & din(64-15) & din(64- 7);
    return val;
  end des_ip;


  --------------------------------------------------------
  -- Final permutation
  function des_fp(din : std_logic_vector(63 downto 0))
    return std_logic_vector is
    variable val : std_logic_vector (63 downto 0);
  begin
    val := din(64-40) & din(64- 8) & din(64-48) & din(64-16) & din(64-56) & din(64-24) & din(64-64) & din(64-32) &
           din(64-39) & din(64- 7) & din(64-47) & din(64-15) & din(64-55) & din(64-23) & din(64-63) & din(64-31) &
           din(64-38) & din(64- 6) & din(64-46) & din(64-14) & din(64-54) & din(64-22) & din(64-62) & din(64-30) &
           din(64-37) & din(64- 5) & din(64-45) & din(64-13) & din(64-53) & din(64-21) & din(64-61) & din(64-29) &
           din(64-36) & din(64- 4) & din(64-44) & din(64-12) & din(64-52) & din(64-20) & din(64-60) & din(64-28) &
           din(64-35) & din(64- 3) & din(64-43) & din(64-11) & din(64-51) & din(64-19) & din(64-59) & din(64-27) &
           din(64-34) & din(64- 2) & din(64-42) & din(64-10) & din(64-50) & din(64-18) & din(64-58) & din(64-26) &
           din(64-33) & din(64- 1) & din(64-41) & din(64- 9) & din(64-49) & din(64-17) & din(64-57) & din(64-25);
    return val;
  end des_fp;


  --------------------------------------------------------
  -- Key permutation, converts a 64 bit key into a 56 bit key, ignoring parity
  function des_kp(din : std_logic_vector (63 downto 0))
    return std_logic_vector is
    variable val : std_logic_vector (55 downto 0);
  begin
    val := din(64-57) & din(64-49) & din(64-41) & din(64-33) & din(64-25) & din(64-17) & din(64- 9) & din(64- 1) &
           din(64-58) & din(64-50) & din(64-42) & din(64-34) & din(64-26) & din(64-18) & din(64-10) & din(64- 2) &
           din(64-59) & din(64-51) & din(64-43) & din(64-35) & din(64-27) & din(64-19) & din(64-11) & din(64- 3) &
           din(64-60) & din(64-52) & din(64-44) & din(64-36) &

           din(64-63) & din(64-55) & din(64-47) & din(64-39) & din(64-31) & din(64-23) & din(64-15) & din(64- 7) &
           din(64-62) & din(64-54) & din(64-46) & din(64-38) & din(64-30) & din(64-22) & din(64-14) & din(64- 6) &
           din(64-61) & din(64-53) & din(64-45) & din(64-37) & din(64-29) & din(64-21) & din(64-13) & din(64- 5) &

           din(64-28) & din(64-20) & din(64-12) & din(64- 4);
    return val;
  end des_kp;


  --------------------------------------------------------
  -- Compression Permutation, converts a 56 bit key into a 48 bits.
  function des_cp(din : std_logic_vector (55 downto 0))
    return std_logic_vector is
    variable val : std_logic_vector (47 downto 0);
  begin
    val := din(56-14) & din(56-17) & din(56-11) & din(56-24) & din(56- 1) & din(56- 5) &
           din(56- 3) & din(56-28) & din(56-15) & din(56- 6) & din(56-21) & din(56-10) &
           din(56-23) & din(56-19) & din(56-12) & din(56- 4) & din(56-26) & din(56- 8) &
           din(56-16) & din(56- 7) & din(56-27) & din(56-20) & din(56-13) & din(56- 2) &
           din(56-41) & din(56-52) & din(56-31) & din(56-37) & din(56-47) & din(56-55) &
           din(56-30) & din(56-40) & din(56-51) & din(56-45) & din(56-33) & din(56-48) &
           din(56-44) & din(56-49) & din(56-39) & din(56-56) & din(56-34) & din(56-53) &
           din(56-46) & din(56-42) & din(56-50) & din(56-36) & din(56-29) & din(56-32);
    return val;
  end des_cp;


  --------------------------------------------------------
  -- Expansion permutation
  function des_ep(din : std_logic_vector (31 downto 0))
    return std_logic_vector is
    variable val : std_logic_vector (47 downto 0);
  begin
    val := din(32-32) & din(32- 1) & din(32- 2) & din(32- 3) & din(32- 4) & din(32- 5) &
           din(32- 4) & din(32- 5) & din(32- 6) & din(32- 7) & din(32- 8) & din(32- 9) &
           din(32- 8) & din(32- 9) & din(32-10) & din(32-11) & din(32-12) & din(32-13) &
           din(32-12) & din(32-13) & din(32-14) & din(32-15) & din(32-16) & din(32-17) &
           din(32-16) & din(32-17) & din(32-18) & din(32-19) & din(32-20) & din(32-21) &
           din(32-20) & din(32-21) & din(32-22) & din(32-23) & din(32-24) & din(32-25) &
           din(32-24) & din(32-25) & din(32-26) & din(32-27) & din(32-28) & din(32-29) &
           din(32-28) & din(32-29) & din(32-30) & din(32-31) & din(32-32) & din(32- 1);
    return val;
  end des_ep;


  --------------------------------------------------------
  -- S-Box Substitution, 48 bits in, 32 bits out.
  function des_sbox(din : std_logic_vector (47 downto 0))
    return std_logic_vector is
    variable val : std_logic_vector (31 downto 0);
  begin
    -- SBOX 8
    case din(5 downto 0) is
      when "000000" => val(3 downto 0) := "1101"; when "000001" => val(3 downto 0) := "0001";
      when "000010" => val(3 downto 0) := "0010"; when "000011" => val(3 downto 0) := "1111";
      when "000100" => val(3 downto 0) := "1000"; when "000101" => val(3 downto 0) := "1101";
      when "000110" => val(3 downto 0) := "0100"; when "000111" => val(3 downto 0) := "1000";
      when "001000" => val(3 downto 0) := "0110"; when "001001" => val(3 downto 0) := "1010";
      when "001010" => val(3 downto 0) := "1111"; when "001011" => val(3 downto 0) := "0011";
      when "001100" => val(3 downto 0) := "1011"; when "001101" => val(3 downto 0) := "0111";
      when "001110" => val(3 downto 0) := "0001"; when "001111" => val(3 downto 0) := "0100";
      when "010000" => val(3 downto 0) := "1010"; when "010001" => val(3 downto 0) := "1100";
      when "010010" => val(3 downto 0) := "1001"; when "010011" => val(3 downto 0) := "0101";
      when "010100" => val(3 downto 0) := "0011"; when "010101" => val(3 downto 0) := "0110";
      when "010110" => val(3 downto 0) := "1110"; when "010111" => val(3 downto 0) := "1011";
      when "011000" => val(3 downto 0) := "0101"; when "011001" => val(3 downto 0) := "0000";
      when "011010" => val(3 downto 0) := "0000"; when "011011" => val(3 downto 0) := "1110";
      when "011100" => val(3 downto 0) := "1100"; when "011101" => val(3 downto 0) := "1001";
      when "011110" => val(3 downto 0) := "0111"; when "011111" => val(3 downto 0) := "0010";
      when "100000" => val(3 downto 0) := "0111"; when "100001" => val(3 downto 0) := "0010";
      when "100010" => val(3 downto 0) := "1011"; when "100011" => val(3 downto 0) := "0001";
      when "100100" => val(3 downto 0) := "0100"; when "100101" => val(3 downto 0) := "1110";
      when "100110" => val(3 downto 0) := "0001"; when "100111" => val(3 downto 0) := "0111";
      when "101000" => val(3 downto 0) := "1001"; when "101001" => val(3 downto 0) := "0100";
      when "101010" => val(3 downto 0) := "1100"; when "101011" => val(3 downto 0) := "1010";
      when "101100" => val(3 downto 0) := "1110"; when "101101" => val(3 downto 0) := "1000";
      when "101110" => val(3 downto 0) := "0010"; when "101111" => val(3 downto 0) := "1101";
      when "110000" => val(3 downto 0) := "0000"; when "110001" => val(3 downto 0) := "1111";
      when "110010" => val(3 downto 0) := "0110"; when "110011" => val(3 downto 0) := "1100";
      when "110100" => val(3 downto 0) := "1010"; when "110101" => val(3 downto 0) := "1001";
      when "110110" => val(3 downto 0) := "1101"; when "110111" => val(3 downto 0) := "0000";
      when "111000" => val(3 downto 0) := "1111"; when "111001" => val(3 downto 0) := "0011";
      when "111010" => val(3 downto 0) := "0011"; when "111011" => val(3 downto 0) := "0101";
      when "111100" => val(3 downto 0) := "0101"; when "111101" => val(3 downto 0) := "0110";
      when "111110" => val(3 downto 0) := "1000"; when "111111" => val(3 downto 0) := "1011";
      when others   => val(3 downto 0) := "1011";
    end case;

    -- SBOX 7
    case din(11 downto 6) is
      when "000000" => val(7 downto 4) := "0100"; when "000001" => val(7 downto 4) := "1101";
      when "000010" => val(7 downto 4) := "1011"; when "000011" => val(7 downto 4) := "0000";
      when "000100" => val(7 downto 4) := "0010"; when "000101" => val(7 downto 4) := "1011";
      when "000110" => val(7 downto 4) := "1110"; when "000111" => val(7 downto 4) := "0111";
      when "001000" => val(7 downto 4) := "1111"; when "001001" => val(7 downto 4) := "0100";
      when "001010" => val(7 downto 4) := "0000"; when "001011" => val(7 downto 4) := "1001";
      when "001100" => val(7 downto 4) := "1000"; when "001101" => val(7 downto 4) := "0001";
      when "001110" => val(7 downto 4) := "1101"; when "001111" => val(7 downto 4) := "1010";
      when "010000" => val(7 downto 4) := "0011"; when "010001" => val(7 downto 4) := "1110";
      when "010010" => val(7 downto 4) := "1100"; when "010011" => val(7 downto 4) := "0011";
      when "010100" => val(7 downto 4) := "1001"; when "010101" => val(7 downto 4) := "0101";
      when "010110" => val(7 downto 4) := "0111"; when "010111" => val(7 downto 4) := "1100";
      when "011000" => val(7 downto 4) := "0101"; when "011001" => val(7 downto 4) := "0010";
      when "011010" => val(7 downto 4) := "1010"; when "011011" => val(7 downto 4) := "1111";
      when "011100" => val(7 downto 4) := "0110"; when "011101" => val(7 downto 4) := "1000";
      when "011110" => val(7 downto 4) := "0001"; when "011111" => val(7 downto 4) := "0110";
      when "100000" => val(7 downto 4) := "0001"; when "100001" => val(7 downto 4) := "0110";
      when "100010" => val(7 downto 4) := "0100"; when "100011" => val(7 downto 4) := "1011";
      when "100100" => val(7 downto 4) := "1011"; when "100101" => val(7 downto 4) := "1101";
      when "100110" => val(7 downto 4) := "1101"; when "100111" => val(7 downto 4) := "1000";
      when "101000" => val(7 downto 4) := "1100"; when "101001" => val(7 downto 4) := "0001";
      when "101010" => val(7 downto 4) := "0011"; when "101011" => val(7 downto 4) := "0100";
      when "101100" => val(7 downto 4) := "0111"; when "101101" => val(7 downto 4) := "1010";
      when "101110" => val(7 downto 4) := "1110"; when "101111" => val(7 downto 4) := "0111";
      when "110000" => val(7 downto 4) := "1010"; when "110001" => val(7 downto 4) := "1001";
      when "110010" => val(7 downto 4) := "1111"; when "110011" => val(7 downto 4) := "0101";
      when "110100" => val(7 downto 4) := "0110"; when "110101" => val(7 downto 4) := "0000";
      when "110110" => val(7 downto 4) := "1000"; when "110111" => val(7 downto 4) := "1111";
      when "111000" => val(7 downto 4) := "0000"; when "111001" => val(7 downto 4) := "1110";
      when "111010" => val(7 downto 4) := "0101"; when "111011" => val(7 downto 4) := "0010";
      when "111100" => val(7 downto 4) := "1001"; when "111101" => val(7 downto 4) := "0011";
      when "111110" => val(7 downto 4) := "0010"; when "111111" => val(7 downto 4) := "1100";
      when others   => val(7 downto 4) := "1100";
    end case;

    -- SBOX 6
    case din(17 downto 12) is
      when "000000" => val(11 downto 8) := "1100"; when "000001" => val(11 downto 8) := "1010";
      when "000010" => val(11 downto 8) := "0001"; when "000011" => val(11 downto 8) := "1111";
      when "000100" => val(11 downto 8) := "1010"; when "000101" => val(11 downto 8) := "0100";
      when "000110" => val(11 downto 8) := "1111"; when "000111" => val(11 downto 8) := "0010";
      when "001000" => val(11 downto 8) := "1001"; when "001001" => val(11 downto 8) := "0111";
      when "001010" => val(11 downto 8) := "0010"; when "001011" => val(11 downto 8) := "1100";
      when "001100" => val(11 downto 8) := "0110"; when "001101" => val(11 downto 8) := "1001";
      when "001110" => val(11 downto 8) := "1000"; when "001111" => val(11 downto 8) := "0101";
      when "010000" => val(11 downto 8) := "0000"; when "010001" => val(11 downto 8) := "0110";
      when "010010" => val(11 downto 8) := "1101"; when "010011" => val(11 downto 8) := "0001";
      when "010100" => val(11 downto 8) := "0011"; when "010101" => val(11 downto 8) := "1101";
      when "010110" => val(11 downto 8) := "0100"; when "010111" => val(11 downto 8) := "1110";
      when "011000" => val(11 downto 8) := "1110"; when "011001" => val(11 downto 8) := "0000";
      when "011010" => val(11 downto 8) := "0111"; when "011011" => val(11 downto 8) := "1011";
      when "011100" => val(11 downto 8) := "0101"; when "011101" => val(11 downto 8) := "0011";
      when "011110" => val(11 downto 8) := "1011"; when "011111" => val(11 downto 8) := "1000";
      when "100000" => val(11 downto 8) := "1001"; when "100001" => val(11 downto 8) := "0100";
      when "100010" => val(11 downto 8) := "1110"; when "100011" => val(11 downto 8) := "0011";
      when "100100" => val(11 downto 8) := "1111"; when "100101" => val(11 downto 8) := "0010";
      when "100110" => val(11 downto 8) := "0101"; when "100111" => val(11 downto 8) := "1100";
      when "101000" => val(11 downto 8) := "0010"; when "101001" => val(11 downto 8) := "1001";
      when "101010" => val(11 downto 8) := "1000"; when "101011" => val(11 downto 8) := "0101";
      when "101100" => val(11 downto 8) := "1100"; when "101101" => val(11 downto 8) := "1111";
      when "101110" => val(11 downto 8) := "0011"; when "101111" => val(11 downto 8) := "1010";
      when "110000" => val(11 downto 8) := "0111"; when "110001" => val(11 downto 8) := "1011";
      when "110010" => val(11 downto 8) := "0000"; when "110011" => val(11 downto 8) := "1110";
      when "110100" => val(11 downto 8) := "0100"; when "110101" => val(11 downto 8) := "0001";
      when "110110" => val(11 downto 8) := "1010"; when "110111" => val(11 downto 8) := "0111";
      when "111000" => val(11 downto 8) := "0001"; when "111001" => val(11 downto 8) := "0110";
      when "111010" => val(11 downto 8) := "1101"; when "111011" => val(11 downto 8) := "0000";
      when "111100" => val(11 downto 8) := "1011"; when "111101" => val(11 downto 8) := "1000";
      when "111110" => val(11 downto 8) := "0110"; when "111111" => val(11 downto 8) := "1101";
      when others   => val(11 downto 8) := "1101";
    end case;

    -- SBOX 5
    case din(23 downto 18) is
      when "000000" => val(15 downto 12) := "0010"; when "000001" => val(15 downto 12) := "1110";
      when "000010" => val(15 downto 12) := "1100"; when "000011" => val(15 downto 12) := "1011";
      when "000100" => val(15 downto 12) := "0100"; when "000101" => val(15 downto 12) := "0010";
      when "000110" => val(15 downto 12) := "0001"; when "000111" => val(15 downto 12) := "1100";
      when "001000" => val(15 downto 12) := "0111"; when "001001" => val(15 downto 12) := "0100";
      when "001010" => val(15 downto 12) := "1010"; when "001011" => val(15 downto 12) := "0111";
      when "001100" => val(15 downto 12) := "1011"; when "001101" => val(15 downto 12) := "1101";
      when "001110" => val(15 downto 12) := "0110"; when "001111" => val(15 downto 12) := "0001";
      when "010000" => val(15 downto 12) := "1000"; when "010001" => val(15 downto 12) := "0101";
      when "010010" => val(15 downto 12) := "0101"; when "010011" => val(15 downto 12) := "0000";
      when "010100" => val(15 downto 12) := "0011"; when "010101" => val(15 downto 12) := "1111";
      when "010110" => val(15 downto 12) := "1111"; when "010111" => val(15 downto 12) := "1010";
      when "011000" => val(15 downto 12) := "1101"; when "011001" => val(15 downto 12) := "0011";
      when "011010" => val(15 downto 12) := "0000"; when "011011" => val(15 downto 12) := "1001";
      when "011100" => val(15 downto 12) := "1110"; when "011101" => val(15 downto 12) := "1000";
      when "011110" => val(15 downto 12) := "1001"; when "011111" => val(15 downto 12) := "0110";
      when "100000" => val(15 downto 12) := "0100"; when "100001" => val(15 downto 12) := "1011";
      when "100010" => val(15 downto 12) := "0010"; when "100011" => val(15 downto 12) := "1000";
      when "100100" => val(15 downto 12) := "0001"; when "100101" => val(15 downto 12) := "1100";
      when "100110" => val(15 downto 12) := "1011"; when "100111" => val(15 downto 12) := "0111";
      when "101000" => val(15 downto 12) := "1010"; when "101001" => val(15 downto 12) := "0001";
      when "101010" => val(15 downto 12) := "1101"; when "101011" => val(15 downto 12) := "1110";
      when "101100" => val(15 downto 12) := "0111"; when "101101" => val(15 downto 12) := "0010";
      when "101110" => val(15 downto 12) := "1000"; when "101111" => val(15 downto 12) := "1101";
      when "110000" => val(15 downto 12) := "1111"; when "110001" => val(15 downto 12) := "0110";
      when "110010" => val(15 downto 12) := "1001"; when "110011" => val(15 downto 12) := "1111";
      when "110100" => val(15 downto 12) := "1100"; when "110101" => val(15 downto 12) := "0000";
      when "110110" => val(15 downto 12) := "0101"; when "110111" => val(15 downto 12) := "1001";
      when "111000" => val(15 downto 12) := "0110"; when "111001" => val(15 downto 12) := "1010";
      when "111010" => val(15 downto 12) := "0011"; when "111011" => val(15 downto 12) := "0100";
      when "111100" => val(15 downto 12) := "0000"; when "111101" => val(15 downto 12) := "0101";
      when "111110" => val(15 downto 12) := "1110"; when "111111" => val(15 downto 12) := "0011";
      when others   => val(15 downto 12) := "0011";
    end case;

    -- SBOX 4
    case din(29 downto 24) is
      when "000000" => val(19 downto 16) := "0111"; when "000001" => val(19 downto 16) := "1101";
      when "000010" => val(19 downto 16) := "1101"; when "000011" => val(19 downto 16) := "1000";
      when "000100" => val(19 downto 16) := "1110"; when "000101" => val(19 downto 16) := "1011";
      when "000110" => val(19 downto 16) := "0011"; when "000111" => val(19 downto 16) := "0101";
      when "001000" => val(19 downto 16) := "0000"; when "001001" => val(19 downto 16) := "0110";
      when "001010" => val(19 downto 16) := "0110"; when "001011" => val(19 downto 16) := "1111";
      when "001100" => val(19 downto 16) := "1001"; when "001101" => val(19 downto 16) := "0000";
      when "001110" => val(19 downto 16) := "1010"; when "001111" => val(19 downto 16) := "0011";
      when "010000" => val(19 downto 16) := "0001"; when "010001" => val(19 downto 16) := "0100";
      when "010010" => val(19 downto 16) := "0010"; when "010011" => val(19 downto 16) := "0111";
      when "010100" => val(19 downto 16) := "1000"; when "010101" => val(19 downto 16) := "0010";
      when "010110" => val(19 downto 16) := "0101"; when "010111" => val(19 downto 16) := "1100";
      when "011000" => val(19 downto 16) := "1011"; when "011001" => val(19 downto 16) := "0001";
      when "011010" => val(19 downto 16) := "1100"; when "011011" => val(19 downto 16) := "1010";
      when "011100" => val(19 downto 16) := "0100"; when "011101" => val(19 downto 16) := "1110";
      when "011110" => val(19 downto 16) := "1111"; when "011111" => val(19 downto 16) := "1001";
      when "100000" => val(19 downto 16) := "1010"; when "100001" => val(19 downto 16) := "0011";
      when "100010" => val(19 downto 16) := "0110"; when "100011" => val(19 downto 16) := "1111";
      when "100100" => val(19 downto 16) := "1001"; when "100101" => val(19 downto 16) := "0000";
      when "100110" => val(19 downto 16) := "0000"; when "100111" => val(19 downto 16) := "0110";
      when "101000" => val(19 downto 16) := "1100"; when "101001" => val(19 downto 16) := "1010";
      when "101010" => val(19 downto 16) := "1011"; when "101011" => val(19 downto 16) := "0001";
      when "101100" => val(19 downto 16) := "0111"; when "101101" => val(19 downto 16) := "1101";
      when "101110" => val(19 downto 16) := "1101"; when "101111" => val(19 downto 16) := "1000";
      when "110000" => val(19 downto 16) := "1111"; when "110001" => val(19 downto 16) := "1001";
      when "110010" => val(19 downto 16) := "0001"; when "110011" => val(19 downto 16) := "0100";
      when "110100" => val(19 downto 16) := "0011"; when "110101" => val(19 downto 16) := "0101";
      when "110110" => val(19 downto 16) := "1110"; when "110111" => val(19 downto 16) := "1011";
      when "111000" => val(19 downto 16) := "0101"; when "111001" => val(19 downto 16) := "1100";
      when "111010" => val(19 downto 16) := "0010"; when "111011" => val(19 downto 16) := "0111";
      when "111100" => val(19 downto 16) := "1000"; when "111101" => val(19 downto 16) := "0010";
      when "111110" => val(19 downto 16) := "0100"; when "111111" => val(19 downto 16) := "1110";
      when others   => val(19 downto 16) := "1110";
    end case;

    -- SBOX 3
    case din(35 downto 30) is
      when "000000" => val(23 downto 20) := "1010"; when "000001" => val(23 downto 20) := "1101";
      when "000010" => val(23 downto 20) := "0000"; when "000011" => val(23 downto 20) := "0111";
      when "000100" => val(23 downto 20) := "1001"; when "000101" => val(23 downto 20) := "0000";
      when "000110" => val(23 downto 20) := "1110"; when "000111" => val(23 downto 20) := "1001";
      when "001000" => val(23 downto 20) := "0110"; when "001001" => val(23 downto 20) := "0011";
      when "001010" => val(23 downto 20) := "0011"; when "001011" => val(23 downto 20) := "0100";
      when "001100" => val(23 downto 20) := "1111"; when "001101" => val(23 downto 20) := "0110";
      when "001110" => val(23 downto 20) := "0101"; when "001111" => val(23 downto 20) := "1010";
      when "010000" => val(23 downto 20) := "0001"; when "010001" => val(23 downto 20) := "0010";
      when "010010" => val(23 downto 20) := "1101"; when "010011" => val(23 downto 20) := "1000";
      when "010100" => val(23 downto 20) := "1100"; when "010101" => val(23 downto 20) := "0101";
      when "010110" => val(23 downto 20) := "0111"; when "010111" => val(23 downto 20) := "1110";
      when "011000" => val(23 downto 20) := "1011"; when "011001" => val(23 downto 20) := "1100";
      when "011010" => val(23 downto 20) := "0100"; when "011011" => val(23 downto 20) := "1011";
      when "011100" => val(23 downto 20) := "0010"; when "011101" => val(23 downto 20) := "1111";
      when "011110" => val(23 downto 20) := "1000"; when "011111" => val(23 downto 20) := "0001";
      when "100000" => val(23 downto 20) := "1101"; when "100001" => val(23 downto 20) := "0001";
      when "100010" => val(23 downto 20) := "0110"; when "100011" => val(23 downto 20) := "1010";
      when "100100" => val(23 downto 20) := "0100"; when "100101" => val(23 downto 20) := "1101";
      when "100110" => val(23 downto 20) := "1001"; when "100111" => val(23 downto 20) := "0000";
      when "101000" => val(23 downto 20) := "1000"; when "101001" => val(23 downto 20) := "0110";
      when "101010" => val(23 downto 20) := "1111"; when "101011" => val(23 downto 20) := "1001";
      when "101100" => val(23 downto 20) := "0011"; when "101101" => val(23 downto 20) := "1000";
      when "101110" => val(23 downto 20) := "0000"; when "101111" => val(23 downto 20) := "0111";
      when "110000" => val(23 downto 20) := "1011"; when "110001" => val(23 downto 20) := "0100";
      when "110010" => val(23 downto 20) := "0001"; when "110011" => val(23 downto 20) := "1111";
      when "110100" => val(23 downto 20) := "0010"; when "110101" => val(23 downto 20) := "1110";
      when "110110" => val(23 downto 20) := "1100"; when "110111" => val(23 downto 20) := "0011";
      when "111000" => val(23 downto 20) := "0101"; when "111001" => val(23 downto 20) := "1011";
      when "111010" => val(23 downto 20) := "1010"; when "111011" => val(23 downto 20) := "0101";
      when "111100" => val(23 downto 20) := "1110"; when "111101" => val(23 downto 20) := "0010";
      when "111110" => val(23 downto 20) := "0111"; when "111111" => val(23 downto 20) := "1100";
      when others   => val(23 downto 20) := "1100";
    end case;

    -- SBOX 2
    case din(41 downto 36) is
      when "000000" => val(27 downto 24) := "1111"; when "000001" => val(27 downto 24) := "0011";
      when "000010" => val(27 downto 24) := "0001"; when "000011" => val(27 downto 24) := "1101";
      when "000100" => val(27 downto 24) := "1000"; when "000101" => val(27 downto 24) := "0100";
      when "000110" => val(27 downto 24) := "1110"; when "000111" => val(27 downto 24) := "0111";
      when "001000" => val(27 downto 24) := "0110"; when "001001" => val(27 downto 24) := "1111";
      when "001010" => val(27 downto 24) := "1011"; when "001011" => val(27 downto 24) := "0010";
      when "001100" => val(27 downto 24) := "0011"; when "001101" => val(27 downto 24) := "1000";
      when "001110" => val(27 downto 24) := "0100"; when "001111" => val(27 downto 24) := "1110";
      when "010000" => val(27 downto 24) := "1001"; when "010001" => val(27 downto 24) := "1100";
      when "010010" => val(27 downto 24) := "0111"; when "010011" => val(27 downto 24) := "0000";
      when "010100" => val(27 downto 24) := "0010"; when "010101" => val(27 downto 24) := "0001";
      when "010110" => val(27 downto 24) := "1101"; when "010111" => val(27 downto 24) := "1010";
      when "011000" => val(27 downto 24) := "1100"; when "011001" => val(27 downto 24) := "0110";
      when "011010" => val(27 downto 24) := "0000"; when "011011" => val(27 downto 24) := "1001";
      when "011100" => val(27 downto 24) := "0101"; when "011101" => val(27 downto 24) := "1011";
      when "011110" => val(27 downto 24) := "1010"; when "011111" => val(27 downto 24) := "0101";
      when "100000" => val(27 downto 24) := "0000"; when "100001" => val(27 downto 24) := "1101";
      when "100010" => val(27 downto 24) := "1110"; when "100011" => val(27 downto 24) := "1000";
      when "100100" => val(27 downto 24) := "0111"; when "100101" => val(27 downto 24) := "1010";
      when "100110" => val(27 downto 24) := "1011"; when "100111" => val(27 downto 24) := "0001";
      when "101000" => val(27 downto 24) := "1010"; when "101001" => val(27 downto 24) := "0011";
      when "101010" => val(27 downto 24) := "0100"; when "101011" => val(27 downto 24) := "1111";
      when "101100" => val(27 downto 24) := "1101"; when "101101" => val(27 downto 24) := "0100";
      when "101110" => val(27 downto 24) := "0001"; when "101111" => val(27 downto 24) := "0010";
      when "110000" => val(27 downto 24) := "0101"; when "110001" => val(27 downto 24) := "1011";
      when "110010" => val(27 downto 24) := "1000"; when "110011" => val(27 downto 24) := "0110";
      when "110100" => val(27 downto 24) := "1100"; when "110101" => val(27 downto 24) := "0111";
      when "110110" => val(27 downto 24) := "0110"; when "110111" => val(27 downto 24) := "1100";
      when "111000" => val(27 downto 24) := "1001"; when "111001" => val(27 downto 24) := "0000";
      when "111010" => val(27 downto 24) := "0011"; when "111011" => val(27 downto 24) := "0101";
      when "111100" => val(27 downto 24) := "0010"; when "111101" => val(27 downto 24) := "1110";
      when "111110" => val(27 downto 24) := "1111"; when "111111" => val(27 downto 24) := "1001";
      when others   => val(27 downto 24) := "1001";
    end case;

    -- SBOX 1
    case din(47 downto 42) is
      when "000000" => val(31 downto 28) := "1110"; when "000001" => val(31 downto 28) := "0000";
      when "000010" => val(31 downto 28) := "0100"; when "000011" => val(31 downto 28) := "1111";
      when "000100" => val(31 downto 28) := "1101"; when "000101" => val(31 downto 28) := "0111";
      when "000110" => val(31 downto 28) := "0001"; when "000111" => val(31 downto 28) := "0100";
      when "001000" => val(31 downto 28) := "0010"; when "001001" => val(31 downto 28) := "1110";
      when "001010" => val(31 downto 28) := "1111"; when "001011" => val(31 downto 28) := "0010";
      when "001100" => val(31 downto 28) := "1011"; when "001101" => val(31 downto 28) := "1101";
      when "001110" => val(31 downto 28) := "1000"; when "001111" => val(31 downto 28) := "0001";
      when "010000" => val(31 downto 28) := "0011"; when "010001" => val(31 downto 28) := "1010";
      when "010010" => val(31 downto 28) := "1010"; when "010011" => val(31 downto 28) := "0110";
      when "010100" => val(31 downto 28) := "0110"; when "010101" => val(31 downto 28) := "1100";
      when "010110" => val(31 downto 28) := "1100"; when "010111" => val(31 downto 28) := "1011";
      when "011000" => val(31 downto 28) := "0101"; when "011001" => val(31 downto 28) := "1001";
      when "011010" => val(31 downto 28) := "1001"; when "011011" => val(31 downto 28) := "0101";
      when "011100" => val(31 downto 28) := "0000"; when "011101" => val(31 downto 28) := "0011";
      when "011110" => val(31 downto 28) := "0111"; when "011111" => val(31 downto 28) := "1000";
      when "100000" => val(31 downto 28) := "0100"; when "100001" => val(31 downto 28) := "1111";
      when "100010" => val(31 downto 28) := "0001"; when "100011" => val(31 downto 28) := "1100";
      when "100100" => val(31 downto 28) := "1110"; when "100101" => val(31 downto 28) := "1000";
      when "100110" => val(31 downto 28) := "1000"; when "100111" => val(31 downto 28) := "0010";
      when "101000" => val(31 downto 28) := "1101"; when "101001" => val(31 downto 28) := "0100";
      when "101010" => val(31 downto 28) := "0110"; when "101011" => val(31 downto 28) := "1001";
      when "101100" => val(31 downto 28) := "0010"; when "101101" => val(31 downto 28) := "0001";
      when "101110" => val(31 downto 28) := "1011"; when "101111" => val(31 downto 28) := "0111";
      when "110000" => val(31 downto 28) := "1111"; when "110001" => val(31 downto 28) := "0101";
      when "110010" => val(31 downto 28) := "1100"; when "110011" => val(31 downto 28) := "1011";
      when "110100" => val(31 downto 28) := "1001"; when "110101" => val(31 downto 28) := "0011";
      when "110110" => val(31 downto 28) := "0111"; when "110111" => val(31 downto 28) := "1110";
      when "111000" => val(31 downto 28) := "0011"; when "111001" => val(31 downto 28) := "1010";
      when "111010" => val(31 downto 28) := "1010"; when "111011" => val(31 downto 28) := "0000";
      when "111100" => val(31 downto 28) := "0101"; when "111101" => val(31 downto 28) := "0110";
      when "111110" => val(31 downto 28) := "0000"; when "111111" => val(31 downto 28) := "1101";
      when others   => val(31 downto 28) := "1101";
    end case;

    return val;
  end des_sbox;


  --------------------------------------------------------
  -- P-Box Permutation
  function des_pbox(din : std_logic_vector (31 downto 0))
    return std_logic_vector is
    variable val : std_logic_vector (31 downto 0);
  begin
    val := din(32-16) & din(32- 7) & din(32-20) & din(32-21) & din(32-29) & din(32-12) & din(32-28) & din(32-17) &
           din(32- 1) & din(32-15) & din(32-23) & din(32-26) & din(32- 5) & din(32-18) & din(32-31) & din(32-10) &
           din(32- 2) & din(32- 8) & din(32-24) & din(32-14) & din(32-32) & din(32-27) & din(32- 3) & din(32- 9) &
           din(32-19) & din(32-13) & din(32-30) & din(32- 6) & din(32-22) & din(32-11) & din(32- 4) & din(32-25);
    return val;
  end des_pbox;


  --------------------------------------------------------
  -- Key Shift
  function des_keyshift (din : std_logic_vector (55 downto 0);
                         n   : std_logic_vector (4 downto 0))
    return std_logic_vector is
    variable val : std_logic_vector (55 downto 0);
  begin
    case n is
      when "00000" => val := din(55 downto 28) & din(27 downto 0);
      when "00001" => val := din(54 downto 28) & din (55) & din(26 downto 0) & din (27);
      when "00010" => val := din(53 downto 28) & din (55 downto 54) & din(25 downto 0) & din (27 downto 26);
                       --when "00011" =>  val := din(52 downto 28) & din (55 downto 53) & din(24 downto  0) & din (27 downto 25);
      when "00100" => val := din(51 downto 28) & din (55 downto 52) & din(23 downto 0) & din (27 downto 24);
                       --when "00101" =>  val := din(50 downto 28) & din (55 downto 51) & din(22 downto  0) & din (27 downto 23);
      when "00110" => val := din(49 downto 28) & din (55 downto 50) & din(21 downto 0) & din (27 downto 22);
                       --when "00111" =>  val := din(48 downto 28) & din (55 downto 49) & din(20 downto  0) & din (27 downto 21);
      when "01000" => val := din(47 downto 28) & din (55 downto 48) & din(19 downto 0) & din (27 downto 20);
                       --when "01001" =>  val := din(46 downto 28) & din (55 downto 47) & din(18 downto  0) & din (27 downto 19);
      when "01010" => val := din(45 downto 28) & din (55 downto 46) & din(17 downto 0) & din (27 downto 18);
                       --when "01011" =>  val := din(44 downto 28) & din (55 downto 45) & din(16 downto  0) & din (27 downto 17);
      when "01100" => val := din(43 downto 28) & din (55 downto 44) & din(15 downto 0) & din (27 downto 16);
                       --when "01101" =>  val := din(42 downto 28) & din (55 downto 43) & din(14 downto  0) & din (27 downto 15);
      when "01110" => val := din(41 downto 28) & din (55 downto 42) & din(13 downto 0) & din (27 downto 14);
      when "01111" => val := din(40 downto 28) & din (55 downto 41) & din(12 downto 0) & din (27 downto 13);
                       --when "10000" =>  val := din(39 downto 28) & din (55 downto 40) & din(11 downto  0) & din (27 downto 12);
      when "10001" => val := din(38 downto 28) & din (55 downto 39) & din(10 downto 0) & din (27 downto 11);
                       --when "10010" =>  val := din(37 downto 28) & din (55 downto 38) & din( 9 downto  0) & din (27 downto 10);
      when "10011" => val := din(36 downto 28) & din (55 downto 37) & din(8 downto 0) & din (27 downto 9);
                       --when "10100" =>  val := din(35 downto 28) & din (55 downto 36) & din( 7 downto  0) & din (27 downto  8);
      when "10101" => val := din(34 downto 28) & din (55 downto 35) & din(6 downto 0) & din (27 downto 7);
                       --when "10110" =>  val := din(33 downto 28) & din (55 downto 34) & din( 5 downto  0) & din (27 downto  6);
      when "10111" => val := din(32 downto 28) & din (55 downto 33) & din(4 downto 0) & din (27 downto 5);
                       --when "11000" =>  val := din(31 downto 28) & din (55 downto 32) & din( 3 downto  0) & din (27 downto  4);
      when "11001" => val := din(30 downto 28) & din (55 downto 31) & din(2 downto 0) & din (27 downto 3);
                       --when "11010" =>  val := din(29 downto 28) & din (55 downto 30) & din( 1 downto  0) & din (27 downto  2);
      when "11011" => val := din(28) & din (55 downto 29) & din(0) & din (27 downto 1);
      when others  => val := din;
    end case;

    return val;
  end des_keyshift;

end des_lib;
