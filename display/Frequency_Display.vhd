library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Frequency_Display is
    Port (
        clk            : in  std_logic;    -- System clock
        reset          : in  std_logic;    -- Reset signal
        frequency_in   : in  unsigned(31 downto 0); -- Detected frequency input
        leds           : out std_logic_vector(7 downto 0) -- 8 LEDs for display
    );
end Frequency_Display;

architecture Behavioral of Frequency_Display is
    -- Frequency thresholds for each LED (adjust these as needed)
    constant THRESHOLD_1 : unsigned(31 downto 0) := to_unsigned(41, 32); -- 41 Hz (E1)
    constant THRESHOLD_2 : unsigned(31 downto 0) := to_unsigned(55, 32); -- 55 Hz (A1)
    constant THRESHOLD_3 : unsigned(31 downto 0) := to_unsigned(73, 32); -- 73 Hz (D2)
    constant THRESHOLD_4 : unsigned(31 downto 0) := to_unsigned(98, 32); -- 98 Hz (G2)
    constant THRESHOLD_5 : unsigned(31 downto 0) := to_unsigned(123, 32); -- Example threshold
    constant THRESHOLD_6 : unsigned(31 downto 0) := to_unsigned(148, 32); -- Example threshold
    constant THRESHOLD_7 : unsigned(31 downto 0) := to_unsigned(174, 32); -- Example threshold
    constant THRESHOLD_8 : unsigned(31 downto 0) := to_unsigned(200, 32); -- Example threshold

begin

    process(clk, reset)
    begin
        if reset = '1' then
            leds <= (others => '0'); -- Turn off all LEDs on reset
        elsif rising_edge(clk) then
            -- Map frequency ranges to LEDs
            if frequency_in < THRESHOLD_1 then
                leds <= "00000001"; -- LED 0 for very low frequencies
            elsif frequency_in < THRESHOLD_2 then
                leds <= "00000010"; -- LED 1 for E1 (41 Hz)
            elsif frequency_in < THRESHOLD_3 then
                leds <= "00000100"; -- LED 2 for A1 (55 Hz)
            elsif frequency_in < THRESHOLD_4 then
                leds <= "00001000"; -- LED 3 for D2 (73 Hz)
            elsif frequency_in < THRESHOLD_5 then
                leds <= "00010000"; -- LED 4 for G2 (98 Hz)
            elsif frequency_in < THRESHOLD_6 then
                leds <= "00100000"; -- LED 5 for higher frequencies
            elsif frequency_in < THRESHOLD_7 then
                leds <= "01000000"; -- LED 6 for higher frequencies
            else
                leds <= "10000000"; -- LED 7 for very high frequencies
            end if;
        end if;
    end process;

end Behavioral;
