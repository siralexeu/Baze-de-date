/*Utilizati un bloc PL/SQL pentru a afisa pentru fiecare departament (id, denumire) valoarea totala a salariilor platite angajatilor.*/
set serveroutput on;

DECLARE 
  CURSOR c1 IS SELECT a.id_departament, denumire_departament, SUM(salariul) AS total_salarii
               FROM angajati a, departamente d
               WHERE a.id_departament=d.id_departament
               GROUP BY a.id_departament, denumire_departament;
BEGIN
    FOR rec_dep IN c1 LOOP
     DBMS_OUTPUT.PUT_LINE('Departamentul '||rec_dep.denumire_departament||' are cheltuieli salariale totale in valoare de '||rec_dep.total_salarii);
     END LOOP;
END;
/

/*Realizati un bloc PL/SQL prin care sa se afiseze pentru fiecare angajat ( id, nume) detalii 
cu privire la comenzile intermediate de catre acesta (id_comanda, data, modalitate). */
DECLARE
    CURSOR c_ang IS SELECT id_angajat, nume FROM angajati;
    CURSOR c_com(id angajati.id_angajat%TYPE) IS 
                    SELECT id_comanda, data, modalitate
                    FROM comenzi
                    WHERE id_angajat=id;
BEGIN
   FOR rec_ang IN c_ang LOOP
       DBMS_OUTPUT.PUT_LINE('Angajatul '||rec_ang.nume);
         FOR rec_com IN c_com(rec_ang.id_angajat) LOOP
           DBMS_OUTPUT.PUT_LINE('Comanda '||rec_com.id_comanda ||' plasata la '||rec_com.data);
         END LOOP;
   END LOOP;
END;
/
--EXERCITII SEMINAR
/*1.Printr-un bloc PL/SQL, sa se atribuie o valoare de comision angajatilor din departamentul al carui id este citit de la tastatura. 
Sa se afiseze numarul de modificari totale efectuate. */
DECLARE
    v_department_id angajati.id_departament%TYPE;
    v_nr_modificari NUMBER := 0;

    CURSOR c_angajati IS
        SELECT id_angajat
        FROM angajati
        WHERE id_departament = v_department_id;
BEGIN
    v_department_id := &department_id;

    FOR rec_ang IN c_angajati LOOP
        UPDATE angajati
        SET comision = 0.1
        WHERE id_angajat = rec_ang.id_angajat;
        
        v_nr_modificari := v_nr_modificari + SQL%ROWCOUNT;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Numarul total de modificari: ' || v_nr_modificari);
END;
/

/*2.     Prin intermediul unui bloc PL/SQL actualizati pretul de lista al produselor, in functie de pretul minim al acestora astfel:
-        produsele cu pretul minim cuprins intre 1 si 100 primesc o marire de 25 procente a pretului de lista
-        produsele cu pretul minim cuprins intre 101 si 1000  primesc o marire de 15 procente a pretului de lista
-        Celorlalte produse nu li se mareste pretul.
S? se afi?eze num?rul de modific?ri totale efectuate.*/
DECLARE
    v_nrmodificari NUMBER := 0;
    CURSOR c_prod IS SELECT id_produs, pret_lista FROM produse;
BEGIN
    FOR produs IN c_prod LOOP
        IF produs.pret_lista >= 1 AND produs.pret_lista <= 100 THEN
            UPDATE produse
            SET pret_lista = ROUND(produs.pret_lista * 1.25, 2) -- Marire cu 25%
            WHERE id_produs = produs.id_produs;
            v_nrmodificari := v_nrmodificari + 1;
        ELSIF produs.pret_lista >= 101 AND produs.pret_lista <= 1000 THEN
            UPDATE produse
            SET pret_lista = ROUND(produs.pret_lista * 1.15, 2) -- Marire cu 15%
            WHERE id_produs = produs.id_produs;
            v_nrmodificari := v_nrmodificari + 1;
        END IF;
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('Numarul total de modificari efectuate: ' || v_nrmodificari);
END;
/
rollback;

/*3.     Construiti un bloc PL/SQL prin care sa se afiseze informatii despre angajatii din orasul Oxford.*/
DECLARE
    v_nr_angajati NUMBER := 0;
    CURSOR c_ang IS 
        SELECT a.nume, a.prenume, a.salariu 
        FROM angajati a
        JOIN locatii l ON a.id_locatie = l.id_locatie
        WHERE LOWER(l.oras) LIKE '%oxford%';
BEGIN
    FOR angajat IN c_ang LOOP
        DBMS_OUTPUT.PUT_LINE('Nume: ' || angajat.nume || ', Prenume: ' || angajat.prenume || ', Salariu: ' || angajat.salariu);
        v_nr_angajati := v_nr_angajati + 1;
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('Numarul total de angajati din Oxford: ' || v_nr_angajati);
END;
/
/*4.     Realiza?i un bloc PL/SQL care sa afi?eze informa?ii despre angaja?i ?i num?rul de comenzi intermediat de ace?tia.*/
DECLARE
    v_id_angajat angajati.id_angajat%TYPE;
    v_prenume angajati.prenume%TYPE;
    v_nume angajati.nume%TYPE;
    v_numar_comenzi INTEGER;

    CURSOR c_ang_com IS
        SELECT a.id_angajat, a.prenume, a.nume, COUNT(c.id_comanda) AS numar_comenzi
        FROM angajati a
        LEFT JOIN comenzi c ON a.id_angajat = c.id_angajat
        GROUP BY a.id_angajat, a.prenume, a.nume;

BEGIN
    OPEN c_ang_com;
    
    LOOP
        FETCH c_ang_com INTO v_id_angajat, v_prenume, v_nume, v_numar_comenzi;
        EXIT WHEN c_ang_com%NOTFOUND;
        
        DBMS_OUTPUT.PUT_LINE('Angajat ID: ' || v_id_angajat || ', Nume: ' || v_nume || ' ' || v_prenume || ', Num?r de comenzi: ' || v_numar_comenzi);
    END LOOP;

    CLOSE c_ang_com;
END;
/
/*5.     S? se creeze un bloc PL/SQL prin care s? se afi?eze pentru fiecare departament (id ?i nume) informa?ii despre angaja?ii aferen?i (id, nume, salariu). 
S? se afi?eze ?i salariul total aferent fiec?rui departament.*/
DECLARE
    CURSOR c_departments IS
        SELECT id_departament, nume_departament
        FROM departamente;
    
    v_department_id angajati.id_departament%TYPE;
    v_department_name departamente.nume_departament%TYPE;
    v_total_salary NUMBER;
BEGIN
    FOR rec_department IN c_departments LOOP
        v_department_id := rec_department.id_departament;
        v_department_name := rec_department.nume_departament;
        v_total_salary := 0;

        DBMS_OUTPUT.PUT_LINE('Departament ID: ' || v_department_id || ', Nume departament: ' || v_department_name);

        FOR rec_employee IN (SELECT id_angajat, nume, salariu
                             FROM angajati
                             WHERE id_departament = v_department_id) LOOP
            v_total_salary := v_total_salary + rec_employee.salariu;
            DBMS_OUTPUT.PUT_LINE('  Angajat ID: ' || rec_employee.id_angajat || ', Nume: ' || rec_employee.nume || ', Salariu: ' || rec_employee.salariu);
        END LOOP;

        DBMS_OUTPUT.PUT_LINE('  Total salariu pentru departament: ' || v_total_salary);
    END LOOP;
END;
/




  
  
       
       