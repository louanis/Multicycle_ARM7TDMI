library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.all;


entity UART_TX is
    Generic ( Fxtal   : integer  := 50e6;  -- in Hertz
            Parity  : boolean  := false;
            Even    : boolean  := false
          );
    port (
        Clk   : in std_logic;
        Reset : in std_logic;
        Go    : in std_logic;
        Data  : in std_logic_vector(7 downto 0);
        Tick  : in std_logic;
        Tx    : out std_logic;
        Busy  : out std_logic
    );
end entity;

architecture RTL of UART_TX is
    signal bit_compt : integer := 0;
    signal s_busy, parite_bit : std_logic;
    signal front_go, prec_go  : std_logic;

begin
    process(clk,reset)
    begin 
        if reset = '1' then
            bit_compt <= 0;
            s_busy <= '0';
            front_go <= '0';
            prec_go <= '0';
            tx <= '1'; -- on passe la sortie en idle
            parite_bit <= '0';

        elsif rising_edge(clk) then

            


            if tick = '1' then


                prec_go <= go;
                front_go <= '0';

                if prec_go = '0' then
                    if go = '1' then
                        front_go <= '1';
                    end if;
                end if;

                
                if front_Go = '1' then -- de base j'avais une detection de front mais pour les test bench il en faut pas a priori (?)
                    if s_busy = '0' then
                        s_busy <= '1';
                        tx <= '0';
                    end if; 
                end if;

                if s_busy = '1' then -- je teste busy et pas go car je ne sais pas si go reste '1' tant qu'on emmet
                    if bit_compt < 8 then
                        tx <= Data(bit_compt);
                        parite_bit <= parite_bit xor Data(bit_compt);
                    end if;
                    bit_compt <= bit_compt + 1;
                    if bit_compt = 8 then
                        if parity = false then
                            tx <= '1';
                            bit_compt <= 0;
                            s_busy <= '0';

                            -- PARTIE AVEC PARITE
                        else
                            if even = true then
                                tx <= not parite_bit;
                            else
                                tx <= parite_bit;
                            end if;
                        end if;
                    elsif bit_compt = 9 then
                        tx <= '1';
                        bit_compt <= 0;
                        s_busy <= '0';
                    end if;
                    -- FIN PARTIE AVEC PARITE
                end if;

            end if;
        end if;
        Busy <= s_Busy;

    end process;

end architecture;