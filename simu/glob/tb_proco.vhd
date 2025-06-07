-- filepath: d:\cours\VHDL\Projet\Monocycle_ARM7TDMI\simu\Reg\tb_Reg.vhd
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_proco is
end tb_proco;

architecture sim of tb_proco is
    signal clk   : std_logic := '0';
    signal rst   : std_logic := '0';
    signal Aff   : std_logic_vector(31 downto 0);

    constant clk_period : time := 10 ns;
begin
    proco_inst : entity work.proco
        port map (
            clk     => clk,
            rst     => rst,
            Affout  => Aff
        );

    clk_process: process
    begin
        while now < 5000 ns loop
            clk <= '0'; wait for clk_period/2;
            clk <= '1'; wait for clk_period/2;
        end loop;
        wait;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Reset the register
        rst <= '1';
        wait for clk_period;
        rst <= '0';
        wait for clk_period;

        wait for 5000 ns;
        wait;
    end process;

end architecture sim;