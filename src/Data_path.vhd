library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity Data_path is
    port(
        clk      : in std_logic;
        rst      : in std_logic;
        res      : out std_logic_vector(31 downto 1);
        IRQ      : in std_logic_vector(1 downto 0);
        IRQ_serv : out std_logic
    );
end entity Data_path;

architecture RTL of Data_path is

    signal ALU_out, Reg_ALU_out, Reg_LR_out, VIC_Out, Mux_4v1_Out : std_logic_vector(31 downto 0);
    signal PCSel                                                  : std_logic_vector(1 downto 0);

    signal PCWrEn                                                 : std_logic;
    signal PCOut                                                  : std_logic_vector(31 downto 0);
    
    signal LRWrEn                                                 : std_logic;

    signal AdrSel                                                 : std_logic;
    signal Mux_addr                                               : std_logic_vector(5 downto 0);

    signal MemRdEn, MemWrEn                                       : std_logic;    
    signal RdData, WrData                                         : std_logic_vector(31 downto 0);

    signal Reg_IR_out                                             : std_logic_vector(31 downto 0);
    signal IRWrEn                                                 : std_logic;    

    
    signal Reg_DR_out                                             : std_logic_vector(31 downto 0);
    
    signal Mux_Reg_out                                            : std_logic_vector(3 downto 0);
    signal RbSel                                                  : std_logic;

    signal Mux_bus_out                                            : std_logic_vector(31 downto 0);
    signal WSel                                                   : std_logic;

    signal BusA, BusB                                             : std_logic_vector(31 downto 0);
    signal RegWrEn                                                : std_logic;

    signal extend_ir_8                                            : std_logic_vector(31 downto 0);
    
    signal extend_ir_24                                           : std_logic_vector(31 downto 0);
    
    signal RegA, RegB                                             : std_logic_vector(31 downto 0);

    signal mux_alu_a_out                                          : std_logic_vector(31 downto 0);
    signal ALUSelA                                                : std_logic; 

    signal Alu_out_Reg                                            : std_logic_vector(31 downto 0);

    signal mux_alu_b_out                                          : std_logic_vector(31 downto 0);
    signal ALUSelB                                                : std_logic_vector(1 downto 0); 

    signal ALUOP                                                  : std_logic_vector(1 downto 0);
    signal flag_N, flag_Z                                         : std_logic;
    
    signal ResWrEn                                                : std_logic;
    signal Resultat                                               : std_logic_vector(31 downto 0);

    signal CPSRSel                                                : std_logic;
    signal CPSRA,  RegCPSRin                                      : std_logic_vector(31 downto 0);

    signal RegCPSROut                                             : std_logic_vector(31 downto 0);
    signal CPSRWrEn                                               : std_logic;
    
    signal RegSPSROut                                             : std_logic_vector(31 downto 0);
    signal SPSRWrEn                                               : std_logic;


begin

    mux_pc : entity work.mux4v1
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

    mem_dat: entity work.Memoire_data(RTL)
        port map(
            clk     => clk,
            rst     => rst,
            DataIn  => WrData,
            DataOut => RdData,
            Addr    => Mux_addr,
            WrEn    => MemWrEn,
            RdEn    => MemRdEn
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
            Dout => Alu_out_Reg
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





    Machine_AE : entity work.MAE
    port map(
        clk             => clk,               -- Clock signal
        rst             => rst,               -- Reset signal         
        IRQ             => IRQ,               -- IRQ interrupt signals
        inst_memory     => RdData,            -- Instruction fetched from memory (not Reg_IR_out)
        inst_register   => Reg_IR_out,        -- Instruction already in the Instruction Register (IR)
        CPSR            => CPSRA,             -- Assuming you want to pass the current CPSR value
        IRQServ         => IRQ_serv,          -- IRQ service output (indicating if interrupt is handled)
        
        -- Control Signals for PC and Memory
        PCSel           => PCSel,             -- Program Counter selection signal
        PCWrEn          => PCWrEn,            -- Program Counter Write Enable
        LRWrEn          => LRWrEn,            -- Link Register Write Enable
        AdrSel          => AdrSel,            -- Address selection signal
        MemRden         => MemRdEn,           -- Memory Read Enable
        MemWrEn         => MemWrEn,           -- Memory Write Enable
        
        -- Instruction Register and Register File control
        IRWrEn          => IRWrEn,            -- Instruction Register Write Enable
        WSel            => WSel,              -- Write selection for registers
        RegWrEn         => RegWrEn,           -- Register Write Enable
        
        -- ALU Operation control
        ALUSelA         => ALUSelA,           -- ALU Operand A Select
        ALUSelB         => ALUSelB,           -- ALU Operand B Select
        ALUOP           => ALUOP,             -- ALU Operation Select
        
        -- CPSR and SPSR control
        CPSRSel         => CPSRSel,           -- CPSR selection signal (to decide if CPSR or SPSR is used)
        CPSRWrEn        => CPSRWrEn,          -- CPSR Write Enable
        SPSRWrEn        => SPSRWrEn,          -- SPSR Write Enable
        
        -- Result Write Enable
        ResWrEn         => ResWrEn
    );

end architecture RTL;