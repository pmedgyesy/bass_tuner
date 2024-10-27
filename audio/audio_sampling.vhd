library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Audio_Sampling is
    Port (
        clk           : in  std_logic;  -- System clock
        reset         : in  std_logic;  -- Reset signal
        i2s_sck       : in  std_logic;  -- I2S serial clock
        i2s_sd        : in  std_logic;  -- I2S serial data (audio data)
        audio_sample  : out std_logic_vector(23 downto 0); -- 24-bit audio sample output
        sample_ready  : out std_logic   -- Indicates when a new sample is ready
    );
end Audio_Sampling;

architecture Behavioral of Audio_Sampling is
    signal audio_data : std_logic_vector(23 downto 0) := (others => '0');
    signal bit_counter : integer := 0;
    signal sample_rdy : std_logic := '0';
begin
    -- Process to handle system clock-related logic
    process (clk, reset)
    begin
        if reset = '1' then
            sample_rdy <= '0';
        elsif rising_edge(clk) then
            if bit_counter = 0 then
                sample_rdy <= '0'; -- Reset sample ready flag at the start of a new sample
            end if;
        end if;
    end process;

    -- Process to handle I2S clock-related logic and data capture
    process (i2s_sck, reset)
    begin
        if reset = '1' then
            audio_data <= (others => '0');
            bit_counter <= 0;
        elsif rising_edge(i2s_sck) then
            audio_data(bit_counter) <= i2s_sd; -- Shift in I2S data bit by bit
            if bit_counter = 23 then
                bit_counter <= 0;
                audio_sample <= audio_data; -- Output the captured 24-bit audio sample
                sample_rdy <= '1'; -- Indicate that a sample is ready
            else
                bit_counter <= bit_counter + 1;
            end if;
        end if;
    end process;

end Behavioral;

