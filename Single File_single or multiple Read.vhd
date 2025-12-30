library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library STD;
use STD.TEXTIO.ALL;

use work.String_to_Vector.all;

-- ============================================================================
-- Entity: Conv32File_read
-- ----------------------------------------------------------------------------
-- Purpose:
--   Reads pixel data from a text file using TextIO and outputs it on Dataout.
--
-- Behavior:
--   1) When reset='1': the file is opened (or re-opened) and data_over is cleared.
--   2) On each rising edge of clk, if send_data='1':
--        - If not EOF: reads one line, converts it to std_logic_vector(7 downto 0),
--          drives Dataout, and keeps data_over='0'.
--        - If EOF: sets data_over='1' and drives Dataout to 'U' (invalid).
--
-- Note:
--   Because the file is opened on reset, reset can also be used as a control signal
--   to restart reading from the beginning of the file.
-- ============================================================================
entity Conv32File_read is
    port(
        clk       : in  std_logic;
        reset     : in  std_logic;
        send_data : in  std_logic;
        data_over : out std_logic;
        Dataout   : out std_logic_vector(7 downto 0)
    );
end Conv32File_read;

architecture Behavioral of Conv32File_read is

    -- TextIO file handle
    file fptr : text;

begin

    -- Note:
    --   Actual file reading occurs only on rising_edge(clk).
    --   reset is checked synchronously inside the clocked block.
    process (clk, send_data, reset)
        -- Buffer holding one complete line read from the file
        variable line_buffer : line;

        -- String read from each line (8 characters).
        -- Assumption: each line contains an 8-bit value encoded as a string
        -- (e.g., "01010101"). Adjust if your file format is different.
        variable pixel_data  : string(8 downto 1);
    begin

        if rising_edge(clk) then

            -- ------------------------------------------------------------
            -- RESET: open/re-open the file and prepare for reading from start
            -- ------------------------------------------------------------
            if (reset = '1') then
                -- Update this path to match your system
                file_open(
                    fptr,
                    "C:\\Users\\Mahyar\\Desktop\\project\\Test\\Conv32\\image test2.txt",
                    read_mode
                );

                -- Not at end-of-file after reset
                data_over <= '0';

                -- Optional: initialize output on reset
                -- Dataout <= (others => '0');

            else
                -- --------------------------------------------------------
                -- Normal operation:
                --   Read one sample only when send_data='1'
                -- --------------------------------------------------------
                if (send_data = '1') then

                    -- If there is still data to read
                    if (not endfile(fptr)) then
                        -- Read one line from the file into line_buffer
                        readline(fptr, line_buffer);

                        -- Parse the line into an 8-char string
                        read(line_buffer, pixel_data);

                        -- Convert the string to an 8-bit std_logic_vector
                        Dataout <= Convert_String_to_Vector(pixel_data);

                        -- Still reading, not EOF
                        data_over <= '0';

                    else
                        -- ------------------------------------------------
                        -- EOF reached: signal completion and output invalid
                        -- ------------------------------------------------
                        data_over <= '1';
                        Dataout <= (others => 'U');
                    end if;

                else
                    -- ----------------------------------------------------
                    -- send_data='0': no read is performed this cycle.
                    -- Keep output invalid (or keep last value if preferred).
                    -- ----------------------------------------------------
                    Dataout <= (others => 'U');
                end if;

            end if; -- reset

        end if; -- rising_edge(clk)

    end process;

end Behavioral;
