library library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity Data_path is
    generic(
        N : integer := 2 
    )
    port(
        clk      : in std_logic;
        rst      : in std_logic;
        res      : out std_logic_vector(31 downto 1);
        IRQ      : in std_logic_vector(N-1 downto 0);
        IRQ_serv : out std_logic
    );
end entity Data_path;

architecture RTL of Data_path is

begin

end architecture RTL;


