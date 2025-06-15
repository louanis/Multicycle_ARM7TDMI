-- Testbench for Data_path
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_Data_path is
end entity;

architecture behavior of tb_Data_path is

    -- Component under test
    component Data_path
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
    end component;

    -- Signals to drive inputs and monitor outputs
    signal clk, rst     : std_logic := '0';
    signal IRQ0, IRQ1   : std_logic := '0';
    signal IRQ_serv     : std_logic := '0';
    signal PCSel        : std_logic_vector(1 downto 0) := "00";
    signal PCWrEn       : std_logic := '0';
    signal LRWrEn       : std_logic := '0';
    signal AdrSel       : std_logic := '0';
    signal MemRdEn      : std_logic := '0';
    signal MemWrEn      : std_logic := '0';
    signal IRWrEn       : std_logic := '0';
    signal RbSel        : std_logic := '0';
    signal WSel         : std_logic := '0';
    signal RegWrEn      : std_logic := '0';
    signal ALUSelA      : std_logic := '0';
    signal ALUSelB      : std_logic_vector(1 downto 0) := "00";
    signal ALUOP        : std_logic_vector(1 downto 0) := "00";
    signal ResWrEn      : std_logic := '0';
    signal CPSRSel      : std_logic := '0';
    signal CPSRWrEn     : std_logic := '0';
    signal SPSRWrEn     : std_logic := '0';

    -- Outputs
    signal IRQ          : std_logic;
    signal Resultat     : std_logic_vector(31 downto 0);
    signal CPSROUT      : std_logic_vector(31 downto 0);
    signal inst_mem     : std_logic_vector(31 downto 0);
    signal inst_reg     : std_logic_vector(31 downto 0);

begin

    -- Instantiate the DUT
    DUT: Data_path
        port map(
            clk       => clk,
            rst       => rst,
            Resultat  => Resultat,
            IRQ0      => IRQ0,
            IRQ1      => IRQ1,
            IRQ       => IRQ,
            IRQ_serv  => IRQ_serv,
            CPSROUT   => CPSROUT,
            inst_mem  => inst_mem,
            inst_reg  => inst_reg,
            PCSel     => PCSel,
            PCWrEn    => PCWrEn,
            LRWrEn    => LRWrEn,
            AdrSel    => AdrSel,
            MemRdEn   => MemRdEn,
            MemWrEn   => MemWrEn,
            IRWrEn    => IRWrEn,
            RbSel     => RbSel,
            WSel      => WSel,
            RegWrEn   => RegWrEn,
            ALUSelA   => ALUSelA,
            ALUSelB   => ALUSelB,
            ALUOP     => ALUOP,
            ResWrEn   => ResWrEn,
            CPSRSel   => CPSRSel,
            CPSRWrEn  => CPSRWrEn,
            SPSRWrEn  => SPSRWrEn
        );

    -- Clock generation
    clk_process : process
    begin
        clk <= '0'; wait for 10 ns;
        clk <= '1'; wait for 10 ns;
    end process;

    -- Stimulus
    stim_proc: process
    begin
        rst <= '1'; wait for 20 ns;
        rst <= '0';

        -- Load dummy values for control signals to stimulate different paths
        -- Add more stimulus as needed for full verification
        IRWrEn <= '1';
        MemRdEn <= '1';
        AdrSel <= '1';
        wait for 20 ns;

        IRWrEn <= '0';
        MemRdEn <= '0';

        RegWrEn <= '1';
        WSel <= '1';
        wait for 40 ns;

        RegWrEn <= '0';

        wait for 100 ns;
        assert false report "Simulation ended." severity failure;
    end process;

end architecture;
