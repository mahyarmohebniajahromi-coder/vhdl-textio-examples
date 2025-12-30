library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library STD;
use STD.TEXTIO.ALL;

use work.String_to_Vector.all;

-- ============================================================================
-- Entity: Conv64File_read
-- ----------------------------------------------------------------------------
-- Purpose:
--   This module reads **25-bit data** from a set of text files (32 files total).
--   Each file contains a fixed number of samples (here: 676 lines).
--
-- High-level idea:
--   - There are 32 input files (outputdata01.txt ... outputdata32.txt).
--   - A "current file index" selects which file to read.
--   - The module outputs one 25-bit word per line when send_data='1'.
--   - When the current file reaches its last line (676th), it stops outputting
--     valid data and asserts data_over='1' until the top level requests the
--     next file via next_address='1'.
--
-- Control signals:
--   next_address:
--     When asserted, moves to the next file and resets the per-file line counter.
--
-- Outputs:
--   data_over:
--     Indicates that the current file has finished (676 samples were read).
--
--   file_over:
--     Indicates that all files are finished (after file 32 and its 676 samples).
--
-- Notes / Cautions (important!):
--   1) file_open should NOT be executed continuously as a concurrent statement.
--      It should be done in a controlled clocked/reset process, otherwise the
--      simulator may repeatedly reopen the file.
--   2) Some processes below are missing rising_edge(clk) (pure combinational),
--      but they read counter/state signals; consider making them synchronous.
--   3) For clarity, consider using generics for:
--      - NUM_FILES = 32
--      - LINES_PER_FILE = 676
-- ============================================================================
entity Conv64File_read is
    port(
        clk          : in  std_logic;
        reset        : in  std_logic;
        next_address : in  std_logic;
        send_data    : in  std_logic;
        data_over    : out std_logic;
        file_over    : out std_logic;
        Dataout      : out std_logic_vector(24 downto 0)
    );
end Conv64File_read;

architecture Behavioral of Conv64File_read is

    -- ------------------------------------------------------------------------
    -- File list: 32 absolute Windows paths (each 71 chars long)
    -- ------------------------------------------------------------------------
    type file_array is array (0 to 31) of string(1 to 71);

    constant filenames : file_array := (
        "C:\\Users\\Mahyar\\Desktop\\CNN OutPut\\conv64\\input\\outputdata01.txt",
        "C:\\Users\\Mahyar\\Desktop\\CNN OutPut\\conv64\\input\\outputdata02.txt",
        "C:\\Users\\Mahyar\\Desktop\\CNN OutPut\\conv64\\input\\outputdata03.txt",
        "C:\\Users\\Mahyar\\Desktop\\CNN OutPut\\conv64\\input\\outputdata04.txt",
        "C:\\Users\\Mahyar\\Desktop\\CNN OutPut\\conv64\\input\\outputdata05.txt",
        "C:\\Users\\Mahyar\\Desktop\\CNN OutPut\\conv64\\input\\outputdata06.txt",
        "C:\\Users\\Mahyar\\Desktop\\CNN OutPut\\conv64\\input\\outputdata07.txt",
        "C:\\Users\\Mahyar\\Desktop\\CNN OutPut\\conv64\\input\\outputdata08.txt",
        "C:\\Users\\Mahyar\\Desktop\\CNN OutPut\\conv64\\input\\outputdata09.txt",
        "C:\\Users\\Mahyar\\Desktop\\CNN OutPut\\conv64\\input\\outputdata10.txt",
        "C:\\Users\\Mahyar\\Desktop\\CNN OutPut\\conv64\\input\\outputdata11.txt",
        "C:\\Users\\Mahyar\\Desktop\\CNN OutPut\\conv64\\input\\outputdata12.txt",
        "C:\\Users\\Mahyar\\Desktop\\CNN OutPut\\conv64\\input\\outputdata13.txt",
        "C:\\Users\\Mahyar\\Desktop\\CNN OutPut\\conv64\\input\\outputdata14.txt",
        "C:\\Users\\Mahyar\\Desktop\\CNN OutPut\\conv64\\input\\outputdata15.txt",
        "C:\\Users\\Mahyar\\Desktop\\CNN OutPut\\conv64\\input\\outputdata16.txt",
        "C:\\Users\\Mahyar\\Desktop\\CNN OutPut\\conv64\\input\\outputdata17.txt",
        "C:\\Users\\Mahyar\\Desktop\\CNN OutPut\\conv64\\input\\outputdata18.txt",
        "C:\\Users\\Mahyar\\Desktop\\CNN OutPut\\conv64\\input\\outputdata19.txt",
        "C:\\Users\\Mahyar\\Desktop\\CNN OutPut\\conv64\\input\\outputdata20.txt",
        "C:\\Users\\Mahyar\\Desktop\\CNN OutPut\\conv64\\input\\outputdata21.txt",
        "C:\\Users\\Mahyar\\Desktop\\CNN OutPut\\conv64\\input\\outputdata22.txt",
        "C:\\Users\\Mahyar\\Desktop\\CNN OutPut\\conv64\\input\\outputdata23.txt",
        "C:\\Users\\Mahyar\\Desktop\\CNN OutPut\\conv64\\input\\outputdata24.txt",
        "C:\\Users\\Mahyar\\Desktop\\CNN OutPut\\conv64\\input\\outputdata25.txt",
        "C:\\Users\\Mahyar\\Desktop\\CNN OutPut\\conv64\\input\\outputdata26.txt",
        "C:\\Users\\Mahyar\\Desktop\\CNN OutPut\\conv64\\input\\outputdata27.txt",
        "C:\\Users\\Mahyar\\Desktop\\CNN OutPut\\conv64\\input\\outputdata28.txt",
        "C:\\Users\\Mahyar\\Desktop\\CNN OutPut\\conv64\\input\\outputdata29.txt",
        "C:\\Users\\Mahyar\\Desktop\\CNN OutPut\\conv64\\input\\outputdata30.txt",
        "C:\\Users\\Mahyar\\Desktop\\CNN OutPut\\conv64\\input\\outputdata31.txt",
        "C:\\Users\\Mahyar\\Desktop\\CNN OutPut\\conv64\\input\\outputdata32.txt"
    );

    -- Current selected file path (based on data_address_signal)
    signal current_file        : string(1 to 71);

    -- File selection index (0..31)
    signal data_address_signal : integer := 0;

    -- Per-file line counter: counts how many lines have been output from current file
    -- For your use-case: 676 lines per file
    signal counter676          : integer := 1;

    -- Flags and outputs
    signal data_over_signal    : std_logic;
    signal Dataout_signal      : std_logic_vector(24 downto 0);

    -- TextIO file handle
    file fptr : text;

begin

    -- Select current file from filename table
    current_file <= filenames(data_address_signal);

    -- IMPORTANT:
    -- The following file_open is a concurrent statement in your original code.
    -- That means it can execute repeatedly and is generally unsafe.
    -- Kept as-is here to preserve your behavior, but recommended to move it
    -- into a clocked process triggered by reset / next_address.
    file_open(fptr, current_file, read_mode);

    -- Drive outputs
    data_over <= data_over_signal;
    Dataout   <= Dataout_signal;

    -- ------------------------------------------------------------------------
    -- address_Controller:
    -- Controls which file index is active (0..31).
    -- - On reset: selects file 0 and clears file_over.
    -- - When next_address='1': increments file index (moves to next file).
    -- - When last file (31) reaches last line (676): asserts file_over.
    -- ------------------------------------------------------------------------
    address_Controller : process (clk, reset, counter676, data_address_signal, data_over_signal)
    begin
        if reset = '1' then
            data_address_signal <= 0;
            file_over <= '0';

        elsif rising_edge(clk) then
            if data_address_signal = 31 then
                -- Last file selected: when last line is reached, whole set is done
                if counter676 = 676 then
                    file_over <= '1';
                end if;

            elsif next_address = '1' then
                -- Move to next file when requested by top level
                data_address_signal <= data_address_signal + 1;
                file_over <= '0';
            end if;
        end if;
    end process;

    -- ------------------------------------------------------------------------
    -- sending_Data:
    -- Reads one line from the currently opened file when send_data='1'.
    -- Stops providing valid output after 676 reads (per file).
    -- ------------------------------------------------------------------------
    sending_Data : process (clk, send_data, reset, counter676)
        variable line_buffer : line;
        variable pixel_data  : string(25 downto 1); -- One 25-bit value encoded as string
    begin
        if reset = '0' then
            if rising_edge(clk) then
                if send_data = '1' then

                    -- If the file already produced 676 samples, stop outputting valid data
                    if counter676 = 676 then
                        Dataout_signal <= (others => 'U');
                    else
                        -- Read next line and convert to vector
                        readline(fptr, line_buffer);
                        read(line_buffer, pixel_data);
                        Dataout_signal <= Convert_String_to_Vector(pixel_data);
                    end if;

                else
                    -- No request: output invalid (or hold last value if preferred)
                    Dataout_signal <= (others => 'U');
                end if;
            end if;
        end if; -- reset
    end process;

    -- ------------------------------------------------------------------------
    -- data_over generator:
    -- data_over='1' when current file finished (counter676 reached 676)
    -- data_over returns to '0' when next_address is asserted or reset is active.
    -- ------------------------------------------------------------------------
    process (clk, counter676, next_address, reset)
    begin
        if reset = '1' then
            data_over_signal <= '0';
        else
            if next_address = '1' then
                data_over_signal <= '0';
            else
                if counter676 = 676 then
                    data_over_signal <= '1';
                else
                    data_over_signal <= '0';
                end if;
            end if;
        end if;
    end process;

    -- ------------------------------------------------------------------------
    -- counter676 controller:
    -- - On reset: initialize counter
    -- - On next_address: restart per-file counter for next file
    -- - Otherwise: increment when Dataout_signal looks valid (not 'U')
    -- ------------------------------------------------------------------------
    process (reset, Dataout_signal, clk, next_address)
    begin
        if reset = '1' then
            counter676 <= 1;

        elsif rising_edge(clk) then
            if next_address = '1' then
                counter676 <= 1;

            -- If output is valid (your convention: LSB not 'U'), count this sample
            elsif Dataout_signal(1) /= 'U' then
                if counter676 < 676 then
                    counter676 <= counter676 + 1;
                end if;
            end if;
        end if;
    end process;

end Behavioral;