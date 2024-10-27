library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Frequency_Measurement is
    Port (
        clk            : in  std_logic;  -- System clock
        reset          : in  std_logic;  -- Reset signal
        audio_sample   : in  std_logic_vector(23 downto 0);  -- 24-bit audio sample input
        sample_ready   : in  std_logic;  -- Indicates when a new sample is available
        frequency      : out unsigned(31 downto 0)  -- Calculated frequency as unsigned (32-bit output)
    );
end Frequency_Measurement;

architecture Behavioral of Frequency_Measurement is
    signal previous_sample : std_logic_vector(23 downto 0) := (others => '0');
    signal zero_crossing_count : integer := 0;
    signal time_between_crossings : integer := 0;
    signal period : integer := 0;
    constant SAMPLE_RATE : integer := 48000;  -- Assuming 48 kHz audio sampling rate
    
begin

    process(clk, reset)
        variable frequency_calc : integer := 0;
    begin
        if reset = '1' then
            previous_sample <= (others => '0');
            zero_crossing_count <= 0;
            time_between_crossings <= 0;
            period <= 0;
            frequency <= (others => '0');
        elsif rising_edge(clk) then
            if sample_ready = '1' then
                -- Detect zero crossing: previous sample positive, current sample negative or vice versa
                if (signed(previous_sample) > 0 and signed(audio_sample) < 0) or
                   (signed(previous_sample) < 0 and signed(audio_sample) > 0) then
                   
                    zero_crossing_count <= zero_crossing_count + 1;

                    -- Calculate period as time between zero crossings
                    if zero_crossing_count = 2 then
                        period <= time_between_crossings;
                        time_between_crossings <= 0;  -- Reset for next measurement
                        zero_crossing_count <= 0;

                        -- Calculate frequency: f = SAMPLE_RATE / period
                        if period > 0 then
                            frequency_calc := SAMPLE_RATE / period;
                            frequency <= to_unsigned(frequency_calc, 32);
                        else
                            frequency <= (others => '0');  -- Avoid division by zero
                        end if;
                    end if;

                end if;

               -- Increment time between crossings only if we are not resetting it
                if zero_crossing_count /= 2 then
                    time_between_crossings <= time_between_crossings + 1;
                end if;

                -- Store the current sample for the next comparison
                previous_sample <= audio_sample;
            end if;
        end if;
    end process;

end Behavioral;