library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Reg is
    generic(
        N : integer := 32  
    );
    port (
        CLK     : in  std_logic;
        RST     : in  std_logic;
        WE      : in  std_logic;
        Din     : in  std_logic_vector(N-1 downto 0);
        Dout    : out std_logic_vector(N-1 downto 0)
    );
end entity Reg;

architecture Behavioral of Reg is
begin
    process(CLK, RST)
    begin
        if RST = '1' then
            Dout <= (others => '0');  -- Reset output to zero
        elsif rising_edge(CLK) then
            if WE = '1' then
                Dout <= Din;  -- Write data to output on clock edge if WE is high
            end if;
        end if;
    end process;
end architecture Behavioral;