--####################################################
-- SISTEMAS DIGITAIS 2012-1
-- Controle de navegacao de um veiculo terrestre
-- por hardware embarcado em FPGA 
--
-- 
-- CIRCUITO PARA ACIONAMENTO DO MOTOR
--
--####################################################

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;


entity carro_controlado is 
	port
	( 
		CLOCK, DADO, SINC   : in std_logic;  
		T1,T2,T3,T4         : out std_logic
	);

end carro_controlado; -- fim da entidade


architecture arch of carro_controlado is

-- ####### INCIO SINAIS GLOBAIS #########
    signal MODO     : std_logic;
    signal MOV      : std_logic_vector(1 downto 0);
-- ####### FIM SINAIS GLOBAIS #########


-- #### Inicio dos sinais para intertravamento ####
    signal chave   : std_logic;
    signal leitura : std_logic := '1';
    signal aciona  : std_logic := '0'; 
-- #### Fim dos sinais para intertravamento ####

 
-- ####### INCIO SINAIS PROC_LEITURA ######### 
    signal conta_ler	: integer range 0 to 2 :=2;
    signal vetor_dados	: std_logic_vector(2 downto 0);
-- ####### FIM SINAIS PROC_LEITURA #########


-- ####### INCIO SINAIS PROC_DIVISOR: ######### 
    signal cont     : integer range 0 to 11:=1; -- contador1
--  signal cont     : integer range 0 to 20000001:=1; -- contador1 
 
    signal CLK_2s   : std_logic;
-- ####### FIM SINAIS PROC_DIVISOR: ######### 
  
  
-- ####### INCIO SINAIS PROC_ACIONAMENTO: ######### 
    signal sentido_aux	: std_logic_vector(1 to 4); 
	signal PASSO 		: integer range 0 to 5:=0;
-- ####### FIM SINAIS PROC_ACIONAMENTO: ######### 



begin

chave <= leitura xor aciona;  -- faz o intertravamento




PROC_LEITURA: 
    process(SINC)  --#### Inicio do processo de leitura dos dados ####
    begin
        if(chave='1') then 
            if falling_edge(SINC) then
        
                if (conta_ler > 0) then 
                    vetor_dados(conta_ler) <= DADO;
                    conta_ler <= conta_ler - 1;
					 
                elsif (conta_ler = 0) then
                    vetor_dados(conta_ler) <= DADO;
                    conta_ler <= 2;
                    MODO <= vetor_dados(2);
                    MOV(1) <= vetor_dados(1);
                    MOV(0) <= DADO;
                
                    leitura <= not leitura;
                end if;	
            end if;    
        end if;
    end process;  --#### Fim do processo de leitura dos dados ####








PROC_DIVISOR:
		process(CLOCK) -- clock 2 seg
		begin 
            if falling_edge(CLOCK) then  -- detecta a transicao de descida de A
			
--				if cont<10000000 then
                if cont<5 then
                    CLK_2s <='0';
                    cont <= cont + 1;

--				elsif cont>=10000000 and cont<20000000 then  
                elsif cont>=5 and cont<10 then
                    CLK_2s <='1';
                    cont <= cont + 1;		
                else
                    cont <= 1;			
                end if;
                
            end if;
		end process; --fim do processo








PROC_ACIONAMENTO: 
	process(CLK_2s)  --####Inicio do processo de acionamento do motor ####
	begin
    
-- ################# INICIO MODO MANUAL  #################

        if FALLING_EDGE(CLK_2s) then

            if (chave='0') and (MODO = '0') then -- 0 - Modo Manual
                case MOV is
                    when "00"    => sentido_aux <= "1010";  -- frente (4321) > (T1,T2,T3,T4)
                    when "01"    => sentido_aux <= "0110";  -- giro direita
                    when "10"    => sentido_aux <= "1001";  -- giro esquerda
                    when "11"    => sentido_aux <= "0101";  -- tras
                    when others  => sentido_aux <= "0000";  -- parado
                end case;
                aciona <= not aciona;
                
-- ################# FIM MODO MANUAL  #################
				
                
-- ################# INICIO MODO AUTOMATICO  #################	
				
            elsif (chave = '0') and (MODO = '1') then   -- 1 - Modo Automatico
                if (PASSO <= 4) then
                    case PASSO is
                        when 0      => sentido_aux <= "1010";  -- frente
						when 1      => sentido_aux <= "0110";  -- giro direita
						when 2      => sentido_aux <= "0101";  -- tras 
						when 3      => sentido_aux <= "1001";  -- giro esquerda
                        when 4      => sentido_aux <= "0101";  -- tras 
						when others => sentido_aux <= "0000";  -- parado
                    end case;
					PASSO <= PASSO + 1;                   
				else
					aciona <= not aciona;
				end if;
                
-- ################# FIM MODO AUTOMATICO  #################
 
			else -- Ao sair do manual ou automatico
                sentido_aux <= "0000"; -- carro parado
                
			end if;		
		end if;  -- Fim do falling_edge(clock)
	end process;
	

T1 <= sentido_aux(4);
T2 <= sentido_aux(3);
T3 <= sentido_aux(2);
T4 <= sentido_aux(1);


end arch; -- fim da arquitetura
