library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Multiplexeur is
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
end entity Multiplexeur;

architecture Behavioral of Multiplexeur is
    signal counter : integer range 0 to Nb_bits_K-1 := 0;     -- Compteur pour le changement de module

begin
    process (clk, reset)
    variable zero : std_logic_vector(Nb_sorties-1 downto 0) := (others =>'0');
    begin
        if rising_edge(clk) then
            if reset = '1' then
                counter <= 0;
                dataOut <= (others => '0');
            elsif ( datain ='1') then 
                if (dataOut = zero) then 
                    dataOut <= (0=>'1', others => '0');
                elsif counter = Nb_bits_K-1 then
                    if ( dataOut(Nb_sorties-1) = '1') then 
                        dataOut <= (0=>'1', others => '0');
                    else 
                        dataOut <= (dataOut(Nb_sorties-2 downto 0) & "0");
                    end if;
                else
                   -- Pas de changement de module, les sorties restent inchangées
                    dataOut <= dataOut;
                end if;
                counter <= (counter + 1) mod Nb_bits_K;
            else 
                dataOut <= (others => '0');               
            end if;
        end if;
    end process;
end architecture Behavioral;