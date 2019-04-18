ENTITY latch_0a IS
  PORT (enb, d1, d2, d3 : IN     BIT;
        q1, q2, q3      : BUFFER BIT);    
END latch_0a;

ARCHITECTURE teste OF latch_0a IS
BEGIN
 q1 <= d1 WHEN enb ='1' ELSE 
       q1;

 q2 <= d2 WHEN enb ='1'; 
       
 WITH enb SELECT
   q3 <= d3 WHEN '1',
         q3 WHEN '0';
END teste;
