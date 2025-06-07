library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Unite_traitement is
    port(
        clk      : in std_logic;
        rst      : in std_logic;
        regWr    : in std_logic;
        RW       : in std_logic_vector(3 downto 0);
        RA       : in std_logic_vector(3 downto 0);
        RB       : in std_logic_vector(3 downto 0);
        ALUSrc   : in std_logic;
        ALUCtr   : in std_logic_vector(1 downto 0);
        MemWr    : in std_logic;
        MemToReg : in std_logic;
        Immediat : in std_logic_vector(7 downto 0);
        N        : out std_logic;
        Z        : out std_logic;
        Aff      : out std_logic_vector(31 downto 0)
        
    );
end Unite_traitement;

architecture RTL of Unite_traitement is
    signal BusA, BusB, BusW, Imm_ext, SortieMux, ALUout, DataMemOut : std_logic_vector(31 downto 0);
    signal s_N, s_Z : std_logic;
begin

    banc_reg : entity work.RegisterARM(RTL)
    port map(
        CLK   => CLK,
        Reset => RST,
        W     => BusW,
        RA    => RA,
        RB    => RB,
        RW    => RW,
        WE    => RegWr,
        A     => BusA,
        B     => BusB
    ); 

    imm_extend : entity work.Extend(Behavioral)
    generic map(
        N => 8
    )
    port map(
        E => Immediat,
        S => Imm_ext
    );

    mux_alu : entity work.mux2v1(Behavioral)
    generic map(
        N => 32
    )
    port map(
        A   => BusB,
        B   => Imm_ext,
        COM => ALUSrc,
        S   => SortieMux
    );

    alu_cabl_mux: entity work.ALU(rtl)
    port map(
        OP => ALUCtr,
        A  => BusA,
        B  => SortieMux,
        S  => ALUout,
        N  => N,
        Z  => Z
    );  


    mem_dat: entity work.Memoire_data(RTL)
    port map(
        clk => clk,
        rst => rst,
        DataIn => BusB,
        DataOut => DataMemOut,
        Addr => ALUout(5 downto 0),
        WrEn => MemWr
    );

    mux_toreg: entity work.mux2v1(Behavioral)
    generic map(
        N => 32
    )
    port map(
        A   => ALUout,
        B   => DataMemOut,
        COM => MemToReg,
        S   => BusW
    );

    Aff <= BusB;


end RTL;