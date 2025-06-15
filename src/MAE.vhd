-- MAE.vhd (Fixed)
library ieee;
use ieee.std_logic_1164.all;

entity MAE is 
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
end entity;

architecture Behavioral of MAE is 

    type enum_instruction is (MOV, ADDi, ADDr , CMP, LDR, STR, BAL, BLT, BX);
    type state is (E1, E2, E3, E4, E5, E6, E7, E8, E9, E10, E11, E12, E13, E15, E16, E17, E18);

    signal instr_courante : enum_instruction := MOV;
    signal curr_state     : state := E1;
    signal isr            : std_logic := '0';

begin

    -- Instruction decoder (uses inst_register)
    process(inst_memory,inst_register,curr_state)
    begin
        instr_courante <= MOV; -- default
            case inst_register(31 downto 24) is
                when "11101010" => instr_courante <= BAL;
                when "10111010" => instr_courante <= BLT;
                when others =>
                    case inst_register(31 downto 20) is
                        when "111000101000" => instr_courante <= ADDi;
                        when "111000001000" => instr_courante <= ADDr;
                        when "111000110101" => instr_courante <= CMP;
                        when "111000010101" => instr_courante <= CMP;
                        when "111000111010" => instr_courante <= MOV;
                        when others =>
                            case inst_register(31 downto 26) is
                                when "111001" =>
                                    case inst_register(20) is
                                        when '1' => instr_courante <= LDR;
                                        when '0' => instr_courante <= STR;
                                        when others => instr_courante <= MOV;
                                    end case;
                                when others =>
                                    instr_courante <= MOV;
                            end case;
                    end case;
            end case;
            if inst_register = x"EB000000" then
                instr_courante <= BX;
            end if;
    end process;
                                

    -- FSM
    process(clk, rst)
    begin
        if rst = '1' then
            curr_state <= E1;
            PCSel      <= "00";
            PCWrEn     <= '0';
            LRWrEn     <= '0';
            MemWrEn    <= '0';
            WSel       <= '0';
            RegWrEn    <= '0';
            ALUSelA    <= '0';
            ALUSelB    <= "00";
            ALUOP      <= "00";
            CPSRSel    <= '0';
            CPSRWrEn   <= '0';
            SPSRWrEn   <= '0';
            ResWrEn    <= '0';
            RbSel      <= '0';
            MemRden    <= '1';
            IRWrEn     <= '1';
            AdrSel     <= '1';
            IRQServ    <= '0';

            isr        <= '0';
        elsif rising_edge(clk) then

            -- Default signal values
            

            case curr_state is

                when E1 => -- Fetch
                    PCWrEn   <= '0';
                    LRWrEn   <= '0';
                    MemRden  <= '1';
                    MemWren  <= '0';
                    RegWrEn  <= '0';
                    CPSRWrEn <= '0';
                    SPSRWrEn <= '0';
                    ResWrEn  <= '0';
                    IRWrEn   <= '0';
                    AdrSel   <= '0';
                    curr_state <= E2;

                when E2 => -- Decode / IRQ check
                    IRWrEn   <= '1';
                    MemRden  <= '0';
                    IRQServ  <= '0';
                    if IRQ = '1' and isr = '0' then
                        curr_state <= E16;
                    elsif isr = '1' and instr_courante = BX then
                        curr_state <= E18;
                    elsif instr_courante = BAL or (instr_courante = BLT and CPSR(31) = '1') then
                        curr_state <= E4;
                    elsif instr_courante = BLT then
                        curr_state <= E15;
                    else
                        curr_state <= E3;
                    end if;

                when E3 => -- PC <- PC + 1
                    PCSel   <= "00";
                    PCWrEn  <= '1';
                    RbSel   <= '0';
                    IrWrEn  <= '0';

                    ALUSelA <= '0';
                    ALUSelB <= "11";
                    ALUOP   <= "00";
                    case instr_courante is
                        when LDR | STR | ADDi => curr_state <= E5;
                        when ADDr             => curr_state <= E6;
                        when MOV              => curr_state <= E7;
                        when CMP              => curr_state <= E8;
                        when others           => curr_state <= E1;
                    end case;

                when E4 => -- Branch target
                    PCSel   <= "00";
                    PCWrEn  <= '1';
                    IrWrEn  <= '0';

                    ALUSelA <= '1';
                    ALUSelB <= "10";
                    ALUOP   <= "00";

                    curr_state <= E1;

                when E5 =>
                    PCWrEn  <= '0';

                    ALUSelA <= '1';
                    ALUSelB <= "01";
                    ALUOP   <= "00";
                    case instr_courante is
                        when LDR  => curr_state <= E9;
                        when STR  => curr_state <= E12;
                        when ADDi => curr_state <= E13;
                        when others => curr_state <= E1;
                    end case;

                when E6 =>
                    PCWrEn  <= '0';

                    ALUSelA <= '1';
                    ALUSelB <= "00";
                    ALUOP   <= "00";
                    curr_state <= E13;

                when E7 =>
                    PCWrEn  <= '0';

                    ALUSelB <= "01";
                    ALUOP   <= "01";
                    curr_state <= E13;

                when E8 => -- CMP
                    PCWrEn   <= '0';
 
                    ALUSelA  <= '1';
                    ALUSelB  <= "01";
                    ALUOP    <= "10";
 
                    CPSRSel  <= '0';
                    CPSRWrEn <= '1';
                    curr_state <= E1;

                when E9 =>
                    AdrSel   <= '1';
                    MemRden <= '1';
                    curr_state <= E10;

                when E10 =>
                    MemRden <= '0';

                    curr_state <= E11;

                when E11 =>
                    WSel     <= '0';
                    RegWrEn  <= '1';
                    curr_state <= E1;

                when E12 =>
                    AdrSel   <= '1';
                    MemWrEn  <= '1';
                    ResWrEn  <= '1';
                    curr_state <= E1;

                when E13 =>
                    WSel     <= '1';
                    RegWrEn  <= '1';
                    CPSRWrEn <= '0';
                    curr_state <= E1;

                when E15 =>
                    PCSel   <= "00";
                    PCWrEn  <= '1';
                    ALUSelA <= '0';
                    ALUSelB <= "11";
                    ALUOP   <= "00";
                    curr_state <= E1;

                when E16 =>
                    SPSRWrEn <= '1';
                    LRWrEn   <= '1';
                    IrWrEn   <= '0';
                    curr_state <= E17;

                when E17 =>
                    PCSel   <= "11";
                    PCWrEn  <= '1';
                    LrWrEn  <= '0';
                    isr     <= '1';
                    curr_state <= E1;

                when E18 =>
                    PCSel    <= "10";
                    PCWrEn   <= '1';
                    CPSRSel  <= '1';
                    CPSRWrEn <= '1';
                    isr      <= '0';
                    IRQServ  <= '1';
                    IrWrEn   <= '0';
                    curr_state <= E1;

                when others =>
                    curr_state <= E1;
            end case;
        end if;
    end process;

end Behavioral;
