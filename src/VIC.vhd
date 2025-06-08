library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity VIC is
    port (
        CLK      : in  std_logic;
        RESET    : in  std_logic;
        IRQ0     : in  std_logic;
        IRQ1     : in  std_logic;
        IRQ_SERV : in  std_logic;  -- Acknowledgment from the MAE
        IRQ      : out std_logic;
        VICPC    : out std_logic_vector(31 downto 0)
    );
end entity VIC;

architecture Behavioral of VIC is

    signal IRQ0_prev  : std_logic := '0';
    signal IRQ1_prev  : std_logic := '0';
    signal IRQ0_memo  : std_logic := '0';
    signal IRQ1_memo  : std_logic := '0';

begin

    -- Rising edge detection and memo handling
    process(CLK, RESET)
    begin
        if RESET = '1' then
            IRQ0_prev <= '0';
            IRQ1_prev <= '0';
            IRQ0_memo <= '0';
            IRQ1_memo <= '0';
        elsif rising_edge(CLK) then
            -- Detect rising edge for IRQ0
            if IRQ0 = '1' and IRQ0_prev = '0' then
                IRQ0_memo <= '1';
            end if;
            -- Detect rising edge for IRQ1
            if IRQ1 = '1' and IRQ1_prev = '0' then
                IRQ1_memo <= '1';
            end if;

            -- Clear memos on IRQ_SERV
            if IRQ_SERV = '1' then
                IRQ0_memo <= '0';
                IRQ1_memo <= '0';
            end if;

            -- Update previous IRQs
            IRQ0_prev <= IRQ0;
            IRQ1_prev <= IRQ1;
        end if;
    end process;

    -- IRQ is high if either memo is active
    IRQ <= IRQ0_memo or IRQ1_memo;

    -- Address output based on priority (IRQ0 > IRQ1)
    process(IRQ0_memo, IRQ1_memo)
    begin
        if IRQ0_memo = '1' then
            VICPC <= x"00000009";  -- Address for IRQ0
        elsif IRQ1_memo = '1' then
            VICPC <= x"00000015";  -- Address for IRQ1
        else
            VICPC <= (others => '0');
        end if;
    end process;

end architecture Behavioral;
