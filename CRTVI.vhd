library ieee;
use ieee.std_logic_1164.all;

library work;

entity CRTVI is
	port (
		i_board_clock       : in  std_logic;
		i_board_reset_n     : in  std_logic;

		i_eth_rx_clock      : in  std_logic;
		i_eth_rx_error      : in  std_logic;
		i_eth_rx_data_valid : in  std_logic;
		i_eth_rx_data       : in  std_logic_vector(7 downto 0);

		o_eth_phy_reset_n   : out std_logic;

		o_eth_tx_enable     : out std_logic;
		o_eth_gtx_clock     : out std_logic;
		o_eth_tx_error      : out std_logic;
		o_eth_tx_data       : out std_logic_vector(7 downto 0);

		o_csync             : out std_logic;
		o_video_blue        : out std_logic_vector(4 downto 0);
		o_video_green       : out std_logic_vector(5 downto 0);
		o_video_red         : out std_logic_vector(4 downto 0)
	);
end CRTVI;

architecture structural of CRTVI is

begin
end structural;
