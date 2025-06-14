library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity proco is
    port(
        clk         : in std_logic;
        rst         : in std_logic;
        IRQ0        : in std_logic;
        IRQ1        : in std_logic;
        Affout      : out std_logic_vector(31 downto 0)
    );
end entity proco;


architecture Behavioral of proco is

    signal Affin                       : std_logic_vector(31 downto 0);
    signal CPSRA                       : std_logic_vector(31 downto 0);
    signal IRQ, IRQ_serv               : std_logic;
    signal PCSel                       : std_logic_vector(1 downto 0);
    signal PCWrEn, LRWrEn              : std_logic;
    signal AdrSel, MemRden, MemWrEn    : std_logic;
    signal IRWrEn, WSel, RegWrEn       : std_logic;
    signal ALUSelA                     : std_logic;
    signal ALUSelB, ALUOP              : std_logic_vector(1 downto 0);
    signal CPSRSel, CPSRWrEn, SPSRWrEn : std_logic;
    signal ResWrEn                     : std_logic;
    signal RbSel                       : std_logic;
    signal RdData                      : std_logic_vector(31 downto 0);
    signal Reg_IR_out                  : std_logic_vector(31 downto 0);

    signal Instruction                 : std_logic_vector(31 downto 0);
    signal inst_mem, inst_reg : std_logic_vector(31 downto 0);


    begin


        
        Chemin_donnee : entity work.Data_path
            port map(
                clk      => clk,
                rst      => rst,
                Resultat => Affout,
                IRQ0     => IRQ0,
                IRQ1     => IRQ1,
                IRQ      => IRQ, --
                IRQ_serv => IRQ_serv, --
                inst_mem   => inst_mem,
                inst_reg   => inst_reg,
                CPSROUT  => CPSRA, --
                PCSel    => PCSel,
                PCWrEn   => PCWrEn,
                LRWrEn   => LRWrEn,
                AdrSel   => AdrSel,
                MemRdEn  => MemRdEn,
                MemWrEn  => MemWrEn,
                IRWrEn   => IRWrEn,
                RbSel    => RbSel,
                WSel     => WSel,
                RegWrEn  => RegWrEn,
                ALUSelA  => ALUSelA,
                ALUSelB  => ALUSelB,
                ALUOP    => ALUOP,
                ResWrEn  => ResWrEn,
                CPSRSel  => CPSRSel,
                CPSRWrEn => CPSRWrEn,
                SPSRWrEn => SPSRWrEn        
            );

        Machine_AE : entity work.MAE
            port map(
                clk             => clk,               -- Clock signal
                rst             => rst,               -- Reset signal         
                IRQ             => IRQ,               -- IRQ interrupt signals
                inst_memory     => inst_mem,            -- Instruction fetched from memory (not Reg_IR_out)
                inst_register   => inst_reg,        -- Instruction already in the Instruction Register (IR)
                CPSR            => CPSRA,             -- Assuming you want to pass the current CPSR value
                IRQServ         => IRQ_serv,          -- IRQ service output (indicating if interrupt is handled)
                
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



        


end Behavioral;