-- DE_top_tb.vhd
-- ---------------------------------------------
--    VHDL Test Bench for UART Top_Level
-- ---------------------------------------------

-- Compile in '93
--
-- Note that we've put the Constants in the entity section.
-- You must match the BaudRate here with the UARTS combination
-- of Baud1/Baud2 (in TOP_UART) and DIPSWitch position (here).
-- Xtal freq and parity settings are passed all the way down
-- the hierarchy, automatically.
--
-- During the simulation, you don't really need the waveform :
-- the activity is logged in the transcript : character echoed
-- by the system are "received" in this testbench and written
-- in the simulation transcript.

  USE std.textio.all;
LIBRARY ieee;
  USE ieee.std_logic_1164.ALL;
  USE ieee.numeric_std.ALL;
  USE ieee.std_logic_textio.ALL;

-- ---------------------------------------------
    Entity DE_top_tb is
-- ---------------------------------------------
-- Enter HERE all the parameters :
  constant Fxtal    : integer  := 50E6; 
  constant Baudrate : positive := 9600;
end;

-- ---------------------------------------------
    Architecture TEST of DE_top_tb is
-- ---------------------------------------------

  constant Period    : time := 1 sec / Fxtal;  -- System Clock
  constant BITPeriod : time := 1 sec / BaudRate;
  constant Parity    : boolean := false;
  constant Even      : boolean := false;

  signal  Clk : std_logic := '0';
  signal nRST : std_logic;
  signal   RX : std_logic;
  signal   TX : std_logic;
  signal ENDF : boolean;
  signal SW   : STD_LOGIC_VECTOR(9 DOWNTO 0);
  signal KEY  : STD_LOGIC_VECTOR(2 DOWNTO 0);

begin

  -- --------------------------
  --  UUT Instanciation
  -- --------------------------
  UUT : entity work.DE_top
     Port Map ( CLOCK_50       => Clk,
                KEY   	=> KEY,
				SW    	=> SW ,
                UART_RXD => RX,
                UART_TXD => TX );
				
	KEY(0) <= nRST;

  -- -----------------------------
  --  Clock, Reset
  -- -----------------------------

  nRST <= '0', '1' after Period;
  Clk <= '0' when ENDF else not Clk after Period / 2;

  -- --------------------------
  --  Console
  -- --------------------------

  -- generic "filename" could be set by a configuration section at tb_top
  i_CONSOLE : entity work.HEXCONSOLE
   Generic Map ( BaudRate => BaudRate,
                 filename => "test.hex" )
    Port Map   ( RX       => RX,
                 CTS      => open,
                 ENDF     => ENDF    );

  assert NOT ENDF  -- note : this is a concurrent assertion
    report "End of Simulation (not a failure)." severity Failure;

  -- -----------------------------
  --  Serial Receive (behavioral)
  -- -----------------------------

  process
    variable L   : line;
    variable MOT : std_logic_vector (7 downto 0);
    variable ParityBit : std_logic;
  begin

    loop
      ParityBit := '0';

      wait until TX = '0';         -- get falling edge

      wait for (0.5 * BITperiod);  -- Middle of Start bit
      assert TX = '0'
        report "Error during Start Bit ???" severity warning;

      wait for BITperiod;          -- First Data Bit
      for i in 0 to 7 loop         -- Get word
        MOT(i) := TX;
        ParityBit := ParityBit xor TX;
        wait for BITperiod;
      end loop;

      if Parity then
        if not Even then
          ParityBit := not ParityBit;
        end if;
        if ParityBit /= TX then
          report "Error during Parity Bit" severity warning;
        end if;
        wait for BITperiod;
      end if;

      wait for BITperiod;         -- Stop bit
      assert TX = '1'
        report "Error during Stop bit ???" severity warning;

      write  (L,string'("Character received (hex) = "));
      hwrite (L,MOT);             -- trace
      write  (L,string'(" - '" & character'val(to_integer(unsigned(MOT))) & "'" ));
      writeline (output,L);       -- write to simulation transcript
    end loop;
  end process;

end TEST;
