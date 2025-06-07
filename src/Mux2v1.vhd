library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Mux2v1 is
    generic (
        N : integer := 8  -- Taille par défaut du bus
    );
    port (
        A   : in  std_logic_vector(N-1 downto 0);
        B   : in  std_logic_vector(N-1 downto 0);
        COM : in  std_logic;
        S   : out std_logic_vector(N-1 downto 0)
    );
end entity Mux2v1;

architecture Behavioral of Mux2v1 is
begin
    process(A, B, COM)
    begin
        if COM = '0' then
            S <= A;
        else
            S <= B;
        end if;
    end process;
end architecture Behavioral;