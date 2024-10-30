set serveroutput on;


ACCEPT g_id prompt 'introduceti id-ul angajatului cautat'
DECLARE
  v_nume angajati.nume%TYPE;
  v_vechime number(2);
  v_venit number;
  v_id angajati.id_angajat%TYPE := 100;
BEGIN
  SELECT nume, 
         (MONTHS_BETWEEN(SYSDATE, data_angajare) / 12), 
         salariul * (1 + NVL(comision, 0))
    INTO v_nume, v_vechime, v_venit
    FROM angajati
    WHERE id_angajat = v_id;

  DBMS_OUTPUT.PUT_LINE(' angajatul cu id-ul '||v_id||' se numeste '||v_nume||' are venitul '||v_venit||' si o vechime de '||TRUNC(v_vechime));
END;
