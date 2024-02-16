
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity RegFileMIPS is
  Port ( 
        clk: in std_logic;
        enable_mpg: in std_logic;
        RegWrite: in std_logic;
        RA1: in std_logic_vector(2 downto 0);
        RA2: in std_logic_vector(2 downto 0);
        WA: in std_logic_vector(2 downto 0);
        WD: in std_logic_vector(15 downto 0);
        RD1: out std_logic_vector(15 downto 0);
        Rd2: out std_logic_vector(15 downto 0)
  );
end RegFileMIPS;

architecture Behavioral of RegFileMIPS is
   
    type register_array is array (0 to 7) of std_logic_vector(15 downto 0);
      signal reg_file: register_array := (
          x"0002", --000
          x"0901", --001 
          x"2002", --010
          x"00CD", --011
          x"34CA", --100
          others=>x"0000"
      );
begin
    process (clk) 
    begin
        if rising_edge(clk) then
            if RegWrite = '1' then
                if enable_mpg = '1' then
                    reg_file(conv_integer(WA)) <= WD;
                end if;
            end if;
        end if;
    end process;
    
    RD1 <= reg_file(conv_integer(RA1));
    RD2 <= reg_file(conv_integer(RA2));

end Behavioral;