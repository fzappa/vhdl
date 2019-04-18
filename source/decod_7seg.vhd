entity decodificador_7seg is
port(     bcd: IN BIT_VECTOR(3 DOWNTO 0);
    segmentos: OUT BIT_VECTOR(6 DOWNTO 0));
end decodificador_7seg;
 
architecture teste_4 of decodificador_7seg is
begin
WITH bcd SELECT
segmentos <= "1111110" WHEN "0000",
             "0110000" WHEN "0001",
             "1101101" WHEN "0010",
             "1111001" WHEN "0011",
             "0110011" WHEN "0100",
             "1011011" WHEN "0101",
             "1011111" WHEN "0110",
             "1110000" WHEN "0111",
             "1111111" WHEN "1000",
             "1111011" WHEN "1001",
             "1111110" WHEN OTHERS;    
end teste_4;
