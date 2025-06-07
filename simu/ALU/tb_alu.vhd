-- filepath: d:\cours\VHDL\Projet\Monocycle_ARM7TDMI\simu\ALU\tb_alu.vhd
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_alu is
end entity tb_alu;

architecture sim of tb_alu is
    -- Component declaration for the ALU
    component alu
        port (
            OP : in  std_logic_vector(1 downto 0);
            A  : in  std_logic_vector(31 downto 0);
            B  : in  std_logic_vector(31 downto 0);
            S  : out std_logic_vector(31 downto 0);
            N  : out std_logic;
            Z  : out std_logic
        );
    end component;

    -- Signals for testbench
    signal OP : std_logic_vector(1 downto 0);
    signal A, B, S : std_logic_vector(31 downto 0);
    signal N, Z : std_logic;

begin
    -- Instantiate the ALU
    uut: alu
        port map (
            OP => OP,
            A  => A,
            B  => B,
            S  => S,
            N  => N,
            Z  => Z
        );

    -- Test process
    process
    begin
        -- Test ADD: 5 + 3 = 8
        A <= std_logic_vector(to_signed(5, 32));
        B <= std_logic_vector(to_signed(3, 32));
        OP <= "00";
        wait for 10 ns;
        assert S = std_logic_vector(to_signed(8, 32)) report "ADD failed" severity error;
        assert N = '0' report "ADD N flag failed" severity error;
        assert Z = '0' report "ADD Z flag failed" severity error;

        -- Test ADD: -5 + -3 = -8
        A <= std_logic_vector(to_signed(-5, 32));
        B <= std_logic_vector(to_signed(-3, 32));
        OP <= "00";
        wait for 10 ns;
        assert S = std_logic_vector(to_signed(-8, 32)) report "ADD negative failed" severity error;
        assert N = '1' report "ADD negative N flag failed" severity error;
        assert Z = '0' report "ADD negative Z flag failed" severity error;

        -- Test B: Y = B
        A <= std_logic_vector(to_signed(123, 32));
        B <= std_logic_vector(to_signed(-42, 32));
        OP <= "01";
        wait for 10 ns;
        assert S = std_logic_vector(to_signed(-42, 32)) report "B failed" severity error;
        assert N = '1' report "B N flag failed" severity error;
        assert Z = '0' report "B Z flag failed" severity error;

        -- Test SUB: 10 - 10 = 0
        A <= std_logic_vector(to_signed(10, 32));
        B <= std_logic_vector(to_signed(10, 32));
        OP <= "10";
        wait for 10 ns;
        assert S = std_logic_vector(to_signed(0, 32)) report "SUB zero failed" severity error;
        assert N = '0' report "SUB zero N flag failed" severity error;
        assert Z = '1' report "SUB zero Z flag failed" severity error;

        -- Test SUB: 5 - 10 = -5
        A <= std_logic_vector(to_signed(5, 32));
        B <= std_logic_vector(to_signed(10, 32));
        OP <= "10";
        wait for 10 ns;
        assert S = std_logic_vector(to_signed(-5, 32)) report "SUB negative failed" severity error;
        assert N = '1' report "SUB negative N flag failed" severity error;
        assert Z = '0' report "SUB negative Z flag failed" severity error;

        -- Test A: Y = A
        A <= std_logic_vector(to_signed(-1, 32));
        B <= std_logic_vector(to_signed(0, 32));
        OP <= "11";
        wait for 10 ns;
        assert S = std_logic_vector(to_signed(-1, 32)) report "A failed" severity error;
        assert N = '1' report "A N flag failed" severity error;
        assert Z = '0' report "A Z flag failed" severity error;

        -- Test A: Y = A = 0
        A <= std_logic_vector(to_signed(0, 32));
        B <= std_logic_vector(to_signed(123, 32));
        OP <= "11";
        wait for 10 ns;
        assert S = std_logic_vector(to_signed(0, 32)) report "A zero failed" severity error;
        assert N = '0' report "A zero N flag failed" severity error;
        assert Z = '1' report "A zero Z flag failed" severity error;

        wait;
    end process;
end architecture sim;