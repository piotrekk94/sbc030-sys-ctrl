library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity sys_ctrl_tb is

end;

architecture arch of sys_ctrl_tb is

component sys_ctrl is
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
end component;

signal clk, rstn, as, ds, rw, tirq, pirq, dirq, mirq : std_logic;
signal fc : std_logic_vector(1 downto 0);
signal addr : std_logic_vector(31 downto 16);
signal addr_lo : std_logic_vector(3 downto 1);

begin

process
begin
	clk <= '0';
	wait for 20.835ns;
	clk <= '1';
	wait for 20.835ns;
end process;

process
begin
	rstn <= '0';
	wait for 1us;
	rstn <= '1';
end process;

process
begin
	as <= '1';
	wait for 1500ns;
	as <= '0';
	wait for 400ns;
	as <= '1';
end process;

ds <= '0';
rw <= '0';
tirq <= '1';
pirq <= '1';
dirq <= '1';
mirq <= '1';
fc <= "00";
addr <= (others => '0');
addr_lo <= "000";

dut : sys_ctrl port map(
	clk => clk,
	rstn => rstn,
	as => as,
	tirq => tirq,
	pirq => pirq,
	dirq => dirq,
	mirq => mirq,
	fc => fc,
	addr => addr,
	addr_lo => addr_lo
);

end; 