library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.std_logic_unsigned.all;
 
entity PWM is 

	port(
		clk: in std_logic;
		data: in std_logic_vector(25 downto 0);
		servo: out std_logic
	);
end entity;
 
architecture Behavioral of PWM is

signal servo_tmp: std_logic := '1';

-- de acordo com as especificacoes do servo motor e da placa FPGA 50000000
constant period_1hz: 	std_logic_vector(25 downto 0) := "00000011110100001001000000"; -- 50 Hz 

begin  
	process(clk) 
	variable count: integer := 0;
	begin
	if clk'event and clk = '1' then
	
		if(count < to_integer(unsigned(data))) then
			servo_tmp <= '1';
		else
			servo_tmp <= '0';
		end if;  


		if(count = to_integer(unsigned(period_1hz)) - 1) then
			count := 0;
		else
			count := count + 1;
		end if;
	 end if;	
	end process;

servo <= servo_tmp;

end Behavioral;