library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity sys_ctrl is
	port (
		clk : in std_logic;
		rstn : in std_logic;
		as : in std_logic;
		ds : in std_logic;
		rw : in std_logic;
		fc : in std_logic_vector(1 downto 0);
		tirq : in std_logic;
		pirq : in std_logic;
		dirq : in std_logic;
		mirq : in std_logic;
		addr : in std_logic_vector(31 downto 16);
		addr_lo : in std_logic_vector(3 downto 1);
		ipl : out std_logic_vector(2 downto 0);
		dsack0 : out std_logic;
		berr : out std_logic;
		oe : out std_logic;
		pcs : out std_logic;
		dcs : out std_logic;
		scs : out std_logic;
		romcs : out std_logic;
		ramcs : out std_logic
	);
end;

architecture arch of sys_ctrl is

signal iack : std_logic;
signal cpu_space : std_logic;

signal romcs_i : std_logic;
signal ramcs_i : std_logic;

signal pcs_i : std_logic;
signal dcs_i : std_logic;

signal ecs_i : std_logic;

constant berr_timeout : integer := 64;

signal dsack_i : std_logic;

signal as_d, as_dd : std_logic;

signal booted : std_logic;

signal berr_i : std_logic;

begin

	ipl <= "110" when dirq = '0' else
			 "101" when tirq = '0' else
			 "100" when mirq = '0' else
			 "111";
	
	romcs <= romcs_i;
	ramcs <= ramcs_i;
	pcs <= pcs_i;
	dcs <= dcs_i;

	oe <= not rw;
	cpu_space <= '1' when fc = "11" else '0';
	iack <= '1' when cpu_space = '1' and addr(19 downto 16) = "1111" else '0';
	
	berr <= berr_i;

	dsack0 <= dsack_i when (romcs_i = '0' or ramcs_i = '0') else
				 'Z' when (pcs_i = '0' or dcs_i = '0' or ecs_i = '0' or cpu_space = '1') else
				 '1';
	
	addr_decode : process(addr, as, ds, cpu_space, rstn)
	begin
		pcs_i <= '1';
		dcs_i <= '1';
		ecs_i <= '1';
		scs <= '1';
		romcs_i <= '1';
		ramcs_i <= '1';
		if(as = '0' and cpu_space = '0' and rstn = '1')then
			if(addr(31 downto 28) = "0000")then
				if(booted = '0')then
					romcs_i <= '0';
				else
					scs <= '0';
				end if;
			elsif(addr(31 downto 28) = "1110")then
				ecs_i <= '0';
			elsif(addr(31 downto 28) = "1111")then
				case addr(27 downto 26) is
					when "00" =>
						dcs_i <= '0';
					when "01" =>
						pcs_i <= '0';
					when "10" =>
						ramcs_i <= '0';
					when "11" =>
						romcs_i <= '0';
				end case;
			end if;
		end if;
	end process;
	
	bootcnt : process(rstn, as, clk)
	variable cnt : integer range 0 to 9;
	begin
		if(rstn = '0')then
			cnt := 0;
			booted <= '0';
			as_d <= '1';
			as_dd <= '1';
		elsif(rising_edge(clk))then
			as_d <= as;
			as_dd <= as_d;
			if (as_d = '0' and as_dd = '1') then
				if (cnt = 9) then
					booted <= '1';
				else
					cnt := cnt + 1;
				end if;
			end if;
		end if;
	end process;
	
	dsack : process(rstn, romcs_i, ramcs_i, clk)
	variable cnt : integer range 0 to 7;
	begin
		if(rstn = '0' or (romcs_i = '1' and ramcs_i = '1'))then
			cnt := 0;
			dsack_i <= '1';
		elsif(rising_edge(clk))then
			if(cnt = 4)then
				dsack_i <= '0';
			else
				cnt := cnt + 1;
			end if;
		end if;
	end process;
	
	berr_gen : process(rstn, as, clk)
	variable cnt : integer range 0 to berr_timeout;
	begin
		if(rstn = '0' or as = '1')then
			cnt := 0;
			berr_i <= '1';
		elsif(rising_edge(clk))then
			if(cnt = berr_timeout)then
				berr_i <= '0';
			else
				cnt := cnt + 1;
			end if;
		end if;
	end process;
end; 
