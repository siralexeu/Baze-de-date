SET SERVEROUTPUT ON;
/*1. adaugare produs nou in tabela produsenet, modifica categoria produsului, afisare categorie si descriere completa a produsului*/
CREATE OR REPLACE PACKAGE Pachet_Produse AS
  PROCEDURE Adauga_Produs(
    id_produs IN NUMBER,
    denumire_produs IN VARCHAR2,
    descriere IN VARCHAR2,
    pret_unitar IN NUMBER,
    categorie IN VARCHAR2
  );

  PROCEDURE Modifica_Categorie_Produs(
    id_produs IN NUMBER,
    noua_categorie IN VARCHAR2
  );

  FUNCTION Categorie_Produs(
    id_produs IN NUMBER
  ) RETURN VARCHAR2;

  FUNCTION Descriere_Completa_Produs(
    id_produs IN NUMBER
  ) RETURN VARCHAR2;
END Pachet_Produse;
/
CREATE OR REPLACE PACKAGE BODY Pachet_Produse AS
  PROCEDURE Adauga_Produs(
    id_produs IN NUMBER,
    denumire_produs IN VARCHAR2,
    descriere IN VARCHAR2,
    pret_unitar IN NUMBER,
    categorie IN VARCHAR2
  ) IS
    produs_existent EXCEPTION;
    PRAGMA EXCEPTION_INIT(produs_existent, -00001);
  BEGIN
    INSERT INTO ProduseNet (id_produs, denumire_produs, descriere, pret_unitar, categorie)
    VALUES (id_produs, denumire_produs, descriere, pret_unitar, categorie);
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Inregistrare adaugata cu succes in tabela ProduseNet.');
  EXCEPTION
    WHEN produs_existent THEN
      DBMS_OUTPUT.PUT_LINE('Exista deja un produs cu id-ul specificat in tabela ProduseNet.');
  END Adauga_Produs;

  PROCEDURE Modifica_Categorie_Produs(
    id_produs IN NUMBER,
    noua_categorie IN VARCHAR2
  ) IS
    produs_negasit EXCEPTION;
  BEGIN
    UPDATE ProduseNet SET categorie = noua_categorie WHERE id_produs = id_produs;
    IF SQL%ROWCOUNT = 0 THEN
      RAISE produs_negasit;
    ELSE
      DBMS_OUTPUT.PUT_LINE('Categoria produsului a fost modificat? cu succes.');
    END IF;
  EXCEPTION
    WHEN produs_negasit THEN
      DBMS_OUTPUT.PUT_LINE('Produsul cu id-ul specificat nu a fost g?sit în tabela ProduseNet.');
  END Modifica_Categorie_Produs;

  FUNCTION Categorie_Produs(
    id_produs IN NUMBER
  ) RETURN VARCHAR2 IS
    categoria_produs VARCHAR2(100);
  BEGIN
    SELECT categorie INTO categoria_produs FROM ProduseNet WHERE id_produs = id_produs;
    RETURN categoria_produs;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN 'Produs inexistent';
    WHEN TOO_MANY_ROWS THEN
      RETURN 'Mai multe categorii g?site';
  END Categorie_Produs;

  FUNCTION Descriere_Completa_Produs(
    id_produs IN NUMBER
  ) RETURN VARCHAR2 IS
    descriere VARCHAR2(1000);
  BEGIN
    SELECT descriere INTO descriere FROM ProduseNet WHERE id_produs = id_produs;
    RETURN descriere;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN 'Produs inexistent';
    WHEN TOO_MANY_ROWS THEN
      RETURN 'Mai multe descrieri g?site';
  END Descriere_Completa_Produs;

END Pachet_Produse;
/
BEGIN
  Pachet_Produse.Adauga_Produs(11, 'Scaun', 'Scaun ergonimic', 300, 'Mobilier');
END;
/
DECLARE
  categoria_produs VARCHAR2(20);
BEGIN
  categoria_produs := Pachet_Produse.Categorie_Produs(11);
  DBMS_OUTPUT.PUT_LINE('Categoria produsului este: ' || categoria_produs);
END;
/
DECLARE
  descriere_completa VARCHAR2(30);
BEGIN
  descriere_completa := Pachet_Produse.Descriere_Completa_Produs(11);
  DBMS_OUTPUT.PUT_LINE('Descrierea completa a produsului este: ' || descriere_completa);
END;
/
BEGIN
  Pachet_Produse.Modifica_Categorie_Produs(11, 'electronice');
END;
/
rollback;
select * from produsenet;

/*2. Schimbare modalitate comanda din cash in ramburs*/
CREATE OR REPLACE PACKAGE Pachet_ModificareModalitate AS
  PROCEDURE Modifica_Modalitate_Comanda(
    id_comanda IN NUMBER,
    noua_modalitate IN VARCHAR2
  );
  
  FUNCTION Get_Modalitate_Comanda(
    id_comanda IN NUMBER
  ) RETURN VARCHAR2;
  
  FUNCTION Numara_Comenzi_Ramburs RETURN NUMBER;
END Pachet_ModificareModalitate;
/
CREATE OR REPLACE PACKAGE BODY Pachet_ModificareModalitate AS
  PROCEDURE Modifica_Modalitate_Comanda(
    id_comanda IN NUMBER,
    noua_modalitate IN VARCHAR2
  ) IS
    modalitate_invalida EXCEPTION;
  BEGIN
    IF noua_modalitate = 'Cash' THEN
      RAISE modalitate_invalida;
    END IF;
    UPDATE ComenziNet SET modalitate = noua_modalitate WHERE id_comanda = id_comanda;
    DBMS_OUTPUT.PUT_LINE('Modalitatea comenzii a fost schimbata cu succes in: ' || noua_modalitate);
  EXCEPTION
    WHEN modalitate_invalida THEN
      DBMS_OUTPUT.PUT_LINE('Nu se poate schimba modalitatea în "Cash".');
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('A intervenit o eroare. Modalitatea comenzii nu a fost modificcata.');
  END Modifica_Modalitate_Comanda;
  
  FUNCTION Get_Modalitate_Comanda(
    id_comanda IN NUMBER
  ) RETURN VARCHAR2 IS
    modalitate VARCHAR2(50);
  BEGIN
    SELECT modalitate INTO modalitate FROM ComenziNet WHERE id_comanda = id_comanda;
    RETURN modalitate;
  END Get_Modalitate_Comanda;
  
  FUNCTION Numara_Comenzi_Ramburs RETURN NUMBER IS
    nr_comenzi NUMBER;
  BEGIN
    SELECT COUNT(*) INTO nr_comenzi FROM ComenziNet WHERE modalitate = 'Ramburs';
    RETURN nr_comenzi;
  END Numara_Comenzi_Ramburs;
END Pachet_ModificareModalitate;
/
BEGIN
  Pachet_ModificareModalitate.Modifica_Modalitate_Comanda(1, 'Ramburs');
END;
/
/*3. înregistrarea unei noi comenzi ?i actualizarea cantit??ii stocului unui produs.
 calcularea totalului unei comenzi ?i verificarea disponibilit??ii în stoc a unui produs.*/
CREATE OR REPLACE PACKAGE Pachet_Utilitare IS
  PROCEDURE InregistreazaComanda(
    id_comanda IN NUMBER,
    data_comanda IN DATE,
    modalitate IN VARCHAR2,
    id_client IN NUMBER
  );

  FUNCTION CalculTotalComanda(id_comanda IN NUMBER) RETURN NUMBER;

  PROCEDURE ActualizeazaStoc(
    id_produs IN NUMBER,
    noua_cantitate IN NUMBER
  );

  FUNCTION VerificaDisponibilitateStoc(id_produs IN NUMBER) RETURN NUMBER;
END Pachet_Utilitare;
/
CREATE OR REPLACE PACKAGE BODY Pachet_Utilitare IS
  PROCEDURE InregistreazaComanda(
    id_comanda IN NUMBER,
    data_comanda IN DATE,
    modalitate IN VARCHAR2,
    id_client IN NUMBER
  ) IS
  BEGIN
    INSERT INTO ComenziNet (id_comanda, data_comanda, modalitate, id_client)
    VALUES (id_comanda, data_comanda, modalitate, id_client);
    COMMIT;
  END InregistreazaComanda;

  FUNCTION CalculTotalComanda(id_comanda IN NUMBER) RETURN NUMBER IS
    total NUMBER := 0;
  BEGIN
    SELECT SUM(cantitate * pret) INTO total FROM Produse_comenzi WHERE id_comanda = id_comanda;
    RETURN total;
  END CalculTotalComanda;

  PROCEDURE ActualizeazaStoc(
    id_produs IN NUMBER,
    noua_cantitate IN NUMBER
  ) IS
  BEGIN
    UPDATE StocNet SET cantitate_stoc = noua_cantitate WHERE id_produs = id_produs;
    COMMIT;
  END ActualizeazaStoc;

   FUNCTION VerificaDisponibilitateStoc(id_produs IN NUMBER) RETURN NUMBER IS
  disponibil NUMBER := 0;
BEGIN
  FOR rec IN (SELECT cantitate_stoc FROM StocNet WHERE id_produs = id_produs) LOOP
    disponibil := rec.cantitate_stoc;
    EXIT;
  END LOOP;
  RETURN disponibil;
END VerificaDisponibilitateStoc;

END Pachet_Utilitare;
/
BEGIN
  Pachet_Utilitare.InregistreazaComanda(15, SYSDATE, 'card', 1);
END;
/
DECLARE
  total_comanda NUMBER;
BEGIN
  total_comanda := Pachet_Utilitare.CalculTotalComanda(101);
  DBMS_OUTPUT.PUT_LINE('Totalul comenzii este: ' || total_comanda);
END;
/

BEGIN
  Pachet_Utilitare.ActualizeazaStoc(1, 50);
END;
/

DECLARE
  disponibilitate NUMBER;
BEGIN
  disponibilitate := Pachet_Utilitare.VerificaDisponibilitateStoc(1);
  IF disponibilitate > 0 THEN
    DBMS_OUTPUT.PUT_LINE('Produsul este disponibil în stoc.');
  ELSE
    DBMS_OUTPUT.PUT_LINE('Produsul nu este disponibil în stoc.');
  END IF;
END;
/


