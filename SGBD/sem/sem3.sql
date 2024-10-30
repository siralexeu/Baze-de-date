/*Intr un bloc Pl/ SQl actualizati salariul unui angajat al carui id il citim
de la tastatura , in functie de numarul de comenzi intermediate de acesta
astfel:
• Daca angajatul a intermediat intre 4 si 8 comenzi , are o crestere de 10 procente
• Daca a intermediat mai mult de 8 comenzi , cresterea este de 20 de procente
• Altfel nu i se modifica salariul
Afisati numele si salariul initial, identificati si afisati numarul de
comenzi aferent angajatului , realizati actualizarea si apoi afisati noul
salariu primit de angajatul respectiv . */

set serveroutput on;

DECLARE
    v_id angajati.id_angajat%TYPE := &g_id;
    v_nume angajati.nume%TYPE;
    v_salariul angajati.salariul%TYPE;
    v_nrcomenzi number;

BEGIN
    SELECT nume, salariul,count(c.id_angajat) INTO v_nume, v_salariul 
    FROM angajati a, comenzi c
    WHERE a.id_angajat = v_id and a.id_angajat=c.id_angajat
    GROUP BY nume, salariul;
    
    DBMS_OUTPUT.PUT_LINE('Angajatul '||v_nume||' are salariul initial '||v_salariul);
 
    /*SELECT count(id_angajat) INTO v_nrcomenzi FROM comenzi WHERE id_angajat = v_id; 
    DBMS_OUTPUT.PUT_LINE('El a intermediat '||v_nrcomenzi||' comenzi');*/
 
    if v_nrcomenzi BETWEEN 4 AND 8 then
        v_salariul := v_salariul * 1.1;
    elsif v_nrcomenzi > 8 then
        v_salariul := v_salariul * 1.2;
    end if;
    
    UPDATE angajati
    SET salariul = v_salariul
    WHERE id_angajat = v_id;
    
        DBMS_OUTPUT.PUT_LINE('Angajatul '||v_nume||' are salariul final '||v_salariul);
END;
/

/*Într un bloc PL/SQL sa se parcurga toti angaja?ii cu id_angajat de la 100
la 110 , afisand numele si salariul acestora . exemplificatii utilizând toate
cele 3 structuri repetitive)*/

declare
    v_nume angajati.nume%type;
    v_salariul angajati.nume%type;
begin
    for v_id in 100..110 loop
     select nume,salariul into v_nume, v_salariul from angajati
     where id_angajat=v_id;
     DBMS_OUTPUT.PUT_LINE(v_id||' '||v_nume||' '||v_salariul);
    end loop;
end;
/

--afisati aceleasi date pt toti angajatii firmei
declare
    v_nume angajati.nume%type;
    v_salariul angajati.nume%type;
    v_IDMIN angajati.id_angajat%type;
    v_IDMAX angajati.id_angajat%type;
begin
  select min(id_angajat), max(id_angajat) into v_IDMIN, v_IDMAX from angajati;
    for v_id in v_IDMIN..v_IDMAX loop
     select nume,salariul into v_nume, v_salariul from angajati
     where id_angajat=v_id;
     DBMS_OUTPUT.PUT_LINE(v_id||' '||v_nume||' '||v_salariul);
    end loop;
end;
/

--stergeti anagajatul cu id-ul 150
delete from angajati where id_angajat=150;
rollback;


--afisati inca odata toti angajatii dupa stergearea unora dintre ei
declare
    v_nume angajati.nume%type;
    v_salariul angajati.nume%type;
    v_IDMIN angajati.id_angajat%type;
    v_IDMAX angajati.id_angajat%type;
    v_test number;
begin
  select min(id_angajat), max(id_angajat) into v_IDMIN, v_IDMAX from angajati;
    for v_id in v_IDMIN..v_IDMAX loop
    select count(id_angajat) into v_test from angajati where id_angajat=v_id;
    if v_test=1 then
     select nume,salariul into v_nume, v_salariul from angajati
     where id_angajat=v_id;
     DBMS_OUTPUT.PUT_LINE(v_id||' '||v_nume||' '||v_salariul);
   else DBMS_OUTPUT.PUT_LINE('nu exista angajatul cu id-ul curent');
   end if;
    end loop;
end;
/

 