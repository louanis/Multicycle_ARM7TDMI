library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Decoder is
    port(
        instruction : in std_logic_vector(31 downto 0);
        regpsrin    : in std_logic_vector(1 downto 0);
        psren       : out std_logic;
        WrSrc       : out std_logic;
        ALUCtr      : out std_logic_vector(1 downto 0);
        RegAff      : out std_logic;
        ALUsrc      : out std_logic;
        RegSel      : out std_logic;
        RegWr       : out std_logic;
        nPCSel      : out std_logic;
        MemWr       : out std_logic


    );
end Decoder;



architecture Behavioral of Decoder is

    type enum_instruction is (MOV, ADDi, ADDr, CMP, LDR, STR, BAL, BLT); 
    signal instr_courante: enum_instruction;

    begin

    process(instruction, regpsrin)
    begin
            instr_courante <= MOV;
            case instruction(31 downto 24) is
                when "11101010" => instr_courante <= BAL;
                when "10111010" => instr_courante <= BLT;
                when others =>
                    case instruction(31 downto 20) is
                        when "111000101000" => instr_courante <= ADDi;
                        when "111000001000" => instr_courante <= ADDr;
                        when "111000110101" => instr_courante <= CMP;
                        when "111000010101" => instr_courante <= CMP;
                        when "111001100001" => instr_courante <= LDR;
                        when "111000111010" => instr_courante <= MOV;
                        when "111001100000" => instr_courante <= STR;
                        when others => instr_courante <= MOV;
                    end case;
            end case;
    end process;

    process(instr_courante, regpsrin)
    begin
        -- Default values for outputs
        nPCSel <= '0';
        RegWr  <= '0';
        ALUSrc <= '0';
        ALUCtr <= "00";
        psren  <= '0';
        MemWr  <= '0';
        WrSrc  <= '0';
        RegSel <= '0';
        RegAff <= '0';

        case instr_courante is
            when BAL =>
                nPCSel <= '1';

            when BLT =>
                if regpsrin(0) = '1' then
                    nPCSel <= '1';
                    psren  <= '1';
                end if;

            when MOV =>
                RegWr  <= '1';
                ALUSrc <= '1';
                ALUCtr <= "01";
                RegSel <= '1';

            when ADDi =>
                RegWr  <= '1';
                ALUSrc <= '1';
                ALUCtr <= "00";

            when ADDr =>
                RegWr  <= '1';
                ALUCtr <= "00";

            when LDR =>
                RegWr  <= '1';
                ALUSrc <= '1';
                ALUCtr <= "00";
                WrSrc  <= '1';

            when STR =>
                MemWr  <= '1';
                RegSel <= '1';
                RegAff <= '1';

           when CMP =>
                ALUCtr <= "10";  -- Subtract/compare operation
                psren  <= '1';   -- Enable PSR update
                alusrc <= instruction(25);
            when others =>
                -- already defaulted above
                null;
        end case;
    end process;

end Behavioral;