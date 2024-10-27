library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Bass_Tuner_Top is
    Port (
        clk          : in  std_logic; -- System clock input
        reset        : in  std_logic; -- Reset signal
        i2s_sck      : in  std_logic; -- I2S serial clock input
        i2s_sd       : in  std_logic; -- I2S serial data input (audio data)
        leds         : out std_logic_vector(7 downto 0) -- 8 LEDs for frequency display
    );
end Bass_Tuner_Top;

architecture Behavioral of Bass_Tuner_Top is
    -- Signals to connect between modules
    signal frequency : unsigned(31 downto 0) := (others => '0');
    signal sample_ready    : std_logic := '0';
    signal audio_sample    : std_logic_vector(23 downto 0) := (others => '0');

begin
    -- Instantiate the audio sampling module (I2S receiver)
    Audio_Sampling_Inst : entity work.Audio_Sampling
        port map (
            clk          => clk,
            reset        => reset,
            i2s_sck      => i2s_sck,
            i2s_sd       => i2s_sd,
            audio_sample => audio_sample,
            sample_ready => sample_ready
        );

    -- Instantiate the frequency detection module
    Frequency_Measurement_Inst : entity work.Frequency_Measurement
        port map (
            clk            => clk,
            reset          => reset,
            audio_sample   => audio_sample,
            sample_ready   => sample_ready,
            frequency  => frequency
        );

    -- Instantiate the LED control module
    Frequency_Display_Inst : entity work.Frequency_Display
        port map (
            clk          => clk,
            reset        => reset,
            frequency_in => frequency,
            leds         => leds
        );

end Behavioral;
