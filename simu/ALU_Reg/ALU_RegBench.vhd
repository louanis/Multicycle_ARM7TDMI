library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU_RegBench is
end ALU_RegBench;

architecture tb of ALU_RegBench is
    -- Signals for RegisterARM
    signal CLK   : std_logic := '0';
    signal RESET : std_logic := '0';
    signal WE    : std_logic := '0';
    signal W     : std_logic_vector(31 downto 0) := (others => '0');
    signal RA    : std_logic_vector(3 downto 0) := (others => '0');
    signal RB    : std_logic_vector(3 downto 0) := (others => '0');
    signal RW    : std_logic_vector(3 downto 0) := (others => '0');
    signal A     : std_logic_vector(31 downto 0);
    signal B     : std_logic_vector(31 downto 0);

    -- Aliases for RegisterARM outputs (for assertions)
    -- alias R1 : std_logic_vector(31 downto 0) is A when RA = "0001" else (others => 'X');
    -- alias R2 : std_logic_vector(31 downto 0) is A when RA = "0010" else (others => 'X');
    -- alias R3 : std_logic_vector(31 downto 0) is A when RA = "0011" else (others => 'X');
    -- alias R5 : std_logic_vector(31 downto 0) is A when RA = "0101" else (others => 'X');
    -- alias R7 : std_logic_vector(31 downto 0) is A when RA = "0111" else (others => 'X');
    -- alias R15: std_logic_vector(31 downto 0) is A when RA = "1111" else (others => 'X');

    -- Signals for ALU
    signal ALUCtr : std_logic_vector(1 downto 0) := (others => '0');
    signal S      : std_logic_vector(31 downto 0);
    signal N      : std_logic;
    signal Z      : std_logic;

begin
    -- Instantiate RegisterARM
    U_RegisterARM : entity work.RegisterARM
        port map(
            CLK   => CLK,
            Reset => RESET,
            W     => W,
            RA    => RA,
            RB    => RB,
            RW    => RW,
            WE    => WE,
            A     => A,
            B     => B
        );

    -- Instantiate ALU
    U_ALU : entity work.ALU
        port map(
            OP => ALUCtr,
            A  => A,
            B  => B,
            S  => S,
            N  => N,
            Z  => Z
        );

    -- Clock process
    clk_process : process
    begin
        while now < 200 ns loop
            CLK <= '0'; wait for 5 ns;
            CLK <= '1'; wait for 5 ns;
        end loop;
        wait;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Reset registers
        RESET <= '1';
        wait for 10 ns;
        RESET <= '0';
        wait for 10 ns;

        -- 1. Copy R(15) to R(1)
        RA <= "1111"; -- select R15
        wait for 5 ns;
        W <= A;
        RW <= "0001"; -- write to R1
        WE <= '1';
        wait for 10 ns;
        WE <= '0';
        wait for 5 ns;
        RA <= "0001"; -- check R1
        wait for 5 ns;
        assert A = X"00000030" report "R(1) = R(15) failed" severity error;

        -- 2. R(1) = R(1) + R(15)
        RA <= "0001";
        RB <= "1111";
        ALUCtr <= "00"; -- ADD
        wait for 5 ns;
        W <= S;
        RW <= "0001";
        WE <= '1';
        wait for 10 ns;
        WE <= '0';
        wait for 5 ns;
        RA <= "0001";
        wait for 5 ns;
        assert A = X"00000060" report "R(1) = R(1) + R(15) failed" severity error;

        -- 3. R(2) = R(1) + R(15)
        RA <= "0001";
        RB <= "1111";
        ALUCtr <= "00";
        wait for 5 ns;
        W <= S;
        RW <= "0010";
        WE <= '1';
        wait for 10 ns;
        WE <= '0';
        wait for 5 ns;
        RA <= "0010";
        wait for 5 ns;
        assert A = X"00000090" report "R(2) = R(1) + R(15) failed" severity error;

        -- 4. R(3) = R(1) - R(15)
        RA <= "0001";
        RB <= "1111";
        ALUCtr <= "10"; -- SUB
        wait for 5 ns;
        W <= S;
        RW <= "0011";
        WE <= '1';
        wait for 10 ns;
        WE <= '0';
        wait for 5 ns;
        RA <= "0011";
        wait for 5 ns;
        assert A = X"00000030" report "R(3) = R(1) - R(15) failed" severity error;

        -- 5. R(5) = R(7) - R(15)
        RA <= "0111";
        RB <= "1111";
        ALUCtr <= "10"; -- SUB
        wait for 5 ns;
        W <= S;
        RW <= "0101";
        WE <= '1';
        wait for 10 ns;
        WE <= '0';
        wait for 5 ns;
        RA <= "0101";
        wait for 5 ns;
        assert A = X"FFFFFFD0" report "R(5) = R(7) - R(15) failed" severity error;

        report "All tests done." severity note;
        wait;
    end process;

end tb;
