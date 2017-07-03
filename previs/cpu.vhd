-- PREVI 3: Acabeu això, que és copiar i enganxar fent algun petit canvi, i ho fiqueu a la ROM del Mini-AVR. La Gemma ho sap fer :) Canvieu les x per al codi de nota que trieu.

when X"00" => pr_op <= LDI & "0100" & c_r16 & "1000" ; -- DO 4
when X"01" => pr_op <= LDI & "0100" & c_r17 & "0011" ; -- SOL 3
when X"02" => pr_op <= LDI & "0100" & c_r18 & "0000" ; -- MI 3
when X"03" => pr_op <= LDI & "0011" & c_r19 & "0000" ; -- DO 2

when X"04" => pr_op <= LDI & "0100" & c_r16 & "1000" ; -- DO 4
when X"05" => pr_op <= LDI & "0100" & c_r17 & "0011" ; -- SOL 3
when X"06" => pr_op <= LDI & "0100" & c_r18 & "0000" ; -- MI 3
when X"07" => pr_op <= LDI & "0011" & c_r19 & "0000" ; -- DO 2

when X"08" => pr_op <= LDI & "0100" & c_r16 & "1000" ; -- DO 4
when X"09" => pr_op <= LDI & "0100" & c_r17 & "0011" ; -- SOL 3
when X"10" => pr_op <= LDI & "0100" & c_r18 & "0000" ; -- MI 3
when X"11" => pr_op <= LDI & "0011" & c_r19 & "0000" ; -- DO 2

when X"12" => pr_op <= LDI & "0100" & c_r16 & "0101" ; -- SI 3
when X"13" => pr_op <= LDI & "0100" & c_r17 & "0011" ; -- SOL 3
when X"14" => pr_op <= LDI & "0011" & c_r18 & "1110" ; -- RE 3
when X"15" => pr_op <= LDI & "0011" & c_r19 & "0111" ; -- SOL 2


when X"16" => pr_op <= LDI & "0100" & c_r16 & "0101" ; -- SI 3
when X"17" => pr_op <= LDI & "0100" & c_r17 & "0011" ; -- SOL 3
when X"18" => pr_op <= LDI & "0011" & c_r18 & "1110" ; -- RE 3
when X"19" => pr_op <= LDI & "0011" & c_r19 & "0111" ; -- SOL 2

when X"20" => pr_op <= LDI & "0100" & c_r16 & "0101" ; -- SI 3
when X"21" => pr_op <= LDI & "0100" & c_r17 & "0011" ; -- SOL 3
when X"22" => pr_op <= LDI & "0011" & c_r18 & "1110" ; -- RE 3
when X"23" => pr_op <= LDI & "0011" & c_r19 & "0111" ; -- SOL 2

when X"24" => pr_op <= LDI & "0100" & c_r16 & "0101" ; -- SI 3
when X"25" => pr_op <= LDI & "0100" & c_r17 & "0011" ; -- SOL 3
when X"26" => pr_op <= LDI & "0011" & c_r18 & "1110" ; -- RE 3
when X"27" => pr_op <= LDI & "0011" & c_r19 & "0111" ; -- SOL 2

when X"28" => pr_op <= LDI & "0100" & c_r16 & "0101" ; -- LA 3
when X"29" => pr_op <= LDI & "0100" & c_r17 & "0000" ; -- MI 3
when X"30" => pr_op <= LDI & "0011" & c_r18 & "1100" ; -- DO 3
when X"31" => pr_op <= LDI & "0011" & c_r19 & "1001" ; -- LA 2

when X"32" => pr_op <= LDI & "0100" & c_r16 & "0101" ; -- LA 3
when X"33" => pr_op <= LDI & "0100" & c_r17 & "0000" ; -- MI 3
when X"34" => pr_op <= LDI & "0011" & c_r18 & "1100" ; -- DO 3
when X"35" => pr_op <= LDI & "0011" & c_r19 & "1001" ; -- LA 2

when X"36" => pr_op <= LDI & "0100" & c_r16 & "0101" ; -- LA 3
when X"37" => pr_op <= LDI & "0100" & c_r17 & "0000" ; -- MI 3
when X"38" => pr_op <= LDI & "0011" & c_r18 & "1100" ; -- DO 3
when X"39" => pr_op <= LDI & "0011" & c_r19 & "1001" ; -- LA 2


when X"10" => pr_op <= LDI & "0100" & c_r16 & "0101" ; -- LA 3
when X"11" => pr_op <= LDI & "0100" & c_r17 & "0000" ; -- MI 3
when X"12" => pr_op <= LDI & "0011" & c_r18 & "1100" ; -- DO 3
when X"13" => pr_op <= LDI & "0011" & c_r19 & "1001" ; -- LA 2


-- Seguiu vosaltres... És anar copiant l'estructura per tota la partitura

when others => pr_op <= ( others => '-' );

-- PREVI 4: Amb un clk de 2,6 Hz simuleu-ho i mireu que tot vagi bé. Heu de mirar els outputs a r16, r17, r18 i r19.

-- PREVI 5: El feu vosaltres :P



        when X"00" => pr_op <= IN & "0100" & c_r16 & "1000" ;
        when X"08" => pr_op <= LDI & "0100" & c_r16 & "1000" ; -- DO 4
        when X"09" => pr_op <= LDI & "0100" & c_r17 & "0011" ; -- SOL 3
        when X"10" => pr_op <= LDI & "0100" & c_r18 & "0000" ; -- MI 3
        when X"11" => pr_op <= LDI & "0011" & c_r19 & "0000" ; -- DO 2


        when X"00" => pr_op <= IN & "0100" & c_r16 & "1000" ;
        when X"12" => pr_op <= LDI & "0100" & c_r16 & "0111" ; -- SI 3
        when X"13" => pr_op <= LDI & "0100" & c_r17 & "0011" ; -- SOL 3
        when X"14" => pr_op <= LDI & "0011" & c_r18 & "1110" ; -- RE 3
        when X"15" => pr_op <= LDI & "0011" & c_r19 & "0111" ; -- SOL 2

        when X"00" => pr_op <= LDI & "0100" & c_r16 & "1000" ;
        when X"16" => pr_op <= LDI & "0100" & c_r16 & "0111" ; -- SI 3
        when X"17" => pr_op <= LDI & "0100" & c_r17 & "0011" ; -- SOL 3
        when X"18" => pr_op <= LDI & "0011" & c_r18 & "1110" ; -- RE 3
        when X"19" => pr_op <= LDI & "0011" & c_r19 & "0111" ; -- SOL 2

        when X"00" => pr_op <= LDI & "0100" & c_r16 & "1000" ;
        when X"20" => pr_op <= LDI & "0100" & c_r16 & "0111" ; -- SI 3
        when X"21" => pr_op <= LDI & "0100" & c_r17 & "0011" ; -- SOL 3
        when X"22" => pr_op <= LDI & "0011" & c_r18 & "1110" ; -- RE 3
        when X"23" => pr_op <= LDI & "0011" & c_r19 & "0111" ; -- SOL 2

        when X"00" => pr_op <= LDI & "0100" & c_r16 & "1000" ;
        when X"24" => pr_op <= LDI & "0100" & c_r16 & "0101" ; -- LA 3
        when X"25" => pr_op <= LDI & "0100" & c_r17 & "0000" ; -- MI 3
        when X"26" => pr_op <= LDI & "0011" & c_r18 & "1100" ; -- DO 3
        when X"27" => pr_op <= LDI & "0011" & c_r19 & "1001" ; -- LA 2

        when X"00" => pr_op <= LDI & "0100" & c_r16 & "1000" ;
        when X"28" => pr_op <= LDI & "0100" & c_r16 & "0101" ; -- LA 3
        when X"29" => pr_op <= LDI & "0100" & c_r17 & "0000" ; -- MI 3
        when X"30" => pr_op <= LDI & "0011" & c_r18 & "1100" ; -- DO 3
        when X"31" => pr_op <= LDI & "0011" & c_r19 & "1001" ; -- LA 2

        when X"00" => pr_op <= LDI & "0100" & c_r16 & "1000" ;
        when X"32" => pr_op <= LDI & "0100" & c_r16 & "0101" ; -- LA 3
        when X"33" => pr_op <= LDI & "0100" & c_r17 & "0000" ; -- MI 3
        when X"34" => pr_op <= LDI & "0011" & c_r18 & "1100" ; -- DO 3
        when X"35" => pr_op <= LDI & "0011" & c_r19 & "1001" ; -- LA 2

        when X"00" => pr_op <= LDI & "0100" & c_r16 & "1000" ;
        when X"36" => pr_op <= LDI & "0100" & c_r16 & "0101" ; -- LA 3
        when X"37" => pr_op <= LDI & "0100" & c_r17 & "0001" ; -- FA 3
        when X"38" => pr_op <= LDI & "0011" & c_r18 & "1110" ; -- RE 3
        when X"39" => pr_op <= LDI & "0011" & c_r19 & "0010" ; -- RE 2

        when X"00" => pr_op <= LDI & "0100" & c_r16 & "1000" ;
        when X"40" => pr_op <= LDI & "0100" & c_r16 & "0101" ; -- LA 3
        when X"41" => pr_op <= LDI & "0100" & c_r17 & "0001" ; -- FA 3
        when X"42" => pr_op <= LDI & "0011" & c_r18 & "1110" ; -- RE 3
        when X"43" => pr_op <= LDI & "0011" & c_r19 & "0010" ; -- RE 2

        when X"00" => pr_op <= LDI & "0100" & c_r16 & "1000" ;
        when X"44" => pr_op <= LDI & "0100" & c_r16 & "0111" ; -- SI 3
        when X"45" => pr_op <= LDI & "0100" & c_r17 & "0011" ; -- SOL 3
        when X"46" => pr_op <= LDI & "0011" & c_r18 & "1110" ; -- RE 3
        when X"47" => pr_op <= LDI & "0011" & c_r19 & "0111" ; -- SOL 2

        when X"00" => pr_op <= LDI & "0100" & c_r16 & "1000" ;
        when X"48" => pr_op <= LDI & "0100" & c_r16 & "0111" ; -- SI 3
        when X"49" => pr_op <= LDI & "0100" & c_r17 & "0011" ; -- SOL 3
        when X"50" => pr_op <= LDI & "0011" & c_r18 & "1110" ; -- RE 3
        when X"51" => pr_op <= LDI & "0011" & c_r19 & "0111" ; -- SOL 2

        when X"00" => pr_op <= LDI & "0100" & c_r16 & "1000" ;
        when X"52" => pr_op <= LDI & "0100" & c_r16 & "0111" ; -- SI 3
        when X"53" => pr_op <= LDI & "0100" & c_r17 & "0011" ; -- SOL 3
        when X"54" => pr_op <= LDI & "0011" & c_r18 & "1110" ; -- RE 3
        when X"55" => pr_op <= LDI & "0011" & c_r19 & "0111" ; -- SOL 2

        when X"00" => pr_op <= LDI & "0100" & c_r16 & "1000" ;
        When X"56" => pr_op <= LDI & "0100" & c_r16 & "1000" ; -- DO 4
        when X"57" => pr_op <= LDI & "0100" & c_r17 & "0011" ; -- SOL 3
        when X"58" => pr_op <= LDI & "0100" & c_r18 & "0000" ; -- MI 3
        when X"59" => pr_op <= LDI & "0011" & c_r19 & "0000" ; -- DO 2

        when X"00" => pr_op <= LDI & "0100" & c_r16 & "1000" ;
        When X"60" => pr_op <= LDI & "0100" & c_r16 & "1000" ; -- DO 4
        when X"61" => pr_op <= LDI & "0100" & c_r17 & "0011" ; -- SOL 3
        when X"62" => pr_op <= LDI & "0100" & c_r18 & "0000" ; -- MI 3
        when X"63" => pr_op <= LDI & "0011" & c_r19 & "0000" ; -- DO 2

        when X"00" => pr_op <= LDI & "0100" & c_r16 & "1000" ;
        When X"64" => pr_op <= LDI & "0100" & c_r16 & "1000" ; -- DO 4
        when X"65" => pr_op <= LDI & "0100" & c_r17 & "0011" ; -- SOL 3
        when X"66" => pr_op <= LDI & "0100" & c_r18 & "0000" ; -- MI 3
        when X"67" => pr_op <= LDI & "0011" & c_r19 & "0000" ; -- DO 2

        when X"00" => pr_op <= LDI & "0100" & c_r16 & "1000" ;
        When X"68" => pr_op <= LDI & "0100" & c_r16 & "1000" ; -- DO 4
        when X"69" => pr_op <= LDI & "0100" & c_r17 & "0011" ; -- SOL 3
        when X"70" => pr_op <= LDI & "0100" & c_r18 & "0000" ; -- MI 3
        when X"71" => pr_op <= LDI & "0011" & c_r19 & "0000" ; -- DO 2

        when X"00" => pr_op <= LDI & "0100" & c_r16 & "1000" ;
        When X"72" => pr_op <= LDI & "0100" & c_r16 & "1000" ; -- DO 4
        when X"73" => pr_op <= LDI & "0100" & c_r17 & "0101" ; -- LA 3
        when X"74" => pr_op <= LDI & "0100" & c_r18 & "0001" ; -- FA 3
        when X"75" => pr_op <= LDI & "0011" & c_r19 & "0101" ; -- FA 2
