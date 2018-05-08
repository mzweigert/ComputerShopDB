-- AUTOR : MATEUSZ ZWEIGERT
  

SET SERVEROUTPUT ON;
-- FUNKCJA ZWRACA TRUE JESLI KLIENT W CIAGU OSTATNIEGO POLROCZA KUPIL COS W SKLEPIE LUB FALSE JESLI NIE
CREATE OR REPLACE FUNCTION CZY_KLIENT_AKTYWNY(p_klient_id INTEGER)
RETURN BOOLEAN IS
  v_istnieje CHAR(1);
BEGIN

 SELECT COUNT(1) INTO v_istnieje FROM Klient k WHERE k.ID = p_klient_id;
 IF v_istnieje = 0 THEN
     SYS.DBMS_OUTPUT.PUT_LINE('Klient o id : ' || p_klient_id || ' nie istnieje w systemie');
    RETURN FALSE;
 END IF;
 
 SELECT COUNT(1) INTO v_istnieje FROM Zamowienie z 
 WHERE z.klient_id = p_klient_id AND 
 z.oplacone = 1 AND 
 z.data_zamowienia BETWEEN ADD_MONTHS(SYSDATE, -6) AND SYSDATE ;
 
 IF v_istnieje = 1 THEN
    RETURN TRUE;
 ELSE 
    RETURN FALSE;
 END IF;

END;
/
DECLARE
v_akt BOOLEAN;
v_id INTEGER;
BEGIN 
  SELECT z.klient_id INTO v_id FROM Zamowienie z WHERE
  z.oplacone = 1 AND z.data_zamowienia BETWEEN ADD_MONTHS(SYSDATE, -6) AND SYSDATE AND ROWNUM = 1;
 
  v_akt := CZY_KLIENT_AKTYWNY(v_id);
  IF v_akt THEN
    DBMS_OUTPUT.put_line('AKTYWNY');
  ELSE
    DBMS_OUTPUT.put_line('NIEAKTYWNY');
  END IF;
END;

-------------------------------------------------------------------------------------------------------------------
-- FUNKCJA ZWRACA SUME DO ZAPLACENIA DLA PODANEGO ID ZAMOWIENIA BIORACA POD UWAGE PRZYZNANE RABATY

CREATE OR REPLACE FUNCTION SUMA_DO_ZAPLACENIA(Zamow_Id INTEGER)
RETURN NUMBER IS
  v_ilosc Zamowienie_has_Towar.ilosc%TYPE;
  v_cena Towar.cena%TYPE;
  v_k_id KLIENT.id%TYPE;
  v_t_id TOWAR.id%TYPE;
  v_procent RABAT.procent%TYPE;
  v_suma NUMBER(10, 2) := 0;
  CURSOR cur_suma IS 
  SELECT zht.ilosc, t.id, t.cena FROM Zamowienie_has_Towar zht 
  JOIN Towar t on zht.towar_Id=t.id 
  WHERE zht.zamowienie_Id = Zamow_Id;
BEGIN
  SELECT klient_id INTO v_k_id FROM ZAMOWIENIE WHERE id = Zamow_id;
  OPEN cur_suma;
  LOOP
   FETCH cur_suma INTO v_ilosc, v_t_id, v_cena;
   EXIT WHEN cur_suma%NOTFOUND;
   BEGIN
     SELECT procent INTO v_procent FROM RABAT where klient_id = v_k_id AND towar_id = v_t_id AND termin_waznosci > SYSDATE AND wykorzystany = 0;
     v_suma := v_suma + (v_ilosc * (v_cena * (1 - (v_procent / 100 ))));
     EXCEPTION
      WHEN NO_DATA_FOUND THEN
           v_suma := v_suma + (v_ilosc * v_cena);
   END;
  END LOOP;
  CLOSE cur_suma;
  RETURN v_suma;
END;

DECLARE 
  v_ret NUMBER(10, 2) := 0;
  v_z_id INTEGER;
BEGIN 
  SELECT id INTO v_z_id FROM ZAMOWIENIE WHERE OPLACONE = 1 AND ROWNUM =1;
  v_ret := SUMA_DO_ZAPLACENIA(v_z_id);
  DBMS_OUTPUT.put_line(v_ret);
END;

-------------------------------------------------------------------------------------------------------------------
-- FUNKCJA ZWRACA TABELE Z MAGAZYNAMI I ICH ADRESAMI W KTÓRYCH ZNAJDUJE SIÊ TOWAR O DANYM ID
DROP TYPE DOST_TOWAR_TAB;
DROP TYPE DOST_TOWAR_OBJ;
/
create or replace TYPE DOST_TOWAR_OBJ IS OBJECT (magazyn_id INTEGER, magazyn_opis VARCHAR2(200), towar_ilosc INTEGER, adres_kod VARCHAR2(10), adres_dane VARCHAR2(200));
/
create or replace TYPE DOST_TOWAR_TAB IS TABLE OF DOST_TOWAR_OBJ;
/

CREATE OR REPlACE FUNCTION CZY_TOWAR_DOSTEPNY_MIESCIE(p_towar_id INTEGER, p_miasto VARCHAR2, p_kod CHAR)
RETURN DOST_TOWAR_TAB AS
  v_dost_towar_tab DOST_TOWAR_TAB := DOST_TOWAR_TAB();
  v_i INTEGER := 0;
BEGIN
 FOR r IN ( SELECT m.id, m.opis, mht.ilosc, a.kod, a.ulica, a.miasto, a.numer FROM Magazyn m 
    JOIN Magazyn_has_Towar mht ON m.id=mht.magazyn_id 
    JOIN Adres a ON a.id=m.adres_id
    WHERE a.miasto = p_miasto AND a.kod = p_kod AND mht.towar_id = p_towar_id
    ORDER BY mht.ilosc DESC )
    LOOP
       v_dost_towar_tab.EXTEND();
      v_i := v_i + 1;
      v_dost_towar_tab(v_i) := DOST_TOWAR_OBJ(r.id, r.opis, r.ilosc, r.kod, r.miasto || ' ' || r.ulica || ' ' || r.numer );
    END LOOP;
  
  RETURN v_dost_towar_tab;
END;
/
DECLARE
  v_id INTEGER;
  v_id_m INTEGER;
BEGIN
  INSERT INTO ADRES(ULICA, MIASTO, NUMER, KOD) VALUES ('ulicaTEST' , 'miastoTEST' , 'numerTEST' , '12-123') RETURNING id INTO v_id;
  INSERT INTO MAGAZYN(ADRES_ID, OPIS) VALUES(v_id, 'magazyn2') RETURNING id INTO v_id_m;
  INSERT INTO TOWAR(NAZWA, DATA_PRODUKCJI, NUMER_SERYJNY, CENA, KATEGORIA_ID, PRODUCENT_ID) VALUES ('KOMPUTER', SYSDATE, '000000000000001', 1000, 1, 1) RETURNING id INTO v_id;
  INSERT INTO MAGAZYN_HAS_TOWAR VALUES(v_id_m, v_id, 100);
  FOR r IN (SELECT * FROM TABLE (CZY_TOWAR_DOSTEPNY_MIESCIE(v_id, 'miastoTEST', '123')))
  LOOP
    DBMS_OUTPUT.PUT_LINE('magazynId = ' || r.magazyn_id || ', magazyn_opis = ' || r.magazyn_opis || ', towar_ilosc = ' || r.towar_ilosc || ', adres_kod = ' || r.adres_kod || ', adres_dane = ' || r.adres_dane);
  END LOOP;
END;
  
-------------------------------------------------------------------------------------------------------------------
-- FUNKCJA ZWRACA ILOSC WYSTAWIONYCH FAKTUR PRZEZ PRACOWNIKA OD ZADANIEJ DATY DO DZIS
CREATE OR REPLACE FUNCTION ILOSC_WYSTAWIONYCH_FAKTUR(p_pracownik_id INTEGER, p_data_od DATE)
RETURN INT AS
  
  v_i INTEGER := 0;
BEGIN
  SELECT COUNT(*) INTO v_i FROM PRACOWNIK p INNER JOIN FAKTURA_VAT f ON p.id = f.pracownik_id
  WHERE p.id = p_pracownik_id AND f.data_wystawienia >= p_data_od;
  RETURN v_i;
END;
/
DECLARE
v_id INTEGER;
BEGIN
  SELECT id INTO v_id FROM PRACOWNIK p LEFT JOIN FAKTURA_VAT fv ON p.id=fv.pracownik_id WHERE fv.ZAMOWIENIE_ID IS NOT NULL AND ROWNUM = 1;
  SYS.DBMS_OUTPUT.PUT_LINE(ILOSC_WYSTAWIONYCH_FAKTUR(v_id, ADD_MONTHS(SYSDATE, -6)));
END;
-------------------------------------------------------------------------------------------------------------------
-- FUNKCJA ZWRACA MIESIAC W JEZYKU POLSKIM PO PARAMETRZE DATY
CREATE OR REPLACE FUNCTION MIESIAC_STRING(p_data DATE) 
RETURN VARCHAR2 AS
  v_i INTEGER := 0;
BEGIN
  v_i := EXTRACT(MONTH FROM p_data);
  IF v_i = 1 THEN
    RETURN 'styczeñ';
  ELSIF v_i = 2 THEN
    RETURN 'luty';
  ELSIF v_i = 3 THEN
    RETURN 'marzec';
  ELSIF v_i = 4 THEN
    RETURN 'kwiecieñ';
  ELSIF v_i = 5 THEN
    RETURN 'maj';
  ELSIF v_i = 6 THEN
    RETURN 'czerwiec';
  ELSIF v_i = 7 THEN
    RETURN 'lipiec';
  ELSIF v_i = 8 THEN
    RETURN 'sierpieñ';
  ELSIF v_i = 9 THEN
    RETURN 'wrzesieñ';
   ELSIF v_i = 10 THEN
    RETURN 'paŸdziernik';
   ELSIF v_i = 11 THEN
    RETURN 'listopad'; 
  ELSIF v_i = 12 THEN
    RETURN 'grudzieñ';
  ELSE
    RETURN NULL;
  END IF;
END;
/
BEGIN
  SYS.DBMS_OUTPUT.PUT_LINE(MIESIAC_STRING('2012-12-01'));
  -- grudzieñ
END;
