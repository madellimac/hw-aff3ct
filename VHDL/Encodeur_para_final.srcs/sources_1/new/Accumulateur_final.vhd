----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 27.03.2023 15:59:05
-- Design Name: 
-- Module Name: Accumulateur - Behavioral
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


entity Accumulateur_final is
      generic(Nb_bits_N : integer;
              P : integer;
              Nb_sorties : integer);
      port(
      clk : in std_logic;
      rst : in std_logic;
      enable_in : in std_logic_vector(Nb_sorties-1 downto 0);
      enable_out : out std_logic;
      data_in : in std_logic_vector(P-1 downto 0);
      data_out : inout std_logic_vector(Nb_bits_N-1 downto 0));
end Accumulateur_final;

architecture Behavioral of Accumulateur_final is

signal compteur_1 : integer :=0 ;
constant nb_etage : integer :=(Nb_bits_N / P);

type s_array is array(0 to nb_etage) of std_logic_vector(P-1 downto 0);

signal s_int : s_array; 
   
--component bascule is
--  generic(P : integer);
--  Port (clk,rst : in std_logic;
--        d : in std_logic_vector(P-1 downto 0);
--        q : out std_logic_vector(P-1 downto 0));
--end component;
    
--Begin 

--gen_etage : for i in 0 to nb_etage-1 generate
    
--Lower_stage : if i = 0 generate 
    
--    E0 : bascule generic map(P =>P) 
--         port map(clk => clk,
--                rst => rst,
--                d => data_in xor s_int(1),
--                q => s_int(1));    
--    end generate Lower_stage;  
          
--Upper_stage : if i > 0 generate 
--   Ei : bascule generic map(P => P) 
--      port map(clk => clk,
--               rst => rst,
--               d => s_int(i) xor s_int(i+1) ,
--               q => s_int(i+1));
--   end generate Upper_stage;
--end generate gen_etage;
Begin
pr_sortie : process(clk,rst, data_in, enable_in, compteur_1)
    variable zero : std_logic_vector(P-1 downto 0) := (others => '0');
    variable zero_bis : std_logic_vector(Nb_sorties-1 downto 0) :=(others =>'0');
    begin 
        if (clk='1' and clk'event) then 
            if (rst ='1') then
                s_int <= (0 => data_in , others => zero);
            elsif (enable_in /= zero_bis) then 
                    if (nb_etage > 1) then                                                                                      
                        if (compteur_1 = 0) then 
                            s_int <= (0 => data_in , others => zero);
                        else 
                            l : for k in 1 to Nb_etage-1 loop
                                s_int(k) <= s_int(k) xor s_int(k-1);
                            end loop l;
                            s_int(0) <= data_in;
                            s_int(nb_etage) <= s_int(nb_etage-1);
                        end if;
                    
                     else          
                         s_int(1) <= s_int(0);
                         s_int(0) <= data_in;                       
                    end if;
              end if;
       end if;
   end process;
   
pr_enable_sortie : process(clk,rst, enable_in, compteur_1, s_int)
variable i : integer := 0;
variable zero : std_logic_vector(Nb_sorties -1 downto 0) := (others=>'0');

    begin
    
        if (clk ='1' and clk'event) then
            if (rst ='1') then
                compteur_1 <= 0;
                data_out <= (others => '0');
            elsif (compteur_1 < Nb_etage) then
                    enable_out <= '0';
                    data_out <= (others => '0');
                    i := 0; 
                    if (enable_in /= zero) then
                        compteur_1 <= compteur_1 +1;                       
                    end if;
            elsif ( compteur_1 = Nb_etage) then
                    while (i /= Nb_etage) loop 
                    data_out((Nb_bits_N-1-i*P) downto (Nb_bits_N-(i+1)*P)) <= s_int(Nb_etage -(Nb_etage-i)) xor s_int(Nb_etage- (Nb_etage-(i+1)));
                    i := i + 1;
                    end loop;
                    enable_out <= '1';
                    compteur_1 <= 0;                  
            end if;         
        end if;
end process;
     
            
end behavioral;
