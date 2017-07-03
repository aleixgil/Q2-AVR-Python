library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity sintetitzador is
port( midi : in std_logic_vector(7 downto 0);
      clk : in std_logic := '0';
      clock_out : out std_logic);

end sintetitzador;

architecture behav of sintetitzador is
  signal limit : std_logic_vector(14 downto 0) := "000000000000000";
  signal count : unsigned(14 downto 0) := (others => '0');
  signal clk_aux : std_logic := '0';
  begin
        with midi select
        limit <=    "001011001011111" when "00101001", -- Fa 1
                    "001001111101110" when "00101011", -- Sol 1

                    "000111011101110" when "00110000", -- Do 2
                    "000110101001101" when "00110010", -- Re 2
                    "000101100101111" when "00110101", -- Fa 2
                    "000100111110111" when "00110111", -- Sol 2
                    "000100011100001" when "00111001", -- La 2
                    "000011111101001" when "00111011", -- Si 2

                    "000011101110111" when "00111100", -- Do 3
                    "000011010100111" when "00111110", -- Re 3
                    "000010111101101" when "01000000", -- Mi 3
                    "000010110011000" when "01000001", -- Fa 3
                    "000010101001010" when "01001011", -- FA# 3
                    "000010011111100" when "01000011", -- Sol 3
                    "000010010110110" when "01001100", -- Sol# 3
                    "000010001110000" when "01000101", -- La 3
                    "000001111110100" when "01000111", -- Si 3

                    "000001110111100" when "01001000", -- Do 4
                    "000001101010011" when "01001010", -- Re 4

                    "000000000000000" when others;

    process(clk)
    begin
      if rising_edge(clk) then
        if count >= unsigned(limit) then
            clk_aux <= not(clk_aux);
            count <= "000000000000000" ;
        else
           count <= count + 1;
        end if;
        clock_out <= clk_aux;
    end if;

  end process;

end behav;
