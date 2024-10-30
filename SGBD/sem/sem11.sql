/*Construie?te un pachet PL/SQL care s? con?in? urm?toarele:

Procedura afiseaza_angajat, care afi?eaz? numele ?i venitul total (salariu + comision) pentru un angajat cu un anumit id, dat ca parametru.
Func?ia val_comenzi_angajat, care returneaz? valoarea total? a comenzilor intermediate de c?tre un angajat cu un anumit id, dat ca parametru.
Procedura mareste_salariu, care m?re?te salariul angajatului cu un anumit id, dat ca parametru. M?rirea salariului trebuie s? ?in? cont de urm?toarele:
Dac? angajatul a intermediat comenzi cu valoare total? de mai pu?in de 10000, atunci salariul s?u cre?te cu 100.
Dac? angajatul a intermediat comenzi cu valoare total? de mai mult de 10000, atunci salariul s?u cre?te cu 500.*/

SET SERVEROUTPUT ON
SET VERIFY OFF

CREATE OR REPLACE PACKAGE bonus 
IS
    nu_exista EXCEPTION;
    FUNCTION verifica_angajat(p_id in angajati.id_angajat%type) RETURN boolean;
    PROCEDURE afiseaza_angajat(p_id IN angajati.id_angajat%type);
    FUNCTION val_comenzi_angajat(p_id IN angajati.id_angajat%type) RETURN number;
    PROCEDURE mareste_salariu(P_ID IN angajati.id_angajat%type, p_salariu OUT number);
END;
/

CREATE OR REPLACE PACKAGE BODY bonus
IS
    FUNCTION verifica_angajat(p_id in angajati.id_angajat%type) RETURN boolean
    is
    nr NUMBER;
    BEGIN
        SELECT COUNT(id_angajat) into nr from angajati where id_angajat=p_id;
        IF nr=1 THEN 
            RETURN true;
        else 
            RETURN false;
        end if;
    END;
    
    PROCEDURE afiseaza_angajat(p_id IN angajati.id_angajat%type)
    IS
    v_nume angajati.nume%type;
    v_venit NUMBER;
    --nu_este EXCEPTION;
    BEGIN
        IF verifica_angajat(p_id) = true THEN
            SELECT nume, salariul+salariul*NVL(comision,0)
            INTO V_NUME,v_venit
            FROM angajati WHERE id_angajat=p_id;
            dbms_output.put_line('Angajatul '||v_nume||' are venitul total '||v_venit);
        ELSE 
            Raise nu_exista;
        end if;
    EXCEPTION
        WHen nu_exista THEN
            dbms_output.put_line('NU EXISTA NICI UN ANGAJAT CU ID-UL '||p_id);
    END;
    
    FUNCTION val_comenzi_angajat(p_id IN angajati.id_angajat%type) RETURN number
    is
    p_valoare NUMBER;
    --  nu_este EXCEPTION;
    BEGIN
    IF verifica_angajat(p_id) = true THEN
        SELECT SUM(cantitate*pret) INTO p_valoare FROM comenzi c, rand_comenzi rc
        WHERE c.id_comanda=rc.id_comanda AND id_angajat=p_id;
        RETURN NVL(p_valoare,0);
    ELSE
        RAISE nu_exista;
    END IF;
    EXCEPTION
        WHEN nu_exista THEN
            RETURN -1;
    END;
    
    PROCEDURE mareste_salariu(P_ID IN angajati.id_angajat%type, p_salariu OUT number)
    is
    v_marire number;
    BEGIN
    IF verifica_angajat(p_id) = true THEN
        CASE
        WHEN val_comenzi_angajat(p_id) between 1 and 10000 THEN v_marire:=100;
        WHEN val_comenzi_angajat(p_id) >10000 THEN v_marire:=500;
        else v_marire:=0;
        end case;
        
        UPDATE angajati
        SET salariul=salariul+v_marire
        WHERE id_angajat=p_id
        RETURNING salariul INTO p_salariu;
    ELSE 
        RAISE nu_exista;
    END IF;
    
    EXCEPTION
        WHEN nu_exista THEN
            dbms_output.put_line('NU EXISTA NICI UN ANGAJAT CU ID-UL '||p_id);
    END;
END;
/
--APEL
EXECUTE bonus.afiseaza_angajat(1000);   
        
DECLARE
    p_valoare number;
    p_id angajati.id_angajat%type := &id;
BEGIN
    IF bonus.verifica_angajat(p_id) = TRUE THEN
        p_valoare := bonus.val_comenzi_angajat(p_id);
        dbms_output.put_line('Angajatul ' || p_id || ' a gestionat comenzi în valoare de ' || p_valoare);
    ELSE 
        dbms_output.put_line('Angajatul ' || p_id || ' nu a gestionat comenzi');
    END IF;
END;
/

DECLARE
    p_salariu_vechi NUMBER;
    p_salariu_nou NUMBER := 0;
    p_id angajati.id_angajat%TYPE := &id;
BEGIN
    IF bonus.verifica_angajat(p_id) = TRUE THEN
        SELECT salariul INTO p_salariu_vechi FROM angajati WHERE id_angajat = p_id;
        DBMS_OUTPUT.PUT_LINE('Angajatul cu ID-ul ' || p_id || ' are un salariu vechi de ' || p_salariu_vechi);
    ELSE
        dbms_output.put_line('Angajatul cu ID-ul ' || p_id || ' nu exista.');
    END IF;
    
    bonus.mareste_salariu(p_id, p_salariu_nou);
    
    IF p_salariu_nou != 0 THEN
        DBMS_OUTPUT.PUT_LINE('Salariul a fost marit, iar acum este ' || p_salariu_nou);
    END IF;      
END;
/
ROLLBACK;