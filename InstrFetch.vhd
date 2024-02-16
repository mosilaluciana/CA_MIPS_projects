library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity InstrFetch is
 Port(
        Clk:in std_logic;
        en: in std_logic;
        pcSrc :in std_logic;
        BranchAddr:in std_logic_vector(15 downto 0);
        JmpAddr:in std_logic_vector(15 downto 0);
        Jump:in std_logic;
        Instr:out std_logic_vector(15 downto 0);
        pcPlus: out std_logic_vector(15 downto 0)--nextInstr
        );
end InstrFetch;

architecture Behavioral of InstrFetch is
    signal pcAddr :  std_logic_vector(15 downto 0):=x"0000";
    signal mx1 : std_logic_vector(15 downto 0):=x"0000";
    signal mx2 : std_logic_vector(15 downto 0):=x"0000";
    signal sum :  std_logic_vector(15 downto 0):=x"0000";
    
     type ROM_type is array(0 to 255) of std_logic_vector(15 downto 0);
        signal ROM_M: ROM_type := (
   B"001_000_001_0000000",      -- addi $1, $0, 0   j<-0   #2080
   B"001_000_010_0000001",      -- addi $2, $0, 1   i<-1   #2101
   B"001_000_011_0000101",      -- addi $3, $0, 5   n<-5   #2185
   B"001_000_100_0000000",      -- addi $4, $0, 0  s<-0    #2200
   
   B"100_001_011_0000100",      -- beq $1, $3, 4               #8584
   B"000_100_010_100_0_000",    -- add $4, $2, $4  --s=s+i     #1140
   B"001_010_010_0000010",      -- addi $2, $2, 2   -- i=i+2   #2902
   B"001_001_001_0000001",       -- addi $1, $1, 1   -- j++    #2481
   B"111_0000000000100",         --j 4                         #E004
   B"011_000_100_0010100",      -- sw $4, 20($0)        #6214
   others => x"1111");

begin

Instr <= ROM_M (conv_integer(pcAddr)); --ROM
sum <= pcAddr + 1;
 pcPlus<=sum;
MUX1: process(pcSrc)
    begin
    if pcSrc='0' then
        mx1<=sum;
    else
        mx1<=BranchAddr;    
    end if;
end process;
 
MUX2: process(Jump)
    begin 
     if Jump='0' then 
        mx2<=mx1;
    else
        mx2<=JmpAddr;
    end if;  
end process;


PC: process(clk)
begin
    if rising_edge(clk) then
        if en='1' then
            pcAddr<=mx2;
        end if;
   end if;
end process;


end architecture;