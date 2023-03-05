library ieee;
use ieee.std_logic_1164.all;

entity InterfaceController is
	port (
		-- Read side
		i_clock : in  std_logic;
		i_areset : in  std_logic;

		i_rdclk      : in  std_logic;
		i_rdreq      : in  std_logic;
		i_rdreq_mask : in  std_logic;
		o_q          : out std_logic_vector (15 downto 0);

		-- Write side
		i_data       : in  std_logic_vector (7 downto 0);
		i_wrclk      : in  std_logic;
		i_wrreq      : in  std_logic
	);
end InterfaceController;

architecture behavioral of InterfaceController is
  
begin
end architecture;