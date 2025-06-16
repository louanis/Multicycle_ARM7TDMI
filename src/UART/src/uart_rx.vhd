library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.all;


entity UART_RX is
    Generic ( Fxtal   : integer  := 50e6;  -- in Hertz
            Parity  : boolean  := false;
            Even    : boolean  := false
          );
    port (
        Clk          : in std_logic;
        Reset        : in std_logic;
        Rx           : in std_logic;
        Tick_halfbit : in std_logic;
        Clear_fdiv   : out std_logic;
        Err          : out std_logic;
        Data         : out std_logic_vector(7 downto 0);
        RxRDY        : out std_logic
    );
end UART_RX;

architecture RTL of UART_RX is
    signal s_Data : std_logic_vector(8 downto 0);
    signal bit_compt : integer;
    signal busy, parite_bit : std_logic;
begin
    process(clk,reset)
    begin 
        if reset = '1' then

            bit_compt <= 0;
            Data <=  "00000000";
            Err <= '0';
            Clear_fdiv <= '0';
            busy <= '0';
            rxrdy <= '1';
            parite_bit <= '0';

        elsif rising_edge(clk) then
            clear_fdiv <= '0';

            if rx = '0' then
                if busy = '0' then
                    busy <= '1';
                    clear_fdiv <= '1';
                    rxrdy <= '0';
                    bit_compt <= 0;
                end if;
            end if;

            if busy = '1' and Tick_halfbit = '1' then
                if bit_compt = 10 then
                    busy <= '0';
                    bit_compt <= 0;
                    rxrdy <= '1';
                    Data <= s_data(8 downto 1);
                end if;
                if bit_compt < 9 then
                    s_Data(bit_compt) <= rx;
                    bit_compt <= bit_compt + 1;
                    parite_bit <= parite_bit xor rx;
                else
                    busy <= '1';
                    err <= '0';
                    if parity = true then
                        if even = true then
                            err <= ( not parite_bit) xor rx;
                        else
                            err <= ( parite_bit) xor rx;
                        end if;
                        bit_compt <= bit_compt + 1;
                    else
                    -- PARTIE SANS PARITE
                        if rx = '0' then
                            err <= '1';
                        end if;
                        busy <= '0';
                        rxrdy <= '1';
                        Data <= s_data(8 downto 1);
                        bit_compt <= 0;
                    -- FIN PARTIE SANS PARITE
                    end if;
                end if;
            end if;


        end if;
    end process;

end RTL;