library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity EthernetFcs is
	port (
		i_clk       : in  std_logic;
		i_reset    : in  std_logic;
		i_data      : in  std_logic_vector(7 downto 0);
		o_crc       : out std_logic_vector(31 downto 0);

		i_calc      : in  std_logic
   );
end EthernetFcs;

architecture behavioral of EthernetFcs is
   signal crc_next : std_logic_vector(31 downto 0);
   signal crc : std_logic_vector(31 downto 0);
begin
   crc_next(0) <= crc(24) xor crc(30) xor i_data(0) xor i_data(6);
   crc_next(1) <= crc(24) xor crc(25) xor crc(30) xor crc(31) xor i_data(0) xor i_data(1) xor i_data(6) xor i_data(7);
   crc_next(2) <= crc(24) xor crc(25) xor crc(26) xor crc(30) xor crc(31) xor i_data(0) xor i_data(1) xor i_data(2) xor i_data(6) xor i_data(7);
   crc_next(3) <= crc(25) xor crc(26) xor crc(27) xor crc(31) xor i_data(1) xor i_data(2) xor i_data(3) xor i_data(7);
   crc_next(4) <= crc(24) xor crc(26) xor crc(27) xor crc(28) xor crc(30) xor i_data(0) xor i_data(2) xor i_data(3) xor i_data(4) xor i_data(6);
   crc_next(5) <= crc(24) xor crc(25) xor crc(27) xor crc(28) xor crc(29) xor crc(30) xor crc(31) xor i_data(0) xor i_data(1) xor i_data(3) xor i_data(4) xor i_data(5) xor i_data(6) xor i_data(7);
   crc_next(6) <= crc(25) xor crc(26) xor crc(28) xor crc(29) xor crc(30) xor crc(31) xor i_data(1) xor i_data(2) xor i_data(4) xor i_data(5) xor i_data(6) xor i_data(7);
   crc_next(7) <= crc(24) xor crc(26) xor crc(27) xor crc(29) xor crc(31) xor i_data(0) xor i_data(2) xor i_data(3) xor i_data(5) xor i_data(7);
   crc_next(8) <= crc(0) xor crc(24) xor crc(25) xor crc(27) xor crc(28) xor i_data(0) xor i_data(1) xor i_data(3) xor i_data(4);
   crc_next(9) <= crc(1) xor crc(25) xor crc(26) xor crc(28) xor crc(29) xor i_data(1) xor i_data(2) xor i_data(4) xor i_data(5);
   crc_next(10) <= crc(2) xor crc(24) xor crc(26) xor crc(27) xor crc(29) xor i_data(0) xor i_data(2) xor i_data(3) xor i_data(5);
   crc_next(11) <= crc(3) xor crc(24) xor crc(25) xor crc(27) xor crc(28) xor i_data(0) xor i_data(1) xor i_data(3) xor i_data(4);
   crc_next(12) <= crc(4) xor crc(24) xor crc(25) xor crc(26) xor crc(28) xor crc(29) xor crc(30) xor i_data(0) xor i_data(1) xor i_data(2) xor i_data(4) xor i_data(5) xor i_data(6);
   crc_next(13) <= crc(5) xor crc(25) xor crc(26) xor crc(27) xor crc(29) xor crc(30) xor crc(31) xor i_data(1) xor i_data(2) xor i_data(3) xor i_data(5) xor i_data(6) xor i_data(7);
   crc_next(14) <= crc(6) xor crc(26) xor crc(27) xor crc(28) xor crc(30) xor crc(31) xor i_data(2) xor i_data(3) xor i_data(4) xor i_data(6) xor i_data(7);
   crc_next(15) <= crc(7) xor crc(27) xor crc(28) xor crc(29) xor crc(31) xor i_data(3) xor i_data(4) xor i_data(5) xor i_data(7);
   crc_next(16) <= crc(8) xor crc(24) xor crc(28) xor crc(29) xor i_data(0) xor i_data(4) xor i_data(5);
   crc_next(17) <= crc(9) xor crc(25) xor crc(29) xor crc(30) xor i_data(1) xor i_data(5) xor i_data(6);
   crc_next(18) <= crc(10) xor crc(26) xor crc(30) xor crc(31) xor i_data(2) xor i_data(6) xor i_data(7);
   crc_next(19) <= crc(11) xor crc(27) xor crc(31) xor i_data(3) xor i_data(7);
   crc_next(20) <= crc(12) xor crc(28) xor i_data(4);
   crc_next(21) <= crc(13) xor crc(29) xor i_data(5);
   crc_next(22) <= crc(14) xor crc(24) xor i_data(0);
   crc_next(23) <= crc(15) xor crc(24) xor crc(25) xor crc(30) xor i_data(0) xor i_data(1) xor i_data(6);
   crc_next(24) <= crc(16) xor crc(25) xor crc(26) xor crc(31) xor i_data(1) xor i_data(2) xor i_data(7);
   crc_next(25) <= crc(17) xor crc(26) xor crc(27) xor i_data(2) xor i_data(3);
   crc_next(26) <= crc(18) xor crc(24) xor crc(27) xor crc(28) xor crc(30) xor i_data(0) xor i_data(3) xor i_data(4) xor i_data(6);
   crc_next(27) <= crc(19) xor crc(25) xor crc(28) xor crc(29) xor crc(31) xor i_data(1) xor i_data(4) xor i_data(5) xor i_data(7);
   crc_next(28) <= crc(20) xor crc(26) xor crc(29) xor crc(30) xor i_data(2) xor i_data(5) xor i_data(6);
   crc_next(29) <= crc(21) xor crc(27) xor crc(30) xor crc(31) xor i_data(3) xor i_data(6) xor i_data(7);
   crc_next(30) <= crc(22) xor crc(28) xor crc(31) xor i_data(4) xor i_data(7);
   crc_next(31) <= crc(23) xor crc(29) xor i_data(5);

   o_crc <= crc;
   
   process (i_clk)
   begin
      if rising_Edge(i_clk) then
         if i_reset = '1' then
            crc <= (others => '1');
         elsif i_calc = '1' then
            crc <= crc_next;
         end if;
      end if;
   end process;
end behavioral;