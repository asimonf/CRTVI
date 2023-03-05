library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity EthernetRx is
	port (
		i_areset            : in  std_logic;
		i_clock             : in  std_logic;
		i_enabled           : in  std_logic;

		i_eth_mac_address   : in  std_logic_vector(47 downto 0);

		-- Ethernet receive
		i_eth_rx_data_valid : in  std_logic;
		i_eth_rxd           : in  std_logic_vector(7 downto 0);
		i_eth_rx_error      : in  std_logic;

		-- Buffer common stuff
		o_data              : out std_logic_vector(7 downto 0);
		o_write_clock       : out std_logic;

		-- Line buffer
		o_line_buffer_write : out std_logic;

		-- Command buffer
		i_cmd_buffer_full   : in  std_logic;
		o_cmd_buffer_write  : out std_logic
	);
end EthernetRx;

architecture behavioral of EthernetRx is
	type state_type is (
		idle,
		discard,
		preamble,
		sfd,
		dest_mac,
		src_mac,
		ethertype,
		payload_size,
		payload,
		crc
	);

	-- rx side
	signal state             : state_type;

	signal payload_type      : std_logic_vector(15 downto 0);
	signal octet_count       : integer range 0 to 12;
	signal payload_remainder : std_logic_vector(10 downto 0);

	signal src_mac_adress    : std_logic_vector(47 downto 0);
begin
	-- rx fifo clock
	o_write_clock <= i_clock;

	-- eth receive

	process (i_clock, i_areset)
	begin
		-- must be set:
		--    state
		--    src_mac_adress
		--    o_data
		--    o_line_buffer_write
		--    o_cmd_buffer_write
		--    payload_type
		--    octet_count
		--    payload_remainder

		if i_areset = '1' then
			state               <= discard;
			src_mac_adress      <= (others => '0');
			o_data              <= (others => '0');
			o_line_buffer_write <= '0';
			o_cmd_buffer_write  <= '0';
			payload_type        <= (others => '0');
			octet_count         <= 11;
			payload_remainder   <= (others => '0');
		else
			if rising_edge(i_clock) then
				if i_eth_rx_error = '1' then
					state               <= discard;
					src_mac_adress      <= (others => '0');
					o_data              <= (others => '0');
					o_line_buffer_write <= '0';
					o_cmd_buffer_write  <= '0';
					payload_type        <= (others => '0');
					octet_count         <= 11;
					payload_remainder   <= (others => '0');
				else
					case state is
						when idle =>
							src_mac_adress      <= src_mac_adress;
							o_data              <= (others => '0');
							o_line_buffer_write <= '0';
							o_cmd_buffer_write  <= '0';
							payload_type        <= (others => '0');
							payload_remainder   <= (others => '0');
							if i_eth_rx_data_valid = '1' and i_eth_rxd = x"55" then
								state       <= preamble;
								octet_count <= 5;
							else
								state       <= idle;
								octet_count <= 0;
							end if;
						when preamble =>
							src_mac_adress      <= src_mac_adress;
							o_data              <= (others => '0');
							o_line_buffer_write <= '0';
							o_cmd_buffer_write  <= '0';
							payload_type        <= (others => '0');
							payload_remainder   <= (others => '0');
							if i_eth_rx_data_valid = '1' and i_eth_rxd = x"55" then
								if octet_count = 0 then
									state       <= sfd;
									octet_count <= 0;
								else
									state       <= preamble;
									octet_count <= octet_count - 1;
								end if;
							else
								state <= discard;
								if i_eth_rx_data_valid = '1' then
									octet_count <= 11;
								else
									octet_count <= 10;
								end if;
							end if;
						when sfd =>
							src_mac_adress      <= src_mac_adress;
							o_data              <= (others => '0');
							o_line_buffer_write <= '0';
							o_cmd_buffer_write  <= '0';
							payload_type        <= (others => '0');
							payload_remainder   <= (others => '0');
							if i_eth_rx_data_valid = '1' and i_eth_rxd = x"d5" then
								octet_count <= 5;
								state       <= dest_mac;
							else
								state       <= discard;
								octet_count <= 10;
							end if;
						when dest_mac =>
							src_mac_adress      <= src_mac_adress;
							o_data              <= (others => '0');
							o_line_buffer_write <= '0';
							o_cmd_buffer_write  <= '0';
							payload_type        <= (others => '0');
							payload_remainder   <= (others => '0');
							if i_eth_rx_data_valid = '1' then
								case octet_count is
									when 5 =>
										if i_eth_mac_address(47 downto 40) = i_eth_rxd then
											octet_count <= octet_count - 1;
										else
											state       <= discard;
											octet_count <= 11;
										end if;
									when 4 =>
										if i_eth_mac_address(39 downto 32) = i_eth_rxd then
											octet_count <= octet_count - 1;
										else
											state       <= discard;
											octet_count <= 11;
										end if;
									when 3 =>
										if i_eth_mac_address(31 downto 24) = i_eth_rxd then
											octet_count <= octet_count - 1;
										else
											state       <= discard;
											octet_count <= 11;
										end if;
									when 2 =>
										if i_eth_mac_address(23 downto 16) = i_eth_rxd then
											octet_count <= octet_count - 1;
										else
											state       <= discard;
											octet_count <= 11;
										end if;
									when 1 =>
										if i_eth_mac_address(15 downto 8) = i_eth_rxd then
											octet_count <= octet_count - 1;
										else
											state       <= discard;
											octet_count <= 11;
										end if;
									when 0 =>
										if i_eth_mac_address(7 downto 0) = i_eth_rxd then
											octet_count <= 5;
											state       <= src_mac;
										else
											state       <= discard;
											octet_count <= 11;
										end if;
								end case;
							else
								state       <= discard;
								octet_count <= 10;
							end if;
						when src_mac                   =>
							o_data              <= (others => '0');
							o_line_buffer_write <= '0';
							o_cmd_buffer_write  <= '0';
							payload_type        <= (others => '0');
							payload_remainder   <= (others => '0');
							if i_eth_rx_data_valid = '1' then
								case octet_count is
									when 5 =>
										state                        <= src_mac;
										octet_count                  <= octet_count - 1;
										src_mac_adress(47 downto 40) <= i_eth_rxd;
									when 4 =>
										state                        <= src_mac;
										octet_count                  <= octet_count - 1;
										src_mac_adress(39 downto 32) <= i_eth_rxd;
									when 3 =>
										state                        <= src_mac;
										octet_count                  <= octet_count - 1;
										src_mac_adress(31 downto 24) <= i_eth_rxd;
									when 2 =>
										state                        <= src_mac;
										octet_count                  <= octet_count - 1;
										src_mac_adress(23 downto 16) <= i_eth_rxd;
									when 1 =>
										state                       <= src_mac;
										octet_count                 <= octet_count - 1;
										src_mac_adress(15 downto 8) <= i_eth_rxd;
									when 0 =>
										state                      <= ethertype;
										src_mac_adress(7 downto 0) <= i_eth_rxd;
										octet_count                <= 1;
									when others =>
								end case;
							else
								state          <= discard;
								octet_count    <= 10;
								src_mac_adress <= (others => '0');
							end if;
						when ethertype =>
							src_mac_adress      <= src_mac_adress;
							o_data              <= (others => '0');
							o_line_buffer_write <= '0';
							o_cmd_buffer_write  <= '0';
							payload_remainder   <= (others => '0');
							if i_eth_rx_data_valid = '1' then
								if octet_count = 1 then
									state                     <= ethertype;
									octet_count               <= 0;
									payload_type(15 downto 8) <= i_eth_rxd;
									payload_type(7 downto 0)  <= (others => '0');
								else
									payload_type(15 downto 8) <= payload_type(15 downto 8);
									payload_type(7 downto 0)  <= i_eth_rxd;
									octet_count               <= 1;
									state                     <= payload_size;
								end if;
							else
								state        <= discard;
								octet_count  <= 10;
								payload_type <= (others => '0');
							end if;
						when payload_size =>
							src_mac_adress      <= src_mac_adress;
							payload_type        <= payload_type;
							o_data              <= (others => '0');
							o_line_buffer_write <= '0';
							o_cmd_buffer_write  <= '0';
							if i_eth_rx_data_valid = '1' and (payload_type = x"6900" or payload_type = x"6901" or payload_type = x"6902") then
								if octet_count = 1 then
									payload_remainder(10 downto 8) <= i_eth_rxd(2 downto 0);
									state                          <= payload;
								else
									payload_remainder(7 downto 0) <= i_eth_rxd;
									state                         <= payload;
								end if;
								octet_count <= 0;
							else
								state             <= discard;
								octet_count       <= 10;
								payload_remainder <= (others => '0');
							end if;
						when payload =>
							src_mac_adress <= src_mac_adress;
							payload_type   <= payload_type;
							if i_eth_rx_data_valid = '1' then
								if unsigned(payload_remainder) > 0 then
									octet_count       <= 0;
									state             <= payload;
									payload_remainder <= std_logic_vector(unsigned(payload_remainder) - 1);
								else
									octet_count       <= 3;
									state             <= crc;
									payload_remainder <= (others => '0');
								end if;

								if i_enabled = '1' then
									o_data <= i_eth_rxd;

									case payload_type is
										when x"6901" =>
											o_line_buffer_write <= '1';
											o_cmd_buffer_write  <= '0';
										when others => -- commands
											if i_cmd_buffer_full = '1' then
												octet_count         <= 11;
												state               <= discard;
												o_line_buffer_write <= '0';
												o_cmd_buffer_write  <= '0';
											else
												o_line_buffer_write <= '0';
												o_cmd_buffer_write  <= '1';
											end if;
									end case;
								else
									o_data              <= (others => '0');
									o_line_buffer_write <= '0';
									o_cmd_buffer_write  <= '0';
								end if;
							else
								state               <= discard;
								octet_count         <= 10;
								payload_remainder   <= (others => '0');
								o_data              <= (others => '0');
								o_line_buffer_write <= '0';
								o_cmd_buffer_write  <= '0';
							end if;
						when crc =>
							src_mac_adress      <= src_mac_adress;
							o_data              <= (others => '0');
							o_line_buffer_write <= '0';
							o_cmd_buffer_write  <= '0';
							payload_type        <= (others => '0');
							payload_remainder   <= (others => '0');
							if i_eth_rx_data_valid = '1' and octet_count > 0 then
								octet_count <= octet_count - 1;
								state       <= crc;
							else
								state <= discard;
								if i_eth_rx_data_valid = '1' then
									octet_count <= 11;
								else
									octet_count <= 10;
								end if;
							end if;
						when discard =>
							src_mac_adress      <= src_mac_adress;
							o_data              <= (others => '0');
							o_line_buffer_write <= '0';
							o_cmd_buffer_write  <= '0';
							payload_type        <= (others => '0');
							payload_remainder   <= (others => '0');
							if i_eth_rx_data_valid = '1' then
								octet_count <= 11;
								state       <= discard;
							else
								if octet_count > 0 then
									octet_count <= octet_count - 1;
									state       <= discard;
								else
									octet_count <= 0;
									state       <= idle;
								end if;
							end if;
					end case;
				end if;
			end if;
		end if;
	end process;
end behavioral;
