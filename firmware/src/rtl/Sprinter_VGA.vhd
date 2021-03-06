-----------------------------------------------------------------------------------------------------------------------------------------------------------------
--         .-+%########%+:.                                               +#######################%+:-                                                         --
--      :###################@.                                           .############@=+:.                                                                    --
--    :#########*---=#########.                                          +#@=*-.                             .-*=%###                                          --
--   *########-      *########               ..                                                             .#######:              ..                          --
--   =#########%*.             +#######-%##########:   .#######*-@####+ %#######. %#######-@##########- -###############+  .*#############%.    #######+-%####%--
--   .@###############@+-     .##########=+=########%  +##############.:#######* -#####################.%###############.-#######+--*@######+  *##############.--
--      -=#################-  =#######=      %#######..##########=***- @######@  %#######:     ########    @######=     %######-     .#######  ##########=***- --
--             -*%########## .#######=       #######@ =#######+       *#######: :#######*     *#######:   *#######.    %####################% +#######=        --
--########:        %#######@ =#######.      =#######--#######+       .#######%  @######@      #######@    #######+    -#######==============-.#######=         --
--#########+.   .*########@.-########-    .########. %#######        +#######- *#######:     *#######-   +#######-    :######%     .%######* =#######.         --
--.@####################@-  @####################:  :#######*       .#######=  #######%     .#######%    ############- %########@@#######@. -#######+          --
--   .*@############%:.    :#######+-@#######@:.    @######@        =#######. +#######-     =#######.    .%#########=   .*@##########@+.    %#######.          --
--                         ########.                                                                                                                           --
--                        *#######*                                                                                                                            --
--                       .#@%+:..                                                                                                                              --
--																																																					--
-- https://github.com/solegstar/Sprinter-VGA-module																																				--
--																																																					--
-- FPGA firmware for Sprinter VGA Module																																								--
--																																																					--
-- @author Andy Karpov <andy.karpov@gmail.com>																																						--
-- @author Oleh Starychenko <solegstar@gmail.com>																																					--
-- Ukraine, 2021																																																--
-----------------------------------------------------------------------------------------------------------------------------------------------------------------

library IEEE; 
use IEEE.std_logic_1164.all; 
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all; 

entity Sprinter_VGA is

port (
	-- Clocks
	TG42 		: in std_logic := '0';
	WR_COL	: in std_logic := '0';

	-- TV IN
	TV_R 			: in std_logic_vector(7 downto 0) := "00000000";
	TV_G 			: in std_logic_vector(7 downto 0) := "00000000";
	TV_B 			: in std_logic_vector(7 downto 0) := "00000000";
	TV_HS 		: in std_logic := '0';
	TV_VS 		: in std_logic := '0';
	TV_SYNC 		: in std_logic := '0';
	TV_nSYNC 	: out std_logic;
	TV_nBLANK 	: out std_logic;
	TV_nSYNC_IN : in std_logic := '0';
	TV_SYNC_IN 	: out std_logic;
	
	-- VGA 
	VGA_nVGA_IN : in std_logic := '0';
	VGA_VGA_IN	: out std_logic;
	VGA_R 		: out std_logic_vector(7 downto 0);
	VGA_G 		: out std_logic_vector(7 downto 0);
	VGA_B 		: out std_logic_vector(7 downto 0);
	VGA_HS 		: out std_logic;
	VGA_VS 		: out std_logic
	);
end Sprinter_VGA;

architecture rtl of Sprinter_VGA is

signal FRQ			: std_logic := '0';
signal FRQx2		: std_logic := '0';
signal FRQx2_REG	: std_logic := '0';
signal locked		: std_logic;
signal TV_R_REG	: std_logic_vector(7 downto 0) := "00000000";
signal TV_G_REG	: std_logic_vector(7 downto 0) := "00000000";
signal TV_B_REG	: std_logic_vector(7 downto 0) := "00000000";



begin

-- PLL1
U1: entity work.altpll0
port map (
	inclk0			=> TG42,
	locked			=> locked,
	c0 				=> FRQx2
	);
	
-- Scandoubler	
U2: entity work.vga_pal 
port map (
	RGB_IN 			=> TV_R_REG&TV_G_REG&TV_B_REG,
	KSI_IN 			=> not TV_VS,
	SSI_IN 			=> not TV_HS,
	CLK 				=> FRQ,
	CLK2 				=> FRQx2,
	EN 				=> not VGA_nVGA_IN,
	DS80				=> '0',		
	RGB_O(23 downto 16)	=> VGA_R,
	RGB_O(15 downto 8)	=> VGA_G,
	RGB_O(7 downto 0)		=> VGA_B,
	VGA_BLANK_O 	=> TV_nBLANK,
	VSYNC_VGA		=> VGA_VS,
	HSYNC_VGA		=> VGA_HS
);
	

-------------------------------------------------------------------------------
-- clocks

process (FRQx2)
begin 
	if (FRQx2'event and FRQx2 = '1') then 
		FRQ <= not(FRQ);
	end if;
end process;

process (WR_COl, TV_R, TV_G, TV_B, TV_R_REG, TV_G_REG, TV_B_REG)
begin 
	if (WR_COl'event and WR_COl = '1') then 
		TV_R_REG <= TV_R;
		TV_G_REG <= TV_G;
		TV_B_REG <= TV_B;
	end if;
end process;

TV_nSYNC <= not TV_SYNC;
TV_SYNC_IN <= not TV_nSYNC_IN;
	
	-- VGA 
VGA_VGA_IN	<= not VGA_nVGA_IN;
	
end rtl;
