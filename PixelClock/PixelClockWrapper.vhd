library ieee;
use ieee.std_logic_1164.all;

library work;
use work.utils.all;

entity PixelClockWrapper is
	port (
		i_areset        : in  std_logic;
		i_master_clock  : in  std_logic;

		o_pixel_clock   : out std_logic;
		o_clock_locked  : out std_logic;

		i_param_type    : in  PixelClockParam;
		i_param_value   : in  std_logic_vector(8 downto 0);
		i_param_submit  : in  std_logic;
		i_config_reload : in  std_logic;

		o_busy          : out std_logic
	);
end PixelClockWrapper;

architecture behavioral of PixelClockWrapper is
	type state is (
		idle,
		submit_c_low,
		submit_c_mode,
		waiting
	);

	component PixelClock
		port (
			areset       : in  std_logic;
			configupdate : in  std_logic;
			inclk0       : in  std_logic;
			scanclk      : in  std_logic;
			scanclkena   : in  std_logic;
			scandata     : in  std_logic;
			c0           : out std_logic;
			locked       : out std_logic;
			scandataout  : out std_logic;
			scandone     : out std_logic
		);
	end component;

	component PixelClockConfigurator
		port (
			clock            : in  std_logic;
			counter_param    : in  std_logic_vector (2 downto 0);
			counter_type     : in  std_logic_vector (3 downto 0);
			data_in          : in  std_logic_vector (8 downto 0);
			pll_areset_in    : in  std_logic;
			pll_scandataout  : in  std_logic;
			pll_scandone     : in  std_logic;
			read_param       : in  std_logic;
			reconfig         : in  std_logic;
			reset            : in  std_logic;
			write_param      : in  std_logic;
			busy             : out std_logic;
			data_out         : out std_logic_vector (8 downto 0);
			pll_areset       : out std_logic;
			pll_configupdate : out std_logic;
			pll_scanclk      : out std_logic;
			pll_scanclkena   : out std_logic;
			pll_scandata     : out std_logic
		);
	end component;

	-- routing signals, do not touch
	signal s_pll_areset       : std_logic;
	signal s_pll_configupdate : std_logic;
	signal s_pll_scanclk      : std_logic;
	signal s_pll_scanclkena   : std_logic;
	signal s_pll_scandata     : std_logic;
	signal s_pll_scandataout  : std_logic;
	signal s_pll_scandone     : std_logic;

	-- other signals
	signal s_busy             : std_logic;
	signal s_reconfig         : std_logic;
	signal s_write_param      : std_logic;
	signal s_data_latch       : std_logic_vector (8 downto 0);
	signal s_param_data       : std_logic_vector (8 downto 0);
	signal s_counter_type     : std_logic_vector (3 downto 0);
	signal s_counter_param    : std_logic_vector (2 downto 0);
	signal s_reset            : std_logic;

	signal s_state            : state;

begin
	C0 : PixelClock port map(
		areset       => s_pll_areset,
		configupdate => s_pll_configupdate,
		inclk0       => i_master_clock,
		scanclk      => s_pll_scanclk,
		scanclkena   => s_pll_scanclkena,
		scandata     => s_pll_scandata,
		c0           => o_pixel_clock,
		locked       => o_clock_locked,
		scandataout  => s_pll_scandataout,
		scandone     => s_pll_scandone
	);

	Configurator : PixelClockConfigurator port map(
		clock            => i_master_clock,
		counter_param    => s_counter_param,
		counter_type     => s_counter_type,
		data_in          => s_param_data,
		pll_areset_in    => '0',
		pll_scandataout  => s_pll_scandataout,
		pll_scandone     => s_pll_scandone,
		read_param       => '0',
		reconfig         => s_reconfig,
		reset            => s_reset,
		write_param      => s_write_param,
		busy             => s_busy,
		data_out         => open,
		pll_areset       => s_pll_areset,
		pll_configupdate => s_pll_configupdate,
		pll_scanclk      => s_pll_scanclk,
		pll_scanclkena   => s_pll_scanclkena,
		pll_scandata     => s_pll_scandata
	);

	process (i_master_clock, i_areset)
	begin
		if i_areset = '1' then
			s_reset         <= '1';
			o_busy          <= '0';
			s_reconfig      <= '0';
			s_state         <= idle;
			s_counter_type  <= "0000";
			s_counter_param <= "000";
			s_param_data    <= (others => '0');
			s_data_latch    <= (others => '0');
			s_write_param   <= '0';
		elsif rising_edge(i_master_clock) then
			s_reset <= '0';

			case s_state is
				when idle =>
					if i_param_submit = '1' then
						o_busy        <= '1';
						s_reconfig    <= '0';
						s_write_param <= '1';
						s_data_latch  <= i_param_value;

						case i_param_type is
							when M =>
								s_state         <= waiting;
								s_counter_type  <= "0001"; -- M
								s_counter_param <= "111"; -- Nominal
								s_param_data    <= i_param_value;
							when N =>
								s_state         <= waiting;
								s_counter_type  <= "0000"; -- N
								s_counter_param <= "111"; -- Nominal
								s_param_data    <= i_param_value;
							when C =>
								s_state         <= submit_c_low;
								s_counter_type  <= "0100"; -- C0
								s_counter_param <= "000"; -- High Count
								s_param_data    <= "0" & i_param_value(8 downto 1);
							when K =>
								s_state         <= waiting;
								s_counter_type  <= "0011"; -- VCO
								s_counter_param <= "000"; -- Post Scale
								s_param_data    <= (0 => i_param_value(0), others => '0');
						end case;
					elsif i_config_reload = '1' then
						o_busy          <= '1';
						s_state         <= waiting;
						s_counter_type  <= "0000";
						s_counter_param <= "000";
						s_param_data    <= (others => '0');
						s_reconfig      <= '1';
						s_write_param   <= '0';
					else
						o_busy          <= '0';
						s_state         <= idle;
						s_counter_type  <= "0000";
						s_counter_param <= "000";
						s_param_data    <= (others => '0');
						s_reconfig      <= '0';
						s_write_param   <= '0';
					end if;
				when submit_c_low =>
					o_busy          <= '1';
					s_counter_type  <= "0100"; -- C0
					s_counter_param <= "001"; -- Low Count
					s_param_data    <= "0" & s_data_latch(8 downto 1);
					s_reconfig      <= '0';

					if s_busy = '1' then
						s_state       <= submit_c_low;
						s_write_param <= '0';
					else
						s_state       <= submit_c_mode;
						s_write_param <= '1';
					end if;
				when submit_c_mode =>
					o_busy          <= '1';
					s_counter_type  <= "0100"; -- C0
					s_counter_param <= "101"; -- Odd/Even Mode
					s_param_data    <= (0 => s_data_latch(0), others => '0');
					s_reconfig      <= '0';

					if s_busy = '1' then
						s_state       <= submit_c_mode;
						s_write_param <= '0';
					else
						s_state       <= waiting;
						s_write_param <= '1';
					end if;
				when waiting =>
					s_reconfig      <= '0';
					s_counter_type  <= "0000";
					s_counter_param <= "000";
					s_param_data    <= (others => '0');
					s_data_latch    <= (others => '0');
					s_write_param   <= '0';

					if s_busy = '1' then
						o_busy  <= '1';
						s_state <= waiting;
					else
						o_busy  <= '0';
						s_state <= idle;
					end if;
			end case;
		end if;
	end process;

end architecture;