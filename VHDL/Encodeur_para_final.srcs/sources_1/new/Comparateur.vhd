----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09.03.2023 16:14:16
-- Design Name: 
-- Module Name: Comparateur - Behavioral
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

entity Comparateur is
  generic ( Nb_bits_K : integer;
            P : integer);
  Port (clk : in std_logic;
        rst : in std_logic;
        vector_frozen: in std_logic_vector(P-1 downto 0);
        enable_registre_in : in std_logic; 
        registre_in : in std_logic_vector(Nb_bits_k-1 downto 0);
        enable_out : out std_logic;
        output : out std_logic);
end Comparateur;

architecture Behavioral of Comparateur is

signal compteur_rang : integer := 0;
signal compteur : integer := 0;
signal Q : std_logic_vector(P-1 downto 0);

begin



    pr_comparator_mux : process(clk,rst)
        Begin
            if (clk ='1' and clk'event) then
                if (rst ='1') then 
                    Q <= vector_frozen;
                    output <= '0';
                    compteur <= 0;
                    compteur_rang <= 0;
                    enable_out <= '0';
                elsif (enable_registre_in = '1') then
                    enable_out <= '1';
                    if (compteur_rang = P) then 
                        compteur_rang <= 0;
                    elsif (Q(P-1-Compteur_rang) = '1') then --position 1 au bits de poid faible du vecteur frozen
                            output <= '0';
                            compteur_rang <= compteur_rang + 1;
                    elsif (compteur = Nb_bits_K) then 
                         compteur <= 0;
                         compteur_rang <= compteur_rang + 1;
                    else 
                         output <= registre_in(compteur);
                         compteur <= compteur + 1;
                         compteur_rang <= compteur_rang + 1;
                     end if;
                 else 
                    output <= '0';
                    enable_out <= '0';
                    compteur <= 0;
                    compteur_rang <= 0;
                    Q <= vector_frozen;
                 end if;
             end if;
        end process;        



end Behavioral;
