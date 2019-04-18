--####################################################
-- SISTEMAS DIGITAIS
-- Projeto de controle de um motor de passo
-- controla: sentido, velocidade e passos 
--
--####################################################
--
--
--######## BIBLIOTECAS ########
--
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
--
--#############################
--
--
--
--######### Declaracaoo da Entidade ########
--
--      (somente entradas e saidas !!!) 
--
--#########################################
--
entity motor_passo is

    port
    (
        CLOCK, DADO, SINC : in std_logic;      
        ON_OFF: in bit;            
        A1,A2,B1,B2, LIGA_LED : out bit
     ); 		

end entity;

architecture circuito of motor_passo is

	signal vetor_dados     : std_logic_vector(10 downto 0); -- "00000000000" 11 bits, recebe os dados
    signal sentido_rotacao : std_logic; -- 0 ou 1, 1 bit
    signal velocidade      : std_logic_vector(0 to 1); -- "00"
    signal passos          : integer range 0 to 200; -- "00000000";
    signal conta_ler       : integer range 0 to 10 :=10; -- contador leitura
    signal conta_aciona    : integer range 0 to 255 :=0; 
    signal bobina          : bit_vector(0 to 3):="1000"; -- "00"      

--#### Inicio dos sinais para intertravamento ####
    signal chave : bit;
    signal leitura : bit := '1';
    signal aciona  : bit := '0'; 
    signal VELOC   : std_logic;
--#### Fim dos sinais para intertravamento ####


--#### Inicio dos sinais do processo velocidades ####    
        
    signal cont_veloc1 : integer range 0 to 400001 :=1; -- 25Hz
    signal cont_veloc2 : integer range 0 to 200001:=1;  -- 50Hz
    signal cont_veloc3 : integer range 0 to 80001:=1;  -- 125Hz
    
--    signal cont_veloc1 : integer range 0 to 101 :=1; -- 8Hz
--    signal cont_veloc2 : integer range 0 to 31  :=1;  -- 4Hz
--    signal cont_veloc3 : integer range 0 to 11  :=1;  -- 1.6Hz
--#### Fim dos sinais do processo velocidade ####


begin

chave <= leitura xor aciona;  -- faz o intertravamento

LIGA_LED <= '1';

PROC_LEITURA: 
    process(SINC, ON_OFF, chave)  --#### Inicio do processo de leitura dos dados ####
    begin

        if (chave = '1') and (ON_OFF='1') then
			if FALLING_EDGE(SINC) then  --avalia se o clock eh de descida 
            					
					if (conta_ler > 0) then
						vetor_dados(conta_ler) <= DADO;
						conta_ler <= conta_ler - 1;
					elsif (conta_ler = 0) then
						vetor_dados(conta_ler) <= DADO;
						conta_ler <= 10;
						
						sentido_rotacao <= vetor_dados(10);
						velocidade <= vetor_dados(9 downto 8);
						passos <= conv_integer(vetor_dados(7 downto 0));
												
						leitura <= not leitura;
					end if;	
        end if;
        end if;
    end process;  --#### Fim do processo de leitura dos dados ####








    
PROC_VELOCIDADE:  
    process(CLOCK, ON_OFF, chave) -- #### Inicio do processo de velocidades ####
    begin
           
        if (chave = '0') and (ON_OFF='1') then
            if (FALLING_EDGE(CLOCK)) then 
    
 --###### 25Hz ######
                if (velocidade = "00") then
                    if cont_veloc1 < 200000 then
                        VELOC <='0';
                        cont_veloc1 <= cont_veloc1 + 1;
                    
                    elsif cont_veloc1 >= 200000 and cont_veloc1 < 400000 then
                        VELOC <='1';
                        cont_veloc1 <= cont_veloc1 + 1;
                
                    else
                        cont_veloc1 <= 1;
                
                    end if;
                end if;
--#### Fim 8Hz ####


--###### 4Hz ######
                if (velocidade = "01") then           
                    if cont_veloc2 < 100000 then
                        VELOC <='0';
                        cont_veloc2 <= cont_veloc2 + 1;
                    
                    elsif cont_veloc2 >= 100000 and cont_veloc2 < 200000 then
                        VELOC <='1';
                        cont_veloc2 <= cont_veloc2 + 1;
                    
                    else
                        cont_veloc2 <= 1;
                    
                    end if;
                end if;
--#### Fim 4Hz ####            
            
            
--##### 1.6 Hz #### 
                if (velocidade = "10") then           
                    if cont_veloc3 < 40000 then
                        VELOC <='0';
                        cont_veloc3 <= cont_veloc3 + 1;
                    
                    elsif cont_veloc3 >= 40000 and cont_veloc3 < 80000 then
                        VELOC <='1';
                        cont_veloc3 <= cont_veloc3 + 1;
                    
                    else
                        cont_veloc3 <= 1;
                
                    end if;
                end if;
--#### Fim 1.6Hz ####
            end if;
        end if;
        
    end process; --#### Fim do processo de velocidades ####








PROC_ACIONAMENTO: 
	process(VELOC, ON_OFF, chave)  --####Inicio do processo de acionamento do motor ####
	begin
		
		if (chave = '0') and (ON_OFF='1') then 
            if (FALLING_EDGE(VELOC)) then
				
	            if (conta_aciona < passos) then
	            				
					if (sentido_rotacao = '0') then
						bobina <= bobina ROR 1;
						conta_aciona <= conta_aciona +1;
					else
						bobina <= bobina ROL 1;
						conta_aciona <= conta_aciona +1;
					end if;			
	            
				else
					conta_aciona <= 0;
					aciona <= not aciona;
	            
				end if;
			
            end if;
		end if;	



	end process;


A1 <= bobina(0);
A2 <= bobina(1);
B1 <= bobina(2);
B2 <= bobina(3);

end circuito;  --####Fim do processo de acionamento do motor ####
