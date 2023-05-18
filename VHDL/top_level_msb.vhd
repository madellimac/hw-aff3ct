
---------------------------TOP_LEVEL--------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top_level is
    Port ( clk    : in  STD_LOGIC;
        reset  : in  STD_LOGIC;
        RX     : in  STD_LOGIC;
        --vector_frozen : in  STD_LOGIC_VECTOR(9 downto 0);
        --enable : in std_logic;
        TX         : out STD_LOGIC;
        fifo_empty : out STD_LOGIC;
        fifo_afull : out STD_LOGIC;
        fifo_full  : out STD_LOGIC
        );
end top_level;
  

architecture Behavioral of top_level is

component UART_recv is
   Port ( clk    : in  STD_LOGIC;
          reset  : in  STD_LOGIC;
          RX     : in  STD_LOGIC;
          dat    : out STD_LOGIC_VECTOR (7 downto 0);
          dat_en : out STD_LOGIC);
end component;


 component top_level_codeur is
    Port ( clk : in std_logic;
    rst : in std_logic;
    en_in : in std_logic;
    vector_frozen : in std_logic_vector (15 downto 0); --d�signe la position des bits gel�s avec en 'MSB' la position la plus petite
    data_in : in std_logic;
    en_out : out std_logic;
    data_out : out std_logic);
 end component;

component UART_fifoed_send is
    Port (
        clk_100MHz : in  STD_LOGIC;
        reset      : in  STD_LOGIC;
        dat_en     : in  STD_LOGIC;
        dat2        : in  STD_LOGIC_VECTOR (7 downto 0);
        TX         : out STD_LOGIC;
        fifo_empty : out STD_LOGIC;
        fifo_afull : out STD_LOGIC;
        fifo_full  : out STD_LOGIC
    );
end component;


signal s_dat : STD_LOGIC_VECTOR (7 downto 0);
signal s_dat_en : STD_LOGIC;

signal s_oen : std_logic;
signal s_full  : std_logic;

signal s_en_out : std_logic;

signal test : std_logic_vector(7 downto 0);

signal s_fct : std_logic := '0';

signal vector_frozen_vec :  STD_LOGIC_VECTOR(15 downto 0):="1111111010000000";

begin 

rec : UART_recv
port map (clk  =>clk,
        reset  =>reset,
        RX     =>RX,
        dat    =>s_dat,
        dat_en =>s_dat_en);
 
enc : top_level_codeur
    port map (clk  =>clk,
            rst  =>reset,
            en_in => s_dat_en,
            data_in => s_dat(0),
           vector_frozen => vector_frozen_vec,
            en_out   => s_en_out,
            data_out => test(0));

send : UART_fifoed_send
port map (clk_100MHz =>clk,
        reset      =>reset,
        dat_en     =>s_en_out,
        dat2        =>test(7 downto 0),
        TX         =>TX,
        fifo_empty =>fifo_empty,
        fifo_afull =>fifo_afull,
        fifo_full  =>fifo_full
         );
         
end Behavioral;
