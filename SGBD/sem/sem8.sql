SET SERVEROUTPUT ON;
/*Construiti un pachet care sa contina:
- o functie care returneaza numarul de comenzi încheiate de catre clientul al carui id este dat ca parametru.
Tratati cazul în care nu exista clientul specificat precum si cazul in care acesta nu a plasat comenzi;
- o procedura care foloseste functia de mai sus pentru a returna primii 3 clienti cu cele mai multe comenzi încheiate. 
• Sa se apeleze procedura din cadrul pachetului.*/
CREATE OR REPLACE PACKAGE pack AS
  FUNCTION numar_comenzi(p_id  clienti.id_client%TYPE) RETURN NUMBER;
  PROCEDURE top3_clienti;
END;
/   

CREATE OR REPLACE PACKAGE BODY pack AS
  FUNCTION numar_comenzi(p_id clienti.id_client%TYPE) RETURN number
  IS
  nr_com number;
  nr_c1 number;
  client_inexistent exception;
  comenzi_zero exception;
BEGIN
  SELECT COUNT(id_client) INTO nr_c1 FROM clienti WHERE id_client=p_id;
       IF nr_c1=0 THEN
         RAISE client_inexistent;
       END IF;
  SELECT COUNT(id_client) INTO nr_com FROM clienti WHERE id_client=p_id; 
       IF nr_com=0 THEN
         RAISE comenzi_zero;
       ELSE
         RETURN nr_com;
       END IF;
    EXCEPTION
     WHEN client_inexistent THEN
       RETURN -1;
     WHEN comenzi_zero THEN
       RETURN 0;
END;
   PROCEDURE top3_clienti 
   IS
     CURSOR c_clienti IS SELECT nume_client, numar_comenzi(id_client) nr_com
                         FROM clienti
                         ORDER BY nr_com desc
                         FETCH FIRST 3 ROWS ONLY;
BEGIN 
    FOR rec_clienti IN c_clienti LOOP
      DBMS_OUTPUT.PUT_LINE(rec_clienti.nume_client||' '||rec_clienti.nr_com);
    END LOOP;
END;
END;


BEGIN
  pack.top3_clienti;
end;
       