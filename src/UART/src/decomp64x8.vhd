LIBRARY ieee;
  USE ieee.std_logic_1164.ALL;
  USE ieee.numeric_std.ALL;



entity decomp64x8 is
    port (
        Clk          : in std_logic;
        Reset        : in std_logic;
        Din          : in std_logic_vector (63 downto 0);
        TxBusy       : in std_logic;
        Ena          : in std_logic;
        Dout         : out std_logic_vector (7 downto 0);
        Ld           : out std_logic;
        Finished     : out std_logic -- correspond a quand on fini les 8mots de 8bit genre quand on a transmi a l'uart le mot de 64 au complet bout a bout
    );
end decomp64x8;

-- je vais refaire le truc avec un selectionneur indicateur de remplissage


architecture RTL of decomp64x8 is
    signal partie : integer := 0;
    signal tx_busy_front_des, prec_tx_busy : std_logic;
    begin
    process(clk,reset)
    begin
        if reset = '1' then
            partie <= 0;
            Dout <= (others => '0');
            Ld <= '0';
            Finished <= '0';
            tx_busy_front_des <= '0';
        elsif rising_edge(clk) then
            Ld <= not TxBusy;
            prec_tx_busy <= TxBusy;
            if TxBusy = '0' and prec_tx_busy = '1' then
                tx_busy_front_des <= '1';
            else
                tx_busy_front_des <= '0';
            end if;

            if Ena = '1' then
                if tx_busy_front_des = '1' then
                    Dout <= Din(partie+7 downto partie);
                    partie <= partie + 8;
                end if;
            end if;

            if partie = 56 then
                Finished <= '1';
                partie <= 0;
            end if;
        end if;
    end process;
end RTL;