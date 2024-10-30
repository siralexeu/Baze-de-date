SET SERVEROUTPUT ON;

--1. Construi?i un bloc PL/SQL prin care s? se calculeze într-o variabil? global? venitul total al unui angajat pentru care id-ul este citit de la tastatur?.
DECLARE
    v_nume angajati.nume%TYPE;
    v_vechime NUMBER(2);
    v_venit NUMBER;
    v_id angajati.id_angajat%TYPE;
BEGIN
    v_id := &id_angajat;

    SELECT nume,
           (MONTHS_BETWEEN(SYSDATE, data_angajare) / 12),
           salariul * (1 + NVL(comision, 0))
    INTO v_nume, v_vechime, v_venit
    FROM angajati
    WHERE id_angajat = v_id;

    DBMS_OUTPUT.PUT_LINE('Angajatul cu id-ul ' || v_id || ' se numeste ' || v_nume || ' are venitul ' || v_venit || ' si o vechime de ' || TRUNC(v_vechime));
END;

--2. Construi?i un bloc PL/SQL prin care s? se calculeze într-o variabil? global? salariul mediu al angaja?ilor din departamentul al c?rui id este citit de la tastatur?.
DECLARE
    v_department_id departamente.id_departament%TYPE;
    v_salariul_mediu NUMBER := 0;
BEGIN
    v_department_id := &department_id;

    SELECT AVG(salariul)
    INTO v_salariul_mediu
    FROM angajati
    WHERE id_departament = v_department_id;

    DBMS_OUTPUT.PUT_LINE('Salariul mediu al angajatilor din departamentul cu ID-ul ' || v_department_id || ' este: ' || v_salariul_mediu);
END;

--3. Construi?i un bloc PL/SQL prin care s? se calculeze (în variabile locale) ?i s? se afi?eze contribu?iile ?i salariul net pentru angajatul 100. (procentele necesar de aplicat sunt: CAS - 25%, CASS - 10%, Impozit - 10%). 
DECLARE
    v_id_angajat angajati.id_angajat%TYPE := 100;
    v_salariul angajati.salariul%TYPE;
    v_salariul_net NUMBER;

    FUNCTION calculeaza_salariul_net(salariul_brut IN NUMBER) RETURN NUMBER IS
        v_cas NUMBER := salariul_brut * 0.25;
        v_cass NUMBER := salariul_brut * 0.10;
        v_impozit NUMBER := salariul_brut * 0.10;
    BEGIN
        RETURN salariul_brut - v_cas - v_cass - v_impozit;
    END calculeaza_salariul_net;
BEGIN
    SELECT salariul INTO v_salariul FROM angajati WHERE id_angajat = v_id_angajat;


    v_salariul_net := calculeaza_salariul_net(v_salariul);
    
    DBMS_OUTPUT.PUT_LINE('Salariul net al angajatului cu ID-ul ' || v_id_angajat || ' este: ' || v_salariul_net);
END;

--4. Construi?i un bloc PL/SQL prin care s? se adauge un produs nou în tabela Produse, astfel: 
--valoarea coloanei id_produs va fi calculat? ca fiind maximul valorilor existente, incrementat cu 1
--valorile coloanelor denumire_produs ?i descriere vor fi citite de la tastatur? prin variabile de substitu?ie
--restul valorilor pot r?mâne NULL
DECLARE
    v_id_produs produse.id_produs%TYPE;
    v_denumire_produs produse.denumire_produs%TYPE := '&denumire_produs';
    v_descriere produse.descriere%TYPE := '&descriere';
BEGIN
    SELECT MAX(id_produs) + 1 INTO v_id_produs FROM produse;

    INSERT INTO produse (id_produs, denumire_produs, descriere)
    VALUES (v_id_produs, v_denumire_produs, v_descriere);

    DBMS_OUTPUT.PUT_LINE('Produsul a fost adaugat');
END;
rollback;

