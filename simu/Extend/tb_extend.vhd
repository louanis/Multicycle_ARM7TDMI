library ieee;
use ieee.std_logic_1164.all;

entity tb_extend is
end tb_extend;

architecture test of tb_extend is
    constant N : integer := 8;
    signal E : std_logic_vector(N-1 downto 0);
    signal S : std_logic_vector(31 downto 0);
begin
    -- Instanciation du module Extend
    uut: entity work.Extend
        generic map(N => N)
        port map(
            E => E,
            S => S
        );

    -- Processus de test
    stim_proc: process
    begin
        -- Test 1 : valeur positive (bit de signe à 0)
        E <= "01111111"; -- 127
        wait for 10 ns;
        assert S = X"0000007F" report "Test 1 failed: sign extension positive" severity error;

        -- Test 2 : valeur négative (bit de signe à 1)
        E <= "10000000"; -- -128
        wait for 10 ns;
        assert S = X"FFFFFF80" report "Test 2 failed: sign extension negative" severity error;

        -- Test 3 : zéro
        E <= (others => '0');
        wait for 10 ns;
        assert S = X"00000000" report "Test 3 failed: sign extension zero" severity error;

        -- Test 4 : -1 (tous les bits à 1)
        E <= (others => '1');
        wait for 10 ns;
        assert S = X"FFFFFFFF" report "Test 4 failed: sign extension -1" severity error;

        report "Tous les tests Extend sont passés." severity note;
        wait;
    end process;

end architecture test;
