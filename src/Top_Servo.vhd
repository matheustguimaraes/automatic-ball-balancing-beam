library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.std_logic_unsigned.all;
 
entity Top_Servo is 
	port(
		clk : in std_logic;
		pulse : in std_logic;
		trigger_out : out std_logic;
		servo : out std_logic;
		an : out std_logic_vector(2 downto 0);
		sseg : out std_logic_vector (7 downto 0)		
	);
end entity;
architecture Behavioral of Top_Servo is
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

component Pid is
    Port ( 
           clock : in STD_LOGIC;
			  ADC_DATA : in  STD_LOGIC_VECTOR (8 downto 0);
           DAC_DATA : out  STD_LOGIC_VECTOR (8 downto 0)
	   );
end component;

component PWM is 
	generic(
		setpoint: std_logic_vector(8 downto 0) := "000010100"
	);
	port(
		clk: in std_logic;
		data: in std_logic_vector(8 downto 0);
		servo: out std_logic
	);
end component;

component Top_Range_Sensor is 
	port(
		pulse_pin : in std_logic;
		trigger_pin : out std_logic;
		clock : in std_logic;
		an : out std_logic_vector(2 downto 0);
		sseg : out std_logic_vector (7 downto 0)
 	);
end component;

signal distance_out: std_logic_vector(8 downto 0);
signal data_temp: std_logic_vector(8 downto 0);
signal trigg_out: std_logic;

begin
	trigger_out <= trigg_out;

	trig1: trigger_generator 	port map(clk,	trigg_out);
	dist1: Distance_calculator 	port map(clk, 	trigg_out, 	pulse, 		distance_out);
	pid1: Pid 			port map(clk, 	distance_out, 	data_temp);
	PWM1 : PWM generic map ("000010100") port map(clk, data_temp, servo);
	top1 : Top_Range_Sensor port map(pulse, open, clk, an, sseg);

end Behavioral;
