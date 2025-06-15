LIBRARY ieee;
  USE ieee.std_logic_1164.ALL;
  USE ieee.numeric_std.ALL;



entity fifo8x64 is
    port (
        Clk          : in std_logic;
        Reset        : in std_logic;
        Din          : in std_logic_vector (7 downto 0);
        RDY        : in std_logic;
        Dout         : out std_logic_vector (63 downto 0);
        FifoRDY      : out std_logic
    );
end fifo8x64;

-- je vais refaire le truc avec un selectionneur indicateur de remplissage


architecture RTL of fifo8x64 is
    signal s_Dout : std_logic_vector(63 downto 0);
    begin
    process(clk,reset)
    begin
        if reset = '1' then
            s_Dout <= (others => '0');
        elsif rising_edge(clk) then
            if RDY = '1' then
                s_Dout <= s_Dout(55 downto 0) & Din;
                Dout <= s_Dout;
            end if;
        end if;
    end process;
end RTL;