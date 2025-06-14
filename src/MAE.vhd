library ieee;
use ieee.std_logic_1164.all;

entity MAE is 
    port(
        clk, rst                    : in std_logic;
        IRQ                         : in std_logic;
        inst_memory                 : in std_logic_vector(31 downto 0);
        inst_register               : in std_logic_vector(31 downto 0);
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

  type enum_instruction is (MOV, ADDi, ADDr, CMP, LDR, STR, BAL, BLT, BX);
  type state is (E1, E2, E3, E4, E5, E6, E7, E8, E9, E10, E11, E12, E13, E15, E16, E17, E18);
    
  signal instr_courante           : enum_instruction;
  signal Epresent, Efutur : state;
  signal isr                      : std_logic;

  begin
    
        
    
    process(inst_memory)
    begin
        if inst_memory(27 downto 26) = "00" then -- (ADD, MOV, CMP)
          
            if inst_memory(24 downto 21) = "0100" then -- ADD

                if inst_memory(25) = '1' then    -- ADD (Immediate)

                    instr_courante <= ADDi;

                else 	-- ADD (register)

                    instr_courante <= ADDr;

                end if;
           
            elsif inst_memory(24 downto 21) = "1101" then -- MOV
            
                instr_courante <= MOV;
          
            else  -- CMP
            
                instr_courante <= CMP;
            
            end if;
          
        elsif inst_memory(27 downto 26) = "01" then -- (LDR, STR)
          
            if inst_memory(20) = '1' then  -- LDR

                instr_courante <= LDR;

            else  -- STR

                instr_courante <= STR;

            end if;
            
        else  -- (BAL, BLT, BX)
          
            if inst_memory(31 downto 28) = "1110" then  -- (BAL, BX)

                if inst_memory(24) = '0' then  -- BAL

                    instr_courante <= BAL;

                else                        -- BX

                    instr_courante <= BX;

                end if;

            else   -- BLT

                instr_courante <= BLT;

            end if;
          
        end if;
        
    end process;
    
    
    process(clk, rst)
    begin
        if rst = '1' then
            -- reset logic here (e.g., state <= E0)
        elsif rising_edge(clk) then

            -- assume all signals are already set to '0' at the top of the process

            case state is
                when E1 =>  -- Load IR from memory
                    IRWrEn   <= '1';         -- Write to IR
                    MemRdEn  <= '1';         -- Enable memory read
                    PCWrEn   <= '0';         -- Do not write to PC
                    PCSel    <= "00";        -- Address memory using the PC (Program Counter)
                    AdrSel   <= '0';         -- Use PC address to access memory

                    state <= E1;

                when E2 =>  -- Load IR
                    IRWrEn   <= '1';
                    MemRdEn  <= '1';
            
                    IRQServ <= '0';

                    if IRQ = '1' then
                        state <= E16;
                    elsif isr = '1' then
                        state <= E18;
                    else
                        case instruction_courante is
                            when BLT =>
                                if CPSR(31) = '1' then
                                    state <=  E4;
                                else
                                    state <= E15;
                                end if;
                            when BAL =>
                                state <=  E4;
                            when BX =>
                                state <= E18;
                            when LDR =>
                                state <= E3;
                            when STR =>
                                state <= E3;
                            when ADD =>
                                state <= E3;
                            when ADDI => 
                                state <= E3;
                            when CMP =>
                                state <= E3;
                            when MOVE =>
                                state <= E3;
                            others => null
                        end case;
                    end if;

                when E3 =>  -- PC ← PC+1, A ← Reg[Rn], B ← Reg[Rm]
                    PCWrEn   <= '1';
                    PCSel    <= "00";    -- ALU_out (PC + 1)
                    ALUSelA  <= '1';     -- Select PC
                    ALUSelB  <= "11";    -- Select 1
                    ALUOP    <= "00";    -- ADD
                    ResWrEn  <= '1';

                    
                    case instruction_courante is
                        when LDR =>
                            state <= E5;
                        when STR =>
                            state <= E5;
                        when ADD =>
                            state <= E6;
                        when ADDI => 
                            state <= E5;
                        when CMP =>
                            state <= E8;
                        when MOVE =>
                            state <= E7;
                        others => null
                    end case;

                when E4 =>  -- BAL / BLT true
                    PCWrEn   <= '1';
                    PCSel    <= "00";    -- ALU_out
                    ALUSelA  <= '1';     -- PC
                    ALUSelB  <= "10";    -- Imm24
                    ALUOP    <= "00";    -- ADD

                    state <= E1;    

                when E5 =>  -- STR, LDR, ADDI → ALU_out ← A + Imm8
                    ALUSelA  <= '0';     -- RegA
                    ALUSelB  <= "01";    -- Imm8
                    ALUOP    <= "00";    -- ADD
                    ResWrEn  <= '1';
                    
                    case instruction_courante is
                        when LDR =>
                            state <= E9;
                        when STR =>
                            state <= E12;
                        when ADDI => 
                            state <= E13;
                        others => null
                    end case;

                when E6 =>  -- ADD → ALU_out ← A + B
                    ALUSelA  <= '0';
                    ALUSelB  <= "00";
                    ALUOP    <= "00";
                    ResWrEn  <= '1';

                    state <= E13;

                when E7 =>  -- MOV → ALU_out ← Imm8
                    ALUSelA  <= '0';     -- not used
                    ALUSelB  <= "01";
                    ALUOP    <= "01";    -- B
                    ResWrEn  <= '1';

                    state <= E13;

                when E8 =>  -- CMP → flags ← A - Imm8
                    ALUSelA  <= '0';
                    ALUSelB  <= "01";
                    ALUOP    <= "10";    -- SUB
                    -- Flags N/Z will be set by ALU, no extra enables
                    
                    state <= E1;

                when E9 =>  -- LDR → DR ← Mem[ALU_out]
                    AdrSel   <= '1';
                    MemRdEn <= '1';

                    state <= E10;

                when E10 => -- NOPLoad
                    -- No control signals activated (pure wait)
                    state <= E11;

                when E11 => -- LDR writeback
                    RegWrEn <= '1';
                    WSel    <= '0';     -- DR
                    
                    state <= E1;

                when E12 => -- STR → Mem[ALU_out] ← RegB
                    AdrSel  <= '1';
                    MemWrEn <= '1';
                    
                    state <= E1;

                when E13 => -- ADDI writeback
                    RegWrEn <= '1';
                    WSel    <= '1';     -- ALU_out
                    
                    state <= E1;

                when E15 =>  -- BLT (false): PC ← PC + 1
                    PCWrEn   <= '1';
                    PCSel    <= "00";    -- ALU_out
                    ALUSelA  <= '1';     -- PC
                    ALUSelB  <= "11";    -- constant 1
                    ALUOP    <= "00";    -- ADD
                    ResWrEn  <= '1';

                    state <= E1;

                when E16 => -- IRQ prepare: SPSR ← CPSR, LR ← PC
                    SPSRWrEn <= '1';
                    LRWrEn   <= '1';

                    state <= E17;

                when E17 => -- IRQ entry: PC ← VIC, isr <= 1
                    PCWrEn   <= '1';
                    PCSel    <= "11";    -- VIC
                    IRQ_serv <= '1';

                    isr <= '1';

                    state <= E1;

                when E18 => -- ISR return: PC ← LR, CPSR ← SPSR, isr <= 0
                    PCWrEn    <= '1';
                    PCSel     <= "10";   -- LR
                    CPSRSel   <= '1';    -- SPSR
                    CPSRWrEn  <= '1';
                    IRQ_serv  <= '0';

                    ISR <= '0';
                    irqserv <= '1';

                    state <= E1;

                when others =>
                    -- default or idle
            end case;
        end if;
    end process;

					
				
    
    
end Behavioral;