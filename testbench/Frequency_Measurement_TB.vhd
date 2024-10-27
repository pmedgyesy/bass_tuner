library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Frequency_Measurement_TB is
end Frequency_Measurement_TB;

architecture Behavioral of Frequency_Measurement_TB is

    -- Signals to drive the DUT (Device Under Test)
    signal clk           : std_logic := '0';  -- System clock
    signal reset         : std_logic := '0';  -- Reset signal
    signal audio_sample  : std_logic_vector(23 downto 0) := (others => '0');
    signal sample_ready  : std_logic := '0';  -- Simulates when new audio samples are ready
    signal frequency     : unsigned(31 downto 0);  -- Frequency output from DUT

    -- Clock period definition
    constant CLK_PERIOD : time := 10 ns;  -- 100 MHz clock

    -- Simulation parameters
    constant SAMPLE_RATE : integer := 48000;  -- 48 kHz sampling rate
    constant TEST_FREQUENCY : integer := 41; -- A4 note, 41 Hz
    constant CYCLES_PER_PERIOD : integer := SAMPLE_RATE / (2 * TEST_FREQUENCY);

begin

    -- Clock generation
    clk_process : process
    begin
        clk <= '0';
        wait for CLK_PERIOD / 2;
        clk <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    -- Generate a simulated square wave input for the given TEST_FREQUENCY
    audio_waveform_generation : process
    begin
        wait for 100 ns;  -- Initial delay
        audio_sample <= std_logic_vector(to_signed(1000, 24)); -- Positive value
        sample_ready <= '1';
        for i in 0 to 1000 loop  -- Simulate 1000 cycles for a sufficient test run
            -- Simulate the positive half-cycle of the square wave
            wait for CYCLES_PER_PERIOD * CLK_PERIOD;
            audio_sample <= std_logic_vector(to_signed(-1000, 24)); -- Negative value
            sample_ready <= '1';

            -- Simulate the negative half-cycle of the square wave
            wait for CYCLES_PER_PERIOD * CLK_PERIOD;
            audio_sample <= std_logic_vector(to_signed(1000, 24)); -- Positive value
            sample_ready <= '1';
        end loop;
        wait;
    end process;

    -- DUT instance: Instantiate the Frequency_Measurement module
    UUT: entity work.Frequency_Measurement
        port map (
            clk           => clk,
            reset         => reset,
            audio_sample  => audio_sample,
            sample_ready  => sample_ready,
            frequency     => frequency
        );

    -- Stimulus process
    stim_proc: process
    begin
        -- Initialize inputs
        reset <= '1';
        wait for 100 ns;

        -- Deassert reset
        reset <= '0';
        report "Reset deasserted, starting frequency measurement." severity note;
        wait for 50 ns;

        -- Let the simulation run for a few milliseconds to capture frequency
        wait for 100 ms;

        -- Output the detected frequency
        report "Detected frequency: " & integer'image(to_integer(frequency)) & " Hz" severity note;

        -- End simulation
        report "Ending simulation." severity note;
        wait;
    end process;

end Behavioral;
