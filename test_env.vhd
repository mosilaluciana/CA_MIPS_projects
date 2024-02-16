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

signal cnt : std_logic_vector(15 downto 0) := X"0000";
signal enable_mpg : std_logic := '0';
signal cnt2: std_logic_vector(1 downto 0) := "00"; -- iesirea numaratorului pe 2 biti
signal zero_ext1: std_logic_vector(15 downto 0) := X"0000";
signal zero_ext2: std_logic_vector(15 downto 0) := X"0000";
signal zero_ext3: std_logic_vector(15 downto 0) := X"0000";
signal sum: std_logic_vector(15 downto 0) := X"0000";
signal dif: std_logic_vector(15 downto 0) := X"0000";
signal left_shift2: std_logic_vector(15 downto 0) := X"0000";
signal right_shift2: std_logic_vector(15 downto 0) := X"0000";
signal digits: std_logic_vector(15 downto 0) := X"0000"; -- iesrea de la mux 4:1

-- Lab03 
-- ROM 256 x 16 -- memoria de instructiuni
type rom_array is array (0 to 255) of std_logic_vector(15 downto 0);
signal rom256x16: rom_array := (
    B"000_000_000_001_0_000",       -- add $1, $0, $0       #0010
    B"001_000_100_0001010",         -- addi $4, $0, 10      #220A
    B"000_000_000_010_0_000",       -- add $2, $0, $0       #0020
    B"000_000_000_000_0_000",       -- noop                 #0000
    B"000_000_000_000_0_000",       -- noop                 #0000
    B"010_010_101_0000000",         -- lw $5, 0($2)         #4A80
    B"100_001_100_0010001",         -- beq $1, $4, 17       #8611
    B"000_000_000_000_0_000",       -- noop                 #0000
    B"000_000_000_000_0_000",       -- noop                 #0000
    B"000_000_000_000_0_000",       -- noop                 #0000
    B"010_010_011_0000000",         -- lw $3, 0($2)         #4980
    B"000_000_000_000_0_000",       -- noop                 #0000
    B"000_000_000_000_0_000",       -- noop                 #0000
    B"000_101_011_110_0_001",       -- sub $6, $5, $3       #15E1
    B"000_000_000_000_0_000",       -- noop                 #0000
    B"000_000_000_000_0_000",       -- noop                 #0000
    B"101_110_000_0000100",         -- bgez $6, 4           #B804
    B"000_000_000_000_0_000",       -- noop                 #0000
    B"000_000_000_000_0_000",       -- noop                 #0000
    B"000_000_000_000_0_000",       -- noop                 #0000
    B"000_000_011_101_0_000",       -- add $5, $0, $3       #01D0
    B"001_010_010_0000010",         -- addi $2, $2, 2       #2902
    B"001_001_001_0000001",         -- addi $1, $1, 1       #2481
    B"111_0000000000110",           -- j 6                  #E006
    B"000_000_000_000_0_000",       -- noop                 #0000
    B"011_000_101_0010100",         -- sw $5, 20($0)        #6294
    others => x"1111"
);

signal counter8: std_logic_vector(7 downto 0) := x"00"; -- numarator pe 8 biti pentru memorie ROM

-- bloc de registre
signal enable_mpg2 : std_logic := '0';
signal cnt4 : std_logic_vector(3 downto 0) := "0000"; -- numaratorul pentru generarea adreselor
signal rd1_temp : std_logic_vector(15 downto 0) := x"0000";
signal rd2_temp : std_logic_vector(15 downto 0) := x"0000";

-- RAM write first
signal do_shifted : std_logic_vector(15 downto 0) := x"0000"; -- iesirea deplasata la stanga cu 2

component mpg is
  Port ( clk : in std_logic;
        btn : in std_logic;
        enable : out std_logic );
end component;

component SSD is
Port ( 
  clk: in std_logic;
  number : in std_logic_vector(15 downto 0);
    an: out std_logic_vector(3 downto 0);
  cat: out std_logic_vector(6 downto 0)
);
end component;

component reg_file is
  Port (
    clk : in std_logic;
    ra1 : in std_logic_vector(3 downto 0);
    ra2 : in std_logic_vector(3 downto 0);
    wa : in std_logic_vector(3 downto 0);
    wd : in std_logic_vector(15 downto 0);
    reg_wr : in std_logic;
    rd1 : out std_logic_vector(15 downto 0);
    rd2 : out std_logic_vector(15 downto 0) 
   );
end component;

component ram_write_first is
  Port ( 
    clk : in std_logic;
    we : in std_logic;
    en : in std_logic;
    addr : in std_logic_vector(3 downto 0);
    di : in std_logic_vector(15 downto 0);
    do : out std_logic_vector(15 downto 0)
  );
end component;

------------------------------------------------------------ MIPS ------------------------------------------------------------
signal current_instr : STD_LOGIC_VECTOR (15 downto 0) := x"0000";
signal next_instr : STD_LOGIC_VECTOR(15 downto 0) := x"0000";
signal ssd_signal : STD_LOGIC_VECTOR(15 downto 0) := x"0000";
------------ semnale IF ------------
signal jmp_addr: STD_LOGIC_VECTOR (15 downto 0);
------------ semnale ID ------------
signal rdata1:  STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
signal rdata2:  STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
signal wdata:   STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
signal func:    STD_LOGIC_VECTOR(2 downto 0) := (others => '0');
signal extImm:  STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
signal sa:      STD_LOGIC := '0';
signal rd:      STD_LOGIC_VECTOR(2 downto 0) := "000";
signal rt:      STD_LOGIC_VECTOR(2 downto 0) := "000";

------------ semnale UC ------------
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

------------ semnale ALU ------------
signal sgn: std_logic := '0';
signal Zero: STD_LOGIC := '0';
signal Sign: STD_LOGIC := '0';
signal BranchAddr: STD_LOGIC_VECTOR (15 downto 0) := X"0000";
signal Gez: STD_LOGIC := '0'; 
signal ALURes: STD_LOGIC_VECTOR (15 downto 0) := X"0000";

------------ semnale EX ------------
signal WriteAddress: std_logic_vector(2 downto 0) := "000";

------------ semnale MEM ------------

signal r_data: std_logic_vector (15 downto 0) := X"0000";

------------ semnale WB ------------
signal PCSrc: std_logic;

------------ Registri intermediari MIPS pipeline ------------

signal IF_ID: std_logic_vector(31 downto 0);
signal ID_EX: std_logic_vector(85 downto 0);
signal EX_MEM: std_logic_vector(58 downto 0);
signal MEM_WB: std_logic_vector(36 downto 0);


------------ componente PIPELINE ------------

component InstrFetch is
  Port ( clk : in STD_LOGIC;
         en : in STD_LOGIC;
         clr : in STD_LOGIC;
         branch_addr : in STD_LOGIC_VECTOR (15 downto 0);
         jmp_addr : in STD_LOGIC_VECTOR (15 downto 0);
         jump : in STD_LOGIC;
         PCSrc : in STD_LOGIC;
         current_instr : out STD_LOGIC_VECTOR (15 downto 0);
         next_instr_addr : out STD_LOGIC_VECTOR (15 downto 0));
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
end component;

component InstrDecode is
  Port (
        clk: in std_logic;
        enable: in std_logic;
        RegWrite: in std_logic;
        instr: in std_logic_vector(15 downto 0);
        RegDst: in std_logic;
        WD: in std_logic_vector(15 downto 0);
        ExtOp: in std_logic;
        WriteAddress: in std_logic_vector(2 downto 0);
        RD1: out std_logic_vector(15 downto 0);
        RD2: out std_logic_vector(15 downto 0);
        ExtImm: out std_logic_vector(15 downto 0);
        func: out std_logic_vector(2 downto 0);
        sa: out std_logic;
        rt: out std_logic_vector(2 downto 0);
        rd: out std_logic_vector(2 downto 0)
   );
end component;

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
        RegDst: in std_logic;
        rt: in std_logic_vector(2 downto 0);
        rd: in std_logic_vector(2 downto 0);
        Zero: out STD_LOGIC;
        Sign: out STD_LOGIC;
        BranchAddr: out STD_LOGIC_VECTOR (15 downto 0);
        Gez: out STD_LOGIC; -- iesire pentru bgez (sign negat)
        WriteAddress: out std_logic_vector(2 downto 0)
   );
end component;

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
end component;

begin
    
    MPG1: mpg port map(clk, btn(0), enable_mpg);
    MPG2: mpg port map(clk, btn(1), enable_mpg2);
    SSDC: SSD port map(clk, ssd_signal(15 downto 0), an, cat);
    INSTR_FETCH: InstrFetch port map(clk, enable_mpg, enable_mpg2, BranchAddr, jmp_addr, jump, PCSrc, current_instr, next_instr);
    INSTR_DECODER: InstrDecode port map(clk => clk, enable => enable_mpg, RegWrite => MEM_WB(1), instr => IF_ID(31 downto 16), RegDst => regDst, WD => wdata, ExtOp => extOp, WriteAddress => WriteAddress, RD1 => rdata1, RD2 => rdata2, ExtImm => extImm, func => func, sa => sa, rt => rt, rd => rd);
    MAIN_CONTROL: MC port map(Instr => IF_ID(31 downto 16), RegDst => regDst, ExtOp => extOp, ALUSrc => aluSrc, Branch => branch, Bgez => bgez, Bltz => bltz, Jump => jump, Slt => slt, MemWrite => memWrite, MemtoReg => memToReg, RegWrite => regWrite, ALUOp => aluOp);
    
   
    -- EX
    EX_COMP: ALU port map(RD1 => ID_EX(44 downto 29), ALUSrc => ID_EX(1), RD2 => ID_EX(60 downto 45), Ext_Imm => ID_EX(76 downto 61), sa => ID_EX(12), func => ID_EX(79 downto 77), ALUOp => ID_EX(8 downto 6), PCNext => ID_EX(28 downto 13), RegDst => ID_EX(0), rt => ID_EX(82 downto 80), rd => ID_EX(85 downto 83), Zero => Zero, Sign => Sign, BranchAddr => BranchAddr, Gez => Gez, ALURes => ALURes, WriteAddress => WriteAddress);
    
    -- MEM
    MEM_COMP: MEM port map(clk, enable_mpg, EX_MEM(2), EX_MEM(39 downto 24), EX_MEM(55 downto 40), r_data, EX_MEM(39 downto 24));
    
    -- logica combinationala suplimentara - pentru bgez, bltz
    PCSrc <= (EX_MEM(3) and EX_MEM(22)) or (EX_MEM(4) and (not EX_MEM(23))) or (EX_MEM(5) and EX_MEM(23));
    
    -- wb
    wdata <= MEM_WB(17 downto 2) when MEM_WB(0) = '1' else MEM_WB(33 downto 18);
    
    -- jump
    jmp_addr <= "000" & IF_ID(28 downto 16);
    
    -- afisare
    mux_afisare: process(sw(7 downto 5))
                         begin 
                         case sw(7 downto 5) is
                            when "000" => ssd_signal <= IF_ID(15 downto 0);
                            when "001" => ssd_signal <= IF_ID(31 downto 16);
                            when "010" => ssd_signal <= ID_EX(44 downto 29);
                            when "011" => ssd_signal <= EX_MEM(55 downto 40);
                            when "100" => ssd_signal <= ID_EX(76 downto 61);
                            when "101" => ssd_signal <= MEM_WB(33 downto 18);
                            when "110"=>  ssd_signal <= MEM_WB(17 downto 2);
                            when others=> ssd_signal <= wdata;
                         end case;
                         end process;
    
    -- proces registre intermediare
    process(clk, enable_mpg)
        begin
            if(enable_mpg = '1') then
                if(rising_edge(clk)) then
                    IF_ID(15 downto 0) <= next_instr;
                    IF_ID(31 downto 16) <= current_instr;
                    
                    ID_EX(0) <= RegDst;
                    ID_EX(1) <= ALUSrc;
                    ID_EX(2) <= branch;
                    ID_EX(3) <= bgez;
                    ID_EX(4) <= bltz;
                    ID_EX(5) <= slt;
                    ID_EX(8 downto 6) <= aluOp;--
                    ID_EX(9) <= memWrite;
                    ID_EX(10) <= memToReg;
                    ID_EX(11) <= regWrite;
                    ID_EX(12) <= sa;
                    ID_EX(28 downto 13) <= IF_ID(15 downto 0);
                    ID_EX(44 downto 29) <= rdata1;
                    ID_EX(60 downto 45) <= rdata2;
                    ID_EX(76 downto 61) <= extImm;
                    ID_EX(79 downto 77) <= func;
                    ID_EX(82 downto 80) <= rt;
                    ID_EX(85 downto 83) <= rd;
                    
                    EX_MEM(0) <= ID_EX(10);
                    EX_MEM(1) <= ID_EX(11);
                    EX_MEM(2) <= ID_EX(9);
                    EX_MEM(3) <= ID_EX(2);
                    EX_MEM(4) <= ID_EX(3);
                    EX_MEM(5) <= ID_EX(4);
                    EX_MEM(21 downto 6) <= BranchAddr;
                    EX_MEM(22) <= Zero;
                    EX_MEM(23) <= Sign;
                    EX_MEM(39 downto 24) <= ALURes;
                    EX_MEM(55 downto 40) <= ID_EX(60 downto 45);
                    EX_MEM(58 downto 56) <= WriteAddress;    
                    
                    MEM_WB(0) <= EX_MEM(0);
                    MEM_WB(1) <= EX_MEM(1);
                    MEM_WB(17 downto 2) <= r_data;
                    MEM_WB(33 downto 18) <= EX_MEM(39 downto 24);
                    MEM_WB(36 downto 34) <= EX_MEM(58 downto 56);
                    
                end if;
            end if;
        end process;
end Behavioral;
