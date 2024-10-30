/*Sa se stearga din tabela comenzi toate comenzile plasate intr-o modalitate introdusa prin intermediul unei variabile de substitutie. 
Afisati numarulde comenzi care au fost sterse folosind o variabila de mediu. */
set serveroutput on;

ACCEPT g_modalitate PROMPT 'introduceti modalitatea de plasare a comenzii'
VARIABLE g_nrcomenzi VARCHAR2(50)
BEGIN
    DELETE FROM comenzi WHERE modalitate='&g_modalitate';
    :g_nrcomenzi:=TO_CHAR(SQL%rowcount)||' comenzi eliminate din tabela';
END;
/
print g_nrcomenzi;
rollback;

/*Sa se afiseze primele 3 comenzi care au cele mai multe produse comandate. 
În acest caz înregistrarile vor fi ordonate descrescator în functie de numarul produselor comandate. */
DECLARE
CURSOR c1 is SELECT c.id_comanda, data, COUNT(id_produs) nr_produse
             FROM comenzi c, rand_comenzi rc
             WHERE c.id_comanda=rc.id_comanda
             GROUP BY c.id_comanda, data
             ORDER BY nr_produse DESC;
v_rec c1%ROWTYPE;
BEGIN
    IF NOT c1%ISOPEN THEN
        OPEN c1;
    END IF;
    LOOP
        FETCH c1 INTO v_rec;
        DBMS_OUTPUT.PUT_LINE('Comanda '||v_rec.id_comanda||' a fost plasata la data de '||v_rec.data||' si contine '||v_rec.nr_produse||' produse');
        EXIT WHEN c1%ROWCOUNT=3 OR c1%NOTFOUND;
    END LOOP;
END;
/

