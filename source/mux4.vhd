ENTITY mux_9 IS 
  PORT (i0, i1, i2, i3  : IN  BIT; 
        s0, s1          : IN  BIT; 
        ot              : OUT BIT);
END mux_9;

ARCHITECTURE teste OF mux_9 IS
  SIGNAL sel : BIT_VECTOR (1 DOWNTO 0);
BEGIN
  sel <= s1 & s0;
  WITH sel SELECT  
    ot <= i0 WHEN "00",
          i1 WHEN "01",
          i2 WHEN "10",
          i3 WHEN "11";       
END teste;
