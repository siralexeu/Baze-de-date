CREATE TABLE ProduseNet (
id_produs NUMBER(10) PRIMARY KEY,
denumire_produs VARCHAR2(50),
descriere VARCHAR2(1000),
pret_unitar NUMBER(20)
);

CREATE TABLE ClientiNet (
id_client NUMBER(10) PRIMARY KEY,
prenume VARCHAR2(50),
nume VARCHAR2(50),
telefon VARCHAR2(20),
adresa VARCHAR2(255)
);

CREATE TABLE StocNet (
id_stoc NUMBER(10) PRIMARY KEY,
cantitate_stoc NUMBER(10),
id_produs NUMBER(10),
FOREIGN KEY (id_produs) REFERENCES ProduseNet(id_produs)
);

CREATE TABLE ComenziNet (
id_comanda NUMBER(10) PRIMARY KEY,
data_comanda DATE,
modalitate VARCHAR2(50),
id_client NUMBER(10),
FOREIGN KEY (id_client) REFERENCES ClientiNet(id_client)
);

CREATE TABLE Produse_Clienti (
id_comanda NUMBER(10),
id_produs NUMBER(10),
cantitate NUMBER(10),
pret NUMBER(10),
FOREIGN KEY (id_comanda) REFERENCES ComenziNet(id_comanda),
FOREIGN KEY (id_produs) REFERENCES ProduseNet(id_produs)
);

set serveroutput on;
--1. Bloc PL/SQL pentru a insera o comand? nou? 
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
--2. Bloc PL/SQL pentru a mari pretul unui produs cu 10%
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
/*3. Bloc PL/SQL care s? afi?eze detaliile comenzilor înregistrate dintr-un an  citit de la tastatur? din tabela ComenziNet. 
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
/*4.Verific? dac? exist? produse cu pre?ul mai mare de 20 în stoc. Dac? da, afi?eaz? num?rul de produse care îndeplinesc aceast? condi?ie, 
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
