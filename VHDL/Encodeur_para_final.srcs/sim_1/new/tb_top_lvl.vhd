----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 27.02.2023 17:05:50
-- Design Name: 
-- Module Name: tb_top_level_encodeur - Behavioral_tb_top_level_encodeur
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

entity tb_top_level_parallele is
end tb_top_level_parallele;

architecture Behavioral_tb_top_level_parallele of tb_top_level_parallele is

component Top_level_parallele is 
      generic (
      Nb_bits_N : integer;
      Nb_bits_K : integer;
      P : integer);
      Port (
      clk : in std_logic;
      rst : in std_logic;
      en_in : in std_logic;
      vector_frozen : in std_logic_vector (P-1 downto 0); --désigne la position des bits gelés avec en 'MSB' la position la plus petite
      data_in : in std_logic;
      en_out : out std_logic;
      data_out : inout std_logic_vector(Nb_bits_N -1 downto 0));
end component;
  
constant cnst_NB_bits_N : integer :=4;
constant cnst_NB_bits_P : integer :=2;
constant cnst_NB_bits_k : integer :=1; --K est le nombre de bits nin gelés dans P


signal sig_clk : std_logic :='0';  
signal sig_rst : std_logic;  
signal sig_en_in : std_logic;
signal sig_vector_frozen : std_logic_vector (cnst_NB_bits_P-1 downto 0);
signal sig_data_in : std_logic;
signal sig_data_out : std_logic_vector(cnst_NB_bits_N -1 downto 0);
signal sig_en_out : std_logic;

begin

    sig_clk<=not(sig_clk) after 5 ns;
    
    tb_top_level_codeur : Top_level_parallele 
    generic Map(
    Nb_bits_N => cnst_NB_bits_N,
    NB_bits_k => cnst_NB_bits_k,
    P => cnst_NB_bits_P)
    Port MAP(
    clk => sig_clk,
    rst => sig_rst,
    en_in => sig_en_in,
    data_in => sig_data_in,
    vector_frozen => sig_vector_frozen,
    en_out => sig_en_out,
    data_out => sig_data_out);

    process
        Begin
        
--test pour N=16 et K = 4 et P = 8
--0100 pour 10

            sig_rst<='1';
            wait for 20 ns;
            sig_rst <= '0';
            wait for 20 ns;
            
            sig_vector_frozen <= "10";
            sig_data_in <= '0';
            sig_en_in <= '1';
            wait for 10 ns;
            sig_en_in <= '0';
            wait for 40 ns; 
            sig_en_in <= '1';
            sig_data_in <='1';               
            wait for 10 ns;
            
            sig_data_in <= '0';
            sig_en_in <= '0'; 
             
--test pour N=8 et K = 1et P = 4

--            sig_rst<='1';
--            wait for 20 ns;
--            sig_rst <= '0';
--            wait for 20 ns;
            
--            sig_vector_frozen <= "0010";
--            sig_data_in <= '1';
--            sig_en_in <= '1';
--            wait for 10 ns;
--            sig_data_in <='1';   
--            wait for 10 ns;
--            sig_data_in <='0';   
--            wait for 10 ns;
            
--            sig_en_in <= '0';
--            wait for 50 ns; 
--            sig_en_in <= '1';
--            sig_data_in <='1';   
--            wait for 10 ns;
--            sig_data_in <='0'; 
           
--            sig_vector_frozen <= "0010";
--            wait for 10 ns;
--            sig_data_in <='1';   
--            wait for 10 ns;


--            sig_data_in <= '0';
--            sig_en_in <= '0'; 
             

--test pour N=8 et K = 1 et P = 4    
--J'envoie (111110) donc c'est si j'allais coder (011111)
--Frozen : (1100) puis (0000) 
--Donc on va coder (00011111)
--En sortie de P1 : D'abord : (0001) Puis (1111)     
--En sortie de P2 : (11100001)
--              sig_data_in <= '0';
--              sig_en_in <= '1'; 
--              sig_vector_frozen <= "0000"; 
--              wait for 10 ns;
--              sig_data_in <= '1'; 
--              wait for 10 ns;
--              sig_data_in <= '1';
--              wait for 20 ns;
              
--              sig_vector_frozen <= "1100"; 
--              sig_data_in <= '1';
--              wait for 10 ns; 
--              sig_data_in <= '1';
--              wait for 10 ns;
--              sig_data_in <= '1';
--              wait for 20 ns;
              
--              wait for 10 ns;
--              sig_data_in <= '0';
--              sig_en_in <= '0';

            wait;
        end process;

end Behavioral_tb_top_level_parallele;
