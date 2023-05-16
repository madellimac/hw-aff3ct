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
                P : integer :=4);
      Port (clk : in STD_LOGIC;
            enable : in std_logic;
            rst : in std_logic;
            data_in : in std_logic;
            u_pret : out std_logic;  
            registre : out std_logic_vector(Nb_bits_K-1 downto 0) := (others =>'0'));
end registre_a_decalage;

architecture Behavioral of registre_a_decalage is
signal Q : std_logic_vector(Nb_bits_K-1 downto 0) := (others =>'0');
signal compteur_stop : integer :=0;
signal compteur_u_pret : integer :=0;
signal stop : integer :=0;
begin
    process(clk,rst,data_in)
        begin
            if (clk='1' and clk'event) then 
                if (rst ='1') then
                    Q <= (others =>'0');
                else
                    if (enable ='1') then 
                        Q(0) <= data_in;
                        Q(Nb_bits_K-1 downto 1) <= Q(Nb_bits_K-2 downto 0);
                    end if;
                end if;
            end if;
        end process; 
        registre <= Q; 
        
    compteur_finito : process(clk,rst,compteur_u_pret, enable)
        Begin
            if (clk='1' and clk'event) then
                if (rst ='1') then
                    compteur_stop <=  0;
                else 
                    if (enable ='1') then
                        if (compteur_stop < Nb_bits_K) then
                            compteur_stop <= compteur_stop + 1;
                        end if;
                    elsif (compteur_u_pret = P) then
                        compteur_stop <= 0;
                    end if;
                end if;
           end if;
       end process;
       
       
pr_compteur_u_pret : process (clk, rst, compteur_stop, compteur_u_pret)
    Begin
        if (clk ='1' and clk'event) then
            if (rst = '1') then
                compteur_u_pret <= 0;
            else
                if ((compteur_stop = Nb_bits_K) and (compteur_u_pret < P)) then 
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
