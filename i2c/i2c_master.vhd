library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity I2C_Master is
    Port (
        clk         : in STD_LOGIC;  -- Main clock
        reset       : in STD_LOGIC;  -- Reset signal
        start       : in STD_LOGIC;  -- Start I2C transaction
        address     : in STD_LOGIC_VECTOR(6 downto 0); -- 7-bit address of the device
        rw          : in STD_LOGIC;  -- Read/write control ('0' for write, '1' for read)
        reg_addr    : in STD_LOGIC_VECTOR(7 downto 0); -- Register address in ADAU1761
        data_in     : in STD_LOGIC_VECTOR(7 downto 0); -- Data to write
        data_out    : out STD_LOGIC_VECTOR(7 downto 0); -- Data read from ADAU1761
        i2c_scl     : inout STD_LOGIC;  -- I2C clock
        i2c_sda     : inout STD_LOGIC;  -- I2C data
        done        : out STD_LOGIC     -- Indicates transaction completion
    );
end I2C_Master;

architecture Behavioral of I2C_Master is

    -- I2C states
    type state_type is (IDLE, START_CONDITION, SEND_ADDRESS, SEND_REG_ADDR, SEND_DATA, STOP_CONDITION, TRANSACTION_DONE);
    signal bit_counter : integer range 0 to 7 := 0;
    signal reg_bit_counter : integer range 0 to 7 := 0;
    signal data_bit_counter : integer range 0 to 7 := 0;

    signal state : state_type := IDLE;

    -- I2C clock divider for 100kHz (assuming 100MHz system clock)
    signal i2c_clk : STD_LOGIC := '1';
    signal clk_count : INTEGER := 0;
    constant I2C_DIV : INTEGER := 500; -- Divides system clock by 500 to get 100kHz

    -- Internal signals
    signal sda_internal : STD_LOGIC := '1';
    signal scl_internal : STD_LOGIC := '1';

begin

    -- I2C clock generation
    
    process (clk)
    begin
        if rising_edge(clk) then
            if clk_count < I2C_DIV/2 then
                clk_count <= clk_count + 1;
            else
                i2c_clk <= not i2c_clk;
                clk_count <= 0;
            end if;
        end if;
    end process;

    -- I2C state machine
    process (clk, reset)
    begin
        if reset = '1' then
            state <= IDLE;
            sda_internal <= '1';
            scl_internal <= '1';
        elsif rising_edge(clk) then
            case state is
                when IDLE =>
                    if start = '1' then
                        state <= START_CONDITION;
                    end if;

                when START_CONDITION =>
                    sda_internal <= '0';  -- Start condition (SDA goes low while SCL is high)
                    scl_internal <= '1';
                    if i2c_clk = '1' then
                        state <= SEND_ADDRESS;
                    end if;
                    


                when SEND_ADDRESS =>
                    if bit_counter < 7 then
                        -- Send address bits
                        sda_internal <= address(6 - bit_counter); -- Send MSB first
                    elsif bit_counter = 7 then
                        -- Send RW bit (write or read)
                        sda_internal <= rw;
                    end if;
                
                    -- Move to next bit
                    if i2c_clk = '1' then
                        bit_counter <= bit_counter + 1;
                        if bit_counter = 7 then
                            state <= SEND_REG_ADDR; -- Move to the next state after address is sent
                        end if;
                    end if;

                when SEND_REG_ADDR =>
                    -- Send register address bits
                    sda_internal <= reg_addr(7 - reg_bit_counter); -- Send MSB first
                
                    -- Move to next bit
                    if i2c_clk = '1' then
                        reg_bit_counter <= reg_bit_counter + 1;
                        if reg_bit_counter = 7 then
                            state <= SEND_DATA; -- Move to next state after register address is sent
                        end if;
                    end if;

                when SEND_DATA =>
                    -- Send data bits
                    sda_internal <= data_in(7 - data_bit_counter); -- Send MSB first
                
                    -- Move to next bit
                    if i2c_clk = '1' then
                        data_bit_counter <= data_bit_counter + 1;
                        if data_bit_counter = 7 then
                            state <= STOP_CONDITION; -- Move to the stop condition state
                        end if;
                    end if;

                when STOP_CONDITION =>
                    sda_internal <= '1';  -- Stop condition (SDA goes high while SCL is high)
                    scl_internal <= '1';
                    if i2c_clk = '1' then
                        state <= TRANSACTION_DONE;
                    end if;

                when TRANSACTION_DONE =>
                    done <= '1'; -- Transaction is complete
                    state <= IDLE;

                when others =>
                    state <= IDLE;
            end case;
        end if;
    end process;

    -- Assign I2C signals
    i2c_scl <= scl_internal;
    i2c_sda <= sda_internal;

end Behavioral;
