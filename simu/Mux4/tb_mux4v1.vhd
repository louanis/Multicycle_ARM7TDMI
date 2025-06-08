library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_Mux4v1 is
end tb_Mux4v1;

architecture Behavioral of tb_Mux4v1 is
    constant N : integer := 8;

    -- DUT signals
    signal A   : std_logic_vector(N-1 downto 0) := x"AA";
    signal B   : std_logic_vector(N-1 downto 0) := x"BB";
    signal C   : std_logic_vector(N-1 downto 0) := x"CC";
    signal D   : std_logic_vector(N-1 downto 0) := x"DD";
    signal COM : std_logic_vector(1 downto 0) := "00";
    signal S   : std_logic_vector(N-1 downto 0);

begin

    -- Instantiate the Mux
    DUT: entity work.Mux4v1
        generic map (N => N)
        port map (
            A   => A,
            B   => B,
            C   => C,
            D   => D,
            COM => COM,
            S   => S
        );

    -- Stimulus process
    stim_proc: process
    begin
        wait for 10 ns;
        COM <= "00";  -- Expect S = A = x"AA"
        wait for 10 ns;
        COM <= "01";  -- Expect S = B = x"BB"
        wait for 10 ns;
        COM <= "10";  -- Expect S = C = x"CC"
        wait for 10 ns;
        COM <= "11";  -- Expect S = D = x"DD"
        wait for 10 ns;

        -- Optionally test with new inputs
        A <= x"01"; B <= x"02"; C <= x"03"; D <= x"04";
        COM <= "10";  -- Expect S = C = x"03"
        wait for 10 ns;

        -- Finish
        assert false report "Mux4v1 test completed successfully." severity note;
        wait;
    end process;

end Behavioral;
