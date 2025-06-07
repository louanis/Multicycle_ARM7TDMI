-- filepath: d:\cours\VHDL\Projet\Monocycle_ARM7TDMI\src\Extend.vhd
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Extend is
    generic (
        N : integer := 8  -- Taille par défaut de l'entrée
    );
    port (
        E : in  std_logic_vector(N-1 downto 0);
        S : out std_logic_vector(31 downto 0)
    );
end entity Extend;

architecture Behavioral of Extend is
begin
    process(E)
    begin
        if E(N-1) = '1' then
            S <= (31 downto N => '1') & E;
        else
            S <= (31 downto N => '0') & E;
        end if;
    end process;
end architecture Behavioral;