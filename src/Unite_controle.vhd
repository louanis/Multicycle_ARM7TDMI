library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity Unite_controle is
    port(
        clk         : in std_logic;
        rst         : in std_logic;
        instruction : in std_logic_vector(31 downto 0);
        N           : in std_logic;
        Z           : in std_logic;
        WrSrc       : out std_logic; -- 
        ALUCtr      : out std_logic_vector(1 downto 0); --
        RegAff      : out std_logic; -- 
        ALUsrc      : out std_logic; -- 
        RegWr       : out std_logic; -- 
        nPCSel      : out std_logic; --
        MemWr       : out std_logic; --
        Rw          : out std_logic_vector(3 downto 0); -- 
        Ra          : out std_logic_vector(3 downto 0); --
        Rm_d        : out std_logic_vector(3 downto 0) -- 
    );
end Unite_controle;


architecture Behavioral of Unite_controle is
   
    signal PSREn         : std_logic;
    signal RegPSROut     : std_logic_vector(1 downto 0);
    signal RegPSRIn      : std_logic_vector(1 downto 0);
    signal RegSel        : std_logic;

    begin

        decod : entity work.Decoder
        port map(
            instruction => instruction,
            regpsrin    => RegPSROut,
            psren       => PSREn,
            WrSrc       => WrSrc,
            ALUCtr      => ALUCtr,
            RegAff      => RegAff,
            ALUsrc      => ALUsrc,
            RegSel      => RegSel,
            RegWr       => RegWr,
            nPCSel      => nPCSel,
            MemWr       => MemWr
        );

        regist: entity work.reg 
            generic map(
                N => 2
            )
            port map(    
                CLK     => clk,
                RST     => rst,
                WE      => PSREn,
                Din     => RegPSRIn,
                Dout    => RegPSROut
            );

        rb_mux : entity work.Mux2v1
            generic map(
                N => 4
            )
            port map(
                A   => instruction(3 downto 0), -- Rm
                B   => instruction(15 downto 12),   -- Rd
                COM => RegSel,
                S   => Rm_d
            );

        rw <= instruction(15 downto 12); -- Rd
        ra <= instruction(19 downto 16); -- Rn
        RegPSRIn(0) <= N; -- N flag
        RegPSRIn(1) <= Z; -- Z flag

end Behavioral;