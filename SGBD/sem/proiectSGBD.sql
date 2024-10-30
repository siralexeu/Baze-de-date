set serveroutput on;
--1.Afisam produsele cu pretul unitar mai mic sau egal cu 100 si cantitatea disponibila din stoc (structuri de control + cursor explicit)
DECLARE
    CURSOR c1 IS 
        SELECT p.id_produs, p.denumire_produs, p.pret_unitar, s.cantitate_stoc
        FROM ProduseNet p
        INNER JOIN StocNet s ON p.id_produs = s.id_produs;
    v_id_produs ProduseNet.id_produs%TYPE;
    v_denumire_produs ProduseNet.denumire_produs%TYPE;
    v_pret_unitar ProduseNet.pret_unitar%TYPE;
    v_cantitate_stoc StocNet.cantitate_stoc%TYPE;
BEGIN
    OPEN c1;
    LOOP
        FETCH c1 INTO v_id_produs, v_denumire_produs, v_pret_unitar, v_cantitate_stoc;
        EXIT WHEN c1%NOTFOUND;

        IF v_pret_unitar <= 100 THEN
            DBMS_OUTPUT.PUT_LINE('Produsul ' || v_denumire_produs || ' are un pret de ' || v_pret_unitar || ' si o cantitate disponibila in stoc de ' || v_cantitate_stoc);
        END IF;
    END LOOP;
    CLOSE c1;
END;
/
--2. Afi?area primelor 4 comenzi cu cele mai multe produse (structuri de control + cursor explicit)
DECLARE
    CURSOR c2 IS 
        SELECT c.id_comanda, c.data_comanda, COUNT(pc.id_produs) AS nr_produse
        FROM ComenziNet c
        INNER JOIN Produse_comenzi pc ON c.id_comanda = pc.id_comanda
        GROUP BY c.id_comanda, c.data_comanda
        ORDER BY nr_produse DESC;

    v_rec c2%ROWTYPE;
BEGIN
    IF NOT c2%ISOPEN THEN
        OPEN c2;
    END IF;
    
    FOR i IN 1..4 LOOP
        FETCH c2 INTO v_rec;
        EXIT WHEN c2%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Comanda ' || v_rec.id_comanda || ' a fost plasata la data de ' || v_rec.data_comanda || ' si contine ' || v_rec.nr_produse || ' produse');
    END LOOP;
    
    CLOSE c2;
END;
/
/*3.Sa se stearga din tabela comenzi toate comenzile plasate printr-o modalitate introdusa prin de la tastatura. 
Afisati cate comenzi au fost sterse (structuri de control) */
ACCEPT g_modalitate PROMPT 'Introduce?i modalitatea de plasare a comenzii'
VARIABLE g_nrcomenzi NUMBER;
BEGIN
    DELETE FROM Produse_comenzi pc
    WHERE pc.id_comanda IN (SELECT cn.id_comanda FROM ComenziNet cn WHERE cn.modalitate = '&g_modalitate');

    DELETE FROM ComenziNet WHERE modalitate = '&g_modalitate';

    :g_nrcomenzi := SQL%ROWCOUNT;

    DBMS_OUTPUT.PUT_LINE('Num?rul de comenzi eliminate: ' || NVL(TO_CHAR(:g_nrcomenzi), '0'));
END;
/
SET SERVEROUTPUT ON 
PRINT g_nrcomenzi;
ROLLBACK;

--4. Afisare produs comandat, data comenzii, metoda de plata (cursor implicit)
DECLARE
    v_nume_produs ProduseNet.denumire_produs%TYPE;
    v_data_comanda ComenziNet.data_comanda%TYPE;
    v_modalitate_comanda ComenziNet.modalitate%TYPE;
BEGIN
    FOR comanda IN (SELECT p.denumire_produs, c.data_comanda, c.modalitate
                    FROM ComenziNet c
                    INNER JOIN Produse_comenzi pc ON c.id_comanda = pc.id_comanda
                    INNER JOIN ProduseNet p ON pc.id_produs = p.id_produs) LOOP
        v_nume_produs := comanda.denumire_produs;
        v_data_comanda := comanda.data_comanda;
        v_modalitate_comanda := comanda.modalitate;
        
        DBMS_OUTPUT.PUT_LINE('Produsul ' || v_nume_produs || ' a fost comandat în data de ' || TO_CHAR(v_data_comanda, 'DD-MM-YYYY') || ' cu metoda de plata ' || v_modalitate_comanda);
    END LOOP;
END;
/
--5 Detalii despre comenzile plasate (data, client, cantitate, valoare totala comanda). În plus, comenzile  s? fie ordonate descresc?tor în func?ie de valoarea total? a comenzii.
DECLARE
    CURSOR c5 IS
        SELECT c.id_comanda, c.data_comanda, cl.nume || ' ' || cl.prenume AS nume_client,
               SUM(pc.cantitate) AS cantitate, SUM(pc.cantitate * p.pret_unitar) AS total_valoare
        FROM ComenziNet c
        INNER JOIN Produse_comenzi pc ON c.id_comanda = pc.id_comanda
        INNER JOIN ProduseNet p ON pc.id_produs = p.id_produs
        INNER JOIN ClientiNet cl ON c.id_client = cl.id_client
        GROUP BY c.id_comanda, c.data_comanda, cl.nume, cl.prenume
        ORDER BY total_valoare DESC;

    v_id_comanda ComenziNet.id_comanda%TYPE;
    v_data_comanda ComenziNet.data_comanda%TYPE;
    v_nume_client VARCHAR2(100);
    v_cantitate NUMBER;
    v_total_valoare NUMBER;
BEGIN
    OPEN c5;
    LOOP
        FETCH c5 INTO v_id_comanda, v_data_comanda, v_nume_client, v_cantitate, v_total_valoare;
        EXIT WHEN c5%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE('Comanda cu ID ' || v_id_comanda || ' a fost plasata la data de ' || TO_CHAR(v_data_comanda, 'DD-MM-YYYY') ||
                             ' de catre ' || v_nume_client || ' care contine ' || v_cantitate || ' produse in valoare de ' || v_total_valoare || ' lei.');
    END LOOP;

    CLOSE c5;
END;
/
/*6. Actualiza?i pre?ul de list? al produselor în func?ie de valoarea minim? a pre?ului unitar, astfel 
- produsele cu pre?ul unitar între 1 ?i 100 s? primeasc? o majorare de 20%, 
- produsele cu pre?ul unitar între 101 ?i 1000 s? primeasc? o majorare de 10%. 
--Afi?a?i num?rul total de modific?ri efectuate.*/
DECLARE
    v_nrmodificari NUMBER := 0;
    CURSOR c6 IS SELECT id_produs, pret_unitar FROM ProduseNet;
BEGIN
    FOR produs IN c6 LOOP
        IF produs.pret_unitar >= 1 AND produs.pret_unitar <= 100 THEN
            UPDATE ProduseNet
            SET pret_unitar = ROUND(produs.pret_unitar * 1.2, 2) -- marire cu 20%
            WHERE id_produs = produs.id_produs;
            v_nrmodificari := v_nrmodificari + 1;
        ELSIF produs.pret_unitar >= 101 AND produs.pret_unitar <= 1000 THEN
            UPDATE ProduseNet
            SET pret_unitar = ROUND(produs.pret_unitar * 1.1, 2) -- marire cu 10%
            WHERE id_produs = produs.id_produs;
            v_nrmodificari := v_nrmodificari + 1;
        END IF;
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('Numarul total de modificari efectuate: ' || v_nrmodificari);
END;
/
rollback;















