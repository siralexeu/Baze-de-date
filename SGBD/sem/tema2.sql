set serveroutput on;
--1. Într-un bloc PL/SQL s? se parcurg? to?i angaja?ii cu id_angajat de la 100 la 120, afi?ând numele, salariul ?i vechimea, folosind pe rând structurile: 
--WHILE-LOOP
DECLARE
    v_id_angajat    NUMBER := 100;
    v_nume          VARCHAR2(100);
    v_salaraiul     NUMBER;
    v_data_angajare DATE;
    v_vechime       NUMBER;
BEGIN
    WHILE v_id_angajat <= 120 LOOP
        SELECT nume, salariul, data_angajare INTO v_nume, v_salaraiul, v_data_angajare
        FROM Angajati
        WHERE id_angajat = v_id_angajat;        

        v_vechime := ROUND(MONTHS_BETWEEN(SYSDATE, v_data_angajare) / 12, 1);      

        DBMS_OUTPUT.PUT_LINE('Angajatul ' || v_nume || ' are salariul ' || v_salaraiul || ' si vechimea ' || v_vechime || ' ani');

        v_id_angajat := v_id_angajat + 1;        
    END LOOP;
END;
/
--LOOP-EXIT WHEN
DECLARE
    v_id_angajat    NUMBER := 100;
    v_nume          VARCHAR2(100);
    v_salaraiul     NUMBER;
    v_data_angajare DATE;
    v_vechime       NUMBER;
BEGIN
    LOOP
        SELECT nume, salariul, data_angajare INTO v_nume, v_salaraiul, v_data_angajare
        FROM Angajati
        WHERE id_angajat = v_id_angajat;        

        v_vechime := ROUND(MONTHS_BETWEEN(SYSDATE, v_data_angajare) / 12, 1);      

        DBMS_OUTPUT.PUT_LINE('Angajatul ' || v_nume || ' are salariul ' || v_salaraiul || ' si vechimea ' || v_vechime || ' ani');

        v_id_angajat := v_id_angajat + 1;  

        EXIT WHEN v_id_angajat > 120;      
    END LOOP;
END;
/
--2. Într-un bloc PL/SQL s? se parcurg? to?i angaja?ii, folosind pe rând structurile: 
--WHILE-LOOP
DECLARE
    v_id_angajat    NUMBER := 1;
    v_nume          VARCHAR2(100);
    v_salaraiul     NUMBER;
    v_test          NUMBER;
BEGIN
    WHILE v_id_angajat IS NOT NULL LOOP
        SELECT COUNT(*) INTO v_test FROM Angajati WHERE id_angajat = v_id_angajat;
        
        IF v_test = 1 THEN
            SELECT nume, salariul INTO v_nume, v_salaraiul FROM Angajati WHERE id_angajat = v_id_angajat;
            DBMS_OUTPUT.PUT_LINE('Angajatul ' || v_nume || ' are salariul ' || v_salaraiul);
        ELSE
            DBMS_OUTPUT.PUT_LINE('Nu exist? angajat cu ID-ul ' || v_id_angajat);
        END IF;
        
        v_id_angajat := v_id_angajat + 1;
    END LOOP;
END;
/

--LOOP-EXIT WHEN

--3. Printr-o comand? SQL simpl?, s? se ?tearg? angajatul cu id_angajat 150
DELETE FROM Angajati
WHERE id_angajat = 150;
--4. Printr-o comand? SQL simpl?, s? se afi?eze numele utilizatorului curent ?i data sistemului (utilizând USER ?i SYSDATE)
SELECT USER AS "Nume utilizator", SYSDATE AS "Data sistemului" FROM dual;

--5. Într-un bloc PL/SQL s? se parcurg? to?i angaja?ii, folosind pe rând structurile: 
--WHILE-LOOP
DECLARE
    v_id_angajat    NUMBER := 1;
    v_nume          VARCHAR2(100);
    v_salaraiul     NUMBER;
BEGIN
    WHILE v_id_angajat IS NOT NULL LOOP
        SELECT nume, salariul INTO v_nume, v_salaraiul
        FROM Angajati
        WHERE id_angajat = v_id_angajat;
        
        DBMS_OUTPUT.PUT_LINE('Angajatul ' || v_nume || ' are salariul ' || v_salaraiul);
        
        v_id_angajat := v_id_angajat + 1;
    END LOOP;
END;
/
--LOOP-EXIT WHEN
DECLARE
    v_id_angajat    NUMBER := 1;
    v_nume          VARCHAR2(100);
    v_salaraiul     NUMBER;
BEGIN
    LOOP
        SELECT nume, salariul INTO v_nume, v_salaraiul
        FROM Angajati
        WHERE id_angajat = v_id_angajat;
        
        DBMS_OUTPUT.PUT_LINE('Angajatul ' || v_nume || ' are salariul ' || v_salaraiul);
        
        v_id_angajat := v_id_angajat + 1;
        
        EXIT WHEN v_id_angajat > 120; -- Ie?im din bucl? când v_id_angajat dep??e?te 120
    END LOOP;
END;
/


