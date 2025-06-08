library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_Regclk is
end entity tb_Regclk;

architecture Behavioral of tb_Regclk is
    constant N : integer := 32;

    -- DUT signals
    signal CLK  : std_logic := '0';
    signal RST  : std_logic := '1';
    signal Din  : std_logic_vector(N-1 downto 0) := (others => '0');
    signal Dout : std_logic_vector(N-1 downto 0);

    -- Clock period
    constant clk_period : time := 10 ns;

begin

    -- Clock generation
    clk_process : process
    begin
        while now < 200 ns loop
            CLK <= '0';
            wait for clk_period / 2;
            CLK <= '1';
            wait for clk_period / 2;
        end loop;
        wait;
    end process;

    -- Instantiate DUT
    DUT: entity work.Reg
        generic map(N => N)
        port map (
            CLK  => CLK,
            RST  => RST,
            Din  => Din,
            Dout => Dout
        );

    -- Stimulus
    stim_proc: process
    begin
        -- Initial reset active
        wait for 15 ns;
        RST <= '0';  -- Release reset

        -- Load first value
        wait until rising_edge(CLK);
        Din <= x"AAAAAAAA";
        
        -- Next value
        wait until rising_edge(CLK);
        Din <= x"12345678";

        -- Activate reset again
        wait until rising_edge(CLK);
        RST <= '1';
        
        -- Observe reset effect
        wait until rising_edge(CLK);
        RST <= '0';

        -- Final value
        wait until rising_edge(CLK);
        Din <= x"FFFFFFFF";

        -- End simulation
        wait for 20 ns;
        assert false report "Register testbench completed." severity note;
        wait;
    end process;

end Behavioral;
