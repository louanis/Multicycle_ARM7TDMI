library ieee;
use ieee.std_logic_1164.all;

entity tb_mux is
end tb_mux;

architecture test of tb_mux is
    constant N : integer := 8;
    signal A, B, S : std_logic_vector(N-1 downto 0);
    signal COM : std_logic;
begin
    -- Instanciation du multiplexeur
    uut: entity work.Mux2v1
        generic map(N => N)
        port map(
            A => A,
            B => B,
            COM => COM,
            S => S
        );

    -- Processus de test
    stim_proc: process
    begin
        -- Test 1 : COM = 0, S doit être A
        A <= "10101010";
        B <= "01010101";
        COM <= '0';
        wait for 10 ns;
        assert S = A report "Test 1 échoué : S doit être égal à A quand COM=0" severity error;

        -- Test 2 : COM = 1, S doit être B
        COM <= '1';
        wait for 10 ns;
        assert S = B report "Test 2 échoué : S doit être égal à B quand COM=1" severity error;

        -- Test 3 : On change A et B, COM = 0
        A <= "11110000";
        B <= "00001111";
        COM <= '0';
        wait for 10 ns;
        assert S = A report "Test 3 échoué : S doit être égal à A quand COM=0 (nouvelles valeurs)" severity error;

        -- Test 4 : COM = 1
        COM <= '1';
        wait for 10 ns;
        assert S = B report "Test 4 échoué : S doit être égal à B quand COM=1 (nouvelles valeurs)" severity error;

        report "Tous les tests du mux sont passés." severity note;
        wait;
    end process;

end architecture test;
