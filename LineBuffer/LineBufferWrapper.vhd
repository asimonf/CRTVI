library ieee;
use ieee.std_logic_1164.all;

-- When reading from the odd line buffer, write to the even line buffer and vice versa
entity LineBufferWrapper is
	port (
		-- Read side
		i_odd_select : in  std_logic;
		i_rdclk      : in  std_logic;
		i_rdreq      : in  std_logic;
		i_rdreq_mask : in  std_logic;
		o_q          : out std_logic_vector (15 downto 0);

		-- Write side
		i_data       : in  std_logic_vector (7 downto 0);
		i_wrclk      : in  std_logic;
		i_wrreq      : in  std_logic
	);
end LineBufferWrapper;

architecture structural of LineBufferWrapper is
	component LineBuffer
		port (
			data  : in  std_logic_vector (7 downto 0);
			rdclk : in  std_logic;
			rdreq : in  std_logic;
			wrclk : in  std_logic;
			wrreq : in  std_logic;
			q     : out std_logic_vector (15 downto 0)
		);
	end component;

	signal odd_rdreq  : std_logic;
	signal odd_wrreq  : std_logic;
	signal odd_q      : std_logic;

	signal even_rdreq : std_logic;
	signal even_wrreq : std_logic;
	signal even_q     : std_logic;

begin
	-- Read from the odd line buffer when odd_select is asserted
	odd_rdreq  <= i_rdreq when i_odd_select = '1' and i_rdreq_mask = '1' else '0';
	even_rdreq <= i_rdreq when i_odd_select = '0' and i_rdreq_mask = '1' else '0';
	o_q        <= odd_q when i_odd_select = '1' else even_q;

	-- Write to the even line buffer when odd_select is asserted
	odd_wrreq  <= i_wrreq when i_odd_select = '0' else '0';
	even_wrreq <= i_wrreq when i_odd_select = '1' else '0';

	-- Clocks are common, as is the input port (data)
	OddLineBuffer : LineBuffer port map(
		data  => i_data,
		rdclk => i_rdclk,
		rdreq => odd_rdreq,
		wrclk => i_wrclk,
		wrreq => odd_wrreq,
		q     => odd_q
	);

	EvenLineBuffer : LineBuffer port map(
		data  => i_data,
		rdclk => i_rdclk,
		rdreq => even_rdreq,
		wrclk => i_wrclk,
		wrreq => even_wrreq,
		q     => even_q
	);
end structural;