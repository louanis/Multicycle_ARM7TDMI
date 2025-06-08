library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Mux4v1 is
    generic (
        N : integer := 8  -- Taille par défaut du bus
    );
    port (
        A   : in  std_logic_vector(N-1 downto 0);
        B   : in  std_logic_vector(N-1 downto 0);
        C   : in  std_logic_vector(N-1 downto 0);
        D   : in  std_logic_vector(N-1 downto 0);
        COM : in  std_logic_vector(1 downto 0);
        S   : out std_logic_vector(N-1 downto 0)
    );
end entity Mux4v1;

architecture Behavioral of Mux4v1 is
begin
    process(A, B, COM)
    begin
        if    COM = "00" then
            S <= A;
        elsif COM = "01" then
            S <= B;
        elsif COM = "10" then
            S <= C;
        else
            S <= D;
        end if;
    end process;
end architecture Behavioral;