SET SERVEROUTPUT ON;
/*Realizati un pachet de subprograme care sa contina:
- o procedura  care sa adauge o înregistrare noua în tabela Functii. Informatiile ce trebuie adaugate sunt furnizate drept parametri procedurii. 
Se trateaza cazul în care exista deja o functie cu codul introdus.
- o  procedura care sa modifice denumirea unei functii. Codul functiei pentru care se face modificarea si noua denumire a functiei sunt
parametrii procedurii. Se trateaza cazul în care modificarea nu are loc din cauza precizarii unui cod care nu se regaseste în tabela.
- o procedura care sa stearga o functie pe baza codului primit drept parametru. Se trateaza cazul în care codul furnizat nu exista.
Sa se apeleze subprogramele din pachet.*/
CREATE OR REPLACE PACKAGE Pachet_Functii IS

  PROCEDURE Adauga_Functie(
    id_functie IN NUMBER,
    denumire_functie IN VARCHAR2
  );

  PROCEDURE Modifica_Denumire_Functie(
    id_functie IN NUMBER,
    noua_denumire_functie IN VARCHAR2
  );

  PROCEDURE Sterge_Functie(
    id_functie IN NUMBER
  );

END Pachet_Functii;
/

CREATE OR REPLACE PACKAGE BODY Pachet_Functii IS

  PROCEDURE Adauga_Functie(
    id_functie IN NUMBER,
    denumire_functie IN VARCHAR2
  ) IS
    functie_exista EXCEPTION;
    PRAGMA EXCEPTION_INIT(functie_exista, -00001);
  BEGIN
    INSERT INTO Functii (id_functie, denumire_functie) VALUES (id_functie, denumire_functie);
    DBMS_OUTPUT.PUT_LINE('Inregistrare adaugata cu succes in tabela Functii.');
  EXCEPTION
    WHEN functie_exista THEN
      DBMS_OUTPUT.PUT_LINE('Exista deja o functie cu id-ul specificat in tablea Functii.');
  END Adauga_Functie;

  PROCEDURE Modifica_Denumire_Functie(
    id_functie IN NUMBER,
    noua_denumire_functie IN VARCHAR2
  ) IS
    functie_negasita EXCEPTION;
  BEGIN
    UPDATE Functii SET denumire_functie = noua_denumire_functie WHERE id_functie = id_functie;
    IF SQL%ROWCOUNT = 0 THEN
      RAISE functie_negasita;
    ELSE
      DBMS_OUTPUT.PUT_LINE('Denumirea functiei a fost modificata cu succes.');
    END IF;
  EXCEPTION
    WHEN functie_negasita THEN
      DBMS_OUTPUT.PUT_LINE('Functia cu id-ul specificat nu a fost gasita in tabela Functii.');
  END Modifica_Denumire_Functie;

  PROCEDURE Sterge_Functie(
    id_functie IN NUMBER
  ) IS
    functie_negasita EXCEPTION;
  BEGIN
    DELETE FROM Functii WHERE id_functie = id_functie;
    IF SQL%ROWCOUNT = 0 THEN
      RAISE functie_negasita;
    ELSE
      DBMS_OUTPUT.PUT_LINE('Functia a fost stearsa cu succes.');
    END IF;
  EXCEPTION
    WHEN functie_negasita THEN
      DBMS_OUTPUT.PUT_LINE('Functia cu id-ul specificat nu a fost gasita in tabela Functii.');
  END Sterge_Functie;

END Pachet_Functii;
/

BEGIN
  Pachet_Functii.Adauga_Functie('33', 'Functia sef');
  
  Pachet_Functii.Modifica_Denumire_Functie('33', 'Functia director');
  
  Pachet_Functii.Sterge_Functie('33');
END;
/
ROLLBACK;
