library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity Pid is
    Port ( 
           clock : in STD_LOGIC;
	   ADC_DATA : in  STD_LOGIC_VECTOR (8 downto 0);
           DAC_DATA : out  STD_LOGIC_VECTOR (8 downto 0)
	   );
end entity;

architecture Behavioral of Pid is       
    type statetypes is (Reset,		  
			CalculateNewError,
			CalculatePID,      
			DivideKg,         
			Write2DAC,        
			SOverload,        
			ConvDac);	
    
    signal state,next_state : statetypes := Reset; 
    signal Kp : integer := 100;	       
    signal Kd : integer := 50;	      
    signal Ki : integer := 10;	      
    signal Output : integer := 1;    
    signal inter : integer := 0;     
    signal SetVal : integer := 35000; 
    signal sAdc : integer := 0;       
    signal Error : integer := 0;      
    signal p,i,d : integer := 0;      
    signal DacDataCarrier: std_logic_vector (8 downto 0);
  
begin
PROCESS(clock, state, Kp, Kd, Ki, Output, inter, SetVal, sAdc, Error, p,i,d, DacDataCarrier) 
      variable Output_Old : integer := 0;   
      variable Error_Old : integer := 0;
     BEGIN	 
         IF clock'EVENT AND clock = '1' THEN  
				state <= next_state;
         END IF;
         case state is
		 when Reset =>
			sAdc <= to_integer(unsigned(ADC_DATA));  
			next_state <= CalculateNewError;         
			Error_Old := Error;                     
			Output_Old := Output;                    
			
		  when CalculateNewError =>
			next_state <= CalculatePID;                  
			inter <= (SetVal-sAdc);                      
			Error <= to_integer(to_unsigned(inter,32)); 
		  
		  when CalculatePID =>
			next_state <= DivideKg;      
			p <= Kp * (Error);            
			i <= Ki * (Error+Error_Old); 
			d <= Kd * (Error-Error_Old);    
				
		  when DivideKg =>
			next_state <= SOverload;           
			Output <=  Output_Old+(p+i+d)/2048;
		  
		  when SOverload =>
			next_state <=ConvDac;	   
			if Output > 511 then       
				 Output <= 511;
			end if;     
			if Output < 1 then        
				 Output <= 1;
			end if;
				
		  when ConvDac =>        		                            
			DacDataCarrier <= std_logic_vector(to_unsigned(Output, 9)); 
			next_state <= Write2DAC;
			
		  when Write2DAC =>		    
			next_state <= Reset;        
			DAC_DATA <= DacDataCarrier; 
	 end case;

                        
END PROCESS;
end Behavioral;	
