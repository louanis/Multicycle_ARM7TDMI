library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity proco_tb is
end entity;

architecture test of proco_tb is

    -- DUT I/O
    signal clk     : std_logic := '0';
    signal rst     : std_logic := '1';
    signal IRQ0    : std_logic := '0';
    signal IRQ1    : std_logic := '0';
    signal Affout  : std_logic_vector(31 downto 0);

    -- Clock period
    constant clk_period : time := 20 ns;

begin

    -- DUT instantiation
    uut: entity work.proco
        port map (
            clk    => clk,
            rst    => rst,
            IRQ0   => IRQ0,
            IRQ1   => IRQ1,
            Affout => Affout
        );

    -- Clock generation
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    -- Reset + Stimulus
    stim_proc: process
    begin
        -- Initial reset
        wait for 50 ns;
        rst <= '0';

        -- Let program run a few cycles
        wait for 1000 ns;

        -- Trigger IRQ0 (increment MEM[0x20] by +1)
        -- IRQ0 <= '1';
        -- wait for clk_period;
        -- IRQ0 <= '0';

        -- wait for 2000 ns;

        -- -- Trigger IRQ1 (increment MEM[0x20] by +2)
        -- IRQ1 <= '1';
        -- wait for clk_period;
        -- IRQ1 <= '0';

        -- Let simulation run to final state
        wait for 8900 ns;

        -- End simulation
        assert false report "Simulation finished." severity failure;
    end process;

end architecture;
