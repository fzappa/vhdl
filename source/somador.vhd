ENTITY soma IS
  PORT (a, b : IN  INTEGER;  -- entradas, valores entre -2**31 a 2**31 -1
        c    : OUT INTEGER); -- saida , valores entre -2**31 a 2**31 -1
END soma;

ARCHITECTURE teste OF soma IS
BEGIN
  c <= a + b;
end teste;
