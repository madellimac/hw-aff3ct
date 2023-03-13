----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02.03.2023 10:01:52
-- Design Name: 
-- Module Name: registre_a_decalage - Behavioral
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


--On suppose que le LSB arrive en premier 
--A la fin c'est le LSB d'entrée qui sera en MSB du registre
entity registre_a_decalage is
      generic ( Nb_bits_K : integer :=2;
                Nb_bits_N : integer :=4);
      Port (clk : in STD_LOGIC;
            enable : in std_logic;
            rst : in std_logic;
            data_in : in std_logic;
            u_pret : out std_logic; --à 1 durant N*T_clk qd registre est prêt 
            registre : out std_logic_vector(Nb_bits_K-1 downto 0) := (others =>'0'));
end registre_a_decalage;

architecture Behavioral of registre_a_decalage is
signal Q : std_logic_vector(Nb_bits_K-1 downto 0) := (others =>'0');
signal compteur_stop : integer :=0;
signal compteur_u_pret : integer :=0;
signal stop : integer :=0;

-- Ajoute les data_in dans le registre jusqu'à N éléments
-- Ensutie compte de 0 à N en mettant la sortie active.

--Modification: au lieu de compter jusqu'à N et avoir un vecteur de registre en sortie,
--  on pourrait avoir une entré qui vient du comparateur qui demande d'accéder à 
--  la prochaine valeur du registre

-- Ajoute les data d'entree au registre (vector) de sortie par decalage 
--      lorsque le enable = 1 (il est à 1 pendant un seul cycle d'horloge)
-- Les données en entrée arrive moins souvent que le clock
begin
    process(clk,rst, enable)
        begin
            if rising_edge(clk) then 
                if (rst ='1') then
                    Q <= (others =>'0');
                else
                    if (enable ='1') then 
                        Q(0) <= data_in;
                        Q(Nb_bits_K-1 downto 1) <= Q(Nb_bits_K-2 downto 0);
                      --Q(Nb_bits_K-1 downto 0) <= data_in & Q(Nb_bits_K-2 downto 0)
                        if (compteur_stop < Nb_bits_K) then
                            compteur_stop <= compteur_stop + 1;
                        end if;
                        
                    elsif (compteur_u_pret = Nb_bits_N) then
                        compteur_stop <= 0; 
                    end if;
                end if;
            end if;
        end process; 
        registre <= Q; 
        
    -- Lorsque le enable est actif, compte (compteur_stop) jusqu'a K
    -- Sinon, reinitialise le compteur si le compteur_u = N
--    compteur_finito : process(clk, rst)
--        Begin
--            if rising_edge(clk) then
--                if (rst ='1') then
--                    compteur_stop <=  0;
--                else 
--                    if (enable ='1') then
--                        if (compteur_stop < Nb_bits_K) then
--                            compteur_stop <= compteur_stop + 1;
--                        end if;
--                    elsif (compteur_u_pret = Nb_bits_N) then
--                        compteur_stop <= 0;
--                    end if;
--                end if;
--           end if;
--       end process;
       

    -- Quand compteur_stop=K, u_pret = 1 et compte (compteur_u) jusqu'à N 
    pr_compteur_u_pret : process (clk, rst)
        Begin
            if rising_edge(clk) then
                if (rst = '1') then
                    compteur_u_pret <= 0;
                else
                    if ((compteur_stop = Nb_bits_K) and (compteur_u_pret < Nb_bits_N)) then 
                         compteur_u_pret <= compteur_u_pret +1;
                         u_pret <= '1';
                    else 
                        u_pret <= '0';
                        compteur_u_pret <= 0;
                    end if;
                end if;
            end if;
        end process;
end Behavioral;
