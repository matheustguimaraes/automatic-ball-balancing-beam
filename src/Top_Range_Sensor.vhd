library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Top_Range_Sensor is 
	port(
		-- Pino para pulso de entrada
		pulse_pin: in std_logic;
		-- Pino para saida do Trigger
		trigger_pin: out std_logic;
		-- Pino do Clock FPGA
		clock: in std_logic;
		servo: out std_logic;
		an: out std_logic_vector(2 downto 0);
		sseg: out std_logic_vector (7 downto 0)
 	);
end entity;

architecture Arch of Top_Range_Sensor is
component trigger_generator is 
	port(
		clk: in std_logic;
		trigger: out std_logic
	);
end component; 
	
component Distance_calculator is
	port(
		clk: in std_logic;
		Calculation_Reset: in std_logic;
		pulse :in std_logic;
		Distance: out std_logic_vector(8 downto 0)
	);
end component;
	
component BCD_converter is
  port(
	Distance : in std_logic_vector(8 downto 0);
	hundreds, tens, unit: out std_logic_vector(3 downto 0)
  );
end component;

component display_ctr is port
(
  clk: in std_logic;
  in2, in1, in0: in std_logic_vector(3 downto 0);
  an: out std_logic_vector(2 downto 0);
  sseg: out std_logic_vector (7 downto 0)
);
end component;

component PWM is 
	port(
		clk: in std_logic;
		data: in std_logic_vector(25 downto 0);
		servo: out std_logic
	);
end component;

-- Sinais para unidades de medidas
signal Ai: std_logic_vector(3 downto 0);
signal Bi: std_logic_vector(3 downto 0);
signal Ci: std_logic_vector(3 downto 0);
signal distance_out: std_logic_vector(8 downto 0);
signal trigg_out: std_logic;

begin
	trigger_pin <= trigg_out;

	trig: trigger_generator port map(clock,	trigg_out);
	dist: Distance_calculator port map(clock, 	trigg_out, 	pulse_pin, distance_out);
	PWM1 : PWM generic map ("000010100") port map(clock, "00000000001100001101010000", servo);
	BCD_conv: BCD_converter port map(distance_out, 	Ai, 	Bi,	 Ci);
	display: display_ctr port map(clock,	 Ai, 	Bi,	 Ci,	 an, 	sseg);
end Arch;