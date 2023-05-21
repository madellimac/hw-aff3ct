library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Multiplexeur_P2 is
    generic (
        Nb_bits_K    : integer := 3;            -- Nombre de coups d'horloge avant le changement de module
        Nb_bits_N    : integer := 8;            -- Nombre de bits de l'entrée
        P            : integer;
        Nb_sorties   : integer
    );
    port (
        clk      : in  std_logic;
        reset    : in  std_logic;
        enable_in : in  std_logic_vector(Nb_sorties-1 downto 0);
        dataIn   : in  std_logic_vector(Nb_bits_N-1 downto 0);    -- Entrée (enable_in)
        dataOut  : inout std_logic_vector(P-1 downto 0)           -- Sorties (enable out)
    );
end entity Multiplexeur_P2;

architecture Behavioral of Multiplexeur_P2 is
    signal counter : integer range 0 to Nb_bits_K-1 := 0;     -- Compteur pour le changement de module
    signal previousSignal : std_logic_vector(Nb_sorties-1 downto 0) := (others => '0');
begin
    process (clk, reset)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                counter <= 0;
                dataOut <= (others => '0');
            elsif enable_in /= previousSignal then
                counter <= (counter + 1) mod Nb_sorties;
                dataOut <= dataIn((P*(counter+1)-1) downto P*counter);
            end if;
            previousSignal <= enable_in;
        end if;
    end process;
end architecture Behavioral;