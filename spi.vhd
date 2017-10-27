LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY spi IS
  PORT (
        clk : IN std_logic;

        sclk : IN std_logic;
        ss_n : IN std_logic;
        mosi : IN std_logic;
        miso : OUT std_logic;

        spi_data_receive: OUT std_logic_vector(11 downto 0);
        spi_data_send: IN std_logic_vector(11 downto 0);

        spi_data_valid : OUT std_logic;
        spi_write_enable : IN std_logic;

        spi_data_request: OUT std_logic
    );		
END ENTITY spi;

ARCHITECTURE bhv of spi IS

    COMPONENT spi_slave IS
        Generic (   
            N : positive := 32;                                             -- 32bit serial word length is default
            CPOL : std_logic := '0';                                        -- SPI mode selection (mode 0 default)
            CPHA : std_logic := '0';                                        -- CPOL = clock polarity, CPHA = clock phase.
            PREFETCH : positive := 3);                                      -- prefetch lookahead cycles
        Port (  
            clk_i : in std_logic := 'X';                                    -- internal interface clock (clocks di/do registers)
            spi_ssel_i : in std_logic := 'X';                               -- spi bus slave select line
            spi_sck_i : in std_logic := 'X';                                -- spi bus sck clock (clocks the shift register core)
            spi_mosi_i : in std_logic := 'X';                               -- spi bus mosi input
            spi_miso_o : out std_logic := 'X';                              -- spi bus spi_miso_o output
            di_req_o : out std_logic;                                       -- preload lookahead data request line
            di_i : in  std_logic_vector (N-1 downto 0) := (others => 'X');  -- parallel load data in (clocked in on rising edge of clk_i)
            wren_i : in std_logic := 'X';                                   -- user data write enable
            wr_ack_o : out std_logic;                                       -- write acknowledge
            do_valid_o : out std_logic;                                     -- do_o data valid strobe, valid during one clk_i rising edge.
            do_o : out  std_logic_vector (N-1 downto 0);                    -- parallel output (clocked out on falling clk_i)
            --- debug ports: can be removed for the application circuit ---
            do_transfer_o : out std_logic;                                  -- debug: internal transfer driver
            wren_o : out std_logic;                                         -- debug: internal state of the wren_i pulse stretcher
            rx_bit_next_o : out std_logic;                                  -- debug: internal rx bit
            state_dbg_o : out std_logic_vector (3 downto 0);                -- debug: internal state register
            sh_reg_dbg_o : out std_logic_vector (N-1 downto 0)              -- debug: internal shift register
        );         
    END COMPONENT spi_slave;

   

BEGIN

    sp_s: spi_slave GENERIC MAP(N => 12) PORT MAP(
            clk_i => clk,
            spi_ssel_i => ss_n,
            spi_sck_i => sclk,
            spi_mosi_i => mosi,
            spi_miso_o => miso,
            di_req_o => spi_data_request,
            di_i => spi_data_send,
            wren_i => spi_write_enable,
            wr_ack_o => open,
            do_valid_o => spi_data_valid,
            do_o => spi_data_receive
        );


END bhv;