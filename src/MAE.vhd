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
        ResWrEn                     : out std_logic
    );
end entity;

architecture Behavioral of MAE is 

  type enum_instruction is (MOV, ADDi, ADDR , CMP, LDR, STR, BAL, BLT, BX);
  type state is (E1, E2, E3, E4, E5, E6, E7, E8, E9, E10, E11, E12, E13, E15, E16, E17, E18);
    
  signal instr_courante           : enum_instruction;
  signal curr_state               : state;
  signal isr                      : std_logic;

  begin


    process(inst_register)
    begin
        instr_courante <= MOV; -- default
        case inst_register(31 downto 24) is
            when "11101010" => instr_courante <= BAL;
            when "10111010" => instr_courante <= BLT;
            when others =>
                case inst_register(31 downto 20) is
                    when "111000101000" => instr_courante <= ADDi;
                    when "111000001000" => instr_courante <= ADDR;
                    when "111000110101" => instr_courante <= CMP;
                    when "111000010101" => instr_courante <= CMP;
                    when "111001100001" => instr_courante <= LDR;
                    when "111000111010" => instr_courante <= MOV;
                    when "111001100000" => instr_courante <= STR;
                    -- Add BX instruction decoding
                    when "111000010010" => instr_courante <= BX;
                    when others => instr_courante <= MOV;
                end case;
        end case;
    end process;

    process(clk, rst)
    begin
        if rst = '1' then
            curr_state <= E1;
            isr        <= '0';
            -- reset logic here (e.g., curr_state <= E0)
        elsif rising_edge(clk) then

            PCSel      <= "00";
            PCWrEn     <= '0';
            LRWrEn     <= '0';
            AdrSel     <= '0';
            MemRdEn    <= '0';
            MemWrEn    <= '0';
            IRWrEn     <= '0';
            WSel       <= '0';
            RegWrEn    <= '0';
            ALUSelA    <= '0';
            ALUSelB    <= "00";
            ALUOP      <= "00";
            CPSRSel    <= '0';
            CPSRWrEn   <= '0';
            SPSRWrEn   <= '0';
            ResWrEn    <= '0';
            IRQServ    <= '0';

            -- assume all signals are already set to '0' at the top of the process

            case curr_state is
                when E1 =>  -- Load IR from memory
                    IRWrEn   <= '1';         -- Write to IR
                    MemRdEn  <= '1';         -- Enable memory read
                    PCWrEn   <= '0';         -- Do not write to PC
                    PCSel    <= "00";        -- ADDR ess memory using the PC (Program Counter)
                    AdrSel   <= '1';         -- Use PC ADDR ess to access memory

                    curr_state <= E2;

                when E2 =>
                    IRWrEn   <= '1';
                    MemRdEn  <= '1';
                    IRQServ  <= '0';

                    if IRQ = '1' then
                        curr_state <= E16;
                    
                    elsif isr = '1' then
                        curr_state <= E18;
                    
                    else

                        case instr_courante is
                            when ADDi => curr_state <= E3;
                            when ADDr => curr_state <= E3;
                            when MOV  => curr_state <= E3;
                            when CMP  => curr_state <= E3;
                            when LDR  => curr_state <= E3;
                            when STR  => curr_state <= E3;
                            when BAL  => curr_state <= E4;
                            when BX   => curr_state <= E18;
                            when BLT =>
                                case CPSR(31) is
                                    when '1' => curr_state <= E4;
                                    when others => curr_state <= E15;
                                end case;
                            when others => curr_state <= E3;
                        end case;
                    end if;
                
            
                when E3 =>
                    -- PC ← PC + 1 (always the same logic)
                    PCWrEn   <= '1';
                    PCSel    <= "00";    -- ALU_out from PC + 1
                    ALUSelA  <= '1';     -- Select PC
                    ALUSelB  <= "11";    -- Constant 1
                    ALUOP    <= "00";    -- ADD
                    ResWrEn  <= '0';     -- No general result write here

                    -- Next step: go to appropriate execution state
                    case instr_courante is
                        when LDR   => curr_state <= E5;
                        when STR   => curr_state <= E5;
                        when ADDR  => curr_state <= E6;
                        when ADDi  => curr_state <= E5;
                        when CMP   => curr_state <= E8;
                        when MOV   => curr_state <= E7;
                        when others => curr_state <= E1;  -- safe fallback
                    end case;

                when E4 =>  -- BAL / BLT true
                    PCWrEn   <= '1';
                    PCSel    <= "00";    -- ALU_out
                    ALUSelA  <= '1';     -- PC
                    ALUSelB  <= "10";    -- Imm24
                    ALUOP    <= "00";    -- ADD

                    curr_state <= E1;    

                when E5 =>  -- STR, LDR, ADDI → ALU_out ← A + Imm8
                    ALUSelA  <= '0';     -- RegA
                    ALUSelB  <= "01";    -- Imm8
                    ALUOP    <= "00";    -- ADD
                    ResWrEn  <= '1';
                    
                    case instr_courante is
                        when LDR =>
                            curr_state <= E9;
                        when STR =>
                            curr_state <= E12;
                        when ADDI => 
                            curr_state <= E13;
                        when others => 
                            curr_state <= E1;
                    end case;

                when E6 =>  -- ADDR → ALU_out ← A + B
                    ALUSelA  <= '0';
                    ALUSelB  <= "00";
                    ALUOP    <= "00";
                    ResWrEn  <= '1';

                    curr_state <= E13;

                when E7 =>  -- MOV → ALU_out ← Imm8
                    ALUSelA  <= '0';     -- not used
                    ALUSelB  <= "01";
                    ALUOP    <= "01";    -- B
                    ResWrEn  <= '1';

                    curr_state <= E13;

                when E8 =>  -- CMP → flags ← A - Imm8
                    ALUSelA  <= '0';
                    ALUSelB  <= "01";
                    ALUOP    <= "10";    -- SUB
                    -- Flags N/Z will be set by ALU, no extra enables
                    
                    curr_state <= E1;

                when E9 =>  -- LDR → DR ← Mem[ALU_out]
                    AdrSel   <= '1';
                    MemRdEn <= '1';

                    curr_state <= E10;

                when E10 => -- NOPLoad
                    -- No control signals activated (pure wait)
                    curr_state <= E11;

                when E11 => -- LDR writeback
                    RegWrEn <= '1';
                    WSel    <= '0';     -- DR
                    
                    curr_state <= E1;

                when E12 => -- STR → Mem[ALU_out] ← RegB
                    AdrSel  <= '1';
                    MemWrEn <= '1';
                    
                    curr_state <= E1;

                when E13 => -- ADDI writeback
                    RegWrEn <= '1';
                    WSel    <= '1';     -- ALU_out
                    
                    curr_state <= E1;

                when E15 =>
                    -- PC ← PC + 1, because BLT was false (skip)
                    PCWrEn   <= '1';
                    PCSel    <= "00";    -- ALU_out
                    ALUSelA  <= '1';     -- Select PC
                    ALUSelB  <= "11";    -- Constant 1
                    ALUOP    <= "00";    -- ADD
                    ResWrEn  <= '0';

                    curr_state <= E1;


                when E16 => -- IRQ prepare: SPSR ← CPSR, LR ← PC
                    SPSRWrEn <= '1';
                    LRWrEn   <= '1';

                    curr_state <= E17;

                when E17 => -- IRQ entry: PC ← VIC, isr <= 1
                    PCWrEn   <= '1';
                    PCSel    <= "11";    -- VIC

                    isr <= '1';

                    curr_state <= E1;

                when E18 => -- ISR return: PC ← LR, CPSR ← SPSR, isr <= 0
                    PCWrEn    <= '1';
                    PCSel     <= "10";   -- LR
                    CPSRSel   <= '1';    -- SPSR
                    CPSRWrEn  <= '1';

                    isr <= '0';
                    IRQServ <= '1';

                    curr_state <= E1;

                when others =>
                    null;
            end case;
        end if;
    end process;

					
				
    
    
end Behavioral;