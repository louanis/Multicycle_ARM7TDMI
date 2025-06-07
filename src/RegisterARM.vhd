-- filepath: c:\Users\yanis\Cours\3A\S6\VHDL S6\Projet\Monocycle_ARM7TDMI\RegisterARM.vhd
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RegisterARM is
    port(
        CLK   : in std_logic;
        Reset : in std_logic;
        W     : in std_logic_vector(31 downto 0);
        RA    : in std_logic_vector(3 downto 0);
        RB    : in std_logic_vector(3 downto 0);
        RW    : in std_logic_vector(3 downto 0);
        WE    : in std_logic;
        A     : out std_logic_vector(31 downto 0);
        B     : out std_logic_vector(31 downto 0)
    );
end RegisterARM;

architecture rtl of RegisterARM is
    type table is array (15 downto 0) of std_logic_vector(31 downto 0);

    

    signal Banc : table;
begin
    process(CLK, Reset)
    begin
        if Reset = '1' then
            Banc <= (others => (others => '0'));
        elsif rising_edge(CLK) then
            if WE = '1' then
                if to_integer(unsigned(RW)) >= 0 and to_integer(unsigned(RW)) <= 15 then
                    Banc(to_integer(unsigned(RW))) <= W;
                end if;
            end if;
        end if;
    end process;

    A <= Banc(to_integer(unsigned(RA)));
    B <= Banc(to_integer(unsigned(RB)));
end rtl;