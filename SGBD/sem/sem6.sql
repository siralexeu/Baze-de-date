SET SERVEROUTPUT ON;
/*1. Afisati numele, functia si data angajarii pentru acei angajati care au intrat în firma într-un anumit an, citit de la tastatura. 
În cazul în care nu exista nici un astfel de angajat tratati exceptia si afisati mesajul ‘In anul  YYYY nu a fost angajat personal nou’ 
În cazul în care interogarea returneaza mai multe valori tratati exceptia si afisati mesajul 'In anul  YYYY au fost angajate multiple persoane’, 
dupa care afisati lista acelor persoane
Tratati orice alta problema si afitati mesajul ‘A aparut o alta problem?’*/
DECLARE
v_nume angajati.nume%TYPE;
v_functie angajati.id_angajat%TYPE;
v_data angajati.data_angajare%TYPE;
v_an number :=&an;
BEGIN
   SELECT nume, id_functie, data_angajare INTO v_nume, v_functie, v_data
   FROM angajati 
   WHERE EXTRACT(YEAR FROM data_angajare) = v_an;
   DBMS_OUTPUT.PUT_LINE(v_nume||' '||v_functie||' '||v_data);
EXCEPTION
   WHEN NO_DATA_FOUND THEN
       DBMS_OUTPUT.PUT_LINE('In anul '||v_an||' nu a fost anagajat personal nou');
    WHEN TOO_MANY_ROWS THEN
       DBMS_OUTPUT.PUT_LINE('In anul '||v_an||' nu a fost anagajate multiple persoane');
        DECLARE
        CURSOR c_ang IS SELECT nume, id_functie, data_angajare
                        FROM angajati
                        WHERE extract(YEAR FROM data_angajare) = v_an;
        BEGIN
           FOR rec_ang IN c_ang LOOP
               DBMS_OUTPUT.PUT_LINE(rec_ang.nume||' '||rec_ang.data_angajare);
               END LOOP;
        END;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('A aparut o alta eroare'||SQLERRM);
END;
/
/*2. Adaugati în tabela departamente un nou departament cu ID-ul 300, fara a preciza denumirea acestuia. 
În acest caz va apare o eroare cu codul  ORA-02290 prin care suntem avertizati de încalcarea unei restrictii de integritate. 
Tratati aceasa situatie afisand un mesaj corespunzator, precum si mesajul erorii generate:*/
DECLARE
nn_exceptie EXCEPTION;
PRAGMA EXCEPTION_INIT(nn_exceptie, -02290);
BEGIN
   INSERT INTO departamente(id_departament) VALUES (300);
   DBMS_OUTPUT.PUT_LINE('a fost introdus un nou departament');
EXCEPTION
   WHEN nn_exceptie THEN
       DBMS_OUTPUT.PUT_LINE('Nu putem adauga un departament fara denumire');
END;
/
/*3. Acordati o marire salariala de 30 de procente unui angajat al carui id il cititi de la tastatura si afisati un mesaj de confirmare. 
Tratati cu ajutorul unei exceptii situatia în care acest angajat nu exista, afisand un mesaj corespunzator.*/  
DECLARE
 ang_exceptie EXCEPTION;
BEGIN
  UPDATE angajati
  SET salariul=salariul*1.3
  WHERE id_angajat=&sv_id;
  IF SQL%NOTFOUND THEN
    RAISE ang_exceptie;
  ELSE
    DBMS_OUTPUT.PUT_LINE(' a fost acordata marirea');
  END IF;
EXCEPTION 
   WHEN ang_exceptie THEN
      DBMS_OUTPUT.PUT_LINE('Nu exista angajatul cautat');
END;
/
ROLLBACK;
  