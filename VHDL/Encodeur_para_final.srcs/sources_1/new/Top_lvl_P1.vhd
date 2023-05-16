----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06.03.2023 15:45:51
-- Design Name: 
-- Module Name: top_level_codeur - Behavioral
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

--On suppose que le premier bit reçu est le LSB
--exemple : si on envoie un vecteur : (01) avec un vecteur_frozen =(0101), 
--          le vecteur en entrée de calcul registre sera (1000) avec (u0, u1 ,u2, u3)
--          En effet : (01) -> (10) [inversion data_entrée pour faciliter calcul_registre] -> (1000) [ajout des frozen bits] -> code = (1000) donc data_out = 0 puis 0 puis 0 puis 1

--Vector frozen pas encore générique.
entity top_level_codeur is
      generic (P : integer;
               Nb_bits_K : integer);
      Port (
      clk : in std_logic;
      rst : in std_logic;
      en_in : in std_logic;
      vector_frozen : in std_logic_vector (P-1 downto 0); --désigne la position des bits gelés avec en 'MSB' la position la plus petite
      data_in : in std_logic;
      en_out : out std_logic;
      data_out : out std_logic_vector(P -1 downto 0));
end top_level_codeur;

architecture Behavioral of top_level_codeur is

component registre_a_decalage is
      generic ( Nb_bits_K : integer ;
                P : integer);
      Port (clk : in STD_LOGIC;
            enable : in std_logic;
            rst : in std_logic;
            data_in : in std_logic;
            u_pret : out std_logic; 
            registre : out std_logic_vector(Nb_bits_K-1 downto 0) := (others =>'0'));
end component;

component Comparateur is
  generic ( Nb_bits_k : integer;
            P : integer);
  Port (clk : in std_logic;
        rst : in std_logic;
        vector_frozen: in std_logic_vector(P-1 downto 0);
        enable_registre_in : in std_logic; --registre d'entrée prêt pendant N*T_clk
        registre_in : in std_logic_vector(Nb_bits_k-1 downto 0);
        enable_out : out std_logic;
        output : out std_logic);
end component;

component calcul_registre is 
    generic (P : integer);
    Port ( 
      clk : in std_logic;
      rst : in std_logic;
      en_in : in std_logic;
      data_in : in std_logic;
      en_out : out std_logic;
      --data_out : out std_logic
      data_out : out std_logic_vector(P -1 downto 0));
end component calcul_registre;

signal sig_enable_registre_in : std_logic;
signal sig_registre_in : std_logic_vector(Nb_bits_K-1 downto 0);
signal sig_out_comp : std_logic;
signal sig_enable_out_comp : std_logic;

begin

inst_registre_a_decalage : registre_a_decalage
    generic map (Nb_bits_K => Nb_bits_K,
                 P => P)
    Port Map (clk => clk,
            enable => en_in,
            rst => rst,
            data_in => data_in,
            u_pret => sig_enable_registre_in,
            registre => sig_registre_in);
            
            
inst_registre_comparateur : comparateur
    generic map (Nb_bits_K => Nb_bits_K,
                 P => P)
    Port Map (clk => clk,
            rst => rst,
            vector_frozen => vector_frozen,
            enable_registre_in => sig_enable_registre_in,
            registre_in => sig_registre_in,
            enable_out => sig_enable_out_comp,
            output => sig_out_comp);
            
            
            
inst_calcul_reg : calcul_registre 
      generic map(P => P)
      Port Map(clk => clk,
      rst => rst,
      en_in => sig_enable_out_comp,
      data_in => sig_out_comp,
      en_out => en_out,
      data_out => data_out);
      
end Behavioral;
