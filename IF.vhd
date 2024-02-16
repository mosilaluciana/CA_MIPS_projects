library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--use IEEE.NUMERIC_STD.ALL;

entity InstrFile is
    Port ( 
        Clk:in std_logic;
        pcSrc :in std_logic;
        BranchAddr:in std_logic_vector(15 downto 0);
        JmpAddr:in std_logic_vector(15 downto 0);
        Jump:in std_logic;
        Instr:out std_logic_vector(15 downto 0);
        pcPlus: out std_logic_vector(15 downto 0);
        en: in std_logic
        );
end InstrFile;

architecture Behavioral of InstrFile is
    signal pcAddr :  std_logic_vector(15 downto 0);
    signal mx1 : std_logic_vector(15 downto 0);
    signal mx2 : std_logic_vector(15 downto 0);
    
   --  type ROM_type is array(0 downto 255) of std_logic_vector(15 downto 0);
    -- signal ROM_M: ROM_type := (x"0105", x"1234", x"78AF", others =>x"128C");

     type ROM_type is array(0 to 255) of std_logic_vector(15 downto 0);
     signal ROM_M: ROM_type := (x"0001",x"0005", x"000A", x"0F09",x"FF10",others=>x"0000");

begin

      
Instr <= ROM_M (conv_integer(pcAddr(7 downto 0))); --ROM

MUX1: process(pcSrc)
    begin
    if pcSrc='0' then
        mx1<=pcAddr +1;
    else
        mx1<=BranchAddr;    
    end if;
end process;

MUX2: process(Jump,mx1,JmpAddr)
    begin 
     if Jump='0' then 
        mx2<=mx1;
    else
        mx2<=JmpAddr;
    end if;  
end process;

pcPlus <= pcAddr+1; --SUMATORUL

PC: process(clk)
begin
    if rising_edge(clk) then
        if en='1' then
             mx1<=pcAddr;
        end if;
   end if;
end process;


end architecture;