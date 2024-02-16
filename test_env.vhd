library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity test_env is
    Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC_VECTOR (4 downto 0);
           sw : in STD_LOGIC_VECTOR (15 downto 0);
           led : out STD_LOGIC_VECTOR (15 downto 0);
           an : out STD_LOGIC_VECTOR (3 downto 0);
           cat : out STD_LOGIC_VECTOR (6 downto 0));
end test_env;

architecture Behavioral of test_env is

signal enable: std_logic;
signal enable2: std_logic;
signal PCPlus :  STD_LOGIC_VECTOR (15 downto 0):=X"0000";
signal  Instr :  STD_LOGIC_VECTOR (15 downto 0):=X"0000";
signal current_instr : STD_LOGIC_VECTOR (15 downto 0) := x"0000";
signal next_instr : STD_LOGIC_VECTOR(15 downto 0) := x"0000";
signal ssd_signal : STD_LOGIC_VECTOR(15 downto 0) := x"0000";


signal jmp_addr: STD_LOGIC_VECTOR (15 downto 0);

signal rdata1:  STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
signal rdata2:  STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
signal wdata:   STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
signal func:    STD_LOGIC_VECTOR(2 downto 0) := (others => '0');
signal extImm:  STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
signal sa:      STD_LOGIC := '0';

signal regDst:   STD_LOGIC := '0';
signal extOp:    STD_LOGIC := '0';
signal aluSrc:   STD_LOGIC := '0';
signal branch:   STD_LOGIC := '0';
signal bgez:   STD_LOGIC := '0';
signal bltz:    STD_LOGIC := '0';
signal jump:     STD_LOGIC := '0';
signal memWrite: STD_LOGIC := '0';
signal memToReg: STD_LOGIC := '0';
signal regWrite: STD_LOGIC := '0';
signal aluOp:    STD_LOGIC_VECTOR(2 downto 0) := "000"; 
signal slt: STD_LOGIC := '0';

signal sgn: std_logic := '0';
signal Zero: STD_LOGIC := '0';
signal Sign: STD_LOGIC := '0';
signal BranchAddr: STD_LOGIC_VECTOR (15 downto 0) := X"0000";
signal Gez: STD_LOGIC := '0'; 
signal ALURes: STD_LOGIC_VECTOR (15 downto 0) := X"0000";



signal r_data: std_logic_vector (15 downto 0) := X"0000";


signal PCSrc: std_logic;
signal mux : STD_LOGIC_VECTOR(15 downto 0);


component  MPG is
    Port ( btn : in STD_LOGIC;
           clk : in STD_LOGIC;
           enable : out STD_LOGIC);
end component;

component SSD is
    Port ( clk : in STD_LOGIC;
           number : in STD_LOGIC_VECTOR (15 downto 0);
           an : out STD_LOGIC_VECTOR (3 downto 0);
           cat : out STD_LOGIC_VECTOR (6 downto 0));
end component;

component InstrFetch is
    Port ( 
        Clk:in std_logic;
         en: in std_logic;
        pcSrc :in std_logic;
        BranchAddr:in std_logic_vector(15 downto 0);
        JmpAddr:in std_logic_vector(15 downto 0);
        Jump:in std_logic;
        Instr:out std_logic_vector(15 downto 0);
        pcPlus: out std_logic_vector(15 downto 0)
       
        );
end component;

 component InstrDecode is
       Port(
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
end component;

component MC is
  Port ( 
        Instr : in std_logic_vector(15 downto 0);
        RegDst : out std_logic;
        ExtOp : out std_logic;
        ALUSRC : out std_logic;
        Branch : out std_logic;
        Bgez : out std_logic;
        Bltz : out std_logic;
        Jump : out std_logic;
        MemWrite : out std_logic;
        MemtoReg : out std_logic;
        RegWrite : out std_logic;
        ALUOp : out std_logic_vector(2 downto 0);
        Slt : out std_logic
   );
end component MC;

component ALU is
  Port (
        RD1: in STD_LOGIC_VECTOR (15 downto 0);
        ALUSrc: in STD_LOGIC;
        RD2: in STD_LOGIC_VECTOR (15 downto 0);
        Ext_Imm: in STD_LOGIC_VECTOR (15 downto 0);
        sa: in STD_LOGIC;
        func: in STD_LOGIC_VECTOR (2 downto 0);
        ALUOp: in STD_LOGIC_VECTOR (2 downto 0);
        ALURes: out STD_LOGIC_VECTOR (15 downto 0);
        PCNext: in STD_LOGIC_VECTOR (15 downto 0);
        Zero: out STD_LOGIC;
        Sign: out STD_LOGIC;
        BranchAddr: out STD_LOGIC_VECTOR (15 downto 0);
        Gez: out STD_LOGIC -- iesire pentru bgez (sign negat)
   );
end component ALU;

component MEM is
  Port ( 
        clk :       in STD_LOGIC;
        enable :    in STD_LOGIC;
        MemWrite :  in STD_LOGIC;
        Addr :      in STD_LOGIC_VECTOR (15 downto 0);
        w_data :    in STD_LOGIC_VECTOR (15 downto 0);
        r_data :    out STD_LOGIC_VECTOR (15 downto 0);
        ALUResult : out STD_LOGIC_VECTOR (15 downto 0)
  );
end component MEM;

begin

    MPG1: MPG port map( btn(0),clk, enable);
    MPG2: MPG port map( btn(1),clk, enable2);
    SSDC: SSD port map(clk,ssd_signal, an, cat);
    INSTR_FETCH: InstrFetch port map(clk, enable,PCSrc, BranchAddr, jmp_addr, jump, Instr, PCPlus);
    INSTR_DECODER: InstrDecode port map(clk, enable, regWrite, Instr, regDst, wdata, extOp, rdata1, rdata2, extImm, func, sa);
    MAIN_CONTROL: MC port map(Instr, regDst, extOp, aluSrc, branch, bgez, bltz, jump, memWrite,memToReg, regWrite, aluOp, slt);
    
   
    ALU1 : ALU port map(rdata1, aluSrc, rdata2, extImm, sa, func, aluOp,ALURes, PCPlus, Zero, Sign, BranchAddr,Gez);
    
  
    MEM_COMP: MEM port map(clk, enable, memWrite, ALURes, rdata2, r_data, ALURes);
    
  
    PCSrc <= (branch and Zero) or (bgez and Gez) or (bltz and Sign);
   
    wdata <= r_data when memToReg = '1' else ALURes;
    
    jmp_addr <= "000" & Instr(12 downto 0);
    
    mux_afisare: process(sw(7 downto 5))
                         begin 
                         case sw(7 downto 5) is
                            when "000" => ssd_signal <= Instr;
                            when "001" => ssd_signal <= PCplus;
                            when "010" => ssd_signal <= rdata1;
                            when "011" => ssd_signal <= rdata2;
                            when "100" => ssd_signal <= extImm;
                            when "101" => ssd_signal <= ALURes;
                            when "110"=>  ssd_signal <= r_data;
                            when others=> ssd_signal <= wdata;
                         end case;
                         end process;
         
 end Behavioral;