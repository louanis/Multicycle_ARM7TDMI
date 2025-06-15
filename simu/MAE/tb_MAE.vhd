library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_MAE is
end entity;

architecture behavior of tb_MAE is

    -- Component declaration
    component MAE is
        port(
            clk, rst                    : in std_logic;
            IRQ                         : in std_logic;
            inst_register               : in std_logic_vector(31 downto 0);
            inst_memory                 : in std_logic_vector(31 downto 0);
            CPSR                        : in std_logic_vector(31 downto 0);
            IRQServ                     : out std_logic;
            PCSel                       : out std_logic_vector(1 downto 0);
            PCWrEn, LRWrEn              : out std_logic;
            AdrSel, MemRden, MemWrEn    : out std_logic;
            IRWrEn, WSel, RegWrEn       : out std_logic;
            ALUSelA                     : out std_logic;
            ALUSelB, ALUOP              : out std_logic_vector(1 downto 0);
            CPSRSel, CPSRWrEn, SPSRWrEn : out std_logic;
            ResWrEn                     : out std_logic;
            RbSel                       : out std_logic
        );
    end component;

    -- Testbench signals
    signal clk         : std_logic := '0';
    signal rst         : std_logic := '1';
    signal IRQ         : std_logic := '0';
    signal inst_reg    : std_logic_vector(31 downto 0) := (others => '0');
    signal inst_mem    : std_logic_vector(31 downto 0) := (others => '0');
    signal CPSR        : std_logic_vector(31 downto 0) := (others => '0');

    signal IRQServ     : std_logic;
    signal PCSel       : std_logic_vector(1 downto 0);
    signal PCWrEn, LRWrEn : std_logic;
    signal AdrSel, MemRden, MemWrEn : std_logic;
    signal IRWrEn, WSel, RegWrEn : std_logic;
    signal ALUSelA     : std_logic;
    signal ALUSelB, ALUOP : std_logic_vector(1 downto 0);
    signal CPSRSel, CPSRWrEn, SPSRWrEn : std_logic;
    signal ResWrEn     : std_logic;
    signal RbSel       : std_logic;

begin

    -- Clock process
    clk_process : process
    begin
        while true loop
            clk <= '0'; wait for 10 ns;
            clk <= '1'; wait for 10 ns;
        end loop;
    end process;

    -- DUT instance
    uut: MAE
        port map(
            clk         => clk,
            rst         => rst,
            IRQ         => IRQ,
            inst_register => inst_reg,
            inst_memory  => inst_mem,
            CPSR        => CPSR,
            IRQServ     => IRQServ,
            PCSel       => PCSel,
            PCWrEn      => PCWrEn,
            LRWrEn      => LRWrEn,
            AdrSel      => AdrSel,
            MemRden     => MemRden,
            MemWrEn     => MemWrEn,
            IRWrEn      => IRWrEn,
            WSel        => WSel,
            RegWrEn     => RegWrEn,
            ALUSelA     => ALUSelA,
            ALUSelB     => ALUSelB,
            ALUOP       => ALUOP,
            CPSRSel     => CPSRSel,
            CPSRWrEn    => CPSRWrEn,
            SPSRWrEn    => SPSRWrEn,
            ResWrEn     => ResWrEn,
            RbSel       => RbSel
        );

    -- Stimulus process
    stim_proc : process
    begin
        wait for 40 ns;
        rst <= '0';

        -- MOV
        inst_mem <= x"e3a01005"; wait for 60 ns; -- MOV R1, #5

        inst_mem <= x"E5910000";  -- LDR R4, [R1]
        inst_reg <= x"E5910000";
        wait for 100 ns;

        inst_mem <= x"E5822000";  -- STR R5, [R1]
        inst_reg <= x"E5822000";
        wait for 100 ns;


        -- ADDi
        inst_mem <= x"e2802003"; wait for 60 ns; -- ADD R2, R0, #3

        -- ADDr
        inst_mem <= x"e0803002"; wait for 60 ns; -- ADD R3, R0, R2

        -- CMP
        inst_mem <= x"e3500003"; wait for 60 ns; -- CMP R0, #3

        
        -- BAL
        inst_mem <= x"ea000003"; wait for 60 ns; -- BAL to PC+3

        -- BLT (CPSR.N = 1)
        CPSR(31) <= '1';
        inst_mem <= x"ba000002"; wait for 60 ns;

        -- BX
        inst_mem <= x"e12fff1e"; wait for 60 ns;

        -- IRQ test
        IRQ <= '1'; wait for 60 ns;
        IRQ <= '0'; wait for 100 ns;

        wait;
    end process;

end architecture;
