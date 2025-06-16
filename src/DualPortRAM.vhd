LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.NUMERIC_STD.all; 

ENTITY DualPortRAM IS
PORT (
	clock, rst: IN STD_LOGIC;
	data: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
    q: out STD_LOGIC_VECTOR (31 DOWNTO 0);
	rdaddress, wraddress: IN STD_LOGIC_VECTOR (5 DOWNTO 0);
    rden, wren : in std_logic
);
END entity;

ARCHITECTURE rtl OF DualPortRAM IS
TYPE MEM IS ARRAY(0 TO 63) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
signal ram_block : MEM := (
    0 =>   x"E3A01020",  -- MOV R1, #0x20
    1 =>   x"E3A02000",  -- MOV R2, #0
    2 =>   x"E5910000",  -- LDR R0, [R1]
    3 =>   x"E0802002",  -- ADD R2, R0, R2
    4 =>   x"E2811004",  -- ADD R1, R1, #4
    5 =>   x"E352103C",  -- CMP R2, #60
    6 =>   x"BAFFFFFA",  -- BLT loop
    7 =>   x"E5822000",  -- STR R2, [R2]
    8 =>   x"EAFFFFF8",  -- BAL main
    9  =>  x"E60F1000", --           STR R1,0(R15)   	; --MEM[R15] <= R1 
    10 =>  x"E28FF001", --           ADD R15,R15,1  	; --R15 <= R15 + 1
    11 =>  x"E60F3000", --           STR R3,0(R15)   	; --MEM[R15] <= R3
                        --traitement
    12 =>  x"E3A03020", --           MOV R3,0x20     	; --R3 <= 0x20
    13 =>  x"E6131000", --           LDR R1,0(R3)    	; --R1 <= MEM[R3]
    14 =>  x"E2811001", --           ADD R1,R1,1     	; --R1 <= R1 + 1
    15 =>  x"E6031000", --           STR R1,0(R3)    	; --MEM[R3] <= R1
                     -- restauration du contexte
    16 =>  x"E61F3000", --           LDR R3,0(R15)   	; --R3 <= MEM[R15]
    17 =>  x"E28FF0FF", --           ADD R15,R15,-1  	; --R15 <= R15 - 1
    18 =>  x"E61F1000", --           LDR R1,0(R15)   	; --R1 <= MEM[R15]
    19 =>  x"EB000000", --           BX              	; -- instruction de fin d'interruption
    20 =>  x"00000000", 
                 -- ISR1 : interruption 1  
                        --sauvegarde du contexte - R15 correspond au pointeur de pile
    21 =>  x"E60F4000", --           STR R4,0(R15)   	; --MEM[R15] <= R4
    22 =>  x"E28FF001", --           ADD R15,R15,1   	; --R15 <= R15 + 1
    23 =>  x"E60F5000", --           STR R5,0(R15)   ; --MEM[R15] <= R5
                       --traitement
    24 =>  x"E3A05020", --           MOV R5,0x20     	; --R5 <= 0x20
    25 =>  x"E6154000", --           LDR R4,0(R5)    	; --R4 <= MEM[R5]
    26 =>  x"E2844002", --           ADD R4,R4,2     	; --R4 <= R1 + 2
    27 =>  x"E6054000", --           STR R4,0(R5)    	; --MEM[R5] <= R4
                        -- restauration du contexte 
    28 =>  x"E61F5000",--           LDR R5,0(R15)   	; --R5 <= MEM[R15]
    29 =>  x"E28FF0FF",  --           ADD R15,R15,-1  	; --R15 <= R15 - 1
    30 =>  x"E61F4000", --           LDR R4,0(R15)   ; --R4 <= MEM[R15]
    31 =>  x"EB000000",--           BX              	; -- instruction de fin d'interruption
    32 =>  x"00000001",
    33 =>  x"00000002",
    34 =>  x"00000003",
    35 =>  x"00000004",
    36 =>  x"00000005",
    37 =>  x"00000006",
    38 =>  x"00000007",
    39 =>  x"00000008",
    40 =>  x"00000009",
    41 =>  x"0000000A",
    others => (others => '0')
);
BEGIN
PROCESS (clock,rst)
BEGIN
	IF rst = '1' then 
        ram_block <= (
    0 =>   x"E3A01020",  -- MOV R1, #0x20
    1 =>   x"E3A02000",  -- MOV R2, #0
    2 =>   x"E5910000",  -- LDR R0, [R1]
    3 =>   x"E0802002",  -- ADD R2, R0, R2
    4 =>   x"E2811004",  -- ADD R1, R1, #4
    5 =>   x"E352103C",  -- CMP R2, #60
    6 =>   x"BAFFFFFA",  -- BLT loop
    7 =>   x"E5822000",  -- STR R2, [R2]
    8 =>   x"EAFFFFF8",  -- BAL main
    9  =>  x"E60F1000", --           STR R1,0(R15)   	; --MEM[R15] <= R1 
    10 =>  x"E28FF001", --           ADD R15,R15,1  	; --R15 <= R15 + 1
    11 =>  x"E60F3000", --           STR R3,0(R15)   	; --MEM[R15] <= R3
                        --traitement
    12 =>  x"E3A03020", --           MOV R3,0x20     	; --R3 <= 0x20
    13 =>  x"E6131000", --           LDR R1,0(R3)    	; --R1 <= MEM[R3]
    14 =>  x"E2811001", --           ADD R1,R1,1     	; --R1 <= R1 + 1
    15 =>  x"E6031000", --           STR R1,0(R3)    	; --MEM[R3] <= R1
                     -- restauration du contexte
    16 =>  x"E61F3000", --           LDR R3,0(R15)   	; --R3 <= MEM[R15]
    17 =>  x"E28FF0FF", --           ADD R15,R15,-1  	; --R15 <= R15 - 1
    18 =>  x"E61F1000", --           LDR R1,0(R15)   	; --R1 <= MEM[R15]
    19 =>  x"EB000000", --           BX              	; -- instruction de fin d'interruption
    20 =>  x"00000000", 
                 -- ISR1 : interruption 1  
                        --sauvegarde du contexte - R15 correspond au pointeur de pile
    21 =>  x"E60F4000", --           STR R4,0(R15)   	; --MEM[R15] <= R4
    22 =>  x"E28FF001", --           ADD R15,R15,1   	; --R15 <= R15 + 1
    23 =>  x"E60F5000", --           STR R5,0(R15)   ; --MEM[R15] <= R5
                       --traitement
    24 =>  x"E3A05020", --           MOV R5,0x20     	; --R5 <= 0x20
    25 =>  x"E6154000", --           LDR R4,0(R5)    	; --R4 <= MEM[R5]
    26 =>  x"E2844002", --           ADD R4,R4,2     	; --R4 <= R1 + 2
    27 =>  x"E6054000", --           STR R4,0(R5)    	; --MEM[R5] <= R4
                        -- restauration du contexte 
    28 =>  x"E61F5000",--           LDR R5,0(R15)   	; --R5 <= MEM[R15]
    29 =>  x"E28FF0FF",  --           ADD R15,R15,-1  	; --R15 <= R15 - 1
    30 =>  x"E61F4000", --           LDR R4,0(R15)   ; --R4 <= MEM[R15]
    31 =>  x"EB000000",--           BX              	; -- instruction de fin d'interruption
    32 =>  x"00000001",
    33 =>  x"00000002",
    34 =>  x"00000003",
    35 =>  x"00000004",
    36 =>  x"00000005",
    37 =>  x"00000006",
    38 =>  x"00000007",
    39 =>  x"00000008",
    40 =>  x"00000009",
    41 =>  x"0000000A",
    others => (others => '0')
);
    elsif rising_edge(clock) THEN
			if (wren = '1') then
				ram_block(to_integer(unsigned(wrAddress))) <= Data;
			elsif (rden= '1') then
				q <= ram_block(to_integer(unsigned(rdAddress)));
			end if;
end if;

END PROCESS;
END architecture;