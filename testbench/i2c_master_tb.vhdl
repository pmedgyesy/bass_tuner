library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity I2C_Master_TB is
end I2C_Master_TB;

architecture Behavioral of I2C_Master_TB is
    -- Signals for connecting to the DUT (Device Under Test)
    signal clk         : std_logic := '0';
    signal reset       : std_logic := '0';
    signal start       : std_logic := '0';
    signal address     : std_logic_vector(6 downto 0);
    signal rw          : std_logic := '0'; -- Write operation
    signal reg_addr    : std_logic_vector(7 downto 0);
    signal data_in     : std_logic_vector(7 downto 0);
    signal i2c_scl     : std_logic := '1'; -- I2C clock line
    signal i2c_sda     : std_logic := '1'; -- I2C data line
    signal done        : std_logic := '0'; -- Transaction done

    -- Clock period definition
    constant CLK_PERIOD : time := 20 ns; -- 50 MHz clock

begin

    -- Clock generation process
    clk_process : process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;

    -- Instantiate the I2C Master (DUT)
    I2C_Master_Inst : entity work.I2C_Master
        port map (
            clk => clk,
            reset => reset,
            start => start,
            address => address,
            rw => rw,
            reg_addr => reg_addr,
            data_in => data_in,
            data_out => open, -- We are not testing read functionality
            i2c_scl => i2c_scl,
            i2c_sda => i2c_sda,
            done => done
        );

    -- Testbench stimulus process
    stim_proc: process
    begin
        -- Initialization
        reset <= '1';
        start <= '0';
        
        -- Wait for 100 ns
        wait for 100 ns;
        
        -- Deassert reset and start the transaction
        reset <= '0';
        wait for 50 ns;
        
        -- Begin I2C transaction
        start <= '1';
        address <= "0011010";   -- Example address for ADAU1761
        reg_addr <= "01010101"; -- Example register address
        data_in <= "10101010";  -- Example data to write
        rw <= '0';              -- Write operation
        
        -- Wait for transaction to complete
        wait for 20 ns;
        start <= '0'; -- Stop start after a few cycles

        -- Wait for done signal
        wait until done = '1';
        
        report "I2C Transaction Completed" severity note;

        -- End the simulation
        wait;
    end process;

end Behavioral;
