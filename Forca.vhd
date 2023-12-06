----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:37:53 11/07/2023 
-- Design Name: 
-- Module Name:    forca - arq_forca 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;

entity forca is
	Port( entrada     : in  std_logic_vector (2 downto 0);
		   botao       : in  std_logic := '0';
		   reset       : in  std_logic := '0';
		   clk         : in  std_logic;
		   ledvidas    : out std_logic_vector (2 downto 0);
		   displayfinal : out std_logic_vector (6 downto 0)
		 );
end forca;

architecture arq_forca of forca is
---Estados
	type estadosForca is (Compara,Verifica,Acerto,VerificaAcertos,Ganhou,Erro,VerificaErros,Perdeu,Resetar);

---Sinais temporários:
	signal senha                                  : std_logic_vector (14 downto 0) := "111001110101000"; -- Senha: 71650 (S4-S3-S2-S1)
	signal display                                : std_logic_vector(6 downto 0) :="0000000";--[S4(6),S3(5),S2(4),S1(3),S0(2),Ganhou(1),Perdeu(0)]
	signal estado                                 : estadosForca := Compara;
	signal comp4,comp3,comp2,comp1,comp0,auxiliar : std_logic := '0';
	signal vidas                                  : integer range 3 downto 0 := 3;

begin

	auxiliar <= (((comp0 or comp1 )or (comp2 or comp3)) or comp4);
	displayfinal <= display;

---Leds indicando a quantidade de vidas
	process(vidas)
	begin
		if (vidas = 3) then
			ledvidas <= "111"; 
		elsif (vidas = 2) then
			ledvidas <= "011";
		elsif (vidas = 1) then
			ledvidas <= "001";
		elsif (vidas = 0) then
			ledvidas <= "000";
		end if;
	end process;

---Maquina de estado jogo
	process(clk,reset)
		begin

			if(Clk' event and Clk = '1') then
			
				case estado is
				
					when Compara => --Comparação do chute com a resposta
						if (reset = '1') then
							estado <= Resetar;
						end if;
						if (botao = '1') then
							comp0 <= (( entrada(2)xnor senha(2))and (entrada(1)xnor senha(1)))and (entrada(0)xnor senha(0));
							comp1 <= (( entrada(2)xnor senha(5))and (entrada(1)xnor senha(4)))and (entrada(0)xnor senha(3));
							comp2 <= (( entrada(2)xnor senha(8))and (entrada(1)xnor senha(7)))and (entrada(0)xnor senha(6));
							comp3 <= (( entrada(2)xnor senha(11))and (entrada(1)xnor senha(10)))and (entrada(0)xnor senha(9));
							comp4 <= (( entrada(2)xnor senha(14))and (entrada(1)xnor senha(13)))and (entrada(0)xnor senha(12));
							estado <= Verifica;
						end if;
						
					when Verifica => --Verifica se houve algum acerto
						if (reset = '1') then
							estado <= Resetar;
						elsif (auxiliar = '1') then
							estado <= Acerto;
						else
							estado <= Erro;
						end if;

					
					when Acerto => --Print acertos
						display(2) <= comp0 or display(2);
						display(3) <= comp1 or display(3);
						display(4) <= comp2 or display(4);
						display(5) <= comp3 or display(5);
						display(6) <= comp4 or display(6);
						if (reset = '1') then
							estado <= Resetar;
						else
							estado <= VerificaAcertos;
						end if;

						
					when VerificaAcertos => --Verificador de quant. de acertos
					--Caso todos os números tenham sido acertados o jogador ganhou, caso contrário o jogo continua.
						if (reset = '1') then
							estado <= Resetar;
						elsif (display(6 downto 2) = "11111") then
							estado <= Ganhou;
						else
							estado <= Compara;
						end if;	
						
					when Ganhou => --Print "Ganhou"
						display(1) <= '1';
						if (reset = '1') then
							estado <= Resetar;
						else
							estado <= Compara;
						end if;
						
					when Erro => --Perde uma vida
						vidas <= vidas - 1;
						if (reset = '1') then
							estado <= Resetar;
						else
							estado <= VerificaErros;
						end if;
						
					when VerificaErros => --Verificador de quant. de erros
						--Caso as vidas tenham acabado o jogador perdeu, caso contrário o jogo continua.
						if (reset = '1') then
							estado <= Resetar;
						elsif vidas = 0 then
							estado <= Perdeu;
						else
							estado <= Compara;
						end if;
						
					when Perdeu => --Print "Perdeu"
						display(0) <= '1';
						if (reset = '1') then
							estado <= Resetar;
						else
							estado <= Compara;
						end if;
						
					when Resetar => --Volta o jogo aos estados iniciais
					display <= "0000000";
					comp4 <= '0';
					comp3 <= '0';
					comp2 <= '0';
					comp1 <= '0';
					comp0 <= '0';
					vidas <= 3;
					estado <= Compara;
					
					when others =>
					estado <= Resetar;
					
				end case;
				
			end if;
			
	end process;
	
end arq_forca;

