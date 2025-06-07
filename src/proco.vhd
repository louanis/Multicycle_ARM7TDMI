library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity proco is
    port(
        clk         : in std_logic;
        rst         : in std_logic;
        Affout      : out std_logic_vector(31 downto 0)
    );
end entity proco;


architecture Behavioral of proco is

    signal PC                : std_logic_vector(31 downto 0) := (others => '0');
    signal Instruction       : std_logic_vector(31 downto 0);
    signal RegPSRIn          : std_logic_vector(1 downto 0) := (others => '0');
    signal PSREn             : std_logic;
    signal WrSrc             : std_logic;
    signal ALUCtr            : std_logic_vector(1 downto 0);
    signal RegAff            : std_logic;
    signal ALUSrc            : std_logic;
    signal RegSel            : std_logic;
    signal RegWr             : std_logic;
    signal nPCSel            : std_logic;
    signal MemWr             : std_logic;
    signal Imm24             : std_logic_vector(23 downto 0);
    signal BusW, BusA, BusB  : std_logic_vector(31 downto 0);
    signal s_mux_B_Imm       : std_logic_vector(3 downto 0);
    signal ExtendedImm8      : std_logic_vector(31 downto 0);
    signal OutALu            : std_logic_vector(31 downto 0);
    signal s_N, s_Z          : std_logic;
    signal Affin             : std_logic_vector(31 downto 0);
    signal s_rd, s_rn, s_mux : std_logic_vector(3 downto 0);

    begin


        instr_unit: entity work.instruction_unit
            port map(
                clk         => clk,
                rst         => rst,
                Offset      => Instruction(23 downto 0),
                nPCsel      => nPCSel,
                Instr       => Instruction
            );

        Unit_trait : entity work.Unite_Traitement
            port map(
                clk     => clk,
                rst      => rst,
                regWr    => RegWr,
                RW       => Instruction(15 downto 12),
                RA       => Instruction(19 downto 16),
                RB       => s_mux,
                ALUSrc   => ALUSrc,
                ALUCtr   => ALUCtr,
                MemWr    => MemWr,
                MemToReg => WrSrc,
                Immediat => Instruction(7 downto 0),
                N        => s_N,
                Z        => s_Z,
                Aff      => Affin
            );
        
        Unit_controle : entity work.Unite_controle
            port map(
                clk         => clk,
                rst         => rst,
                instruction => instruction,
                N           => s_N,
                Z           => s_Z,
                WrSrc       => WrSrc, 
                ALUCtr      => ALUCtr, --
                RegAff      => RegAff, -- 
                ALUsrc      => ALUSrc,
                RegWr       => RegWr,
                nPCSel      => nPCSel,
                MemWr       => MemWr,
                Rw          => s_rd,
                Ra          => s_rn,
                Rm_d        => s_mux
            );  

        reg_aff : entity work.reg
            generic map(
                N => 32
            )
            port map(    
                CLK     => clk,
                RST     => rst,
                WE      => RegAff,
                Din     => Affin,
                Dout    => Affout
            );


end Behavioral;