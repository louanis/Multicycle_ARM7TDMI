library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_unite_traitement is
end tb_unite_traitement;

architecture test of tb_unite_traitement is
    signal clk      : std_logic := '0';
    signal rst      : std_logic := '0';
    signal regWr    : std_logic := '0';
    signal RW       : std_logic_vector(3 downto 0) := (others => '0');
    signal RA       : std_logic_vector(3 downto 0) := (others => '0');
    signal RB       : std_logic_vector(3 downto 0) := (others => '0');
    signal ALUSrc   : std_logic := '0';
    signal ALUCtr   : std_logic_vector(1 downto 0) := (others => '0');
    signal MemWr    : std_logic := '0';
    signal MemToReg : std_logic := '0';
    signal Immediat : std_logic_vector(7 downto 0) := (others => '0');
    signal BusA, BusB, BusW, Imm_ext, SortieMux, ResAlu, DataMemOut : std_logic_vector(31 downto 0);
    signal s_N, s_Z : std_logic;

begin
    -- Instanciation de l'unite de traitement
    dut: entity work.Unite_traitement
        port map(
            clk      => clk,
            rst      => rst,
            regWr    => regWr,
            RW       => RW,
            RA       => RA,
            RB       => RB,
            ALUSrc   => ALUSrc,
            ALUCtr   => ALUCtr,
            MemWr    => MemWr,
            MemToReg => MemToReg,
            Immediat => Immediat
        );

    -- Clock process
    clk_process: process
    begin
        while now < 500 ns loop
            clk <= '0'; wait for 5 ns;
            clk <= '1'; wait for 5 ns;
        end loop;
        wait;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Reset
        rst <= '1';
        wait for 12 ns;
        rst <= '0';
        wait for 10 ns;

        -- 1. Addition de 2 registres : R1 = R2 + R3
        -- On ecrit 5 dans R2 et 7 dans R3
        regWr <= '1'; RW <= "0010"; BusW <= std_logic_vector(to_unsigned(5,32)); wait for 10 ns; regWr <= '0'; wait for 10 ns;
        regWr <= '1'; RW <= "0011"; BusW <= std_logic_vector(to_unsigned(7,32)); wait for 10 ns; regWr <= '0'; wait for 10 ns;
        -- Addition
        RA <= "0010"; RB <= "0011"; ALUSrc <= '0'; ALUCtr <= "00"; regWr <= '1'; RW <= "0001"; wait for 10 ns; regWr <= '0'; wait for 10 ns;
        RA <= "0001"; wait for 2 ns;
        assert BusA = std_logic_vector(to_unsigned(12,32)) report "Addition de 2 registres echouee" severity error;

        -- 2. Addition registre + immediat : R4 = R1 + 10
        RA <= "0001"; ALUSrc <= '1'; Immediat <= std_logic_vector(to_unsigned(10,8)); ALUCtr <= "00"; regWr <= '1'; RW <= "0100"; wait for 10 ns; regWr <= '0'; wait for 10 ns;
        RA <= "0100"; wait for 2 ns;
        assert BusA = std_logic_vector(to_unsigned(22,32)) report "Addition registre + immediat echouee" severity error;

        -- 3. Soustraction de 2 registres : R5 = R4 - R2
        RA <= "0100"; RB <= "0010"; ALUSrc <= '0'; ALUCtr <= "10"; regWr <= '1'; RW <= "0101"; wait for 10 ns; regWr <= '0'; wait for 10 ns;
        RA <= "0101"; wait for 2 ns;
        assert BusA = std_logic_vector(to_unsigned(17,32)) report "Soustraction de 2 registres echouee" severity error;

        -- 4. Soustraction immediat à registre : R6 = R5 - 3
        RA <= "0101"; ALUSrc <= '1'; Immediat <= std_logic_vector(to_unsigned(3,8)); ALUCtr <= "10"; regWr <= '1'; RW <= "0110"; wait for 10 ns; regWr <= '0'; wait for 10 ns;
        RA <= "0110"; wait for 2 ns;
        assert BusA = std_logic_vector(to_unsigned(14,32)) report "Soustraction immediat à registre echouee" severity error;

        -- 5. Copie d'un registre dans un autre : R7 = R6
        RA <= "0110"; ALUSrc <= '0'; ALUCtr <= "11"; regWr <= '1'; RW <= "0111"; wait for 10 ns; regWr <= '0'; wait for 10 ns;
        RA <= "0111"; wait for 2 ns;
        assert BusA = std_logic_vector(to_unsigned(14,32)) report "Copie de registre echouee" severity error;

        -- 6. Ecriture d'un registre dans la memoire : ecrire R7 à l'adresse 5
        RA <= "0111"; ALUSrc <= '0'; ALUCtr <= "11"; MemWr <= '1'; regWr <= '0'; RW <= "0000"; wait for 10 ns; MemWr <= '0'; wait for 10 ns;

        -- 7. Lecture d'un mot de la memoire dans un registre : R8 = MEM[5]
        MemToReg <= '1'; regWr <= '1'; RW <= "1000"; RA <= "0000"; wait for 10 ns; regWr <= '0'; MemToReg <= '0'; wait for 10 ns;
        RA <= "1000"; wait for 2 ns;
        assert BusA = std_logic_vector(to_unsigned(14,32)) report "Lecture memoire dans registre echouee" severity error;

        -- Set R2 = 5 using immediate
        RA <= "0000";
        ALUSrc <= '1';
        Immediat <= std_logic_vector(to_unsigned(7,8));
        ALUCtr <= "00";
        regWr <= '1'; RW <= "0011";
        wait for 10 ns;
        regWr <= '0'; wait for 10 ns;

        report "Tous les tests Unite_traitement sont passes." severity note;
        wait;
    end process;

end architecture test;
