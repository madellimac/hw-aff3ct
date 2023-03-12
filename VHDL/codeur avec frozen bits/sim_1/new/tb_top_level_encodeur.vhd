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

entity tb_top_level_codeur is
end tb_top_level_codeur;

architecture Behavioral_tb_top_level_codeur of tb_top_level_codeur is

component top_level_codeur is 
      generic (
      Nb_bits_N : integer :=4;
      Nb_bits_K : integer :=2); --nb de clk pour générer une nouvelle valeur de u
      Port (
      clk : in std_logic;
      rst : in std_logic;
      en_in : in std_logic;
      vector_frozen : in std_logic_vector (3 downto 0);
      data_in : in std_logic;
      en_out : out std_logic;
      data_out : out std_logic
      );
end component;
  
constant cnst_NB_bits_N : integer :=4;
constant cnst_NB_bits_K : integer :=2;
signal sig_clk : std_logic :='0';  
signal sig_rst : std_logic;  
signal sig_en_in : std_logic;
signal sig_vector_frozen : std_logic_vector(3 downto 0);
signal sig_en_out : std_logic:='0';
signal sig_data_in : std_logic;
signal sig_data_out : std_logic:='0';

begin

    sig_clk<=not(sig_clk) after 5 ns;
    
    tb_top_level_codeur : top_level_codeur 
    generic Map(
    Nb_bits_N => cnst_NB_bits_N,
    Nb_bits_K => cnst_NB_bits_K)
    Port MAP(
    clk => sig_clk,
    rst => sig_rst,
    en_in  => sig_en_in,
    vector_frozen => sig_vector_frozen,
    data_in => sig_data_in,
    en_out => sig_en_out,
    data_out => sig_data_out);

    process
        Begin
            sig_rst<='1';
            sig_vector_frozen <= "0010";
            wait for 20 ns;
            sig_rst <= '0';
            wait for 20 ns;
            sig_data_in <= '1';
            sig_en_in <= '1';
            wait for 10 ns;
            sig_en_in <= '0';
            sig_data_in <='0';
                 
            wait for 20 ns;
            sig_en_in <= '1';
            wait for 10 ns;
            sig_en_in <= '0';
            wait;
        end process;

end Behavioral_tb_top_level_codeur;
