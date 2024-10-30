SET SERVEROUTPUT ON;
/*1. Realizati o procedura Pl/SQL prin intermediul careia sa mariti cu 20% salariul angajatilor comisionati, 
care au intermediat minim 3 comenzi intr-un an transmis ca parametru. 
Returnati numarul de angajati pentru care se realizeaza aceasta actualizare, 
sau tratati in mod corespunzator o exceptie daca nu exista nici un angajat pentru care se modifica salariul. 
Apelati procedura si afisati numarul de angajati carora li s-a modificat salariul.*/
CREATE OR REPLACE PROCEDURE marire_Salariu(p_an number, p_nr OUT number)
IS
  exceptie EXCEPTION;
BEGIN
  UPDATE angajati
  SET salariul=salariul*1.2
  WHERE comision IS NOT NULL AND
        id_angajat IN (SELECT id_angajat FROM comenzi 
                       WHERE EXTRACT(YEAR FROM DATA)=p_an
                       GROUP BY id_angajat
                       HAVING COUNT(id_angajat)>=3);
 IF SQL%FOUND THEN
    p_nr:=SQL%ROWCOUNT;
 ELSE
    RAISE exceptie;
 END IF;
EXCEPTION
    WHEN exceptie THEN
         p_nr:=0;
END;
/

SET VERIFY OFF
   --BLOC DE APEL AL PROCEDURII
DECLARE
 NR_ANGAJATI NUMBER;
 BEGIN
   MARIRE_SALARIU(&an,nr_angajati);
   IF nr_angajati>0 THEN
      DBMS_OUTPUT.PUT_LINE('Am marit salariul pentru '||nr_angajati);
   ELSE
      DBMS_OUTPUT.PUT_LINE('Nu s-a acordat marire salariu');
   END IF;
END;
/
ROLLBACK;  

/*2. Realizati o functie Pl/SQL care sa returneze categoria in care se incadreaza un angajat al carui id este transmis ca parametru. 
Angajatii cu salariul mai mic de 3000 sunt junior, cei cu salariul intre 3000 and 7000 mid-level, 
iar cei cu salariul peste 7000 sunt incadrati la senior. Tratati exceptia care apare daca angajatul pentru care se face verificarea nu exista.
(returnam un mesaj corespunzator).*/
CREATE OR REPLACE FUNCTION categorie(p_id angajati.id_angajat%TYPE)
RETURN VARCHAR2
IS
  v_sal angajati.salariul%TYPE;
  v_categorie VARCHAR2(20);
BEGIN
  SELECT salariul INTO v_sal FROM angajati WHERE id_angajat=p_id;
  IF v_sal<3000 THEN
     v_categorie:='junior';
     ELSIF v_sal BETWEEN 3000 AND 7000 THEN
           v_categorie:='mid-level';
     ELSE v_categorie:='senior';
  END IF;
  RETURN v_categorie;
EXCEPTION 
  WHEN no_data_found THEN
    RETURN 'nu exista angajat cu id-ul specificat';
END;
/
  
/*Afisati lista tuturor angaatilor specificand numele, salariul si categoria in care se incadreaza*/
SELECT nume, salariul, categorie(id_angajat) AS categorie_angajat
FROM angajati;

  
  
  
  
