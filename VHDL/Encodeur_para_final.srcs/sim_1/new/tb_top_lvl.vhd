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
      Nb_bits_N : integer; --Nb_bits total
      Nb_bits_K : integer; --Nb de bits pas gelés du paquet
      P : integer;
      Nb_sorties : integer); --Nb de bits dans un paquet
      Port (
      clk : in std_logic;
      rst : in std_logic;
      en_in : in std_logic;
      vector_frozen : in std_logic_vector (P-1 downto 0); --désigne la position des bits gelés avec en 'MSB' la position la plus petite
      data_in : in std_logic;
      en_out : out std_logic;
      data_out : inout std_logic_vector(Nb_bits_N -1 downto 0));
end component;
  
constant cnst_NB_bits_N : integer :=8;
constant cnst_NB_bits_P : integer :=4;
constant cnst_NB_bits_k : integer :=3; --K est le nombre de bits non gelés dans P
constant cnst_Nb_sorties : integer :=2;


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
    P => cnst_NB_bits_P,
    Nb_sorties => cnst_Nb_sorties)
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
        
--test pour N=8 et K = 1et P = 4
--Je veux coder 0011 1001. avec frozen bit : ( 0100 ) (rang 2 sur 3 gelé).
--J'envoie donc 011 puis 101
--Attention, il faut attendre K+N+1 période d'horloge pour envoyer le second paquet.

            sig_rst<='1';
            wait for 20 ns;
            sig_rst <= '0';
            wait for 20 ns;
            
            sig_vector_frozen <= "0100";
            sig_data_in <= '1';
            sig_en_in <= '1';
            wait for 10 ns;
            sig_data_in <='1';   
            wait for 10 ns;
            sig_data_in <='0';   
            wait for 10 ns;
            
            --sig_en_in <= '0';
--            wait for 50 ns; --wait for K avec K nb de bits pas gelés.
            --wait for 10 ns;
            sig_en_in <= '1';
            sig_data_in <='1';   
            wait for 10 ns;
            sig_data_in <='0'; 
            --on attend 2P-K
            sig_vector_frozen <= "0100";
            wait for 10 ns;
            sig_data_in <='1';   
            wait for 10 ns;


            sig_data_in <= '0';
            sig_en_in <= '0'; 
             
            wait;
        end process;

end Behavioral_tb_top_level_parallele;
