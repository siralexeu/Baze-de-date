set serveroutput on;
set verify off;
--1.Afisam produsele cu pretul unitar mai mic sau egal cu 100 si cantitatea disponibila din stoc 
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
            DBMS_OUTPUT.PUT_LINE('Produsul ' || v_denumire_produs || ' are un pret de ' || v_pret_unitar || ' si o cantitate disponibila în stoc de ' || v_cantitate_stoc);
        END IF;
    END LOOP;
    CLOSE c1;
END;
/
 
--2. Acesta este blocul PL/SQL actualizat pentru afi?area primelor 4 comenzi cu cele mai multe produse 
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
 


--3.Sa se stearga din tabela comenzi toate comenzile plasate printr-o modalitate introdusa prin de la tastatura. Afisati cate comenzi au fost sterse.
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
 

--4. Afisare produs comandat, data comenzii, metoda de plata 
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
 
--5 Detalii despre comenzile plasate (data, client, cantitate, valoare totala comanda). În plus, comenzile s? fie ordonate descresc?tor în func?ie de valoarea total? a comenzii.
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

 
--7. Bloc PL/SQL pentru a insera o comand? noua
BEGIN
    INSERT INTO ComenziNet (id_comanda, data_comanda, modalitate, id_client)
    VALUES (9, SYSDATE, 'card', 1);
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Comanda cu acest ID exista deja in baza de date.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('A aparut o alta eroare');
END;
/
 
--8. Bloc PL/SQL pentru a mari pretul unui produs cu 10%
DECLARE
    produs_not_found EXCEPTION;
BEGIN
    UPDATE ProduseNet
    SET pret_unitar = pret_unitar * 1.1
    WHERE id_produs = &p_id;
    
    IF SQL%NOTFOUND THEN
        RAISE produs_not_found;
    ELSE
        DBMS_OUTPUT.PUT_LINE('Pretul produsului a fost marit');
    END IF;
EXCEPTION
    WHEN produs_not_found THEN
        DBMS_OUTPUT.PUT_LINE('Produsul cu ID-ul specificat nu exista in baza de date.');
END;
/
ROLLBACK;
 
 
/*9. Bloc PL/SQL care s? afi?eze detaliile comenzilor înregistrate dintr-un an  citit de la tastatur? din tabela ComenziNet. 
În cazul în care sunt g?site mai multe comenzi, nu sunt gasite deloc se va afisa un mesaj*/
DECLARE
    v_id_comanda ComenziNet.id_comanda%TYPE;
    v_data_comanda ComenziNet.data_comanda%TYPE;
    v_modalitate ComenziNet.modalitate%TYPE;
    v_cantitate_produse ComenziNet.cantitate_produse%TYPE;
    v_an NUMBER := &an;
BEGIN
    SELECT id_comanda, data_comanda, modalitate, cantitate_produse
    INTO v_id_comanda, v_data_comanda, v_modalitate, v_cantitate_produse
    FROM ComenziNet
    WHERE EXTRACT(YEAR FROM data_comanda) = v_an;

    DBMS_OUTPUT.PUT_LINE('Comenzi din anul ' || v_an || ':');
    DBMS_OUTPUT.PUT_LINE('ID Comanda: ' || v_id_comanda || ', Data Comanda: ' || v_data_comanda || ', Modalitate: ' || v_modalitate || ', Cantitate Produse: ' || v_cantitate_produse);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('In anul ' || v_an || ' nu a fost inregistrata nicio comanda.');
    WHEN TOO_MANY_ROWS THEN
        DBMS_OUTPUT.PUT_LINE('In anul ' || v_an || ' au fost inregistrate mai multe comenzi.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('A aparut o alta problema: ' || SQLERRM);
END;
/
 

/*10.Verific? dac? exist? produse cu pre?ul mai mare de 20 în stoc. Dac? da, afi?eaz? num?rul de produse care îndeplinesc aceast? condi?ie, 
altfel afi?eaz? un mesaj care indic? c? nu exist? produse cu pre?ul mai mare de 20 în stoc.*/
DECLARE
    v_count NUMBER;
    v_exception EXCEPTION;
BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM StocNet s
    INNER JOIN ProduseNet p ON s.id_produs = p.id_produs
    WHERE p.pret_unitar > 20;

    IF v_count > 0 THEN
        DBMS_OUTPUT.PUT_LINE('Exista ' || v_count || ' produse cu pretul mai mare de 20 in stoc.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Nu exista produse cu pretul mai mare de 20 in stoc.');
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Nu exista produse in stoc.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('A aparut o eroare: ' || SQLERRM);
END;
/
 
/*11. adaugare produs nou in tabela produsenet, modifica categoria produsului, afisare categorie si descriere completa a produsului*/
CREATE OR REPLACE PACKAGE Pachet_Produse AS
  PROCEDURE Adauga_Produs(
    id_produs IN NUMBER,
    denumire_produs IN VARCHAR2,
    descriere IN VARCHAR2,
    pret_unitar IN NUMBER,
    categorie IN VARCHAR2
  );

  PROCEDURE Modifica_Categorie_Produs(
    id_produs IN NUMBER,
    noua_categorie IN VARCHAR2
  );

  FUNCTION Categorie_Produs(
    id_produs IN NUMBER
  ) RETURN VARCHAR2;

  FUNCTION Descriere_Completa_Produs(
    id_produs IN NUMBER
  ) RETURN VARCHAR2;
END Pachet_Produse;
/
CREATE OR REPLACE PACKAGE BODY Pachet_Produse AS
  PROCEDURE Adauga_Produs(
    id_produs IN NUMBER,
    denumire_produs IN VARCHAR2,
    descriere IN VARCHAR2,
    pret_unitar IN NUMBER,
    categorie IN VARCHAR2
  ) IS
    produs_existent EXCEPTION;
    PRAGMA EXCEPTION_INIT(produs_existent, -00001);
  BEGIN
    INSERT INTO ProduseNet (id_produs, denumire_produs, descriere, pret_unitar, categorie)
    VALUES (id_produs, denumire_produs, descriere, pret_unitar, categorie);
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Inregistrare adaugata cu succes in tabela ProduseNet.');
  EXCEPTION
    WHEN produs_existent THEN
      DBMS_OUTPUT.PUT_LINE('Exista deja un produs cu id-ul specificat in tabela ProduseNet.');
  END Adauga_Produs;

  PROCEDURE Modifica_Categorie_Produs(
    id_produs IN NUMBER,
    noua_categorie IN VARCHAR2
  ) IS
    produs_negasit EXCEPTION;
  BEGIN
    UPDATE ProduseNet SET categorie = noua_categorie WHERE id_produs = id_produs;
    IF SQL%ROWCOUNT = 0 THEN
      RAISE produs_negasit;
    ELSE
      DBMS_OUTPUT.PUT_LINE('Categoria produsului a fost modificat? cu succes.');
    END IF;
  EXCEPTION
    WHEN produs_negasit THEN
      DBMS_OUTPUT.PUT_LINE('Produsul cu id-ul specificat nu a fost g?sit în tabela ProduseNet.');
  END Modifica_Categorie_Produs;

  FUNCTION Categorie_Produs(
    id_produs IN NUMBER
  ) RETURN VARCHAR2 IS
    categoria_produs VARCHAR2(100);
  BEGIN
    SELECT categorie INTO categoria_produs FROM ProduseNet WHERE id_produs = id_produs;
    RETURN categoria_produs;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN 'Produs inexistent';
    WHEN TOO_MANY_ROWS THEN
      RETURN 'Mai multe categorii g?site';
  END Categorie_Produs;

  FUNCTION Descriere_Completa_Produs(
    id_produs IN NUMBER
  ) RETURN VARCHAR2 IS
    descriere VARCHAR2(1000);
  BEGIN
    SELECT descriere INTO descriere FROM ProduseNet WHERE id_produs = id_produs;
    RETURN descriere;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN 'Produs inexistent';
    WHEN TOO_MANY_ROWS THEN
      RETURN 'Mai multe descrieri g?site';
  END Descriere_Completa_Produs;

END Pachet_Produse;
/
set verify off;
BEGIN
  Pachet_Produse.Adauga_Produs(11, 'Scaun', 'Scaun ergonimic', 300, 'Mobilier');
END;
/
DECLARE
  categoria_produs VARCHAR2(20);
BEGIN
  categoria_produs := Pachet_Produse.Categorie_Produs(11);
  DBMS_OUTPUT.PUT_LINE('Categoria produsului este: ' || categoria_produs);
END;
/
DECLARE
  descriere_completa VARCHAR2(30);
BEGIN
  descriere_completa := Pachet_Produse.Descriere_Completa_Produs(11);
  DBMS_OUTPUT.PUT_LINE('Descrierea completa a produsului este: ' || descriere_completa);
END;
/
BEGIN
  Pachet_Produse.Modifica_Categorie_Produs(11, 'mobila');
END;
/ 
 
 
 
/*12. Schimbare modalitate comanda din cash in ramburs*/
CREATE OR REPLACE PACKAGE Pachet_ModificareModalitate AS

  PROCEDURE Modifica_Modalitate_Comanda(D
    id_comanda IN NUMBER,
    noua_modalitate IN VARCHAR2
  );

END Pachet_ModificareModalitate;
/
CREATE OR REPLACE PACKAGE BODY Pachet_ModificareModalitate AS
  PROCEDURE Modifica_Modalitate_Comanda(
    id_comanda IN NUMBER,
    noua_modalitate IN VARCHAR2
  ) IS
    modalitate_invalida EXCEPTION;
  BEGIN
    IF noua_modalitate = 'Cash' THEN
      RAISE modalitate_invalida;
    END IF;
    UPDATE ComenziNet SET modalitate = noua_modalitate WHERE id_comanda = id_comanda;
    DBMS_OUTPUT.PUT_LINE('Modalitatea comenzii a fost schimbata cu succes in: ' || noua_modalitate);
  EXCEPTION
    WHEN modalitate_invalida THEN
      DBMS_OUTPUT.PUT_LINE('Nu se poate schimba modalitatea în "Cash".');
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('A intervenit o eroare. Modalitatea comenzii nu a fost modificcata.');
  END Modifica_Modalitate_Comanda;

END Pachet_ModificareModalitate;
/
BEGIN
  Pachet_ModificareModalitate.Modifica_Modalitate_Comanda(1, 'Ramburs');
END;
/

 

/*13. înregistrarea unei noi comenzi ?i actualizarea cantit??ii stocului unui produs.
 calcularea totalului unei comenzi ?i verificarea disponibilit??ii în stoc a unui produs.*/
CREATE OR REPLACE PACKAGE Pachet_Utilitare IS
  PROCEDURE InregistreazaComanda(
    id_comanda IN NUMBER,
    data_comanda IN DATE,
    modalitate IN VARCHAR2,
    id_client IN NUMBER
  );
  FUNCTION CalculTotalComanda(id_comanda IN NUMBER) RETURN NUMBER;
  PROCEDURE ActualizeazaStoc(
    id_produs IN NUMBER,
    noua_cantitate IN NUMBER
  );
  FUNCTION VerificaDisponibilitateStoc(id_produs IN NUMBER) RETURN NUMBER;
END Pachet_Utilitare;
/
CREATE OR REPLACE PACKAGE BODY Pachet_Utilitare IS
  PROCEDURE InregistreazaComanda(
    id_comanda IN NUMBER,
    data_comanda IN DATE,
    modalitate IN VARCHAR2,
    id_client IN NUMBER
  ) IS
  BEGIN
    INSERT INTO ComenziNet (id_comanda, data_comanda, modalitate, id_client)
    VALUES (id_comanda, data_comanda, modalitate, id_client);
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Comanda cu ID-ul ' || id_comanda || ' a fost inregistrata');
  END InregistreazaComanda;

  FUNCTION CalculTotalComanda(id_comanda IN NUMBER) RETURN NUMBER IS
    total NUMBER := 0;
  BEGIN
    SELECT SUM(cantitate * pret) INTO total FROM Produse_comenzi WHERE id_comanda = id_comanda;
    RETURN total;
  END CalculTotalComanda;

  PROCEDURE ActualizeazaStoc(
    id_produs IN NUMBER,
    noua_cantitate IN NUMBER
  ) IS
  BEGIN
    UPDATE StocNet SET cantitate_stoc = noua_cantitate WHERE id_produs = id_produs;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Stocul pentru produsul cu ID-ul ' || id_produs || ' a fost actualizat la ' || noua_cantitate);
  END ActualizeazaStoc;

   FUNCTION VerificaDisponibilitateStoc(id_produs IN NUMBER) RETURN NUMBER IS
  disponibil NUMBER := 0;
BEGIN
  FOR rec IN (SELECT cantitate_stoc FROM StocNet WHERE id_produs = id_produs) LOOP
    disponibil := rec.cantitate_stoc;
    EXIT;
  END LOOP;
  RETURN disponibil;
END VerificaDisponibilitateStoc;

END Pachet_Utilitare;
/
--apel InregistreazaComanda
BEGIN
  Pachet_Utilitare.InregistreazaComanda(12, SYSDATE, 'card', 1);
END;
/
--apel CalculTotalComanda
DECLARE
  total_comanda NUMBER;
BEGIN
  total_comanda := Pachet_Utilitare.CalculTotalComanda(101);
  DBMS_OUTPUT.PUT_LINE('Totalul comenzii este: ' || total_comanda);
END;
/
--apel ActualizeazaStoc
BEGIN
  Pachet_Utilitare.ActualizeazaStoc(1, 50);
END;
/
select * from comenzinet;

--apel VerificaDisponibilitateStoc
DECLARE
  disponibilitate NUMBER;
BEGIN
  disponibilitate := Pachet_Utilitare.VerificaDisponibilitateStoc(1);
  IF disponibilitate > 0 THEN
    DBMS_OUTPUT.PUT_LINE('Produsul este disponibil în stoc.');
  ELSE
    DBMS_OUTPUT.PUT_LINE('Produsul nu este disponibil în stoc.');
  END IF;
END;
/
/*14. Creare declansator care sa nu adaugarea unui stoc negativ */ 
CREATE OR REPLACE TRIGGER stoc_pozitiv
BEFORE INSERT ON produse_comenzi
FOR EACH ROW
BEGIN
  IF :NEW.cantitate < 0 THEN
    RAISE_APPLICATION_ERROR(-20001, 'Nu sunt permise valori negative');
  END IF;
END;
/
INSERT INTO Produse_comenzi (id_comanda, id_produs, cantitate, pret)
VALUES (12, 25, -40, 20);
/*15. Creare declansator care nu premita actualizaea comenzile de dinainte de 2024*/
CREATE OR REPLACE TRIGGER actualizare_comenzi
BEFORE UPDATE ON ComenziNet
FOR EACH ROW
BEGIN
    IF TO_CHAR(:OLD.data_comanda, 'YYYY') < '2024' THEN
        RAISE_APPLICATION_ERROR(-20001, 'Nu este permisa actualizarea comenzilor de dinainte de 2024.');
    END IF;
END;
/
UPDATE ComenziNet
SET modalitate = 'cash'
WHERE id_comanda = 11;

/*16. Declansator care nu permite comandarea produselor peste stoc, si il actualizeaza prin scarea lui*/
CREATE OR REPLACE TRIGGER actualizare_stoc
BEFORE INSERT ON Produse_comenzi
FOR EACH ROW
DECLARE
    v_stoc_disponibil INTEGER;
BEGIN
    SELECT cantitate_stoc INTO v_stoc_disponibil
    FROM StocNet
    WHERE id_produs = :NEW.id_produs;

    IF v_stoc_disponibil < :NEW.cantitate THEN
        RAISE_APPLICATION_ERROR(-20001, 'Cantitatea comandata depaseste stocul');
    ELSE
        UPDATE StocNet
        SET cantitate_stoc = cantitate_stoc - :NEW.cantitate
        WHERE id_produs = :NEW.id_produs;
    END IF;
END;
/
INSERT INTO Produse_comenzi (id_comanda, cantitate, id_produs)
VALUES (1, 55, 3);







