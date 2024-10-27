library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;  -- Use numeric_std for type conversions

entity Audio_Sampling_TB is
end Audio_Sampling_TB;

architecture Behavioral of Audio_Sampling_TB is

    -- Signals to drive the DUT (Device Under Test)
    signal clk          : std_logic := '0';  -- System clock
    signal reset        : std_logic := '0';  -- Reset signal
    signal i2s_sck      : std_logic := '0';  -- I2S serial clock
    signal i2s_sd       : std_logic := '0';  -- I2S serial data
    signal audio_sample : std_logic_vector(23 downto 0);  -- Captured audio sample
    signal sample_ready : std_logic;  -- Sample ready flag

    -- Clock period definition
    constant CLK_PERIOD : time := 10 ns; -- 100 MHz clock

begin

    -- Clock generation
    clk_process : process
    begin
        clk <= '0';
        wait for CLK_PERIOD / 2;
        clk <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    -- I2S clock generation (to simulate I2S communication)
    i2s_sck_process : process
    begin
        wait for 45 ns;  -- Initial delay
        i2s_sck <= '0';
        loop
            i2s_sck <= '1';
            wait for 50 ns;  -- I2S clock high for 50 ns
            i2s_sck <= '0';
            wait for 50 ns;  -- I2S clock low for 50 ns
        end loop;
    end process;

    -- I2S data generation (simulate serial audio data)
    i2s_sd_process : process
    begin
        wait for 100 ns;  -- Initial delay
        i2s_sd <= '1';    -- Simulate sending serial audio data bit by bit
        for i in 0 to 23 loop
            wait for 100 ns;  -- Wait for one I2S clock period
            i2s_sd <= not i2s_sd;  -- Toggle data (alternate 1 and 0 for simplicity)
        end loop;
        wait;
    end process;

    -- DUT instance: Instantiate the Audio_Sampling module
    UUT: entity work.Audio_Sampling
        port map (
            clk          => clk,
            reset        => reset,
            i2s_sck      => i2s_sck,
            i2s_sd       => i2s_sd,
            audio_sample => audio_sample,
            sample_ready => sample_ready
        );

    -- Stimulus process
    stim_proc: process
    begin
        -- Initialize inputs
        reset <= '1';
        wait for 100 ns;
        
        -- Deassert reset
        reset <= '0';
        report "Reset deasserted, starting I2S data capture." severity note;
        wait for 50 ns;

        -- Wait for a longer duration to ensure we capture multiple samples
        wait for 10 us;

        -- Check the captured audio sample if sample_ready goes high
        if sample_ready = '1' then
            report "Audio sample captured: " & integer'image(to_integer(unsigned(audio_sample))) severity note;
        else
            report "Sample was not ready in time." severity warning;
        end if;

        -- End simulation
        report "Ending simulation." severity note;
        wait;
    end process;

end Behavioral;
