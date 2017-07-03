
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity botons is
	port (clk,boto: in std_logic;
	     flag: out std_logic);
end botons;

architecture behav of botons is
    signal q1,q2: std_logic:='0';

begin
  process(clk)
    begin
      if rising_edge(clk) then
           q1<= boto;
	   q2<= q1;
	end if;
end process;

end behav;
