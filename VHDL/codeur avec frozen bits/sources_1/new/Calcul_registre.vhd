----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 27.02.2023 16:27:20
-- Design Name: 
-- Module Name: calcul_pour_registre - Behavioral_calcul_pour_registre
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;



entity calcul_registre is
      generic(Nb_bits_N : integer :=4);
      port(
      clk : in std_logic;
      rst : in std_logic;
      en_in : in std_logic;
      data_in : in std_logic;
      en_out : out std_logic;
      data_out : out std_logic);
end calcul_registre;

architecture Behavioral_calcul_registre of calcul_registre is

--signal compteur_stop : integer :=0;
signal compteur_en_out : integer :=0;
signal registre : std_logic_vector(Nb_bits_N-1 downto 0);
signal flag : integer :=0;

begin
pr_calcul : process(clk,rst)
    begin
            if rising_edge(clk) then
                if (rst ='1') then
                    registre <= (others => '0');
                    en_out <= '0';
                    data_out <= '0';
                    flag <= 0;
                elsif ((en_in = '1')) then
                    registre <= registre xor (data_in & registre(Nb_bits_N-1 downto 1));
                    flag <= 1;
                else
                    data_out <= Registre(0);
                    Registre <= '0' & Registre (Nb_bits_N-1 downto 1);
                    if (flag = 1) then
                        en_out <= '1';
                        if ( compteur_en_out < Nb_bits_N) then 
                            compteur_en_out <= compteur_en_out + 1;
                        else 
                            flag <= 0;
                            compteur_en_out <= 0;
                            en_out <= '0';
                        end if;
                    end if;
                end if;
             end if;
end process;

--pr_compteur_stop : process (clk,rst,en_in,compteur_en_out)
--    Begin
--        if (clk ='1' and clk'event) then
--            if (rst = '1') then
--                compteur_stop <= 0;
--            else 
--                if ((en_in = '1')) then
--                    if (compteur_stop < NB_bits_N) then
--                        compteur_stop <= compteur_stop + 1;
--                    end if;
--                elsif (compteur_en_out = Nb_bits_N) then
--                    compteur_stop <= 0;
--                end if;
                
--            end if;
--        end if;
--    end process;
    
    
--pr_compteur_en_out : process (clk, rst, compteur_stop)
--    Begin
--        if (clk ='1' and clk'event) then
--            if (rst = '1') then
--                compteur_en_out <= 0;
--            else
--                if ((compteur_stop = Nb_bits_N) and (compteur_en_out < Nb_bits_N)) then 
--                     compteur_en_out <= compteur_en_out +1;
--                else 
--                    compteur_en_out <= 0;
--                end if;
--            end if;
--        end if;
--    end process;
end Behavioral_calcul_registre;
