library ieee;
use ieee.std_logic_1164.all;

entity VgaController is
	generic (
		sync_pol : std_logic := '0' --sync pulse polarity (1 = positive, 0 = negative)
	);
	port (
		i_pixel_clk : in  std_logic;               --pixel clock at frequency of VGA mode being used
		i_areset    : in  std_logic;               --active low asynchronous reset

		o_c_sync    : out std_logic;               --composite sync pulse (h_sync XOR v_sync)

		o_h_blank   : out std_logic;               --horizontal blanking period
		o_v_blank   : out std_logic;               --vertical blanking period

		o_disp_ena  : out std_logic;               --display enable ('1' = display time, '0' = blanking time)

		i_h_pulse   : in  integer range 0 to 127;  --horizontal sync pulse width in pixels
		i_h_bp      : in  integer range 0 to 127;  --horizontal back porch width in pixels
		i_h_pixels  : in  integer range 0 to 1023; --horizontal display width in pixels
		i_h_fp      : in  integer range 0 to 127;  --horizontal front porch width in pixels

		i_v_pulse   : in  integer range 0 to 127;  --vertical sync pulse width in pixels
		i_v_bp      : in  integer range 0 to 127;  --vertical back porch width in pixels
		i_v_pixels  : in  integer range 0 to 1023; --vertical display width in pixels
		i_v_fp      : in  integer range 0 to 127;  --vertical front porch width in pixels

		o_odd_row   : out std_logic                -- signals if currently rendering an odd row or not (even)
	);
end VgaController;

architecture behavioral of VgaController is
	signal h_pulse          : integer range 0 to 127;
	signal h_bp             : integer range 0 to 127;
	signal h_pixels         : integer range 0 to 1023;
	signal h_fp             : integer range 0 to 127;

	signal v_pulse          : integer range 0 to 127;
	signal v_bp             : integer range 0 to 127;
	signal v_pixels         : integer range 0 to 1023;
	signal v_fp             : integer range 0 to 127;

	signal h_sync, v_sync   : std_logic;

	signal v_blank, h_blank : std_logic;

	signal h_period         : integer; --total number of pixel clocks in a row
	signal v_period         : integer; --total number of rows in column

begin
	h_period   <= h_pulse + h_bp + h_pixels + h_fp;
	v_period   <= v_pulse + v_bp + v_pixels + v_fp;
	o_c_sync   <= (h_sync xor v_sync) xor '0';
	o_disp_ena <= not (v_blank or h_blank);

	o_h_blank  <= h_blank;
	o_v_blank  <= v_blank;

	process (i_pixel_clk, i_areset)
		variable h_count : integer range 0 to 1023 := 0; --horizontal counter (counts the columns)
		variable v_count : integer range 0 to 1023 := 0; --vertical counter (counts the rows)
	begin

		if i_areset = '1' then 			--reset asserted
			h_count := 0;              --reset horizontal counter
			v_count := 0;              --reset vertical counter

			h_sync    <= not sync_pol; --deassert horizontal sync
			v_sync    <= not sync_pol; --deassert vertical sync

			h_blank   <= '0';
			v_blank   <= '0';

			o_odd_row <= '0';

			h_pulse   <= i_h_pulse;
			h_bp      <= i_h_bp;
			h_pixels  <= i_h_pixels;
			h_fp      <= i_h_fp;

			v_pulse   <= i_v_pulse;
			v_bp      <= i_v_bp;
			v_pixels  <= i_v_pixels;
			v_fp      <= i_v_fp;

		elsif rising_edge(i_pixel_clk) then
			--counters
			if h_count < h_period - 1 then --horizontal counter (pixels)
				h_count := h_count + 1;
			else
				h_count := 0;
				if v_count < v_period - 1 then --vertical counter (rows)
					v_count := v_count + 1;
				else
					v_count := 0;
				end if;
			end if;

			--horizontal sync signal
			if h_count < h_pixels + h_fp or h_count >= h_pixels + h_fp + h_pulse then
				h_sync <= not sync_pol; --deassert horizontal sync pulse
			else
				h_sync <= sync_pol; --assert horizontal sync pulse
			end if;

			--vertical sync signal
			if v_count < v_pixels + v_fp or v_count >= v_pixels + v_fp + v_pulse then
				v_sync <= not sync_pol; --deassert vertical sync pulse
			else
				v_sync <= sync_pol; --assert vertical sync pulse
			end if;

			--set pixel coordinates
			if h_count < h_pixels then --horiztonal display time
				h_blank <= '0';
			else
				h_blank <= '1';
			end if;
			if v_count < v_pixels then --vertical display time
				o_odd_row <= v_count mod 2 = 0;
				v_blank   <= '0';
			else
				v_blank <= '1';
			end if;
		end if;
	end process;
end behavioral;
