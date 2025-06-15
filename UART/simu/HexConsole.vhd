-- HexConsole.vhd
-- ------------------------------------------------------
--  Serial Terminal Emulator with Hex File input
-- ------------------------------------------------------

--
-- Reads in bytes sequentially from the Intel-Hex file which
-- filename is passed as a generic parameter, and sends
-- them over the RS232 line.
-- When the end of file is reached, the ENDF signal is raised.
-- Note : the Serial Output is name "Rx" (it is to be
-- connected to the Rx input of UARTS) !
--
-- Intel-Hex format parsed is :
--    :nnAAAAttdd...ddCC where nn = Nb of data bytes, AAAA=Address, d...d=Data, CC=checksum
--    123456789
--    Note that checksum CC is simply ignored (can be omitted)
--    Address AAAA is ignored too
--    Type tt must be 00 (data record)
--    Other records are simply ignored

  use std.textio.all;
LIBRARY ieee;
  USE ieee.std_logic_1164.ALL;
  USE ieee.numeric_std.all;
  USE ieee.std_logic_textio.ALL;

-- ----------------------------------------------------
    Entity HexConsole is
-- ----------------------------------------------------
    Generic ( BaudRate : integer range 1200 to 460800;
              filename : string  := "test.hex";
              Parity   : boolean := false;
              Even     : boolean := false
            );
    Port    ( RX  : out std_logic;        -- Serial output
              CTS : in  std_logic := '1'; -- if CTS='0', we stop sending
              ENDF: out boolean);
end entity HexConsole;

-- ----------------------------------------------------
    Architecture behavioral of HexConsole is
-- ----------------------------------------------------

  constant BITPERIOD : time := 1E9 ns / BaudRate;
  constant NDbits    : positive := 8;  -- Nb of DATA bits. Do not modify.

  signal RSData : std_logic_vector (7 downto 0);
  file   F      : text;

begin

  process
    variable ParityBit : std_logic;
    variable L   : line;
    variable c   : character;
    variable ok  : boolean;
    variable k   : integer := 0;
    variable Nb  : natural;
    variable H16 : std_logic_vector(15 downto 0);
    variable H8  : std_logic_vector(7 downto 0);
  begin

    ENDF <= FALSE;
    RX <= '1';          -- Idle at startup

    File_open (F, filename, read_mode);

    wait for BITPeriod * 1.6; -- Startup delay

Ext:
    while not ENDFILE(F) loop

      readline (F,L);
      -- interpret the data line
      if L'length < 10 then next Ext; end if;    -- ignore too short lines
      if L(1)/= ':' then  next Ext; end if;      -- ignore non intel-hex lines
      if L(8 to 9)/="00" then  next Ext; end if; -- ignore non data lines
      read (L,c);                                -- get rid of :
      hread (L,H8);
      Nb := to_integer(unsigned(H8));
      report "Nb chars = "&integer'image(Nb);
      hread (L,H16);  -- skip the Address
      hread (L,H8);   -- Skip the type
      while Nb > 0 loop
          -- read the byte
          hread (L,H8);
          Nb := Nb -1;

          -- do not send if outside says busy (RTS=0)
          if CTS='0' then       -- remember : "wait until" is edge sensitive...
            wait until CTS='1';
          end if;

          -- Convert to std_logic_vector :
          RSdata <= H8;

          -- Serialize the character
          RX <= '0';     -- Start bit
          ParityBit := '0';
          wait for BITperiod;

          for i in 0 to NDbits-1 loop -- Data bits
            ParityBit := ParityBit xor RSData(i);
            RX <= RSData(i); wait for BITperiod;
          end loop;

          if Parity then  -- Parity bit if necessary
            if not Even then
              ParityBit := not ParityBit;
            end if;
            RX <= ParityBit; wait for BITperiod;
          end if;

          RX <= '1';     -- 3 x Stop bits
          wait for BITperiod * 3;
      end loop;
    end loop;

    file_close (f);

    -- Make sure all has been sent and handled (even echoed).
    wait for (24 * BITperiod);
    ENDF <= TRUE;
    report "End of Simulation";
    wait;  -- Kill this process

  end process;

end behavioral;
