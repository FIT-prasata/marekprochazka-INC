-- Author: Marek Prochazka (xproch0o, https://github.com/marekprochazka)

library ieee;
use ieee.std_logic_1164.all;

entity UART_FSM is 
port (
    CLK             : in std_logic;
    RST             : in std_logic;
    DIN             : in std_logic;
    READ_FINISHED   : in std_logic;
    CLK_CNT         : in std_logic_vector(4 downto 0);
    READ_ENABLE     : out std_logic;
    VALID           : out std_logic;
    CLK_RST         : out std_logic
);
end entity UART_FSM;


architecture behavioral of UART_FSM is
-- enumerated type for states
type mealy_state_type is (IDLE_STATE, WAIT_READ_STATE, READ_STATE, WAIT_END_STATE);

-- register to hold current state
signal state_sig: mealy_state_type;

begin

    process(CLK, RST) begin
       if RST = '1' then
          state_sig <= IDLE_STATE;
        elsif (rising_edge(clk)) then
        -- Synchronous determination of the next state 
        -- based on the current state and inputs
            case state_sig is
                when IDLE_STATE =>
                    if DIN = '0' then
                        state_sig <= WAIT_READ_STATE;
                    else 
                        state_sig <= IDLE_STATE;
                    end if;
                when WAIT_READ_STATE =>
                    if CLK_CNT = "10000" then
                        state_sig <= READ_STATE;
                    else 
                        state_sig <= WAIT_READ_STATE;
                    end if;
                when READ_STATE =>
                    if READ_FINISHED = '1' then
                        state_sig <= WAIT_END_STATE;
                    else 
                        state_sig <= READ_STATE;
                    end if;
                when WAIT_END_STATE =>
                    if CLK_CNT = "10000" then
                        state_sig <= IDLE_STATE;
                    else 
                        state_sig <= WAIT_END_STATE;
                    end if;
            end case;
        end if;
    end process;

    -- Set output based on current state and inputs
    -- waiting for edge is not necessary

    process(state_sig, DIN, READ_FINISHED, CLK_CNT) begin
        case state_sig is
            when IDLE_STATE => 
                if DIN = '1' then
                    READ_ENABLE <= '0';
                    VALID <= '0';
                    CLK_RST <= '0';
                else
                    READ_ENABLE <= '0';
                    VALID <= '0';
                    CLK_RST <= '1';
                end if;
            when WAIT_READ_STATE =>
                if CLK_CNT = "10000" then
                    READ_ENABLE <= '0';
                    VALID <= '0';
                    CLK_RST <= '1';
                else
                    READ_ENABLE <= '0';
                    VALID <= '0';
                    CLK_RST <= '0';
                end if;
            when READ_STATE =>
                if READ_FINISHED = '1' then
                    READ_ENABLE <= '0';
                    VALID <= '0';
                    CLK_RST <= '1';
                else    
                    if CLK_CNT = "01000" then
                        READ_ENABLE <= '1';
                        VALID <= '0';
                        CLK_RST <= '0';
                    elsif CLK_CNT = "10000" then
                        READ_ENABLE <= '0';
                        VALID <= '0';
                        CLK_RST <= '1';
                    else
                        READ_ENABLE <= '0';
                        VALID <= '0';
                        CLK_RST <= '0';
                    end if;
                end if;
            when WAIT_END_STATE =>
                if CLK_CNT = "10000" then
                    READ_ENABLE <= '0';
                    VALID <= '1';
                    CLK_RST <= '0';
                else
                    READ_ENABLE <= '0';
                    VALID <= '0';
                    CLK_RST <= '0';
                end if;
        end case;
    end process;
end behavioral;
