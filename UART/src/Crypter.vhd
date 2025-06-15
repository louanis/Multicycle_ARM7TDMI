-- CRYPTER.vhd
-- ----------------------------------------------------
--   Communication & "Scrambling" Engine
-- ----------------------------------------------------

LIBRARY ieee;
  USE ieee.std_logic_1164.ALL;
  USE ieee.numeric_std.ALL;


-- ----------------------------------------------------
    Entity CRYPTER is
-- ----------------------------------------------------
      Port (     Clk : In  std_logic;
                 Rst1 : In  std_logic;
             Encrypt : in  std_logic;                    -- '1'=Encrypt, '0'=Decrypt
                 RTS : In  std_logic;                    -- from UARTS
               RxRDY : In  std_logic;                    -- from UARTS
                SDin : In  std_logic_vector (7 downto 0);-- from UARTS

              TxBusy : In  std_logic;                    -- from UARTS
            LD_SDout : Out std_logic;                    -- to UARTS
               SDout : Out std_logic_vector (7 downto 0);-- to UARTS
              Failed : out std_logic                     -- indicates an overflow failure
            );
end entity CRYPTER;


-- ----------------------------------------------------
    Architecture RTL of CRYPTER is
-- ----------------------------------------------------
signal s_fifo_dout,s_crypt_dout : std_logic_vector(63 downto 0);
signal s_dout_valid,s_din_valid,s_fifordy,ena_decomp : std_logic;
signal s_finished : std_logic := '0';
signal decomp_rst,rst : std_logic;

signal s_rdy_falling_edge : std_logic;
signal s_rx_rdy_prev : std_logic := '0';

begin

    rst <= not rst1;

    process(clk)
    begin
        if rising_edge(clk) then
            -- Check for falling edge of RxRDY
            if RxRDY = '0' and s_rx_rdy_prev = '1' then
                s_rdy_falling_edge <= '1';  -- Falling edge detected
            else
                s_rdy_falling_edge <= '0';  -- No falling edge
            end if;

            -- Store the current state of RxRDY for the next clock cycle
            s_rx_rdy_prev <= RxRDY;
        end if;
    end process;

    inst_fifo: entity work.fifo8x64(RTL) port map(
        Clk => clk,
        Reset => rst,
        Din => SDin,
        RDY => s_rdy_falling_edge, -- Connect falling edge signal to RDY
        Dout => s_fifo_dout,
        FifoRDY => s_fifordy
    );

    inst_DES_small: entity work.DES_small(arch_des_small) port map(
        clk => clk,
        reset => rst,
        encrypt => encrypt,
        key_in => (others => '0'),
        din => s_fifo_dout,
        din_valid => s_fifordy,
        dout => s_crypt_dout,
        dout_valid => s_dout_valid
    );

    decomp_rst <= rst or s_finished;
    ena_decomp <= s_dout_valid and (not s_finished);

    inst_decomp: entity work.decomp64x8(RTL) port map(
        Clk => clk,
        Reset => decomp_rst,
        Din => s_crypt_dout,
        TxBusy => TxBusy,
        Ena => ena_decomp,
        Dout => SDout,
        Ld => LD_SDout,
        Finished => s_finished
    );

end RTL;

