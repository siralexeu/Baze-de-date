SET SERVEROUTPUT ON;

/*1. Realiza?i o procedur? afiseaza_angajati în care s? declara?i un cursor pentru a selecta numele, 
func?ia ?i data angaj?rii salaria?ilor din tabela Angaja?i. 
Parcurge?i fiecare rând al cursorului ?i, în cazul în care data angaj?rii dep??e?te 01-AUG-2010, 
afi?a?i informa?iile preluate. Apela?i procedura.*/
CREATE OR REPLACE PROCEDURE afiseaza_angajati AS
  CURSOR c1 IS
    SELECT nume, id_functie, data_angajare
    FROM angajati;
  v_nume angajati.nume%TYPE;
  v_id_functie angajati.id_functie%TYPE;
  v_data_angajare angajati.data_angajare%TYPE;  
BEGIN 
  OPEN c1;
  LOOP
    FETCH c1 INTO v_nume, v_id_functie, v_data_angajare;
    EXIT WHEN c1%NOTFOUND;
    IF v_data_angajare > TO_DATE('01-AUG-2010', 'DD-MON-YYYY') THEN
      DBMS_OUTPUT.PUT_LINE('Angajatul '||v_nume||'  Functia '||v_id_functie||'  Data angajarii '||TO_CHAR(v_data_angajare,'DD-MON-YYYY'));
    END IF;
  END LOOP;
  CLOSE c1;
END;
/
BEGIN
  afiseaza_angajati;
END;
/
/*2. Realiza?i o func?ie vechime_angajat (p_cod angajati.id_angajat%type) care s? returneze vechimea angajatului 
(calculat? drept diferen?? între data actual? ?i cea a angaj?rii) care are codul primit ca parametru.
Trata?i excep?iile ap?rute. Apela?i func?ia dintr-un bloc PL/SQL ?i utiliza?i un cursor pentru a parcurge to?i angaja?ii.*/
CREATE OR REPLACE FUNCTION vechime_angajat(p_cod angajati.id_angajat%TYPE) RETURN NUMBER IS
  v_vechime NUMBER;
BEGIN
  SELECT TRUNC(MONTHS_BETWEEN(SYSDATE, data_angajare) / 12) INTO v_vechime
  FROM angajati
  WHERE id_angajat = p_cod;
  RETURN v_vechime;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN NULL;
  WHEN OTHERS THEN
    RETURN NULL;
END;
/
DECLARE
  v_cod_angajat angajati.id_angajat%TYPE;
  v_vechime NUMBER;
  CURSOR c2 IS
    SELECT id_angajat FROM angajati;
BEGIN
  OPEN c2;
  LOOP
    FETCH c2 INTO v_cod_angajat;
    EXIT WHEN c2%NOTFOUND;
    v_vechime := vechime_angajat(v_cod_angajat);
    DBMS_OUTPUT.PUT_LINE('Angajatul '||v_cod_angajat||' are vechimea '||v_vechime||' ani');
  END LOOP;
  CLOSE c2;
END;
/
/*3. Realiza?i o procedur? vechime_angajat_proc (p_cod  IN angajati.id_angajat %type, p_vechime OUT number)
care s? calculeze vechimea angajatului care are codul primit ca parametru. Trata?i excep?iile ap?rute. 
Apela?i procedura dintr-un bloc PL/SQL ?i utiliza?i un cursor pentru a parcurge to?i angaja?ii. */
CREATE OR REPLACE PROCEDURE vechime_angajat_proc(p_cod IN angajati.id_angajat%TYPE, p_vechime OUT NUMBER) IS
BEGIN
  SELECT TRUNC(MONTHS_BETWEEN(SYSDATE, data_angajare)/12)
  INTO p_vechime
  FROM angajati
  WHERE id_angajat = p_cod;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    p_vechime := NULL;
  WHEN OTHERS THEN
    p_vechime := NULL;
END;
/
DECLARE
  v_cod_angajat angajati.id_angajat%TYPE;
  v_vechime NUMBER;
BEGIN
  FOR angajat_rec IN (SELECT id_angajat FROM angajati) LOOP
    vechime_angajat_proc(angajat_rec.id_angajat, v_vechime);
    DBMS_OUTPUT.PUT_LINE('Angajatul ' || angajat_rec.id_angajat || ' are vechimea ' || v_vechime || ' ani');
  END LOOP;
END;
/
/*4. Realiza?i o procedur? vechime_angajat_proc2 care s? calculeze vechimea fiec?rui angajat 
(înregistr?rile se vor parcurge printr-un cursor). Trata?i excep?iile ap?rute. Testa?i procedura. */
CREATE OR REPLACE PROCEDURE vechime_angajat_proc2 IS
  CURSOR c4 IS
    SELECT id_angajat, data_angajare
    FROM angajati;
  v_id_angajat angajati.id_angajat%TYPE;
  v_data_angajare angajati.data_angajare%TYPE;
  v_vechime NUMBER;
BEGIN
  OPEN c4;
  LOOP
    FETCH c4 INTO v_id_angajat, v_data_angajare;
    EXIT WHEN c4%NOTFOUND;
    BEGIN
      v_vechime := TRUNC(MONTHS_BETWEEN(SYSDATE, v_data_angajare) / 12);
      DBMS_OUTPUT.PUT_LINE('Angajatul ' || v_id_angajat || ' are vechimea ' || v_vechime || ' ani');
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Nu exista vechimea pentru angajatul ' || v_id_angajat);
      WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('A aparut o eroare pentru angajatul ' || v_id_angajat);
    END;
  END LOOP;
  CLOSE c4;
END;
/
BEGIN
  vechime_angajat_proc2;
END;
/
/*5. Realiza?i o procedur? prin care s? se returneze data încheierii ?i valoarea celei mai recente comenzi: 
info_comanda_recenta (p_data OUT comenzi.data%type, p_valoare OUT number). */
CREATE OR REPLACE PROCEDURE info_comanda_recenta(p_data OUT comenzi.data%TYPE, p_valoare OUT NUMBER) IS
BEGIN
  SELECT c.data, SUM(rc.pret*rc.cantitate)
  INTO p_data, p_valoare
  FROM comenzi c
  JOIN Rand_comenzi rc ON c.id_comanda = rc.id_comanda
  WHERE c.data = (SELECT MAX(data) FROM comenzi)
  GROUP BY c.data;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    p_data:=NULL;
    p_valoare:=NULL;
  WHEN OTHERS THEN
    p_data:=NULL;
    p_valoare:=NULL;
END;
/
DECLARE
  v_data comenzi.data%TYPE;
  v_valoare NUMBER;
BEGIN
  info_comanda_recenta(v_data, v_valoare);
  IF v_data IS NOT NULL THEN
    DBMS_OUTPUT.PUT_LINE('Cea mai recenta comanda ' ||v_data||' si valoarea comenzii '||v_valoare);
  ELSE
    DBMS_OUTPUT.PUT_LINE('Nu avem comenzi');
  END IF;
END;
/

/*6. Realiza?i un declan?ator cantitati_pozitive care s? nu permit? în tabela Rând_comenzi valori negative ale cantit??ii care poate fi comandat?. 
Testa?i declan?area trigger-ului. */
CREATE OR REPLACE TRIGGER cantitati_pozitive
BEFORE INSERT ON rand_comenzi
FOR EACH ROW
BEGIN
  IF :NEW.cantitate < 0 THEN
    RAISE_APPLICATION_ERROR(-20001, 'Nu sunt permise valori negative');
  END IF;
END;
/
INSERT INTO Rand_comenzi (id_comanda, id_produs, pret, cantitate)
VALUES (12, 25, 40, -20);

/*7. Realiza?i un declan?ator marire_stop care s? împiedice m?rirea salariului pentru angaja?ii cu vechimea mai mare de 10 de ani. 
Testa?i declan?area trigger-ului. */
CREATE OR REPLACE TRIGGER marire_stop
BEFORE UPDATE OF salariu ON angajati
FOR EACH ROW
BEGIN
  IF vechime_angajat(:OLD.id_angajat) > 10 THEN
    IF :NEW.salariu > :OLD.salariu THEN
      RAISE_APPLICATION_ERROR(-20001, 'Nu este permisa marirea salariului pentru angajatii cu o vechime mai mare de 10 ani');
    END IF;
  END IF;
END;
/
