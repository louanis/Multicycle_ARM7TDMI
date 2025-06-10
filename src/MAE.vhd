library ieee;
use ieee.std_logic_1164.all;

Entity MAE is Port(
  clk, rst                    : in std_logic;
  IRQ                         : in std_logic;
  inst_memory                    : in std_logic_vector(31 downto 0);
  inst_register                    : in std_logic_vector(31 downto 0);
  N                           : in std_logic;
  IRQServ                     : out std_logic;
  PCSel                       : out std_logic_vector(1 downto 0);
  PCWrEn, LRWrEn              : out std_logic;
  AdrSel, MemRden, MemWrEn    : out std_logic;
  IRWrEn, WSel, RegWrEn       : out std_logic;
  ALUSelA                     : out std_logic;
  ALUSelB, ALUOP              : out std_logic_vector(1 downto 0);
  CPSRSel, CPSRWrEn, SPSRWrEn : out std_logic;
  ResWrEn                     : out std_logic);
end entity;

Architecture Behavioral of MAE is 

  type enum_instruction is (MOV, ADDi, ADDr, CMP, LDR, STR, BAL, BLT, BX);
  type state is (E_1, E_2, E_3, E_4, E_5, E_6, E_7, E_8, E_9, E_20, E_21, E_22, E_23, E_24, E_25, E_26, E_27, E_28);
    
  signal instr_courante           : enum_instruction;
  signal E_present, E_futur : state;
  signal isr                      : std_logic;

  begin
    
    process(clk, rst)
    begin
        
        if(rst = '1') then
        
            E_present <= E_1;
          
        elsif rising_edge(clk) then
          
            E_present <= E_futur;
          
        end if;
          
    end process;
        
    
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
    
    
    process(E_present, instr_courante, isr, IRQ, N)
    begin
        
        case E_present is 
          
        when E_1 => 
            IRQServ <= '0';
	    	    PCSel <= "--";
            PCWrEn <= '0';
            LRWrEn <= '0';
            AdrSel <= '0';
            MemRdEn <= '1';
            MemWrEn <= '0';
            IRWrEn <= '1';
	    	    WSel <= '-';
            RegWrEn <= '0';
	    	    ALUSelA <= '-';
            ALUSelB <= "--";
	    	    ALUOp <= "--";
	    	    CPSRSel <= '-';
            CPSRWrEn <= '0';
            SPSRWrEn <= '0';
            ResWrEn <= '0';

            E_futur <= E_2;
          
          
        when E_2 =>
            IRQServ <= '0';
	    	    PCSel <= "--";
            PCWrEn <= '0';
            LRWrEn <= '0';
            AdrSel <= '-';
            MemRdEn <= '0';
            MemWrEn <= '0';
            IRWrEn <= '1';
	    	    WSel <= '-';
            RegWrEn <= '0';
	    	    ALUSelA <= '-';
            ALUSelB <= "--";
	    	    ALUOp <= "--";
	    	    CPSRSel <= '-';
            CPSRWrEn <= '0';
            SPSRWrEn <= '0';
            ResWrEn <= '0';
          
            if IRQ = '1' and isr = '0' then
                E_futur <= E_27;
            elsif isr = '1' and instr_courante = BX then
                E_futur <= E_26;
            else
                if((instr_courante = LDR) or (instr_courante = STR) or (instr_courante = ADDr) or (instr_courante = ADDi) or (instr_courante = CMP) or (instr_courante = MOV)) then
                    E_futur <= E_3;
                elsif (instr_courante = BAL) or ((instr_courante = BLT) and (N = '1')) then
                    E_futur <= E_4;
                else
                    E_futur <= E_5;
                end if;
            end if;
          
          
        when E_3 =>
            IRQServ <= '0';
            PCSel <= "00";
            PCWrEn <= '1';
            LRWrEn <= '0';
	    	    AdrSel <= '-';
            MemRdEn <= '0';
            MemWrEn <= '0';
            IRWrEn <= '0';
	    	    WSel <= '-';
            RegWrEn <= '0';
            ALUSelA <= '0';
            ALUSelB <= "11";
            ALUOp <= "00";
	    	    CPSRSel <= '-';
            CPSRWrEn <= '0';
            SPSRWrEn <= '0';
            ResWrEn <= '0';
			
            E_futur <= E_6;
          
          
        when E_4 =>
            IRQServ <= '0';
            PCSel <= "00";
            PCWrEn <= '1';
            LRWrEn <= '0';
	    	    AdrSel <= '0';
            MemRdEn <= '1';
            MemWrEn <= '0';
            IRWrEn <= '0';
	    	    WSel <= '-';
            RegWrEn <= '0';
            ALUSelA <= '0';
            ALUSelB <= "10";
            ALUOp <= "00";
	    	    CPSRSel <= '-';
            CPSRWrEn <= '0';
            SPSRWrEn <= '0';
            ResWrEn <= '0';
                    
            E_futur <= E_1;
          
          
        when E_5 =>
            IRQServ <= '0';
            PCSel <= "00";
            PCWrEn <= '1';
            LRWrEn <= '0';
	    	    AdrSel <= '0';
            MemRdEn <= '1';
            MemWrEn <= '0';
            IRWrEn <= '0';
	    	    WSel <= '-';
            RegWrEn <= '0';
            ALUSelA <= '0';
            ALUSelB <= "11";
            ALUOp <= "00";
	    	    CPSRSel <= '-';
            CPSRWrEn <= '0';
            SPSRWrEn <= '0';
            ResWrEn <= '0';
                    
            E_futur <= E_1;
          
          
        when E_6 =>
            IRQServ <= '0';
	    	    PCSel <= "--";
            PCWrEn <= '0';
            LRWrEn <= '0';
	    	    AdrSel <= '-';
            MemRdEn <= '0';
            MemWrEn <= '0';
            IRWrEn <= '0';
	    	    WSel <= '-';
            RegWrEn <= '0';
	    	    ALUSelA <= '-';
            ALUSelB <= "--";
	    	    ALUOp <= "--";
	    	    CPSRSel <= '-';
            CPSRWrEn <= '0';
            SPSRWrEn <= '0';
            ResWrEn <= '0';
                    
            if ((instr_courante = LDR) or (instr_courante = STR) or (instr_courante = ADDi)) then
                etatfutur <= E_7;
            elsif instr_courante = ADDr then
                etatfutur <= E_8;
            elsif instr_courante = MOV then
                etatfutur <= E_9;
            else
                E_futur <= E_20;
            end if;
          
          
        when E_7 => 
            IRQServ <= '0';
	    	    PCSel <= "--";
            PCWrEn <= '0';
            LRWrEn <= '0';
	    	    AdrSel <= '-';
            MemRdEn <= '0';
            MemWrEn <= '0';
            IRWrEn <= '0';
	    	    WSel <= '-';
            RegWrEn <= '0';
            ALUSelA <= '1';
            ALUSelB <= "01";
            ALUOp <= "00";
	    	    CPSRSel <= '-';
            CPSRWrEn <= '0';
            SPSRWrEn <= '0';
            ResWrEn <= '0';
                
                
            if instr_courante = LDR then
                E_futur <= E_21;
            elsif instr_courante = STR then
                E_futur <= E_22;
            else
                E_futur <= E_23;
            end if;
          
          
        when E_8 =>
            IRQServ <= '0';
	    	    PCSel <= "--";
            PCWrEn <= '0';
            LRWrEn <= '0';
	    	    AdrSel <= '-';
            MemRdEn <= '0';
            MemWrEn <= '0';
            IRWrEn <= '0';
	    	    WSel <= '-';
            RegWrEn <= '0';
            ALUSelA <= '1';
            ALUSelB <= "00";
            ALUOp <= "00";
	    	    CPSRSel <= '-';
            CPSRWrEn <= '0';
            SPSRWrEn <= '0';
            ResWrEn <= '0';
                
            E_futur <= E_23;
          
          
        when E_9 =>
            IRQServ <= '0';
	    	    PCSel <= "--";
            PCWrEn <= '0';
            LRWrEn <= '0';
	    	    AdrSel <= '-';
            MemRdEn <= '0';
            MemWrEn <= '0';
            IRWrEn <= '0';
	    	    WSel <= '-';
            RegWrEn <= '0';
	    	    ALUSelA <= '-';
            ALUSelB <= "01";
            ALUOp <= "01";
	    	    CPSRSel <= '-';
            CPSRWrEn <= '0';
            SPSRWrEn <= '0';
            ResWrEn <= '0';
                
            E_futur <= E_23;
          
          
        when E_20 => 
            IRQServ <= '0';
	    	    PCSel <= "--";
            PCWrEn <= '0';
            LRWrEn <= '0';
	    	    AdrSel <= '0';
            MemRdEn <= '1';
            MemWrEn <= '0';
            IRWrEn <= '0';
	    	    WSel <= '-';
            RegWrEn <= '0';
            ALUSelA <= '1';
            ALUSelB <= "01";
            ALUOp <= "10";
            CPSRSel <= '0';
            CPSRWrEn <= '1';
            SPSRWrEn <= '0';
            ResWrEn <= '0';
                
            E_futur <= E_1;
            
          
        when E_21 =>
            IRQServ <= '0';
	    	    PCSel <= "--";
            PCWrEn <= '0';
            LRWrEn <= '0';
            AdrSel <= '1';
            MemRdEn <= '1';
            MemWrEn <= '0';
            IRWrEn <= '0';
            WSel <= '-';
            RegWrEn <= '0';
	    	    ALUSelA <= '-';
            ALUSelB <= "--";
	    	    ALUOp <= "--";
	    	    CPSRSel <= '-';
            CPSRWrEn <= '0';
            SPSRWrEn <= '0';
            ResWrEn <= '0';
                
            E_futur <= E_24;
          
          
        when E_22 =>
            IRQServ <= '0';
	    	    PCSel <= "--";
            PCWrEn <= '0';
            LRWrEn <= '0';
            AdrSel <= '1';
            MemRdEn <= '0';
            MemWrEn <= '1';
            IRWrEn <= '0';
	    	    WSel <= '-';
            RegWrEn <= '0';
	    	    ALUSelA <= '-';
            ALUSelB <= "--";
	    	    ALUOp <= "--";
	    	    CPSRSel <= '-';
            CPSRWrEn <= '0';
            SPSRWrEn <= '0';
            ResWrEn <= '1';
                
            E_futur <= E_1;
          
          
        when E_23 =>
            IRQServ <= '0';
	    	    PCSel <= "--";
            PCWrEn <= '0';
            LRWrEn <= '0';
	    	    AdrSel <= '0';
            MemRdEn <= '1';
            MemWrEn <= '0';
            IRWrEn <= '0';
            WSel <= '1';
            RegWrEn <= '1';
	    	    ALUSelA <= '-';
            ALUSelB <= "--";
	    	    ALUOp <= "--";
	    	    CPSRSel <= '-';
            CPSRWrEn <= '0';
            SPSRWrEn <= '0';
            ResWrEn <= '0';
                
            E_futur <= E_1;
          
          
        when E_24 =>
            IRQServ <= '0';
	    	    PCSel <= "--";
            PCWrEn <= '0';
            LRWrEn <= '0';
	    	    AdrSel <= '-';
            MemRdEn <= '0';
            MemWrEn <= '0';
            IRWrEn <= '0';
	    	    WSel <= '-';
            RegWrEn <= '0';
	    	    ALUSelA <= '-';
            ALUSelB <= "--";
		       	ALUOp <= "--";
	    	    CPSRSel <= '-';
            CPSRWrEn <= '0';
            SPSRWrEn <= '0';
            ResWrEn <= '0';
                
            E_futur <= E_25;
          
          
        when E_25 =>
            IRQServ <= '0';
	    	    PCSel <= "--";
            PCWrEn <= '0';
            LRWrEn <= '0';
	    	    AdrSel <= '0';
            MemRdEn <= '1';
            MemWrEn <= '0';
            IRWrEn <= '0';
            WSel <= '0';
            RegWrEn <= '1';
	    	    ALUSelA <= '-';
            ALUSelB <= "--";
	    	    ALUOp <= "--";
	    	    CPSRSel <= '-';
            CPSRWrEn <= '0';
            SPSRWrEn <= '0';
            ResWrEn <= '0';
                
            E_futur <= E_1;
          
          
        when E_26 =>
            IRQServ <= '1';
            PCSel <= "10";
            PCWrEn <= '1';
            LRWrEn <= '0';
	    	    AdrSel <= '0';
            MemRdEn <= '1';
            MemWrEn <= '0';
            IRWrEn <= '0';
	    	    WSel <= '-';
            RegWrEn <= '0';
	    	    ALUSelA <= '-';
            ALUSelB <= "--";
	    	    ALUOp <= "--";
            CPSRSel <= '1';
            CPSRWrEn <= '1';
            SPSRWrEn <= '0';
            ResWrEn <= '0';
                
            E_futur <= E_1;
          
          
        when E_27 => 
            IRQServ <= '0';
	    	    PCSel <= "--";
            PCWrEn <= '0';
            LRWrEn <= '1';
	    	    AdrSel <= '-';
            MemRdEn <= '0';
            MemWrEn <= '0';
            IRWrEn <= '0';
	    	    WSel <= '-';
            RegWrEn <= '0';
	    	    ALUSelA <= '-';
            ALUSelB <= "--";
	    	    ALUOp <= "--";
	    	    CPSRSel <= '-';
            CPSRWrEn <= '0';
            SPSRWrEn <= '1';
            ResWrEn <= '0';
                
            E_futur <= E_28;
          
          
        when E_28 =>
            IRQServ <= '0';
            PCSel <= "11";
            PCWrEn <= '1';
            LRWrEn <= '0';
	    	    AdrSel <= '0';
            MemRdEn <= '1';
            MemWrEn <= '0';
            IRWrEn <= '0';
	    	    WSel <= '-';
            RegWrEn <= '0';
	    	    ALUSelA <= '-';
            ALUSelB <= "--";
	    	    ALUOp <= "--";
	    	    CPSRSel <= '-';
            CPSRWrEn <= '0';
            SPSRWrEn <= '0';
            ResWrEn <= '0';
                
            E_futur <= E_1;
            
        end case;
    end process;
		
	process(clk, rst)
	begin
			
		if rst = '1' then
			isr <= '0';
				
		elsif rising_edge(clk) then
				
			if E_present = E_26 then
					isr <= '0';
			elsif E_present = E_28 then
					isr <= '1';
			end if;
		end if;
	end process;
					
				
    
    
end Behavioral;