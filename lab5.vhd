library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity project_2 is
    Port ( En:in std_logic;
        Clk:in std_logic;
        PCSrc :in std_logic;
        BranchAddr:in std_logic_vector(15 downto 0);
        JmpAddr:in std_logic_vector(15 downto 0);
        Jump:in std_logic;
        Instr:out std_logic_vector(15 downto 0);
        PCplus: out std_logic_vector(15 downto 0)
        );
end project_2;

architecture Behavioral of project_2 is
    signal PcAddr :  std_logic_vector(15 downto 0);
    signal sum : std_logic_vector(15 downto 0);
    signal mx1 : std_logic_vector(15 downto 0);
    signal mx2 : std_logic_vector(15 downto 0);

begin

process(PCSrc,sum,BranchAddr)
    begin
    if PCSrc='0' then
        mx1<=sum;
    else
        mx1<=BranchAddr;    
    end if;
end process;

process(Jump)
    begin 
     if Jump='0' then 
        mx2<=mx1;
    else
        mx2<=JmpAddr;
    end if;
end process;
end architecture;