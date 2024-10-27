library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity I2C_Controller is
    Port (
        clk         : in STD_LOGIC;
        reset       : in STD_LOGIC;
        start       : in STD_LOGIC;          -- Start configuration
        done        : out STD_LOGIC;         -- Configuration done signal
        i2c_scl     : inout STD_LOGIC;       -- I2C clock
        i2c_sda     : inout STD_LOGIC        -- I2C data
    );
end I2C_Controller;

architecture Behavioral of I2C_Controller is

    signal i2c_start : STD_LOGIC := '0';
    signal i2c_done  : STD_LOGIC;
    signal i2c_data  : STD_LOGIC_VECTOR(7 downto 0);
    signal i2c_reg_addr : STD_LOGIC_VECTOR(7 downto 0);

    -- States for sending multiple I2C commands to configure the codec
    type state_type is (IDLE, SEND_PLL_CONFIG, SEND_PLL_UPPER_BYTE, SEND_ADC_CONFIG, TRANSACTION_DONE);
    signal state : state_type := IDLE;

begin
    process (clk, reset)
    begin
        if reset = '1' then
            state <= IDLE;
            done <= '0';
        elsif rising_edge(clk) then
            case state is
                when IDLE =>
                    if start = '1' then
                        -- Start configuration by sending the first I2C command
                        state <= SEND_PLL_CONFIG;
                    end if;

                when SEND_PLL_CONFIG =>
                    -- Send PLL lower byte configuration
                    i2c_start <= '1';
                    i2c_reg_addr <= x"40"; -- Lower 8-bit address for PLL
                    i2c_data <= x"03";     -- Example data for PLL lower byte
                    if i2c_done = '1' then
                        state <= SEND_PLL_UPPER_BYTE; -- Move to the next state to send the upper byte
                    end if;
                    
                    when SEND_PLL_UPPER_BYTE =>
                        -- Send PLL upper byte configuration
                        i2c_start <= '1';
                        i2c_reg_addr <= x"41"; -- Upper 8-bit address for PLL
                        i2c_data <= x"00";     -- Example data for PLL upper byte
                        if i2c_done = '1' then
                            state <= SEND_ADC_CONFIG; -- Move to ADC config after PLL config
                        end if;
                    
                when SEND_ADC_CONFIG =>
                    -- Send I2C command to configure ADC
                    i2c_start <= '1';  -- Start I2C transaction
                    i2c_reg_addr <= x"18";  -- 8-bit ADC config register address
                    i2c_data <= x"31";  -- 8-bit ADC enable and input gain data
                    if i2c_done = '1' then
                        state <= TRANSACTION_DONE;  -- Move to TRANSACTION_DONE state after ADC config
                    end if;

                when TRANSACTION_DONE =>
                    done <= '1'; -- Signal configuration done
                    state <= IDLE;

                when others =>
                    state <= IDLE;
            end case;
        end if;
    end process;

    -- Instantiate the I2C Master to handle the actual communication
    I2C_Master_Inst : entity work.I2C_Master
        port map (
            clk => clk,
            reset => reset,
            start => i2c_start,
            address => "0011010",  -- ADAU1761 address
            rw => '0',             -- Write operation
            reg_addr => i2c_reg_addr,
            data_in => i2c_data,
            data_out => open,      -- Not needed for this
            i2c_scl => i2c_scl,
            i2c_sda => i2c_sda,
            done => i2c_done
        );

end Behavioral;
