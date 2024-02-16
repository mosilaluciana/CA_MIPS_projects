library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity InstrDecode is
  Port (
        clk: in std_logic;
        enable: in std_logic;
        RegWrite: in std_logic;
        instr: in std_logic_vector(15 downto 0);
        RegDst: in std_logic;
        WD: in std_logic_vector(15 downto 0);
        ExtOp: in std_logic;
        
        RD1: out std_logic_vector(15 downto 0);
        RD2: out std_logic_vector(15 downto 0);
        ExtImm: out std_logic_vector(15 downto 0);
        func: out std_logic_vector(2 downto 0);
        sa: out std_logic);
end InstrDecode;

architecture Behavioral of InstrDecode is

component RegFileMIPS is
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
end component;

signal wrAddr: std_logic_vector(2 downto 0) := ( others => '0' );

begin

    register_file: RegFileMIPS port map(clk, enable, RegWrite, instr(12 downto 10), instr(9 downto 7), wrAddr, WD, RD1, RD2 );
    mux_2_la_1: wrAddr <= instr(9 downto 7) when RegDst = '0' else instr(6 downto 4);
    
    sa <= instr(3);
    func <= instr(2 downto 0);
    ExtImm <= B"000_000_000" & instr(6 downto 0) when ExtOp = '0'
        else instr(6) & instr(6) & instr(6) & instr(6) & instr(6) & instr(6) & instr(6) & instr(6) & instr(6) & instr(6 downto 0);
    
end Behavioral;