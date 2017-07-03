library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Entity
entity mini_avr_01 is
port (clk : in std_logic;
    reset : in std_logic; -- Let's have some registers as outputs:
    port_A0   : in std_logic_vector(7 downto 0);
    port_A1   : in std_logic_vector(7 downto 0);
    port_A8i   : out std_logic_vector(7 downto 0);
    port_A9i   : out std_logic_vector(7 downto 0);
    pr_16, pr_17, pr_18, pr_19  : out std_logic_vector(7 downto 0));
end mini_avr_01;

-- Architecture
architecture behav of mini_avr_01 is
    -- Types and signals
    type register_bank is array(15 downto 0) of std_logic_vector(7 downto 0); -- Un array de vectors forma el registre
    signal regs : register_bank; -- Registers r16 .. r31


    type status_reg is
        record
            Z : std_logic;
            C : std_logic;
        end record;
    signal  pr_SR,
            nx_SR : status_reg;

    type out_mux_type is (mux_alu , mux_lit, mux_in_out); -- El mux que surt de la unitat de control, que pot triar entre si la dada ve del ALU o de la ordre Load Immediate
    signal out_mux : out_mux_type;

    -- Signals alone
    signal add_temp : std_logic_vector(9 downto 0);
    signal reg_we : std_logic;
    signal pr_op : std_logic_vector(15 downto 0);
    signal r_reg : std_logic_vector(3 downto 0);
    signal d_reg : std_logic_vector(3 downto 0);
    signal k, in_data : std_logic_vector(7 downto 0);
    signal ALU_op : std_logic_vector(2 downto 0);
    signal k_jmp : std_logic_vector(7 downto 0);
    signal update_Z : std_logic;
    signal alu_in_b, alu_in_a, alu_out : std_logic_vector(7 downto 0);
    signal debug_zero, debug_carry : std_logic;
    signal nx_reg : std_logic_vector(7 downto 0);
    signal pr_pc : std_logic_vector(7 downto 0);
    signal nx_pc : std_logic_vector(7 downto 0);
    signal port_we, presc_tc : std_logic;
    signal port_adr : std_logic_vector(3 downto 0);
    signal synchA0, synchA1, presynchA0, presynchA1, timer_limit : std_logic_vector(7 downto 0);
    signal timer_state, timer_count, presc_count, presc_count_limit : std_logic_vector(7 downto 0);
    signal c_r16 : std_logic_vector(3 downto 0) := "0000";
    signal c_r17 : std_logic_vector(3 downto 0) := "0001";
    signal c_r18 : std_logic_vector(3 downto 0) := "0000";
    signal c_r19 : std_logic_vector(3 downto 0) := "0001";


    -- Constants
    -- OPCODES
    constant NOP : std_logic_vector(3 downto 0) := "0000";
    constant LDI : std_logic_vector(3 downto 0) := "1110";
    constant ADC : std_logic_vector(3 downto 0) := "0001";
    constant MOV : std_logic_vector(3 downto 0) := "0010";
    constant BRANCH : std_logic_vector(3 downto 0) := "1111";
    constant RJMP : std_logic_vector(3 downto 0) := "1100";
    constant BREQ : std_logic_vector(3 downto 0) := "1111";

    constant ALU_B : std_logic_vector (3 downto 0) := "0010";
    constant ALU_B_AND : std_logic_vector (1 downto 0) := "00";
    constant ALU_B_EOR : std_logic_vector (1 downto 0) := "01";
    constant ALU_B_OR : std_logic_vector (1 downto 0) := "10";
    constant ALU_B_MOV : std_logic_vector (1 downto 0) := "11";
    constant IN_OUT : std_logic_vector( 3 downto 0 ) := "1011";

    -- Ordres al ALU
    constant ALU_ADC : std_logic_vector(2 downto 0) := "001";
    constant ALU_MOV : std_logic_vector(2 downto 0) := "010";
    constant ALU_EOR : std_logic_vector(2 downto 0) := "011";
    constant ALU_OR : std_logic_vector(2 downto 0) := "100";
    constant ALU_AND : std_logic_vector(2 downto 0) := "101";

    -- Process
    begin
    process(clk) -- Register write
        begin
            if rising_edge(clk) then
                if reg_we = '1' then -- Només escriu si el senyal reg_we està actiu
                    regs(to_integer(unsigned (d_reg))) <= nx_reg; -- Escriu nx_reg a la posició d_reg del array
                end if;
            end if;
    end process;



    ROM : process (pr_pc) -- Program ROM
    begin
        case pr_pc is
            when X"00" => pr_op <= LDI & "0100" & c_r16 & "1000" ; -- DO 4
            when X"01" => pr_op <= LDI & "0100" & c_r17 & "0011" ; -- SOL 3
            when X"02" => pr_op <= LDI & "0100" & c_r18 & "0000" ; -- MI 3
            when X"03" => pr_op <= LDI & "0011" & c_r19 & "0000" ; -- DO 2

            when X"04" => pr_op <= LDI & "0100" & c_r16 & "0101" ; -- SI 3
            when X"05" => pr_op <= LDI & "0100" & c_r17 & "0011" ; -- SOL 3
            when X"06" => pr_op <= LDI & "0011" & c_r18 & "1110" ; -- RE 3
            when X"07" => pr_op <= LDI & "0011" & c_r19 & "0111" ; -- SOL 2

            when X"08" => pr_op <= LDI & "0100" & c_r16 & "0101" ; -- LA 3
            when X"09" => pr_op <= LDI & "0100" & c_r17 & "0000" ; -- MI 3
            when X"0A" => pr_op <= LDI & "0011" & c_r18 & "1100" ; -- DO 3
            when X"0B" => pr_op <= LDI & "0011" & c_r19 & "1001" ; -- LA 2
            when X"0C" => pr_op <= RJMP & "----" & "1100" & "0000";
            when others => pr_op <= ( others => '-' );
        end case ;
    end process ;


    CONTROL : process(pr_op, pr_pc, pr_SR)
        begin

            r_reg   <= pr_op(3 downto 0); -- Per defecte:  posició r_reg: La indicada per l'OPCODE
            d_reg   <= pr_op(7 downto 4); --               posició d_reg: la indicada per l'OPCODE
            k       <= (others => '-'); --                 k del LDI:     0000 0000
            ALU_op  <= ( others => '-'); --                operació per ALU: 000
            reg_we  <= '0'; --                             es permet l'escriptura al registre: No
            out_mux <= mux_alu; --                         les dades vénen del alu
            k_jmp <= (others => '0'); --                   no hi ha k_jmp

            case pr_op (15 downto 12) is -- Llegeix els 4 primers bits, que porten la ordre
                when NOP => -- NOP Instruction
                    null; -- No fa res

                when LDI => -- LDI Instruction
                    out_mux <= mux_lit; -- El mux es prepara per rebre del LDI
                    k <= pr_op(11 downto 8) & pr_op(3 downto 0); -- Concatena la k
                    reg_we <= '1'; -- El registre escriu

                when ALU_B => -- - - - - - - - - - - MOV , AND , EOR , OR Instructions
                    reg_we <= '1'; -- Enable register write
                        case pr_op (11 downto 10) is -- Decode further down
                            when ALU_B_MOV => ALU_op <= ALU_MOV;
                            when ALU_B_EOR => ALU_op <= ALU_EOR;
                            when ALU_B_AND => ALU_op <= ALU_AND;
                            when ALU_B_OR => ALU_op <= ALU_OR;
                            when others => null ;
                        end case;

                when ADC => -- ADC Instruction
                    reg_we <= '1'; -- El registre es prepara per escriure
                    ALU_op <= ALU_ADC; -- L'ALU rep la ordre ADC

                when BRANCH => -- BRANCH Instruction
                    if pr_op(10) = '0' then -- BREQ Instruction
                        if pr_SR.Z = '1' then -- Si el Z està actiu
                            k_jmp(6 downto 0) <= pr_op (9 downto 3); -- Posa k_jmp al valor indicat per l'OPCODE
                            k_jmp(7) <= pr_op(9);
                        end if;
                    else -- BRNE Instruction
                        if pr_SR.Z = '0' then -- Si el Z no està actiu
                            k_jmp(6 downto 0) <= pr_op (9 downto 3); -- Posa k_jmp al valor indicat per l'OPCODE
                            k_jmp(7) <= pr_op(9);
                        end if;
                    end if;

                when RJMP => -- RJMP
                    k_jmp(7 downto 0) <= pr_op (7 downto 0); -- Posa k_jmp al valor indicat per l'OPCODE

                when IN_OUT =>
                    if pr_op(11)= '1' then -- OUT
                        port_we <= '1';
                        port_adr <= pr_op(3 downto 0);
                        r_reg <= pr_op(7 downto 4);

                    else -- IN
                        out_mux <= mux_in_out; -- Prepara el mux per rebre de fora
                        d_reg <= pr_op(7 downto 4); -- Registre destí
                        reg_we <= '1'; -- Permet l'escriptura
                        case pr_op (1 downto 0) is -- Decode IN address
                            when "00" => in_data <= synchA0;
                            when "01" => in_data <= synchA1 ;
                            when "10" => in_data <= timer_state ;
                            when others => null ;
                        end case ;
                    end if;

                when others =>
                    null;
            end case;
    end process;


    ALU : process(ALU_op, alu_in_a, alu_in_b, pr_SR.C, add_temp)
        begin
            nx_SR.C <= pr_SR.C; -- by default , preserve
            update_Z <= '1'; -- Most operations update Z

            case ALU_op is
                when ALU_MOV => -- MOV
                    alu_out <= alu_in_b;
                    update_Z <= '0';

                when ALU_AND => -- AND
                    alu_out <= alu_in_a and alu_in_b;

                when ALU_OR => -- OR
                alu_out <= alu_in_a or alu_in_b;

                when ALU_EOR => -- EOR / XOR
                alu_out <= alu_in_a xor alu_in_b;

                when ALU_ADC => -- - - - - - - - - - - - - - - - ADC : Already known
                    add_temp <= std_logic_vector(unsigned('0' & alu_in_a & '1') + unsigned ('0' & alu_in_b & pr_SR.C )); -- Suma amb carry
                    alu_out <= add_temp(8 downto 1); -- elimina el '0' i el Carry, i passa el resultat a alu_out
                    nx_SR.C <= add_temp(9); -- Agafa el Carry

                    if add_temp(8 downto 1) = x"00" then -- Si el resultat en alu_out és 0
                        nx_SR.Z <= '1'; -- Activa el Zero Flag
                    else
                        nx_SR.Z <= '0'; -- Sinó el desactiva
                    end if;
                when others => -- Should never happen
                alu_out <= ( others => '-'); -- Don't care
            end case;
    end process;

    UPD_z : process(update_Z, alu_out, pr_SR)
        begin
            if update_Z = '1' then -- Update Zero Flag
                if alu_out = x"00" then
                    nx_SR.Z <= '1';
                else
                    nx_SR.Z <= '0';
                end if;
            else -- - - - - - - - - Keep old value
                nx_SR.Z <= pr_SR.Z;
            end if;
        end process ;


    MUX : process(out_mux, alu_out, k, in_data)
        begin
            case out_mux is
                when mux_alu => nx_reg <= alu_out;
                when mux_lit => nx_reg <= k;
                when mux_in_out => nx_reg <= in_data;
                when others => nx_reg <=(others => '-');
            end case;
    end process;

    PortW : process ( clk )
        begin
            if rising_edge ( clk ) then
                if port_we = '1' then
                    case port_adr is
                        when "1000" =>
                            port_A8i <= regs(to_integer(unsigned(r_reg)));
                        when "1001" =>
                            port_A9i <= regs(to_integer(unsigned(r_reg)));
                        when "1010" =>
                            timer_limit <= regs(to_integer(unsigned(r_reg)));
                        when others => null ;
                    end case ;
                end if;
            end if;
    end process PortW ;

    process (clk, reset) -- Synchronous elements
        begin
            if reset = '1' then -- Si es fa un reset
                pr_pc <= (others => '0'); -- pròxim programa: el primer
                pr_SR.C <= '0'; -- no hi ha Carry
                pr_SR.Z <= '0'; -- no hi ha Zero
            elsif (rising_edge(clk)) then -- A cada clk
                pr_pc <= nx_pc; -- El pròxim programa és nx_pc
                pr_SR <= nx_SR; -- El pròxim flag és l'acutal
                -- synchronizer for inputs ports
                presynchA0 <= port_A0;
                synchA0 <= presynchA0;
                presynchA1 <= port_A1;
                synchA1 <= presynchA1;
            end if;
    end process ;

    NEXT_PC : process (pr_pc, k_jmp)
        variable tmp_pc : std_logic_vector(8 downto 0);
        begin
            tmp_pc := std_logic_vector(signed(pr_pc & '1') + signed(k_jmp & '1')); -- El pròxim programa serà l'actual +1 + k si n'hi ha
            nx_pc <= tmp_pc (8 downto 1);
        end process;

    process (clk)
        begin
            if rising_edge(clk) then
                if port_we = '1' and port_adr ="1010" then -- reset counter
                timer_count <= (others => '0'); -- when writing
                presc_count <= (others => '0'); -- new timer_limit
                else
                    if timer_state /= x"00" and presc_tc = '1' then
                        timer_count <= std_logic_vector(unsigned(timer_count)+1);
                    end if;
                    if presc_tc = '1' then
                        presc_count <= (others => '0');
                    else
                        presc_count <= std_logic_vector(unsigned(presc_count)+1);
                    end if;
                end if;
            end if;
    end process ;

    timer_state <= x"00" when timer_count = timer_limit
        else x"01" ; -- 1: counting 0: finished
    presc_tc <= '1' when presc_count = presc_count_limit -- constant
        else '0';


    -- Concurrent
    -- Register read : ALU inputs
    alu_in_a <= regs(to_integer(unsigned(d_reg))); -- La dada que ocupi la posició d_reg del registre va al alu
    alu_in_b <= regs(to_integer(unsigned(r_reg))); -- La dada que ocupi la posició r_reg del registre va al alu

    -- Senyals auxiliars per Debug
    debug_carry <= pr_SR.C;
    debug_zero <= pr_SR.Z;
    pr_16 <= regs(0);
    pr_17 <= regs(1);
    pr_18 <= regs(2);
    pr_19 <= regs(3);
end behav;
mom
