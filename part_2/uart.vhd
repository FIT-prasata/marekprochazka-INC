-- uart.vhd: UART controller - receiving part
-- Author(s): Marek Prochazka
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-------------------------------------------------
entity UART_RX is
port(	
    CLK: 	    in std_logic;
	RST: 	    in std_logic;
	DIN: 	    in std_logic;
	DOUT: 	    out std_logic_vector(7 downto 0);
	DOUT_VLD: 	out std_logic
);
end UART_RX;  

-------------------------------------------------
architecture behavioral of UART_RX is
-- fsm inputs
signal clk_cnt          : std_logic_vector(4 downto 0):= "00000";
signal read_finihed     : std_logic := '0';

-- fsm outputs
signal data_valid       : std_logic := '0';
signal read_enable      : std_logic := '0';
signal clk_cnt_reset    : std_logic := '0';

-- another signals 
signal bit_count        : std_logic_vector(3 downto 0):= "0000";
begin 

FSM: entity work.UART_FSM(behavioral) 
    port map (
        CLK => CLK,
        RST => RST,
        DIN => DIN,
        READ_FINISHED => read_finihed,
        CLK_CNT => clk_cnt,
        READ_ENABLE => read_enable,
        VALID => data_valid,
        CLK_RST => clk_cnt_reset
    );

    process(CLK) begin 
        if rising_edge(CLK) then
            -- set default valid output to 0
            DOUT_VLD <= data_valid;
			

            -- increase counter
            if clk_cnt_reset = '1' then
                clk_cnt <= "00000";
            else 
                clk_cnt <= clk_cnt + '1';
            end if;

            -- bit counter 
            if read_enable = '1' then 
                bit_count <= bit_count + '1';
            end if;

            -- read finished comparator
            if bit_count = "1000" then
                read_finihed <= '1';
            else 
                read_finihed <= '0';
            end if;

            if data_valid = '1' then 
                DOUT_VLD <= '1';
				bit_count <= "0000";
            end if;

            -- reading data
            if read_enable = '1' then 
                case bit_count is 
                    when "0000" => DOUT(0) <= DIN;
                    when "0001" => DOUT(1) <= DIN;
                    when "0010" => DOUT(2) <= DIN;
                    when "0011" => DOUT(3) <= DIN;
                    when "0100" => DOUT(4) <= DIN;
                    when "0101" => DOUT(5) <= DIN;
                    when "0110" => DOUT(6) <= DIN;
                    when "0111" => DOUT(7) <= DIN;
                    when others => null;
                end case;
            end if;
            end if;
    end process;

end behavioral;
