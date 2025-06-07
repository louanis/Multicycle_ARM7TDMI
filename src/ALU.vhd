-- filepath: c:\Users\yanis\Cours\3A\S6\VHDL S6\Projet\Monocycle_ARM7TDMI\ALU.vhd
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU is
    port(
        OP : in std_logic_vector(1 downto 0);
        A  : in std_logic_vector(31 downto 0);
        B  : in std_logic_vector(31 downto 0);
        S  : out std_logic_vector(31 downto 0);
        N  : out std_logic;
        Z  : out std_logic
    );
end ALU;

architecture rtl of ALU is
    signal result : signed(31 downto 0);
begin
    process(OP, A, B)
    begin
        case OP is
            when "00" => -- ADD
                result <= signed(A) + signed(B);
            when "01" => -- B
                result <= signed(B);
            when "10" => -- SUB
                result <= signed(A) - signed(B);
            when others => -- A
                result <= signed(A);
        end case;
    end process;

    S <= std_logic_vector(result);
    N <= '1' when result < 0 else '0';
    Z <= '1' when result = 0 else '0';
end rtl;