library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity instruction_unit is
    port(
        clk       : in std_logic;
        rst       : in std_logic;
        Offset    : in std_logic_vector(23 downto 0);
        nPCsel    : in std_logic;
        Instr     : out std_logic_vector(31 downto 0)
    );
end instruction_unit;


architecture RTL of instruction_unit is
    signal PC : std_logic_vector(31 downto 0) := (others => '0');
    signal PC_next : std_logic_vector(31 downto 0);
begin

    extend: entity work.Extend(Behavioral)
    generic map(
        N => 24
    )
    port map(
        E => Offset,
        S => PC_next
    );

    inst_mem: entity work.instruction_memory(RTL)
    port map(
        PC => PC,
        Instruction => Instr
    );

    
    process(clk, rst)
    begin
        -- Asynchronous reset
        if rst = '1' then
            PC <= (others => '0');
        -- If CLK is on rising edge
        elsif rising_edge(clk) then
            if nPCsel = '1' then
                PC <= std_logic_vector(signed(PC) + 1 + signed(PC_next));  -- Correct: PC + offset
            else
                PC <= std_logic_vector(signed(PC) + 1);                 -- Normal increment
            end if;
        end if;
    end process;


end rtl;