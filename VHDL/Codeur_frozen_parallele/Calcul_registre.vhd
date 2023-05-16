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
      generic(P : integer :=4);
      port(
      clk : in std_logic;
      rst : in std_logic;
      en_in : in std_logic;
      data_in : in std_logic;
      en_out : out std_logic;
      data_out : out std_logic_vector(P-1 downto 0));
end calcul_registre;

architecture Behavioral_calcul_registre of calcul_registre is

signal compteur_en_out : integer :=0;
signal registre : std_logic_vector(P-1 downto 0);

begin
pr_calcul : process(clk,rst)
    begin
            if (clk ='1' and clk'event) then
                if (rst ='1') then
                    registre <= (others => '0');
                    en_out <= '0';
                    data_out <= (others => '0');
                elsif ((en_in = '1')) then
                    registre <= registre xor (data_in & registre(P-1 downto 1));
                    compteur_en_out <= compteur_en_out + 1 ;
                    en_out <= '0';
                    data_out <= (others => '0');
                else
                    Registre <= (others => '0');
                    if (compteur_en_out = P) then   
                        en_out <= '1';
                        compteur_en_out <= 0;
                        l : for i in 0 to P-1 loop
                            data_out(i) <= registre(P - 1-i);
                        end loop l;
                     else 
                        en_out <= '0';
                        data_out <= (others => '0');
                    end if;
             end if;
         end if;
end process;


end Behavioral_calcul_registre;
