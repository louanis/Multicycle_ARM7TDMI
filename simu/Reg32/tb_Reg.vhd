-- filepath: d:\cours\VHDL\Projet\Monocycle_ARM7TDMI\simu\Reg\tb_Reg.vhd
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_Reg is
end tb_Reg;

architecture sim of tb_Reg is
    signal clk   : std_logic := '0';
    signal rst   : std_logic := '0';
    signal we    : std_logic := '0';
    signal din   : std_logic_vector(31 downto 0) := (others => '0');
    signal dout  : std_logic_vector(31 downto 0);

    constant clk_period : time := 10 ns;
begin

    -- Instantiate the Reg
    uut: entity work.Reg
        generic map (
            N => 32  
        )
        port map (
            clk  => clk,
            rst  => rst,
            we   => we,
            din  => din,
            dout => dout
        );

    -- Clock process
    clk_process: process
    begin
        while now < 100 ns loop
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

        -- Write 0x12345678
        din <= x"12345678";
        we  <= '1';
        wait for clk_period;
        we  <= '0';
        wait for clk_period;
        assert dout = x"12345678" report "Write or hold failed (0x12345678)" severity error;

        -- Write 0xFFFFFFFF
        din <= x"FFFFFFFF";
        we  <= '1';
        wait for clk_period;
        we  <= '0';
        wait for clk_period;
        assert dout = x"FFFFFFFF" report "Write or hold failed (0xFFFFFFFF)" severity error;

        -- Hold value (no write enable)
        din <= x"00000000";
        we  <= '0';
        wait for clk_period;
        assert dout = x"FFFFFFFF" report "Hold failed (should still be 0xFFFFFFFF)" severity error;

        -- Reset again
        rst <= '1';
        wait for clk_period;
        rst <= '0';
        wait for clk_period;
        assert dout = x"00000000" report "Reset failed (should be 0)" severity error;

        report "All Reg tests passed." severity note;
        wait;
    end process;

end architecture sim;