----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:05:19 12/29/2022 
-- Design Name: 
-- Module Name:    data - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_unsigned.all;
use IEEE.STD_LOGIC_ARITH.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity data is
    Port ( clk: in STD_LOGIC;
				enable: in  STD_LOGIC;
				reset: in  STD_LOGIC;
				sel: in STD_LOGIC_VECTOR(2 downto 0);
				switch_0: in  STD_LOGIC;
				switch_1: in  STD_LOGIC;
				switch_2: in  STD_LOGIC;
				ENTER_UP : in  STD_LOGIC;
				ENTER_DOWN : in  STD_LOGIC;
				EXIT_UP : in  STD_LOGIC;
				EXIT_DOWN : in  STD_LOGIC;
				SUBIU : in  STD_LOGIC;
				DESCEU : in  STD_LOGIC;
				pres1_in_up: out STD_LOGIC;
				pres2_in_up: out STD_LOGIC;
				pres1_in_down: out STD_LOGIC;
				pres2_in_down: out STD_LOGIC;
				pres1_out_up: out STD_LOGIC;
				pres2_out_up : out STD_LOGIC;
				pres1_out_down: out STD_LOGIC;
				pres2_out_down: out STD_LOGIC;
				ticket_in_entry_up: out STD_LOGIC;
				ticket_in_entry_down: out STD_LOGIC;
				ticket_out_entry_up: out STD_LOGIC;
				ticket_out_entry_down: out STD_LOGIC;
				and_12 : out STD_LOGIC;
				and_12b: out STD_LOGIC;
				and_21: out STD_LOGIC;
				and_21b: out STD_LOGIC;
				 dig3_3:		out STD_LOGIC;
				 dig3_2:		out STD_LOGIC;
				 dig3_1:		out STD_LOGIC;
				 dig3_0:		out STD_LOGIC;
				 dig2_3:		out STD_LOGIC;
				 dig2_2:		out STD_LOGIC;
				 dig2_1:		out STD_LOGIC;
				 dig2_0:		out STD_LOGIC;
				 dig1_3:		out STD_LOGIC;
				 dig1_2:		out STD_LOGIC;
				 dig1_1:		out STD_LOGIC;
				 dig1_0:		out STD_LOGIC;
				 dig0_3:		out STD_LOGIC;
				 dig0_2:		out STD_LOGIC;
				 dig0_1:		out STD_LOGIC;
				 dig0_0:		out STD_LOGIC;
				 P_ABERTO: out STD_LOGIC;
			    set : in STD_LOGIC);
end data;

architecture Behavioral of data is
--parque
signal reg_up_0, reg_down_0, reg_a_0, reg_a_1, reg_up_1, reg_down_1, reg_aux_0, reg_aux_1: STD_LOGIC_VECTOR(3 downto 0);
signal reg_entradas_0, reg_entradas_1, reg_saidas_0, reg_saidas_1, reg_aux_3, reg_aux_4: STD_LOGIC_VECTOR(3 downto 0);
signal dig_0_0, dig_0_1, dig_0_2, dig_0_3, dig_1_0, dig_1_1, dig_1_2, dig_1_3, dig_2_0, dig_2_1, dig_2_2, dig_2_3, dig_3_0, dig_3_1, dig_3_2, dig_3_3, horas: STD_LOGIC;
signal e11: std_logic := '0';
signal e12 :std_logic := '0';
signal e21 :std_logic := '0';
signal e22 :std_logic := '0';
signal tic1e :std_logic := '0';
signal tic2e:std_logic := '0';
signal s11:std_logic := '0';
signal s12:std_logic := '0';
signal s21:std_logic := '0';
signal s22:std_logic := '0';
signal tic1s :std_logic:= '0';
signal tic2s:std_logic := '0';
signal r12a:std_logic:= '0';
signal r12b:std_logic:= '0';
signal r21a:std_logic:= '0';
signal r21b:std_logic:= '0';


--relogio
signal count_s, count_ds, count_m, count_dm, count_h, count_dh: std_logic_vector (3 downto 0);
signal count_ns : integer range 0 to 50000000;
signal check_s, check_ds, check_m, check_dm, check_h, check_dh, check_day : STD_LOGIC;
signal c_seg_u, c_seg_d, c_min_u, c_min_d: STD_LOGIC_VECTOR (3 downto 0);

--signal t_min_u_open: STD_LOGIC_VECTOR(3 downto 0) := "0000";
--signal t_min_d_open: STD_LOGIC_VECTOR(3 downto 0) := "0000";
--signal t_hora_u_open: STD_LOGIC_VECTOR(3 downto 0) := "0000";
--signal t_hora_d_open: STD_LOGIC_VECTOR(3 downto 0) := "0000";
signal t_min_u_open: STD_LOGIC_VECTOR(3 downto 0) := "0010";
signal t_min_d_open: STD_LOGIC_VECTOR(3 downto 0) := "0000";
signal t_hora_u_open: STD_LOGIC_VECTOR(3 downto 0) := "0000";
signal t_hora_d_open: STD_LOGIC_VECTOR(3 downto 0) := "0000";
signal t_min_u_close: STD_LOGIC_VECTOR(3 downto 0) := "0011";
signal t_min_d_close: STD_LOGIC_VECTOR(3 downto 0) := "0010";
--signal t_min_u_close: STD_LOGIC_VECTOR(3 downto 0) := "0000";
--signal t_min_d_close: STD_LOGIC_VECTOR(3 downto 0) := "0000";
signal t_hora_u_close: STD_LOGIC_VECTOR(3 downto 0) := "0000";
signal t_hora_d_close: STD_LOGIC_VECTOR(3 downto 0) := "0000";
--signal t_hora_u_close: STD_LOGIC_VECTOR(3 downto 0) := "0010";
--signal t_hora_d_close: STD_LOGIC_VECTOR(3 downto 0) := "0000";


begin
---multiplexer
process(clk)
begin
if clk'event and clk = '1' then

e11 <= '0';
e12 <= '0';
e21 <= '0';
e22 <= '0';
tic1e <= '0';
tic2e <= '0';
s11<= '0';
s12<= '0';
s21<= '0';
s22<= '0';
tic1s <= '0';
tic2s<= '0';
r12a<= '0';
r12b<= '0';
r21a<= '0';
r21b<= '0';

	if (sel = "000" and conv_integer(switch_0) = 1) then e11 <= '1'; end if; -- primeiro sensor piso 1	
	if (sel = "000" and conv_integer(switch_1) = 1 ) then tic1e <= '1'; end if; -- ticket sensor piso 1	
	if (sel = "000" and conv_integer(switch_2) = 1 ) then e12 <= '1'; end if; -- segundo sensor piso 1
	if sel = "000" then reg_aux_1 <= reg_up_0; end if; -- mostra carros piso de cima	
	if sel = "000" then reg_aux_0 <= reg_up_1; end if;	
	if (sel = "000") then reg_aux_4 <= reg_a_0; end if;  -- mostra carros piso de baixo
	if (sel = "000") then reg_aux_3 <= reg_a_1; end if;
	if sel = "000" then horas <= '0'; end if;	
	
	if (sel = "001" and conv_integer(switch_0) = 1 ) then e21 <= '1'; end if; -- primeiro sensor piso 2
	if (sel = "001" and conv_integer(switch_1) = 1 ) then tic2e <= '1'; end if; -- ticket sensor piso 2
	if (sel = "001" and conv_integer(switch_2) = 1 ) then e22 <= '1'; end if; -- segundo sensor piso 2
	if (sel = "001") then reg_aux_1 <= reg_down_0; end if;  -- mostra carros piso de baixo
	if (sel = "001") then reg_aux_0 <= reg_down_1; end if;
	if (sel = "001") then reg_aux_4 <= reg_a_0; end if;  -- mostra carros piso de baixo
	if (sel = "001") then reg_aux_3 <= reg_a_1; end if;	
	if (sel = "001") then horas <= '0'; end if;	
	
	if (sel = "010" and conv_integer(switch_0) = 1 ) then s11 <= '1'; end if; -- primeiro sensor piso 1
	if (sel = "010" and conv_integer(switch_1) = 1 ) then tic1s <= '1'; end if; -- ticket sensor piso 1
	if (sel = "010" and conv_integer(switch_2) = 1 ) then s12 <= '1'; end if; -- segundo sensor piso 1
	if (sel = "010") then reg_aux_1 <= reg_up_0; end if;  -- mostra carros piso de cima
	if (sel = "010") then reg_aux_0 <= reg_up_1; end if;
	if (sel = "010") then reg_aux_4 <= reg_a_0; end if;  -- mostra carros piso de baixo
	if (sel = "010") then reg_aux_3 <= reg_a_1; end if;
	if (sel = "010") then horas <= '0'; end if;	
	
	if (sel = "011" and conv_integer(switch_0) = 1 ) then s21 <= '1'; end if; -- primeiro sensor piso 2
	if (sel = "011" and conv_integer(switch_1) = 1 ) then tic2s <= '1'; end if; -- ticket sensor piso 2
	if (sel = "011" and conv_integer(switch_2) = 1 ) then s22 <= '1'; end if; -- segundo sensor piso 2
	if (sel = "011") then reg_aux_1 <= reg_down_0; end if;  -- mostra carros piso de baixo
	if (sel = "011") then reg_aux_0 <= reg_down_1; end if;
	if (sel = "011") then reg_aux_4 <= reg_a_0; end if;  -- mostra carros piso de baixo
	if (sel = "011") then reg_aux_3 <= reg_a_1; end if;
	if (sel = "011") then horas <= '0'; end if;	
	
	if (sel = "100" and conv_integer(switch_0) = 1 ) then r12a <= '1'; end if; -- primeiro sensor piso 1
	if (sel = "100" and conv_integer(switch_1) = 1 ) then r12b <= '1'; end if; -- segundo sensor piso 1	
	if (sel = "101" and conv_integer(switch_0) = 1 ) then r21a <= '1'; end if; -- primeiro sensor piso 2
	if (sel = "101" and conv_integer(switch_1) = 1 ) then r21b <= '1'; end if; -- segundo sensor piso 2

	if (sel = "110") then horas <= '1'; end if; --mostra horas

	if (sel = "111") then reg_aux_1 <= reg_entradas_0; end if;  -- mostra carros piso de baixo
	if (sel = "111") then reg_aux_0 <= reg_entradas_1; end if;
	if (sel = "111") then reg_aux_4 <= reg_saidas_0; end if;  -- mostra carros piso de baixo
	if (sel = "111") then reg_aux_3 <= reg_saidas_1; end if;
	if (sel = "111") then horas <= '0'; end if;

end if;
end process;

--parque
process(clk, reset)
begin
if reset = '1' then
	reg_up_0 <= "0000";
	reg_down_0 <= "0000";
	reg_up_1 <= "0000";
	reg_down_1 <= "0000";

elsif clk'event and clk = '1' then

	if ENTER_UP = '1' then
		reg_up_0 <= reg_up_0 + "0001"; 
	elsif SUBIU = '1' then
		reg_up_0 <= reg_up_0 + "0001";
	end if;
	if EXIT_UP = '1' then
		if reg_up_0 = "0000" and not (reg_up_1 = "0000") then
			reg_up_1 <= reg_up_1 - "0001";
			reg_up_0 <= "1001";
		else
			reg_up_0 <= reg_up_0 - "0001";
		end if;
	elsif DESCEU = '1' then
		if reg_up_0 = "0000" and not (reg_up_1 = "0000") then
			reg_up_1 <= reg_up_1 - "0001";
			reg_up_0 <= "1001";
		else
			reg_up_0 <= reg_up_0 - "0001";
		end if;	
	end if;		

	if ENTER_DOWN = '1' then
		reg_down_0 <= reg_down_0 + "0001"; 
	elsif DESCEU = '1' then
		reg_down_0 <= reg_down_0 + "0001";
	end if;
	if EXIT_DOWN = '1' then
		if reg_down_0 = "0000" and not (reg_down_1 = "0000") then
			reg_down_1 <= reg_down_1 - "0001";
			reg_down_0 <= "1001";
		else
			reg_down_0 <= reg_down_0 - "0001";
		end if;
	elsif SUBIU = '1' then
		if reg_down_0 = "0000" and not (reg_down_1 = "0000") then
			reg_down_1 <= reg_down_1 - "0001";
			reg_down_0 <= "1001";
		else
			reg_down_0 <= reg_down_0 - "0001";
		end if;
	end if;	
	
	if reg_up_0 = "1010" then
		reg_up_1 <= reg_up_1 + "0001";
		reg_up_0 <= "0000";
	end if;
	
	if reg_down_0 = "1010" then
		reg_down_1 <= reg_down_1 + "0001";
		reg_down_0 <= "0000";
	end if;	
end if;
end process;	

--somador dos dois pisos
process(clk, reset)
begin
if reset = '1' then
	reg_a_0 <= "0000";
	reg_a_1 <= "0000";
	reg_entradas_0<= "0000";
	reg_entradas_1<= "0000";
	reg_saidas_0<= "0000";
	reg_saidas_1<= "0000";
elsif clk'event and clk = '1' then

	if ENTER_UP = '1' or ENTER_DOWN = '1' then
		reg_a_0 <= reg_a_0 + "0001";
		reg_entradas_0 <= reg_entradas_0 + "0001";
	end if;
	if EXIT_UP = '1' or EXIT_UP = '1' then
		reg_saidas_0 <= reg_saidas_0 + "0001";
		if reg_a_0 = "0000" and not (reg_a_1 = "0000") then
			reg_a_1 <= reg_a_1 - "0001";
			reg_a_0 <= "1001";
		else
			reg_a_0 <= reg_a_0 - "0001";
		end if;
	end if;		
	
	if reg_a_0 = "1010" then
		reg_a_1 <= reg_a_1 + "0001";
		reg_a_0 <= "0000";
	end if;
	
	if reg_entradas_0 = "1010" then
		reg_entradas_1 <= reg_entradas_1 + "0001";
		reg_entradas_0 <= "0000";
	end if;
	
	if reg_saidas_0 = "1010" then
		reg_saidas_1 <= reg_saidas_1 + "0001";
		reg_saidas_0 <= "0000";
	end if;
	
end if;
end process;

-----------------------------------------------------------------
--relogio
--Bloco da contagem de Nanosegundos
process (clk, reset)
begin
	if reset = '1' then
		count_ns <= 0;
	elsif clk'event and clk = '1' then
			if count_ns = 49999999 then
				count_ns <= 0;
			else count_ns <= count_ns + 1;
			end if;
	end if;
end process;

check_s  <= '1' when count_ns = 49999999 else '0';

--Bloco da contagem de Segundos
process (clk, reset) 
begin
	if reset = '1' then
		count_s <= "0000";
	elsif clk'event and clk = '1' then
		if check_s = '1' then
			count_s <= count_s + 1;
			if count_s = 9 then
				count_s <= "0000";
			end if;
		end if;
	end if;
end process;

check_ds <= '1' when count_s = 9 and check_s = '1' else '0';

--Bloco da contagem de Dezenas de Segundos
process (clk, reset)
begin
	if reset = '1' then
		count_ds <= "0000";
	elsif clk'event and clk = '1' then	
		if check_ds = '1' then
			count_ds <= count_ds + 1;
			if count_ds = 5 then
				count_ds <= "0000";
			end if;
		end if;
	end if; 
end process;

check_m <= '1' when count_ds = 5 and check_ds = '1' else '0';

--Bloco da contagem de Minutos
process (clk, reset) 
begin 
	if reset = '1' then
		count_m <= "0000";
	elsif clk'event and clk = '1' then
		if set = '1' then
			--count_m <= set_seg_u;
		elsif check_m = '1' then
			count_m <= count_m + 1;
			if count_m = 9 then
				count_m <= "0000";
			end if;
		end if;
	end if;
end process;

check_dm <= '1' when count_m = 9 and check_m = '1' else '0';


--Bloco da contagem de Dezenas de Minutos
process (clk, reset)
begin

	if reset = '1' then
		count_dm <= "0000";
	elsif clk'event and clk = '1' then
		if set = '1' then
			--count_dm <= set_seg_d;
		elsif check_dm = '1' then
			count_dm <= count_dm + 1;
			if count_dm = 5 then
				count_dm <= "0000";
			end if;
		end if;
	end if;
end process;

check_h <= '1' when count_dm = 5 and check_dm = '1' else '0';

--Bloco da contagem de Horas
process (clk, reset) 
begin 
	if reset = '1' then
		count_h <= "0000";
	elsif clk'event and clk = '1' then
		if set = '1' then
			--count_h <= set_min_u;
		elsif check_h = '1' then
			count_h <= count_h + 1;
			if count_h = 9 then
				count_h <= "0000";
			elsif count_dh = 2 and count_h = 3 and check_h = '1' then
				count_h <= "0000";
			end if;
		end if;
	end if;
end process;

check_dh  <= '1' when count_h = 9 and check_h = '1' else '0';

--Bloco da contagem de Dezenas de Horas
process (clk, reset)
begin
	if reset = '1' then
		count_dh <= "0000";
	elsif clk'event and clk = '1' then
		if set = '1' then
			--count_dh <= set_min_d;
		elsif check_dh = '1' then
			count_dh <= count_dh + 1;
		elsif count_dh = 2 and count_h = 3 and check_h = '1' then
				count_dh <= "0000";
		end if;
	end if;
end process;

--comparador de horas
process (clk)
begin
if count_dh > t_hora_d_open and count_dh < t_hora_d_open then
	P_ABERTO <= '1';
elsif count_dh = t_hora_d_open then
	if count_h > t_hora_u_open then
		P_ABERTO <= '1';
	elsif count_h = t_hora_u_open then
		if count_dm > t_min_d_open then
			P_ABERTO <= '1';
		elsif count_dm = t_min_d_open then
			if count_m > t_min_u_open then
				P_ABERTO <= '1';
			elsif count_m = t_min_u_open then
				P_ABERTO <= '1';
			else
				P_ABERTO <= '0';
			end if;
		else
			P_ABERTO <= '0';
		end if;
	else
		P_ABERTO <= '0';
	end if;
else
	P_ABERTO <= '0';
end if;
end process;
	----close


--valores no display
process (clk)
begin
	if horas = '0' then 
		if (reg_aux_4 = "0000") then dig_2_0 <= '0'; dig_2_1 <= '0'; dig_2_2 <= '0'; dig_2_3 <= '0'; end if;
		if (reg_aux_4 = "0001") then dig_0_0 <= '1'; dig_0_1 <= '0'; dig_0_2 <= '0'; dig_0_3 <= '0'; end if;
		if (reg_aux_4 = "0010") then dig_0_0 <= '0'; dig_0_1 <= '1'; dig_0_2 <= '0'; dig_0_3 <= '0'; end if;
		if (reg_aux_4 = "0011") then dig_0_0 <= '1'; dig_0_1 <= '1'; dig_0_2 <= '0'; dig_0_3 <= '0'; end if;
		if (reg_aux_4 = "0100") then dig_0_0 <= '0'; dig_0_1 <= '0'; dig_0_2 <= '1'; dig_0_3 <= '0'; end if;
		if (reg_aux_4 = "0101") then dig_0_0 <= '1'; dig_0_1 <= '0'; dig_0_2 <= '1'; dig_0_3 <= '0'; end if;
		if (reg_aux_4 = "0110") then dig_0_0 <= '0'; dig_0_1 <= '1'; dig_0_2 <= '1'; dig_0_3 <= '0'; end if;
		if (reg_aux_4 = "0111") then dig_0_0 <= '1'; dig_0_1 <= '1'; dig_0_2 <= '1'; dig_0_3 <= '0'; end if;
		if (reg_aux_4 = "1000") then dig_0_0 <= '0'; dig_0_1 <= '0'; dig_0_2 <= '0'; dig_0_3 <= '1'; end if;
		if (reg_aux_4 = "1001") then dig_0_0 <= '1'; dig_0_1 <= '0'; dig_0_2 <= '0'; dig_0_3 <= '1'; end if;

		if (reg_aux_3 = "0000") then dig_1_0 <= '0'; dig_1_1 <= '0'; dig_1_2 <= '0'; dig_1_3 <= '0'; end if;
		if (reg_aux_3 = "0001") then dig_1_0 <= '1'; dig_1_1 <= '0'; dig_1_2 <= '0'; dig_1_3 <= '0'; end if;
		if (reg_aux_3 = "0010") then dig_1_0 <= '0'; dig_1_1 <= '1'; dig_1_2 <= '0'; dig_1_3 <= '0'; end if;
		if (reg_aux_3 = "0011") then dig_1_0 <= '1'; dig_1_1 <= '1'; dig_1_2 <= '0'; dig_1_3 <= '0'; end if;
		if (reg_aux_3 = "0100") then dig_1_0 <= '0'; dig_1_1 <= '0'; dig_1_2 <= '1'; dig_1_3 <= '0'; end if;
		if (reg_aux_3 = "0101") then dig_1_0 <= '1'; dig_1_1 <= '0'; dig_1_2 <= '1'; dig_1_3 <= '0'; end if;
		if (reg_aux_3 = "0110") then dig_1_0 <= '0'; dig_1_1 <= '1'; dig_1_2 <= '1'; dig_1_3 <= '0'; end if;
		if (reg_aux_3 = "0111") then dig_1_0 <= '1'; dig_1_1 <= '1'; dig_1_2 <= '1'; dig_1_3 <= '0'; end if;
		if (reg_aux_3 = "1000") then dig_1_0 <= '0'; dig_1_1 <= '0'; dig_1_2 <= '0'; dig_1_3 <= '1'; end if;
		if (reg_aux_3 = "1001") then dig_1_0 <= '1'; dig_1_1 <= '0'; dig_1_2 <= '0'; dig_1_3 <= '1'; end if;

		if (reg_aux_1 = "0000") then dig_2_0 <= '0'; dig_2_1 <= '0'; dig_2_2 <= '0'; dig_2_3 <= '0'; end if;
		if (reg_aux_1 = "0001") then dig_2_0 <= '1'; dig_2_1 <= '0'; dig_2_2 <= '0'; dig_2_3 <= '0'; end if;
		if (reg_aux_1 = "0010") then dig_2_0 <= '0'; dig_2_1 <= '1'; dig_2_2 <= '0'; dig_2_3 <= '0'; end if;
		if (reg_aux_1 = "0011") then dig_2_0 <= '1'; dig_2_1 <= '1'; dig_2_2 <= '0'; dig_2_3 <= '0'; end if;
		if (reg_aux_1 = "0100") then dig_2_0 <= '0'; dig_2_1 <= '0'; dig_2_2 <= '1'; dig_2_3 <= '0'; end if;
		if (reg_aux_1 = "0101") then dig_2_0 <= '1'; dig_2_1 <= '0'; dig_2_2 <= '1'; dig_2_3 <= '0'; end if;
		if (reg_aux_1 = "0110") then dig_2_0 <= '0'; dig_2_1 <= '1'; dig_2_2 <= '1'; dig_2_3 <= '0'; end if;
		if (reg_aux_1 = "0111") then dig_2_0 <= '1'; dig_2_1 <= '1'; dig_2_2 <= '1'; dig_2_3 <= '0'; end if;
		if (reg_aux_1 = "1000") then dig_2_0 <= '0'; dig_2_1 <= '0'; dig_2_2 <= '0'; dig_2_3 <= '1'; end if;
		if (reg_aux_1 = "1001") then dig_2_0 <= '1'; dig_2_1 <= '0'; dig_2_2 <= '0'; dig_2_3 <= '1'; end if;

		if (reg_aux_0 = "0000") then dig_3_0 <= '0'; dig_3_1 <= '0'; dig_3_2 <= '0'; dig_3_3 <= '0'; end if;
		if (reg_aux_0 = "0001") then dig_3_0 <= '1'; dig_3_1 <= '0'; dig_3_2 <= '0'; dig_3_3 <= '0'; end if;
		if (reg_aux_0 = "0010") then dig_3_0 <= '0'; dig_3_1 <= '1'; dig_3_2 <= '0'; dig_3_3 <= '0'; end if;
		if (reg_aux_0 = "0011") then dig_3_0 <= '1'; dig_3_1 <= '1'; dig_3_2 <= '0'; dig_3_3 <= '0'; end if;
		if (reg_aux_0 = "0100") then dig_3_0 <= '0'; dig_3_1 <= '0'; dig_3_2 <= '1'; dig_3_3 <= '0'; end if;
		if (reg_aux_0 = "0101") then dig_3_0 <= '1'; dig_3_1 <= '0'; dig_3_2 <= '1'; dig_3_3 <= '0'; end if;
		if (reg_aux_0 = "0110") then dig_3_0 <= '0'; dig_3_1 <= '1'; dig_3_2 <= '1'; dig_3_3 <= '0'; end if;
		if (reg_aux_0 = "0111") then dig_3_0 <= '1'; dig_3_1 <= '1'; dig_3_2 <= '1'; dig_3_3 <= '0'; end if;
		if (reg_aux_0 = "1000") then dig_3_0 <= '0'; dig_3_1 <= '0'; dig_3_2 <= '0'; dig_3_3 <= '1'; end if;
		if (reg_aux_0 = "1001") then dig_3_0 <= '1'; dig_3_1 <= '0'; dig_3_2 <= '0'; dig_3_3 <= '1'; end if;
	
	elsif horas = '1' then
		if set = '0' then
			if (count_m = "0000") then dig_0_0 <= '0'; dig_0_1 <= '0'; dig_0_2 <= '0'; dig_0_3 <= '0'; end if;
			if (count_m = "0001") then dig_0_0 <= '1'; dig_0_1 <= '0'; dig_0_2 <= '0'; dig_0_3 <= '0'; end if;
			if (count_m = "0010") then dig_0_0 <= '0'; dig_0_1 <= '1'; dig_0_2 <= '0'; dig_0_3 <= '0'; end if;
			if (count_m = "0011") then dig_0_0 <= '1'; dig_0_1 <= '1'; dig_0_2 <= '0'; dig_0_3 <= '0'; end if;
			if (count_m = "0100") then dig_0_0 <= '0'; dig_0_1 <= '0'; dig_0_2 <= '1'; dig_0_3 <= '0'; end if;
			if (count_m = "0101") then dig_0_0 <= '1'; dig_0_1 <= '0'; dig_0_2 <= '1'; dig_0_3 <= '0'; end if;
			if (count_m = "0110") then dig_0_0 <= '0'; dig_0_1 <= '1'; dig_0_2 <= '1'; dig_0_3 <= '0'; end if;
			if (count_m = "0111") then dig_0_0 <= '1'; dig_0_1 <= '1'; dig_0_2 <= '1'; dig_0_3 <= '0'; end if;
			if (count_m = "1000") then dig_0_0 <= '0'; dig_0_1 <= '0'; dig_0_2 <= '0'; dig_0_3 <= '1'; end if;
			if (count_m = "1001") then dig_0_0 <= '1'; dig_0_1 <= '0'; dig_0_2 <= '0'; dig_0_3 <= '1'; end if;

			if (count_dm = "0000") then dig_1_0 <= '0'; dig_1_1 <= '0'; dig_1_2 <= '0'; dig_1_3 <= '0'; end if;
			if (count_dm = "0001") then dig_1_0 <= '1'; dig_1_1 <= '0'; dig_1_2 <= '0'; dig_1_3 <= '0'; end if;
			if (count_dm = "0010") then dig_1_0 <= '0'; dig_1_1 <= '1'; dig_1_2 <= '0'; dig_1_3 <= '0'; end if;
			if (count_dm = "0011") then dig_1_0 <= '1'; dig_1_1 <= '1'; dig_1_2 <= '0'; dig_1_3 <= '0'; end if;
			if (count_dm = "0100") then dig_1_0 <= '0'; dig_1_1 <= '0'; dig_1_2 <= '1'; dig_1_3 <= '0'; end if;
			if (count_dm = "0101") then dig_1_0 <= '1'; dig_1_1 <= '0'; dig_1_2 <= '1'; dig_1_3 <= '0'; end if;
			if (count_dm = "0110") then dig_1_0 <= '0'; dig_1_1 <= '1'; dig_1_2 <= '1'; dig_1_3 <= '0'; end if;
			if (count_dm = "0111") then dig_1_0 <= '1'; dig_1_1 <= '1'; dig_1_2 <= '1'; dig_1_3 <= '0'; end if;
			if (count_dm = "1000") then dig_1_0 <= '0'; dig_1_1 <= '0'; dig_1_2 <= '0'; dig_1_3 <= '1'; end if;
			if (count_dm = "1001") then dig_1_0 <= '1'; dig_1_1 <= '0'; dig_1_2 <= '0'; dig_1_3 <= '1'; end if;

			if (count_h = "0000") then dig_2_0 <= '0'; dig_2_1 <= '0'; dig_2_2 <= '0'; dig_2_3 <= '0'; end if;
			if (count_h = "0001") then dig_2_0 <= '1'; dig_2_1 <= '0'; dig_2_2 <= '0'; dig_2_3 <= '0'; end if;
			if (count_h = "0010") then dig_2_0 <= '0'; dig_2_1 <= '1'; dig_2_2 <= '0'; dig_2_3 <= '0'; end if;
			if (count_h = "0011") then dig_2_0 <= '1'; dig_2_1 <= '1'; dig_2_2 <= '0'; dig_2_3 <= '0'; end if;
			if (count_h = "0100") then dig_2_0 <= '0'; dig_2_1 <= '0'; dig_2_2 <= '1'; dig_2_3 <= '0'; end if;
			if (count_h = "0101") then dig_2_0 <= '1'; dig_2_1 <= '0'; dig_2_2 <= '1'; dig_2_3 <= '0'; end if;
			if (count_h = "0110") then dig_2_0 <= '0'; dig_2_1 <= '1'; dig_2_2 <= '1'; dig_2_3 <= '0'; end if;
			if (count_h = "0111") then dig_2_0 <= '1'; dig_2_1 <= '1'; dig_2_2 <= '1'; dig_2_3 <= '0'; end if;
			if (count_h = "1000") then dig_2_0 <= '0'; dig_2_1 <= '0'; dig_2_2 <= '0'; dig_2_3 <= '1'; end if;
			if (count_h = "1001") then dig_2_0 <= '1'; dig_2_1 <= '0'; dig_2_2 <= '0'; dig_2_3 <= '1'; end if;

			if (count_dh = "0000") then dig_3_0 <= '0'; dig_3_1 <= '0'; dig_3_2 <= '0'; dig_3_3 <= '0'; end if;
			if (count_dh = "0001") then dig_3_0 <= '1'; dig_3_1 <= '0'; dig_3_2 <= '0'; dig_3_3 <= '0'; end if;
			if (count_dh = "0010") then dig_3_0 <= '0'; dig_3_1 <= '1'; dig_3_2 <= '0'; dig_3_3 <= '0'; end if;
			if (count_dh = "0011") then dig_3_0 <= '1'; dig_3_1 <= '1'; dig_3_2 <= '0'; dig_3_3 <= '0'; end if;
			if (count_dh = "0100") then dig_3_0 <= '0'; dig_3_1 <= '0'; dig_3_2 <= '1'; dig_3_3 <= '0'; end if;
			if (count_dh = "0101") then dig_3_0 <= '1'; dig_3_1 <= '0'; dig_3_2 <= '1'; dig_3_3 <= '0'; end if;
			if (count_dh = "0110") then dig_3_0 <= '0'; dig_3_1 <= '1'; dig_3_2 <= '1'; dig_3_3 <= '0'; end if;
			if (count_dh = "0111") then dig_3_0 <= '1'; dig_3_1 <= '1'; dig_3_2 <= '1'; dig_3_3 <= '0'; end if;
			if (count_dh = "1000") then dig_3_0 <= '0'; dig_3_1 <= '0'; dig_3_2 <= '0'; dig_3_3 <= '1'; end if;
			if (count_dh = "1001") then dig_3_0 <= '1'; dig_3_1 <= '0'; dig_3_2 <= '0'; dig_3_3 <= '1'; end if;	
		end if;
		
	end if;
end process;

dig0_3 <= dig_0_3;
dig0_2 <= dig_0_2;
dig0_1 <= dig_0_1;	
dig0_0  <= dig_0_0;

dig1_3 <= dig_1_3;
dig1_2 <= dig_1_2;
dig1_1 <= dig_1_1;	
dig1_0  <= dig_1_0;

dig2_3 <= dig_2_3;
dig2_2 <= dig_2_2;
dig2_1 <= dig_2_1;	
dig2_0  <= dig_2_0;

dig3_3 <= dig_3_3;
dig3_2 <= dig_3_2;
dig3_1 <= dig_3_1;	
dig3_0  <= dig_3_0;

pres1_in_up <= e11;
pres2_in_up <= e12;
pres1_in_down <= e21;
pres2_in_down <= e22;

pres1_out_up <= s11;
pres2_out_up <= s12;
pres1_out_down <= s21;
pres2_out_down <= s22;

ticket_in_entry_up <= tic1e;
ticket_in_entry_down <= tic2e;
ticket_out_entry_up <= tic1s;
ticket_out_entry_down <= tic2s;

and_12 <= r12a;
and_12b <= r12b;
and_21 <= r21a;
and_21b <= r21b;

end Behavioral;
