library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mini_avr_01_tb is
end mini_avr_01_tb;

architecture behav of mini_avr_01_tb is
	component my_mini_avr_01
	port( clk, reset : in std_logic;
        r16, r17, r18, r19 : out std_logic_vector(7 downto 0));
	end component;
	for dut : my_mini_avr_01 use entity work.mini_avr_01;

	signal clk, reset : std_logic;
	signal r16, r17, r18, r19 : std_logic_vector(7 downto 0);

begin

dut : my_mini_avr_01 port map ( clk => clk,
                                reset => reset,
                                r16 => r16,
                                r17 => r17,
                                r18 => r18,
                                r19 => r19);

																clk0_process: process
																begin           --the clock process
																    clk <= '0';
																    reset <= '0';
																    wait for 0.00001000000000000000 ms;
																                reset <= '1';
																    wait for 0.00001000000000000000 ms;
																    wait for 0.00001000000000000000 ms;
																    wait for 0.00001000000000000000 ms;
																  reset <= '0';
																      for i in 1 to 4000 loop
																        clk <= not clk;
																        wait for 0.00001000000000000000 ms;
																      end loop;
																      wait;
																end process clk0_process;

process
	begin
		wait;
	-- Enter here your simulation sequence
end process;
end behav;
