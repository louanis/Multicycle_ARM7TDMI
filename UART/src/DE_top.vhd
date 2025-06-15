-- DE_top.vhd
-- -----------------------------
--   RS232 Encrypter top level -
-- -----------------------------
--

library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;

-- -----------------------------------------------------------------
    Entity DE_top is
-- -----------------------------------------------------------------
  port (CLOCK_50 	:  IN  STD_LOGIC;
		UART_TXD  :  OUT  STD_LOGIC;
		UART_RXD  :  IN STD_LOGIC;
		GPIO_0    :  OUT STD_LOGIC_VECTOR(3 downto 0);
		GPIO_1    :  IN STD_LOGIC_VECTOR(3 downto 0);
		KEY			 	:  IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
		SW 				:  IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
		HEX0 			:  OUT  STD_LOGIC_VECTOR(0 TO 6);
		HEX1 			:  OUT  STD_LOGIC_VECTOR(0 TO 6);
		HEX2 			:  OUT  STD_LOGIC_VECTOR(0 TO 6);
		HEX3 			:  OUT  STD_LOGIC_VECTOR(0 TO 6)     
           );
end entity ;

-- -----------------------------------------------------------------
    Architecture RTL of DE_top is
-- -----------------------------------------------------------------

  signal rst,clk      : std_logic;
  signal Tx,Rx : std_logic;

---------
begin
---------

rst <= not KEY(0);
clk <= CLOCK_50; 
UART_TXD <= Tx;
-- sur les cartes DE, les signaux UART_TX et UART_RX sont difficilement accessible
-- Il faut mieux utiliser les ports extensions GPIO_0 et GPIO_1
-- par exemple GPIO_0(0) pour Tx et GPIO_0(1) pour Rx 
GPIO_0(0) <= Tx;
Rx <= GPIO_0(1);

----------------------------------



-- Insert your code below ... 


end architecture;
