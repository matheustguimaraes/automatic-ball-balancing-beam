library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.std_logic_unsigned.all;
 
entity PWM is 
	generic(
		setpoint: std_logic_vector(8 downto 0) := "000010100" -- 20
	);
	port(
		clk: in std_logic;
		data: in std_logic_vector(8 downto 0);
		servo: out std_logic
	);
end entity;
 
architecture Behavioral of PWM is

signal servo_tmp: std_logic := '1';


constant period_1hz: std_logic_vector(23 downto 0) := "010011000100101101000000"; -- 50 mHz 
constant middle: std_logic_vector(23 downto 0) := "000010110111000110110000"; -- 15 por cento
constant right_servo: std_logic_vector(23 downto 0) := "000001111010000100100000"; -- 10 por cento
constant left_servo: std_logic_vector(23 downto 0) := "000000111101000010010000"; -- 05 por cento

begin  
	process(clk) 
	variable count: integer := 0;
	begin
		if (data < setpoint) then -- descer o servo para a esquerda
			if(count < to_integer(unsigned(left_servo))) then
				servo_tmp <= '1';
			else
				servo_tmp <= '0';
			end if;  

		elsif (data > setpoint) then -- descer o servo para a direita
			if(count < to_integer(unsigned(right_servo))) then
				servo_tmp <= '1';
			else
				servo_tmp <= '0';
			end if;  

		else -- permanecer no centro
			if(count < to_integer(unsigned(middle))) then
				servo_tmp <= '1';
			else
				servo_tmp <= '0';
			end if;  
		end if;

		if(count = to_integer(unsigned(period_1hz)) - 1) then
			count := 0;
		else
			count := count + 1;
		end if;
	end process;

servo <= servo_tmp;

end Behavioral;
