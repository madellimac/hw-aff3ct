----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 15.05.2023 09:56:37
-- Design Name: 
-- Module Name: Top_level_parallele - Behavioral
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

entity Top_level_parallele is
      generic (Nb_bits_N : integer := 8;
               Nb_bits_K : integer := 3;
               P : integer := 4;
               Nb_sorties : integer :=2);
      Port (
      clk : in std_logic;
      rst : in std_logic;
      en_in : in std_logic;
      vector_frozen : in std_logic_vector (P-1 downto 0); --désigne la position des bits gelés avec en 'MSB' la position la plus petite
      data_in : in std_logic;
      en_out : out std_logic;
      data_out : inout std_logic_vector(Nb_bits_N -1 downto 0));
end Top_level_parallele;

architecture Behavioral of Top_level_parallele is
--constant Nb_sorties : integer := Nb_bits_N/P;

component Multiplexeur is
    generic (
        Nb_bits_K         : integer := 3;             -- Nombre de coups d'horloge avant le changement de module
        Nb_sorties         : integer := 2;            -- Nombre de modules de sortie
        P : integer );
    port (
        clk      : in  std_logic;
        reset    : in  std_logic;
        dataIn   : in  std_logic;    -- Entrée (enable_in)
        dataOut  : inout std_logic_vector(Nb_sorties-1 downto 0)  -- Sorties (enable out)
    );
end component Multiplexeur;

component top_level_codeur is
      generic (P : integer :=4;
               Nb_bits_K : integer:=3;
               Nb_sorties : integer :=2);
      Port (
      clk : in std_logic;
      rst : in std_logic;
      en_in : in std_logic;
      vector_frozen : in std_logic_vector (P-1 downto 0); --désigne la position des bits gelés avec en 'MSB' la position la plus petite
      data_in : in std_logic;
      en_out : out std_logic;
      data_out : out std_logic_vector(P -1 downto 0));
end component;


component Multiplexeur_P2 is
    generic (
        Nb_bits_K         : integer := 3;             -- Nombre de coups d'horloge avant le changement de module
        Nb_bits_N         : integer := 8;            -- Nombre de modules de sortie
        P : integer;
        Nb_sorties : integer );
    port (
        clk      : in  std_logic;
        reset    : in  std_logic;
        enable_in : in std_logic_vector(Nb_sorties-1 downto 0);
        dataIn   : in std_logic_vector(Nb_bits_N-1 downto 0);    -- Entrée (enable_in)
        dataOut  : inout std_logic_vector(P-1 downto 0)  -- Sorties (enable out)
    );
end component Multiplexeur_P2;

component top_level_codeur_p2 is
      generic (Nb_bits_N : integer :=8;
               P : integer :=4;
               Nb_sorties : integer :=2);
      Port (
      clk : in std_logic;
      rst : in std_logic;
      enable_in : in std_logic_vector(Nb_sorties-1 downto 0);
      enable_out : out std_logic;
      data_in : in std_logic_vector(P-1 downto 0);
      data_out : inout std_logic_vector(Nb_bits_N-1 downto 0)); 
end component;

signal sig_enable_inter : std_logic_vector(Nb_sorties-1 downto 0);
signal sig_data_inter : std_logic_vector(P-1 downto 0);
signal sig_en_registre : std_logic_vector(Nb_sorties-1 downto 0);
signal sig_data_inter_P2 : std_logic_vector(Nb_bits_N-1 downto 0);
begin

inst_Multiplexeur_P1 : Multiplexeur 
    generic map(
        Nb_bits_K => Nb_bits_K,             -- Nombre de coups d'horloge avant le changement de module
        Nb_sorties => Nb_sorties,            -- Nombre de modules de sortie
        P => P)
    port map(
        clk => clk,
        reset => rst,
        dataIn => en_in,
        dataOut  =>sig_en_registre -- Sorties (enable out)
    );
    
inst_Multiplexeur_P2 : Multiplexeur_P2  
    generic map(
        Nb_bits_K => Nb_bits_K,             -- Nombre de coups d'horloge avant le changement de module
        Nb_sorties => Nb_sorties,            -- Nombre de modules de sortie
        P => P,
        Nb_bits_N => Nb_bits_N)
    port map(
        clk => clk,
        reset => rst,
        enable_in =>sig_enable_inter,
        dataIn => sig_data_inter_P2,
        dataOut  =>sig_data_inter -- Sorties (enable out)
    );
    

    
p1 : for n in (Nb_sorties-1) downto 0 generate
    top_lvl_p1 : top_level_codeur 
        generic map (P => P,
                    Nb_bits_K => Nb_bits_K,
                    Nb_sorties => Nb_sorties)
       port map ( clk => clk,
                  rst => rst,
                  en_in => sig_en_registre(n),
                  vector_frozen => vector_frozen,
                  en_out => sig_enable_inter(n),
                  data_in => data_in,
                  data_out => sig_data_inter_P2(P*(n+1)-1 downto P*n));
END GENERATE p1;


--top_lvl_p1 : top_level_codeur  
--       generic map (P => P,
--                    Nb_bits_K => Nb_bits_K)
--       port map ( clk => clk,
--                  rst => rst,
--                  en_in => en_in,
--                  vector_frozen => vector_frozen,
--                  en_out => sig_enable_inter,
--                  data_in => data_in,
--                  data_out => sig_data_inter);
                  
top_lvl_p2 : top_level_codeur_p2 
      generic map (Nb_bits_N => Nb_Bits_N,
                   P => P,
                   Nb_sorties => nb_sorties)
      Port map (
      clk => clk,
      rst => rst,
      enable_in => sig_enable_inter,
      enable_out => en_out,
      data_in => sig_data_inter,
      data_out => data_out);

end Behavioral;
