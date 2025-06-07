-- filepath: d:\cours\VHDL\Projet\Monocycle_ARM7TDMI\simu\instruction_unit\tb_instruction_unit.vhd
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_instruction_unit is
end tb_instruction_unit;

architecture test of tb_instruction_unit is
    signal clk        : std_logic := '0';
    signal rst        : std_logic := '0';
    signal nPCsel     : std_logic := '0';
    signal offset     : std_logic_vector(23 downto 0) := (others => '0');
    signal Instruction: std_logic_vector(31 downto 0);
    signal PC_out     : std_logic_vector(31 downto 0);

    -- Clock period
    constant clk_period : time := 10 ns;
begin

    -- Instantiate the instruction_unit
    uut: entity work.instruction_unit
        port map (
            clk         => clk,
            rst         => rst,
            nPCsel      => nPCsel,
            offset      => offset,
            Instr       => Instruction
        );

    -- Clock process
    clk_process: process
    begin
        while now < 200 ns loop
            clk <= '0'; wait for clk_period/2;
            clk <= '1'; wait for clk_period/2;
        end loop;
        wait;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Reset PC
        rst <= '1';
        wait for 15 ns;
        rst <= '0';
        wait for clk_period;

        -- Test 1: nPCsel = 0, PC should increment by 1 each cycle
        nPCsel <= '0';
        offset <= (others => '0');
        wait for clk_period;
        assert PC_out = std_logic_vector(to_unsigned(1, 32)) report "PC should be 1" severity error;
        wait for clk_period;
        assert PC_out = std_logic_vector(to_unsigned(2, 32)) report "PC should be 2" severity error;

        -- Test 2: nPCsel = 1, PC should increment by 1 + sign-extended offset
        nPCsel <= '1';
        offset <= std_logic_vector(to_signed(3, 24)); -- offset = 3
        wait for clk_period;
        assert PC_out = std_logic_vector(to_unsigned(6, 32)) report "PC should be 6 (2+1+3)" severity error;

        -- Test 3: nPCsel = 1, negative offset
        offset <= std_logic_vector(to_signed(-2, 24)); -- offset = -2
        wait for clk_period;
        assert PC_out = std_logic_vector(to_unsigned(5, 32)) report "PC should be 5 (6+1-2)" severity error;

        -- Test 4: nPCsel = 0, normal increment
        nPCsel <= '0';
        wait for clk_period;
        assert PC_out = std_logic_vector(to_unsigned(6, 32)) report "PC should be 6" severity error;

        -- Test 5: Reset again
        rst <= '1';
        wait for clk_period;
        rst <= '0';
        wait for clk_period;
        assert PC_out = std_logic_vector(to_unsigned(1, 32)) report "PC should be 1 after reset" severity error;

        report "All instruction_unit tests passed." severity note;
        wait;
    end process;

end architecture test;