library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_vic is
end tb_vic;

architecture Behavioral of tb_vic is
    -- Signals to connect to DUT
    signal CLK      : std_logic := '0';
    signal RESET    : std_logic := '1';
    signal IRQ0     : std_logic := '0';
    signal IRQ1     : std_logic := '0';
    signal IRQ_SERV : std_logic := '0';
    signal IRQ      : std_logic;
    signal VICPC    : std_logic_vector(31 downto 0);

    -- Clock period
    constant clk_period : time := 10 ns;
begin

    -- Clock generation
    clk_process : process
    begin
        while now < 500 ns loop
            CLK <= '0'; wait for clk_period / 2;
            CLK <= '1'; wait for clk_period / 2;
        end loop;
        wait;
    end process;

    -- Instantiate the DUT
    DUT: entity work.VIC
        port map (
            CLK      => CLK,
            RESET    => RESET,
            IRQ0     => IRQ0,
            IRQ1     => IRQ1,
            IRQ_SERV => IRQ_SERV,
            IRQ      => IRQ,
            VICPC    => VICPC
        );

    -- Stimulus process
    stim_proc: process
    begin
        -- Initial reset
        wait for 20 ns;
        RESET <= '0';

        -- Trigger IRQ1 (lower priority)
        IRQ1 <= '1';
        wait for 20 ns;
        IRQ1 <= '0';

        -- Trigger IRQ0 (higher priority) shortly after
        wait for 30 ns;
        IRQ0 <= '1';
        wait for 20 ns;
        IRQ0 <= '0';

        -- Acknowledge interrupt
        wait for 30 ns;
        IRQ_SERV <= '1';
        wait for 10 ns;
        IRQ_SERV <= '0';

        -- Trigger IRQ1 again
        wait for 40 ns;
        IRQ1 <= '1';
        wait for 20 ns;
        IRQ1 <= '0';

        -- Acknowledge again
        wait for 40 ns;
        IRQ_SERV <= '1';
        wait for 10 ns;
        IRQ_SERV <= '0';


        -- conflit de signal
        wait for 40 ns;
        IRQ0 <= '1';
        wait for 10 ns;
        IRQ1 <= '1';
        wait for 10 ns;
        IRQ0 <= '0';
        wait for 10 ns;
        IRQ1 <= '0';


        
        -- Acknowledge again
        wait for 40 ns;
        IRQ_SERV <= '1';
        wait for 10 ns;
        IRQ_SERV <= '0';

        -- Finish simulation
        wait for 50 ns;
        assert false report "Simulation finished" severity note;
        wait;
    end process;

end Behavioral;
