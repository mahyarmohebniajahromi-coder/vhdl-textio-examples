library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library STD;
use STD.TEXTIO.ALL;

-- ============================================================================
-- Entity: Conv32Writeout
-- ----------------------------------------------------------------------------
-- Purpose:
--   Writes the output feature-map data into **separate text files**.
--   File selection is controlled by 'write_address' (0..31), so each channel
--   can be written into its own file (outputdata01.txt ... outputdata32.txt).
--
-- Inputs:
--   clk:
--     Clock for writing data (one line per clock when data is valid).
--
--   reset:
--     Re-opens the current output file in write_mode (overwrite).
--
--   end_file:
--     When asserted, closes the currently opened output file.
--     (Used as a "stop writing / finalize file" signal.)
--
--   write_address:
--     Selects which output file to write (0..31).
--
--   data_out (25-bit):
--     Data to be written. If data_out contains 'U' (invalid), it will not be written.
--
-- Notes / Cautions:
--   1) In this baseline version, file_open is also called as a concurrent statement.
--      This may cause repeated open operations depending on simulator behavior.
--      (It works for your current setup, but should be refactored later.)
--   2) reset currently overwrites the file (write_mode). If you want append behavior,
--      you would use append_mode instead.
-- ============================================================================
entity Conv32Writeout is
    Port (
        clk          : in  STD_LOGIC;
        reset        : in  std_logic;
        end_file     : in  std_logic;
        write_address: in  Integer;
        data_out     : in  STD_LOGIC_VECTOR(24 downto 0)
    );
end Conv32Writeout;

architecture Behavioral of Conv32Writeout is

    -- Convert std_logic_vector to bit_vector for TextIO write()
    signal data_write : bit_vector(24 downto 0);

    -- TextIO file handle for writing output data
    file output_file : text;

    -- List of output filenames (32 channels)
    type file_array is array (0 to 31) of string(1 to 64);
    constant filenames : file_array := (
        "C:\\Users\\Mahyar\\Desktop\\CNN OutPut\\Conv32\\outputdata01.txt",
        "C:\\Users\\Mahyar\\Desktop\\CNN OutPut\\Conv32\\outputdata02.txt",
        "C:\\Users\\Mahyar\\Desktop\\CNN OutPut\\Conv32\\outputdata03.txt",
        "C:\\Users\\Mahyar\\Desktop\\CNN OutPut\\Conv32\\outputdata04.txt",
        "C:\\Users\\Mahyar\\Desktop\\CNN OutPut\\Conv32\\outputdata05.txt",
        "C:\\Users\\Mahyar\\Desktop\\CNN OutPut\\Conv32\\outputdata06.txt",
        "C:\\Users\\Mahyar\\Desktop\\CNN OutPut\\Conv32\\outputdata07.txt",
        "C:\\Users\\Mahyar\\Desktop\\CNN OutPut\\Conv32\\outputdata08.txt",
        "C:\\Users\\Mahyar\\Desktop\\CNN OutPut\\Conv32\\outputdata09.txt",
        "C:\\Users\\Mahyar\\Desktop\\CNN OutPut\\Conv32\\outputdata10.txt",
        "C:\\Users\\Mahyar\\Desktop\\CNN OutPut\\Conv32\\outputdata11.txt",
        "C:\\Users\\Mahyar\\Desktop\\CNN OutPut\\Conv32\\outputdata12.txt",
        "C:\\Users\\Mahyar\\Desktop\\CNN OutPut\\Conv32\\outputdata13.txt",
        "C:\\Users\\Mahyar\\Desktop\\CNN OutPut\\Conv32\\outputdata14.txt",
        "C:\\Users\\Mahyar\\Desktop\\CNN OutPut\\Conv32\\outputdata15.txt",
        "C:\\Users\\Mahyar\\Desktop\\CNN OutPut\\Conv32\\outputdata16.txt",
        "C:\\Users\\Mahyar\\Desktop\\CNN OutPut\\Conv32\\outputdata17.txt",
        "C:\\Users\\Mahyar\\Desktop\\CNN OutPut\\Conv32\\outputdata18.txt",
        "C:\\Users\\Mahyar\\Desktop\\CNN OutPut\\Conv32\\outputdata19.txt",
        "C:\\Users\\Mahyar\\Desktop\\CNN OutPut\\Conv32\\outputdata20.txt",
        "C:\\Users\\Mahyar\\Desktop\\CNN OutPut\\Conv32\\outputdata21.txt",
        "C:\\Users\\Mahyar\\Desktop\\CNN OutPut\\Conv32\\outputdata22.txt",
        "C:\\Users\\Mahyar\\Desktop\\CNN OutPut\\Conv32\\outputdata23.txt",
        "C:\\Users\\Mahyar\\Desktop\\CNN OutPut\\Conv32\\outputdata24.txt",
        "C:\\Users\\Mahyar\\Desktop\\CNN OutPut\\Conv32\\outputdata25.txt",
        "C:\\Users\\Mahyar\\Desktop\\CNN OutPut\\Conv32\\outputdata26.txt",
        "C:\\Users\\Mahyar\\Desktop\\CNN OutPut\\Conv32\\outputdata27.txt",
        "C:\\Users\\Mahyar\\Desktop\\CNN OutPut\\Conv32\\outputdata28.txt",
        "C:\\Users\\Mahyar\\Desktop\\CNN OutPut\\Conv32\\outputdata29.txt",
        "C:\\Users\\Mahyar\\Desktop\\CNN OutPut\\Conv32\\outputdata30.txt",
        "C:\\Users\\Mahyar\\Desktop\\CNN OutPut\\Conv32\\outputdata31.txt",
        "C:\\Users\\Mahyar\\Desktop\\CNN OutPut\\Conv32\\outputdata32.txt"
    );

    -- Local copy of selected file index (0..31)
    signal write_add : integer := 0;

begin

    -- Convert incoming data to bit_vector (TextIO write() works nicely with bit_vector)
    data_write <= to_bitvector(data_out);

    -- Capture file selection address
    write_add <= write_address;

    -- Baseline behavior: open selected file in write_mode (overwrite)
    file_open(output_file, filenames(write_add), write_mode);

    -- ------------------------------------------------------------------------
    -- Writing_process:
    --   - On reset: (re)open file in write_mode.
    --   - If end_file='1': close the file.
    --   - Otherwise: on each rising edge, if data_out looks valid (not 'U'),
    --     write one line into the selected output file.
    -- ------------------------------------------------------------------------
    Writing_process : process (clk, end_file)
        variable line : line;
    begin
        if reset = '1' then
            -- Re-open file (overwrite) when reset is asserted
            file_open(output_file, filenames(write_add), write_mode);

        else
            if end_file = '1' then
                -- Finalize file: close it when the top level indicates "done"
                file_close(output_file);

            else
                if rising_edge(clk) then
                    -- Write only when data is valid (your convention: bit 1 is not 'U')
                    if (data_out(1) /= 'U') then
                        write(line, data_write);
                        writeline(output_file, line);
                    end if;
                end if;
            end if;
        end if;

    end process;

end Behavioral;
