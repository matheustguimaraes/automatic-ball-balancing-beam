library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity Pid is
    Port ( 
           clock : in STD_LOGIC;
	   ADC_DATA : in  STD_LOGIC_VECTOR (8 downto 0);   -- entrada de 9 bits sem sinal PID
           DAC_DATA : out  STD_LOGIC_VECTOR (8 downto 0)   -- saida de 9 bits sem sinal
	   );
end entity;

architecture Behavioral of Pid is             -- tipos de estado do sistema
    type statetypes is (Reset,		   -- reset para determinar o fluxo do sistema
			CalculateNewError, -- calcular novo erro
			CalculatePID,      -- calcular PID
			DivideKg,          -- dividir Kg
			Write2DAC,         -- escrever de volta a saida DAC na entrada ADC
			SOverload,         -- impedir overflow
			ConvDac);	   -- enviar valor atual de DAC no sistema                             
    
    signal state,next_state : statetypes := Reset; -- dois tipos de estado atual e o proximo
    signal Kp : integer := 100;	       -- constante proporcional
    signal Kd : integer := 50;	       -- constante diferencial
    signal Ki : integer := 10;	       -- constante integral
    signal Output : integer := 1;      -- saida intermediaria
    signal inter : integer := 0;       -- signal intermediario
    signal SetVal : integer := 35000;  -- valor definido, isso e o que o loop do PID tenta atingir (colocar o ponto medio da reta)
    signal sAdc : integer := 0;        -- armazena o valor inteiro convertido da entrada ADC
    signal Error : integer := 0;       -- armazena o desvio da entrada para o valor definido
    signal p,i,d : integer := 0;       -- contem o proporcional, derivado e integral erro respectivamente
    signal DacDataCarrier: std_logic_vector (8 downto 0); -- contem o valor convertido em binario da saida para o DAC  
  
begin
PROCESS(clock, state, Kp, Kd, Ki, Output, inter, SetVal, sAdc, Error, p,i,d, DacDataCarrier)  -- sensivel ao clock e estado presente
      variable Output_Old : integer := 0;   
      variable Error_Old : integer := 0;
     BEGIN	 
         IF clock'EVENT AND clock = '1' THEN  
				state <= next_state;
         END IF;
         case state is
		 when Reset =>
			sAdc <= to_integer(unsigned(ADC_DATA));  -- capturar a entrada para calcular o PID
			next_state <= CalculateNewError;         -- calcular novo erro depois do reset
			Error_Old := Error;                      -- capturar o erro antigo
			Output_Old := Output;                    -- capturar a saida  PID antiga
			
		  when CalculateNewError =>
			next_state <= CalculatePID;                  -- calcular novo PID
			inter <= (SetVal-sAdc);                      -- calcular erro, valor objetivo menos valor que atual
			Error <= to_integer(to_unsigned(inter,32));  -- declara um valor inteiro como o calculo de inter
		  
		  when CalculatePID =>
			next_state <= DivideKg;       -- dividir o valor de Kg
			p <= Kp * (Error);            -- calcular PID, multiplicando o erro atual por Kp 
			i <= Ki * (Error+Error_Old);  -- multiplica o valor de Ki com o erro mais o erro antigo
			d <= Kd * (Error-Error_Old);  -- multiplica o valor de Kd com o erro menos o erro antigo    
				
		  when DivideKg =>
			next_state <= SOverload;            -- impedir overlflow de bits no sistema
			Output <=  Output_Old+(p+i+d)/2048; -- calcular nova entrada (/2048 para escalar da saida corretamente)
		  
		  when SOverload =>
			next_state <=ConvDac;	   -- feito para manter a saida dentro de 16 bits
			if Output > 511 then       -- se for mair que 9 bits, permanece no valor maximo
				 Output <= 511;
			end if;     
			if Output < 1 then         -- se for menor, permanece no valor 1
				 Output <= 1;
			end if;
				
		  when ConvDac =>        		                             -- enviar a saida para porta
			DacDataCarrier <= std_logic_vector(to_unsigned(Output, 9));  -- receber a saida de output com 16 bits
			next_state <= Write2DAC;
			
		  when Write2DAC =>		     -- enviar a saida para o DAC
			next_state <= Reset;         -- retornar o loop para o proximo reset
			DAC_DATA <= DacDataCarrier;  -- enviar o valor atual de DAC na entrada DAC_DATA
	 end case;

                        
END PROCESS;	-- fim do processo
end Behavioral;		-- Fim da Arquitetura