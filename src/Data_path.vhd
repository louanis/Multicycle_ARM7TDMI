library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity Data_path is
    port(
        clk      : in std_logic;
        rst      : in std_logic;
        Resultat : out std_logic_vector(31 downto 0);
        IRQ0     : in std_logic;
        IRQ1     : in std_logic;
        IRQ      : out std_logic;
        IRQ_serv : in std_logic;

        CPSROUT  : out std_logic_vector(31 downto 0);

        inst_mem : out std_logic_vector(31 downto 0);
        inst_reg : out std_logic_vector(31 downto 0);

        PCSel    : in std_logic_vector(1 downto 0);
        PCWrEn   : in std_logic;
        LRWrEn   : in std_logic;
        AdrSel   : in std_logic;
        MemRdEn  : in std_logic;
        MemWrEn  : in std_logic;
        IRWrEn   : in std_logic;
        RbSel    : in std_logic;
        WSel     : in std_logic;
        RegWrEn  : in std_logic;
        ALUSelA  : in std_logic;
        ALUSelB  : in std_logic_vector(1 downto 0);
        ALUOP    : in std_logic_vector(1 downto 0);
        ResWrEn  : in std_logic;
        CPSRSel  : in std_logic;
        CPSRWrEn : in std_logic;
        SPSRWrEn : in std_logic
        
    );
end entity Data_path;

architecture RTL of Data_path is

    signal ALU_out, Reg_ALU_out, Reg_LR_out, VIC_Out, Mux_4v1_Out : std_logic_vector(31 downto 0);

    signal PCOut                                                  : std_logic_vector(31 downto 0);
    

    signal Mux_addr                                               : std_logic_vector(5 downto 0);

    signal RdData, WrData                                         : std_logic_vector(31 downto 0);

    signal Reg_IR_out                                             : std_logic_vector(31 downto 0);

    
    signal Reg_DR_out                                             : std_logic_vector(31 downto 0);
    
    signal Mux_Reg_out                                            : std_logic_vector(3 downto 0);

    signal Mux_bus_out                                            : std_logic_vector(31 downto 0);

    signal BusA, BusB                                             : std_logic_vector(31 downto 0);

    signal extend_ir_8                                            : std_logic_vector(31 downto 0);
    
    signal extend_ir_24                                           : std_logic_vector(31 downto 0);
    
    signal RegA, RegB                                             : std_logic_vector(31 downto 0);

    signal mux_alu_a_out                                          : std_logic_vector(31 downto 0);

    signal mux_alu_b_out                                          : std_logic_vector(31 downto 0);

    signal flag_N, flag_Z                                         : std_logic;

    signal CPSRA,  RegCPSRin                                      : std_logic_vector(31 downto 0);

    signal RegCPSROut                                             : std_logic_vector(31 downto 0);
    
    signal RegSPSROut                                             : std_logic_vector(31 downto 0);


begin

    VIC_comp : entity work.VIC
        port map(   
            CLK      => clk, 
            RESET    => rst, 
            IRQ0     => IRQ0, 
            IRQ1     => IRQ1, 
            IRQ_SERV => IRQ_SERV,   
            IRQ      => IRQ, 
            VICPC    => VIC_Out
        );

    mux_pc : entity work.mux4v1
        generic map(
            N => 32
        )
        port map(
            A   => ALU_out,
            B   => Reg_ALU_out,
            C   => Reg_LR_out,
            D   => VIC_Out,
            COM => PCSel,
            S   => Mux_4v1_Out
        );

    Reg_pc : entity work.Reg
        generic map(
            N => 32
        )
        port map(
            CLK     => clk,
            RST     => rst,
            WE      => PCWrEn,
            Din     => Mux_4v1_Out,
            Dout    => PCOut
        );

    Reg_lr : entity work.Reg
        generic map(
            N => 32
        )
        port map(
            CLK     => clk,
            RST     => rst,
            WE      => LRWrEn,
            Din     => PCOut,
            Dout    => Reg_LR_out
        );

    
    mux_mem : entity work.mux2v1
        generic map(
            N => 6
        )
        port map(
            A   => PCOut(5 downto 0),
            B   => ALU_out(5 downto 0),
            COM => AdrSel,
            S   => Mux_addr
        );

    mem_dat: entity work.DualPortRAM(RTL)
        port map(
	        clock     => clk,
            rst       => rst,
	        data      => RegB,
            q         => RdData,
	        rdaddress => Mux_addr,
            wraddress => Mux_addr,
            rden      => MemRdEn,
            wren      => MemWrEn
        );

    Reg_ir : entity work.Reg
        generic map(
            N => 32
        )
        port map(
            CLK     => clk,
            RST     => rst,
            WE      => IRWrEn,
            Din     => RdData,
            Dout    => Reg_IR_out
        );

    Reg_dr : entity work.Regclk
        generic map(
            N => 32
        )
        port map(
            CLK     => clk,
            RST     => rst,
            Din     => RdData,
            Dout    => Reg_DR_out
        );

    mux_Reg_rb : entity work.mux2v1
        generic map(
            N => 4
        )
        port map(
            A   => Reg_IR_out(3 downto 0),
            B   => Reg_IR_out(15 downto 12),
            COM => RbSel,
            S   => Mux_Reg_out
        );
    
    mux_Reg_busw : entity work.mux2v1
        generic map(
            N => 32
        )
        port map(
            A   => Reg_DR_out,
            B   => ALU_out,
            COM => WSel,
            S   => Mux_bus_out
        );


    banc_Reg : entity work.RegisterARM(RTL)
        port map(
            CLK   => CLK,
            Reset => RST,
            W     => Mux_bus_out,
            RA    => Reg_IR_out(19 downto 16),
            RB    => Mux_Reg_out,
            RW    => Reg_IR_out(15 downto 12),
            WE    => RegWrEn,
            A     => BusA,
            B     => BusB
        );

    ext_8 : entity work.Extend
        generic map(
            N => 8
        )
        port map(
            E => Reg_IR_out(7 downto 0),
            S => extend_ir_8
        );

    ext_24 : entity work.Extend
        generic map(
            N => 24
        )
        port map(
            E => Reg_IR_out(23 downto 0),
            S => extend_ir_24
        );

    mux_alu_a : entity work.mux2v1
        generic map(
            N => 32
        )
        port map(
            A   => PCOut,
            B   => RegA,
            COM => ALUSelA,
            S   => mux_alu_a_out
        );

    Reg_A : entity work.Regclk
        generic map(
            N => 32
        )
        port map(
            CLK     => clk,
            RST     => rst,
            Din     => BusA,
            Dout    => RegA
        );

    Reg_B : entity work.Regclk
        generic map(
            N => 32
        )
        port map(
            CLK     => clk,
            RST     => rst,
            Din     => BusB,
            Dout    => RegB
        );

    Reg_aluout : entity work.Regclk
        generic map(
            N => 32
        )
        port map(
            clk  => clk,
            rst  => rst,
            Din  => ALU_out,
            Dout => Reg_ALU_out
        );

    mux_alu_b : entity work.mux4v1
        generic map(
            N => 32
        )
        port map(
            A   => RegB,
            B   => extend_ir_8,
            C   => extend_ir_24,
            D   => std_logic_vector(to_unsigned(1, 32)),
            COM => ALUSelB,
            S   => mux_alu_b_out
        );

    ALU_ab : entity work.ALU
        port map(
            A  => mux_alu_a_out,
            B  => mux_alu_b_out,
            OP => ALUOP,
            S  => ALU_out,
            N  => flag_N,
            Z  => flag_Z
        );

    Result : entity work.Reg
        generic map(
            N => 32
        )
        port map(
            clk  => clk,
            rst  => rst,
            din  => RegB,
            we   => ResWrEn,
            dout => Resultat
        );

    mux_cpsr : entity work.mux2v1
        generic map(
            N => 32
        )
        port map(
            A   => CPSRA,
            B   => RegSPSROut,
            COM => CPSRSel,
            S   => RegCPSRin
        );

    Reg_cpsr : entity work.Reg
        generic map(
            N => 32
        )
        port map(
            clk  => clk,
            rst  => rst,
            din  => RegCPSRin,
            we   => CPSRWrEn,
            dout => RegCPSROut
        );

    Reg_spsr : entity work.Reg
        generic map(
            N => 32
        )
        port map(
            clk  => clk,
            rst  => rst,
            din  => RegCPSROut,
            we   => SPSRWrEn,
            dout => RegSPSROut
        );

    
    CPSRA(31) <= flag_N;
    CPSRA(30) <= flag_Z;
    CPSRA(29 downto 0) <= RegCPSROut(29 downto 0);

    CPSROUT <= CPSRA;

    inst_reg <= Reg_IR_out;
    inst_mem <= RdData;


end architecture RTL;