library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity SSD is
    Port ( clk : in STD_LOGIC;
           number : in STD_LOGIC_VECTOR (15 downto 0);
           an : out STD_LOGIC_VECTOR (3 downto 0);
           cat : out STD_LOGIC_VECTOR (6 downto 0));
end SSD;

architecture Behavioral of SSD is

signal cnt: STD_LOGIC_VECTOR(15 downto 0);
signal dig:STD_LOGIC_VECTOR(3 downto 0);

begin

process(clk)
begin
    if rising_edge(clk) then
        cnt<=cnt+1;
    end if;
end process;

process( cnt(15 downto 14))
begin
    case cnt (15 downto 14) is
        when "00" => an <= "1110";
        when "01" => an <= "1101"; 
        when "10" => an <= "1011";
        when "11" => an <= "0111";
        when others => an <="1110";
    end case;
end process;    


process( cnt(15 downto 14), number)
begin
   case cnt (15 downto 14) is
        when "00" => dig <= number(3 downto 0);
        when "01" => dig <= number(7 downto 4);
        when "10" => dig <= number(11 downto 8);
        when "11" => dig <= number(15 downto 12);
        when others => an <= number(3 downto 0);
    end case;
end process;



process(dig)
begin
    case dig is
        when "0001" => cat<= "1111001";  --1
        when "0010" => cat<= "0100100";  --2
        when "0011" => cat<= "0110000";  --3
        when "0100" => cat<= "0011001";  --4
        when "0101" => cat<= "0010010";  --5
        when "0110" => cat<= "0000010";  --6
        when "0111" => cat<= "1111000";  --7
        when "1000" => cat<= "0000000";  --8
        when "1001" => cat<= "0010000";  --9
        when "1010" => cat<= "0001000";  --A
        when "1011" => cat<= "0000011";  --b
        when "1100" => cat<= "1000110";  --C
        when "1101" => cat<= "0100001";  --d
        when "1110" => cat<= "0000110";  --E
        when "1111" => cat<= "0001110";  --F
        when others => cat<= "1000000";  --0
     end case;
end process;



end Behavioral;
