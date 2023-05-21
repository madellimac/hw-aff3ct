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
entity top_level_codeur_p2 is
      generic (Nb_bits_N : integer :=8;
               P : integer :=4;
               Nb_sorties : integer);
      Port (
      clk : in std_logic;
      rst : in std_logic;
      enable_in : in std_logic_vector(Nb_sorties-1 downto 0);
      enable_out : out std_logic;
      data_in : in std_logic_vector(P-1 downto 0);
      data_out : inout std_logic_vector(Nb_bits_N-1 downto 0)); 
end top_level_codeur_p2;

architecture Behavioral of top_level_codeur_p2 is

component Accumulateur_final is
      generic(Nb_bits_N : integer:=8;
              P : integer :=4;
              Nb_sorties : integer:= 2);
      port(
      clk : in std_logic;
      rst : in std_logic;
      enable_in : std_logic_vector(Nb_sorties-1 downto 0);
      enable_out : out std_logic;
      data_in : in std_logic_vector(P-1 downto 0);
      data_out : inout std_logic_vector(Nb_bits_N-1 downto 0));
end component;

begin

Accu : Accumulateur_final
       generic map (Nb_bits_N => Nb_bits_N,
                    P => P) 
       port map ( clk => clk,
                  rst => rst,
                  enable_in => enable_in,
                  enable_out => enable_out,
                  data_in => data_in,
                  data_out => data_out);
end Behavioral;
