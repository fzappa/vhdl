-- Datasheet
-- http://ww1.microchip.com/downloads/en/DeviceDoc/doc0270.pdf
--
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity EEPROM_2864 is
	generic(constant DATA_WIDTH   : natural := 8;
	
			-- 3 bits for fastest simulation, original is 13
			constant ADDR_WIDTH   : natural := 3;
			
			-- EEPROM_DEPTH = 2**ADDR_WIDTH
			constant EEPROM_DEPTH : natural := 2**3
	);
				
	port(
			ADDR : in std_logic_vector((ADDR_WIDTH - 1) downto 0);
			DATA_IO : inout std_logic_vector((DATA_WIDTH - 1) downto 0);
			
			-- Control pins
			-- Not enable = 1 / Enable = 0
			CE_N : in std_logic; 
			OE_N : in std_logic; 
			WE_N : in std_logic
			
	);
end entity EEPROM_2864;



---------- TABLE OF STATES ----------
--    READ => CE_N=0, OE_N=0, WE_N=1
--   WRITE => CE_N=0, OE_N=1, WE_N=0
-- STANDBY => CE_N=1, OE_N=X, WE_N=X
-------------------------------------


architecture ARCH of EEPROM_2864 is 
	
	-- Begin of internal variables
	
	subtype BYTE is std_logic_vector((DATA_WIDTH - 1) downto 0);
	
	signal DATA_OUT_TEMP : BYTE;
		
	-- Create and initialize the firsts 8 bytes of EEPROM
	type EEPROM is array (0 to (EEPROM_DEPTH-1)) of BYTE;
	signal EEPROM_DATA: EEPROM := ( 
			0 => x"2A", 1 => x"11", 2 => x"22", 3 => x"33",
			4 => x"44", 5 => x"55", 6 => x"66", 7 => x"77",
			others => (others=>'0') );

	-- End of internal variables

begin

	STANDBY:
	-- Put high Z on DATA_IO when chip is not enable
	DATA_IO <= DATA_OUT_TEMP when (CE_N = '0' and OE_N = '0') else (others=>'Z'); 

	EEPROM_READ:
	-- If chip enable, output enable and write is disable, then read from EEPROM
	process(CE_N, OE_N, WE_N, DATA_OUT_TEMP, EEPROM_DATA, ADDR) begin
		if (CE_N = '0' and OE_N = '0' and WE_N = '1') then
			DATA_OUT_TEMP <= EEPROM_DATA(conv_integer(ADDR));
		end if;
	end process;
	
	
	EEPROM_WRITE:
	-- If write is disable (in rising edge), chip is enable
	-- and output is disable, then write DATA_IO in EEPROM
	process(WE_N) 
		variable BUFFER_FF : BYTE := (others=>'0');
		begin
			if(rising_edge(WE_N) and WE_N = '1' and CE_N = '1' and OE_N = '1' ) then
					
				-- t4
				BUFFER_FF := DATA_IO;
					
				-- t5
				DATA_IO <= (others=>'Z');
					
				-- Clear EEPROM address
				EEPROM_DATA(conv_integer(ADDR)) <= x"00";
					
				-- Write data in EEPROM
				EEPROM_DATA(conv_integer(ADDR)) <= BUFFER_FF;
					
			end if;
	end process;
			
end ARCH; 