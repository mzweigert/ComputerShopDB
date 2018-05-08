-- AUTOR : MATEUSZ ZWEIGERT
  

CREATE OR REPLACE TYPE DOST_TOWAR_OBJ IS OBJECT (magazyn_id INTEGER, magazyn_opis VARCHAR2(200), towar_ilosc INTEGER, adres_kod VARCHAR2(10), adres_dane VARCHAR2(200));
CREATE OR REPLACE TYPE DOST_TOWAR_TAB IS TABLE OF DOST_TOWAR_OBJ;
create or replace TYPE RABAT_OBJ IS OBJECT (termin_waznosci DATE , procent INTEGER, wykorzystany CHAR(1), Klient_id INTEGER, Towar_id INTEGER) ;
create or replace TYPE PRACOWNIK_OBJ IS OBJECT (imie VARCHAR2(200) , nazwisko VARCHAR2(200), pesel CHAR (11 CHAR), pensja NUMBER(10,2)  , nr_ubezpieczenia CHAR (15) , NIP CHAR(15)) ;
create or replace TYPE UMOWA_OBJ IS OBJECT (data_podpisania DATE , data_zakonczenia DATE , typ VARCHAR2(20), aktualna CHAR(1)) ;

CREATE OR REPLACE PACKAGE baza IS
  FUNCTION CZY_KLIENT_AKTYWNY(p_klient_id INTEGER) RETURN BOOLEAN;
  FUNCTION ILOSC_WYSTAWIONYCH_FAKTUR(p_pracownik_id INTEGER, p_data_od DATE) RETURN INT ;
  FUNCTION ILOSC_WYSTAWIONYCH_FAKTUR(p_pracownik_id INTEGER, p_data_od DATE, p_data_do DATE) RETURN INT ;
  FUNCTION MIESIAC_STRING(p_data DATE) RETURN VARCHAR2;
  FUNCTION SUMA_DO_ZAPLACENIA(Zamow_Id INTEGER) RETURN NUMBER;
  FUNCTION CZY_TOWAR_DOSTEPNY_MIESCIE(p_towar_id INTEGER, p_miasto VARCHAR2, p_kod CHAR) RETURN DOST_TOWAR_TAB;
  PROCEDURE ZAREJESTRUJ (p_login VARCHAR2, p_haslo VARCHAR2, p_imie VARCHAR2,p_nazwisko VARCHAR2);
  PROCEDURE ZAREJESTRUJ (p_login VARCHAR2, p_haslo VARCHAR2, p_imie VARCHAR2,p_nazwisko VARCHAR2, p_pesel CHAR);
  PROCEDURE KUP_TOWAR (p_towar_id INTEGER, p_klient_id INTEGER, p_ilosc INTEGER);
  PROCEDURE PRZYZNAJ_PREMIE (p_pracownik_id INTEGER, p_wysokosc NUMBER);
  PROCEDURE ZATRUDNIJ_PRACOWNIKA (p_pracownik PRACOWNIK_OBJ, p_umowa UMOWA_OBJ);
  PROCEDURE PRZYZNAJ_RABAT (p_rabat RABAT_OBJ);
END baza;
  SHOW ERRORS;
  
CREATE OR REPLACE PACKAGE BODY baza AS


-- FUNKCJA ZWRACA TRUE JESLI KLIENT W CIAGU OSTATNIEGO POLROCZA KUPIL COS W SKLEPIE LUB FALSE JESLI NIE
  FUNCTION CZY_KLIENT_AKTYWNY(p_klient_id INTEGER)
  RETURN BOOLEAN IS
    v_istnieje CHAR(1) := '0';
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

-------------------------------------------------------------------------------------------------------------------
-- FUNKCJA ZWRACA SUME DO ZAPLACENIA DLA PODANEGO ID ZAMOWIENIA BIORACA POD UWAGE PRZYZNANE RABATY
  
  FUNCTION SUMA_DO_ZAPLACENIA(Zamow_Id INTEGER)
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

-------------------------------------------------------------------------------------------------------------------
-- FUNKCJA ZWRACA TABELE Z MAGAZYNAMI I ICH ADRESAMI W KTÓRYCH ZNAJDUJE SIÊ TOWAR O DANYM ID


FUNCTION CZY_TOWAR_DOSTEPNY_MIESCIE(p_towar_id INTEGER, p_miasto VARCHAR2, p_kod CHAR)
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
  
-------------------------------------------------------------------------------------------------------------------
-- FUNKCJA ZWRACA ILOSC WYSTAWIONYCH FAKTUR PRZEZ PRACOWNIKA OD ZADANIEJ DATY DO DZIS
FUNCTION ILOSC_WYSTAWIONYCH_FAKTUR(p_pracownik_id INTEGER, p_data_od DATE)
RETURN INT AS
  v_i INTEGER := 0;
BEGIN
  SELECT COUNT(*) INTO v_i FROM PRACOWNIK p INNER JOIN FAKTURA_VAT f ON p.id = f.pracownik_id
  WHERE p.id = p_pracownik_id AND f.data_wystawienia >= p_data_od;
  RETURN v_i;
END;

 -- PRZECIAZANA FUNKCJA
FUNCTION ILOSC_WYSTAWIONYCH_FAKTUR(p_pracownik_id INTEGER, p_data_od DATE, p_data_do DATE )
RETURN INT AS
  v_i INTEGER := 0;
BEGIN
  SELECT COUNT(*) INTO v_i FROM PRACOWNIK p INNER JOIN FAKTURA_VAT f ON p.id = f.pracownik_id
  WHERE p.id = p_pracownik_id AND f.data_wystawienia BETWEEN p_data_od AND p_data_do;
  RETURN v_i;
END;


-------------------------------------------------------------------------------------------------------------------
-- FUNKCJA ZWRACA MIESIAC W JEZYKU POLSKIM PO PARAMETRZE DATY
FUNCTION MIESIAC_STRING(p_data DATE) 
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

-- -------------------------------------- PROCEDURY

PROCEDURE ZAREJESTRUJ (
p_login VARCHAR2,
p_haslo VARCHAR2,
p_imie VARCHAR2,
p_nazwisko VARCHAR2) IS

v_osoba Osoba%ROWTYPE;
v_id Klient.id%TYPE;
v_istnieje CHAR(1);
v_haslo Konto.haslo%TYPE;
v_salt Konto.salt%TYPE := 'AFs31235zGSGsxAD323d';
BEGIN
  SELECT COUNT(1) INTO v_istnieje FROM Konto WHERE login = p_login;
  
  IF v_istnieje = 1 THEN
    SYS.DBMS_OUTPUT.PUT_LINE('Konto o loginie : ' || p_login || ' istnieje w systemie');
    RETURN;
  END IF;
  
  v_haslo := DBMS_OBFUSCATION_TOOLKIT.MD5(INPUT_STRING => UPPER(p_login) || v_salt || UPPER(p_haslo));
  SELECT * INTO v_osoba FROM Osoba WHERE imie = p_imie AND nazwisko = p_nazwisko;
  INSERT INTO Klient (ID, DATA_DOLACZENIA) VALUES (v_osoba.id, SYSDATE) RETURNING id INTO v_id;
  INSERT INTO Konto (KLIENT_ID, LOGIN, HASLO, SALT, DATA_ZALOZENIA) VALUES (v_id, p_login, v_haslo, v_salt, SYSDATE);
  EXCEPTION 
    WHEN NO_DATA_FOUND THEN
      INSERT INTO OSOBA(IMIE, NAZWISKO) VALUES (p_imie, p_nazwisko) 
      RETURNING id INTO v_osoba.id;
      INSERT INTO Klient (ID, DATA_DOLACZENIA) VALUES (v_osoba.id, SYSDATE) RETURNING id INTO v_id;
      INSERT INTO Konto (KLIENT_ID, LOGIN, HASLO, SALT, DATA_ZALOZENIA) VALUES (v_id, p_login, v_haslo, v_salt, SYSDATE);
END;


PROCEDURE ZAREJESTRUJ (
p_login VARCHAR2,
p_haslo VARCHAR2,
p_imie VARCHAR2,
p_nazwisko VARCHAR2,
p_pesel CHAR) IS

v_osoba Osoba%ROWTYPE;
v_id Klient.id%TYPE;
v_istnieje CHAR(1);
v_haslo Konto.haslo%TYPE;
v_salt Konto.salt%TYPE := 'AFs31235zGSGsxAD323d';
BEGIN
  SELECT COUNT(1) INTO v_istnieje FROM Konto WHERE login = p_login;
  
  IF v_istnieje = 1 THEN
    SYS.DBMS_OUTPUT.PUT_LINE('Konto o loginie : ' || p_login || ' istnieje w systemie');
    RETURN;
  END IF;
  
  v_haslo := DBMS_OBFUSCATION_TOOLKIT.MD5(INPUT_STRING => UPPER(p_login) || v_salt || UPPER(p_haslo));
  SELECT * INTO v_osoba FROM Osoba WHERE imie = p_imie AND nazwisko = p_nazwisko;
  INSERT INTO Klient (ID, DATA_DOLACZENIA) VALUES (v_osoba.id, SYSDATE) RETURNING id INTO v_id;
  INSERT INTO Konto (KLIENT_ID, LOGIN, HASLO, SALT, DATA_ZALOZENIA) VALUES (v_id, p_login, v_haslo, v_salt, SYSDATE);
  EXCEPTION 
    WHEN NO_DATA_FOUND THEN
      INSERT INTO OSOBA(IMIE, NAZWISKO, PESEL) VALUES (p_imie, p_nazwisko, p_pesel) 
      RETURNING id INTO v_osoba.id;
      INSERT INTO Klient (ID, DATA_DOLACZENIA) VALUES (v_osoba.id, SYSDATE) RETURNING id INTO v_id;
      INSERT INTO Konto (KLIENT_ID, LOGIN, HASLO, SALT, DATA_ZALOZENIA) VALUES (v_id, p_login, v_haslo, v_salt, SYSDATE);
END;


PROCEDURE KUP_TOWAR (
p_towar_id INTEGER,
p_klient_id INTEGER,
p_ilosc INTEGER) IS

v_istnieje CHAR(1);
v_z_id Zamowienie.id%TYPE;
v_zht Zamowienie_has_Towar%ROWTYPE;
v_mht Magazyn_has_Towar%ROWTYPE;
BEGIN

  SELECT COUNT(1) INTO v_istnieje FROM TOWAR WHERE id = p_towar_id;
  IF v_istnieje = 0 THEN
    SYS.DBMS_OUTPUT.PUT_LINE('Towar o id : ' || p_towar_id || ' nie istnieje w systemie');
    RETURN;
  END IF;
  SELECT COUNT(1) INTO v_istnieje FROM Klient WHERE id = p_klient_id;
  IF v_istnieje = 0 THEN
    SYS.DBMS_OUTPUT.PUT_LINE('Klient o id : ' || p_klient_id || ' nie istnieje w systemie');
    RETURN;
  END IF;
  BEGIN
    SELECT * INTO v_mht FROM MAGAZYN_HAS_TOWAR m WHERE m.towar_id = p_towar_id AND m.ilosc >= 1 AND ROWNUM = 1;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        SYS.DBMS_OUTPUT.PUT_LINE('Brak towaru w danej ilosci w magazynie');
        RETURN;
  END;
  BEGIN
    SELECT z.id INTO v_z_id FROM Zamowienie z WHERE z.oplacone = 0 AND z.zrealizowane = 0 and z.klient_id = p_klient_id AND ROWNUM = 1 ORDER BY z.id DESC ;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        INSERT INTO ZAMOWIENIE(DATA_ZAMOWIENIA, ZREALIZOWANE, OPLACONE, KLIENT_ID) VALUES (SYSDATE, '0', '0', p_klient_id) RETURNING id INTO v_z_id;
  END;  
 
  BEGIN
    SELECT * INTO v_zht FROM Zamowienie_has_Towar zht WHERE zht.zamowienie_id = v_z_id AND zht.towar_id = p_towar_id;
    UPDATE Zamowienie_has_Towar zht SET zht.ilosc = zht.ilosc + p_ilosc WHERE zht.zamowienie_id = v_zht.zamowienie_id AND zht.towar_id = v_zht.towar_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        INSERT INTO ZAMOWIENIE_HAS_TOWAR(ZAMOWIENIE_ID, TOWAR_ID, ILOSC) VALUES (v_z_id, p_towar_id, p_ilosc);
  END;
 
  UPDATE MAGAZYN_HAS_TOWAR SET ILOSC = ILOSC - 1 WHERE towar_id = v_mht.towar_id AND magazyn_id = v_mht.magazyn_id AND IlOSC > 0; 
  SYS.DBMS_OUTPUT.PUT_LINE('Poprawnie dodano towar o id = ' || p_towar_id || ' do zamowienia');
END;

PROCEDURE PRZYZNAJ_PREMIE (
p_pracownik_id INTEGER,
p_wysokosc NUMBER) IS

v_istnieje CHAR(1);
v_ilosc_faktur INTEGER;
v_pensja PRACOWNIK.pensja%TYPE;
BEGIN

  SELECT COUNT(1) INTO v_istnieje FROM PRACOWNIK WHERE id = p_pracownik_id;
  IF v_istnieje = 0 THEN
    SYS.DBMS_OUTPUT.PUT_LINE('Pracownik o id : ' || p_pracownik_id || ' nie istnieje w systemie');
    RETURN;
  END IF;
  
  SELECT COUNT(1) INTO v_istnieje FROM Umowa WHERE pracownik_id = p_pracownik_id AND aktualna = '1';
  IF v_istnieje = 0 THEN
    SYS.DBMS_OUTPUT.PUT_LINE('Pracownik o id : ' || p_pracownik_id || ' nie ma aktualnej umowy');
    RETURN;
  END IF;
  
  v_ilosc_faktur := ILOSC_WYSTAWIONYCH_FAKTUR(p_pracownik_id, ADD_MONTHS(SYSDATE, - 6));
  IF v_ilosc_faktur = 0 THEN
     SYS.DBMS_OUTPUT.PUT_LINE('Pracownik o id : ' || p_pracownik_id || ' nie dokonal zadnej tranzakcji w ostatnim pólroczu');
     RETURN;
  END IF;
  
  SELECT COUNT(1) INTO v_istnieje FROM PREMIA p WHERE p.pracownik_id = p_pracownik_id AND p.miesiac = MIESIAC_STRING(SYSDATE) AND p.rok = EXTRACT (YEAR FROM SYSDATE);
    IF v_istnieje = 1 THEN
    SYS.DBMS_OUTPUT.PUT_LINE('Premia za miesiac ' || MIESIAC_STRING(SYSDATE) || ', rok ' || EXTRACT (YEAR FROM SYSDATE) || ' zostala juz przyznana' );
    RETURN;
  END IF;
  
  SELECT p.pensja INTO v_pensja FROM Pracownik p WHERE p.id = p_pracownik_id;
  IF v_pensja <= p_wysokosc THEN
   SYS.DBMS_OUTPUT.PUT_LINE('Premia nie mo¿e wynosic wiecej niz pensja pracownika');
     RETURN;
  END IF;   
 INSERT INTO PREMIA(WARTOSC, MIESIAC, ROK, PRACOWNIK_ID) VALUES (p_wysokosc, MIESIAC_STRING(SYSDATE), EXTRACT (YEAR FROM SYSDATE), p_pracownik_id);
 
END;


PROCEDURE ZATRUDNIJ_PRACOWNIKA (
p_pracownik PRACOWNIK_OBJ,
p_umowa UMOWA_OBJ) IS
v_pracownik PRACOWNIK%ROWTYPE;
v_osoba Osoba%ROWTYPE;
BEGIN

  BEGIN
    SELECT * INTO v_osoba FROM Osoba WHERE pesel = p_pracownik.pesel;
      EXCEPTION 
        WHEN NO_DATA_FOUND THEN
          INSERT INTO OSOBA(IMIE, NAZWISKO, PESEL) VALUES (p_pracownik.imie, p_pracownik.nazwisko, p_pracownik.pesel) 
          RETURNING id INTO v_osoba.id;
  END;
  BEGIN
     SELECT * INTO v_pracownik FROM PRACOWNIK WHERE id = v_osoba.id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          INSERT INTO PRACOWNIK(ID, PENSJA, NR_UBEZPIECZENIA, NIP) VALUES (v_osoba.id, p_pracownik.pensja, p_pracownik.nr_ubezpieczenia, p_pracownik.NIP) RETURNING id INTO v_pracownik.id; 
  END;
  
  INSERT INTO UMOWA(PRACOWNIK_ID, DATA_PODPISANIA, DATA_ZAKONCZENIA, TYP, AKTUALNA) VALUES (v_pracownik.id, p_umowa.data_podpisania, p_umowa.data_zakonczenia, p_umowa.typ, '1'); 
 
END;

    
PROCEDURE PRZYZNAJ_RABAT (
p_rabat RABAT_OBJ) IS
v_istnieje CHAR(1);
v_aktyw BOOLEAN;
BEGIN
  v_aktyw := CZY_KLIENT_AKTYWNY(p_rabat.klient_id);
  IF v_aktyw THEN
    SELECT COUNT(1) INTO v_istnieje FROM MAGAZYN_HAS_TOWAR WHERE towar_id = p_rabat.towar_id AND ilosc > 0 AND ROWNUM = 1;
    IF v_istnieje = 1 THEN
      INSERT INTO RABAT(TERMIN_WAZNOSCI, PROCENT, WYKORZYSTANY, KLIENT_ID, TOWAR_ID) VALUES(p_rabat.termin_waznosci, p_rabat.procent, p_rabat.wykorzystany, p_rabat.klient_id, p_rabat.towar_id);
      SYS.DBMS_OUTPUT.PUT_LINE('Poprawnie przyznano rabat klientowi');
      RETURN;
    END IF;
    SYS.DBMS_OUTPUT.PUT_LINE('Brak towaru w magazynie');
    RETURN;
  END IF;
  SYS.DBMS_OUTPUT.PUT_LINE('Nie mo¿na przyznaæ rabatu niekatywnemu u¿ytkownikowi');
END;

END baza;

/
DECLARE
v_akt BOOLEAN;
v_id INTEGER;
BEGIN 
  SELECT z.klient_id INTO v_id FROM Zamowienie z WHERE
  z.oplacone = 1 AND z.data_zamowienia BETWEEN ADD_MONTHS(SYSDATE, -6) AND SYSDATE AND ROWNUM = 1;
 
  v_akt := baza.CZY_KLIENT_AKTYWNY(v_id);
  IF v_akt THEN
    DBMS_OUTPUT.put_line('AKTYWNY');
  ELSE
    DBMS_OUTPUT.put_line('NIEAKTYWNY');
  END IF;
END;

/

DECLARE 
  v_ret NUMBER(10, 2) := 0;
  v_z_id INTEGER;
BEGIN 
  SELECT id INTO v_z_id FROM ZAMOWIENIE WHERE OPLACONE = 1 AND ROWNUM =1;
  v_ret := baza.SUMA_DO_ZAPLACENIA(v_z_id);
  DBMS_OUTPUT.put_line(v_ret);
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
  FOR r IN (SELECT * FROM TABLE (baza.CZY_TOWAR_DOSTEPNY_MIESCIE(v_id, 'miastoTEST', '123')))
  LOOP
    DBMS_OUTPUT.PUT_LINE('magazynId = ' || r.magazyn_id || ', magazyn_opis = ' || r.magazyn_opis || ', towar_ilosc = ' || r.towar_ilosc || ', adres_kod = ' || r.adres_kod || ', adres_dane = ' || r.adres_dane);
  END LOOP;
END;
  /
DECLARE
v_id INTEGER;
BEGIN
  SELECT id INTO v_id FROM PRACOWNIK p LEFT JOIN FAKTURA_VAT fv ON p.id=fv.pracownik_id WHERE fv.ZAMOWIENIE_ID IS NOT NULL AND ROWNUM = 1;
  SYS.DBMS_OUTPUT.PUT_LINE(baza.ILOSC_WYSTAWIONYCH_FAKTUR(v_id, ADD_MONTHS(SYSDATE, -6)));
END;

/
BEGIN
  SYS.DBMS_OUTPUT.PUT_LINE(baza.MIESIAC_STRING('2012-12-01'));
  -- grudzieñ
END;

/
BEGIN
  baza.ZAREJESTRUJ('mzweigert', 'tajnehaslo', 'Mateusz', 'Zweigert');
  FOR r IN (SELECT o.imie, o.nazwisko, ko.login, ko.haslo FROM Osoba o JOIN Klient k on o.id=k.id JOIN Konto ko on ko.klient_id=k.id WHERE o.imie = 'Mateusz' AND o.nazwisko = 'Zweigert')
  LOOP
    SYS.DBMS_OUTPUT.PUT_LINE('imie = ' || r.imie || ', nazwisko=' || r.nazwisko || ', login=' || r.login || ', haslo=' || r.haslo);
  END LOOP;
END;
/
DECLARE
v_zht ZAMOWIENIE_HAS_TOWAR%ROWTYPE;
v_k_id INTEGER;
v_t_id INTEGER;
BEGIN
  SELECT id INTO v_k_id FROM KLIENT WHERE ROWNUM = 1;
  SELECT id INTO v_t_id FROM TOWAR WHERE ROWNUM = 1 ORDER BY ID DESC;
  baza.KUP_TOWAR(v_t_id, v_k_id, 11);

  FOR r IN (SELECT zht.*, z.* FROM ZAMOWIENIE_HAS_TOWAR zht 
            JOIN ZAMOWIENIE z on zht.zamowienie_id=z.id 
            WHERE  z.klient_id = 5 AND z.zrealizowane ='0' 
            AND z.oplacone ='0'  AND zht.towar_id = 6 AND ROWNUM = 1)
  LOOP
    SYS.DBMS_OUTPUT.PUT_LINE('towarId=' || r.towar_id || ', klientId = ' || r.klient_id || ', zamowienieId = ' || r.zamowienie_id || ', ilosc= ' || r.ilosc);
  END LOOP;

END;
/
DECLARE
v_p PRACOWNIK%ROWTYPE;
v_premia PREMIA%ROWTYPE;
BEGIN
  SELECT pra.* INTO v_p FROM PRACOWNIK pra JOIN PREMIA pre ON pra.id=pre.pracownik_id WHERE ILOSC_WYSTAWIONYCH_FAKTUR(pra.id, ADD_MONTHS(SYSDATE, - 6)) > 0 AND ROWNUM = 1;
  DELETE FROM PREMIA p WHERE p.pracownik_id = v_p.id AND p.miesiac = MIESIAC_STRING(SYSDATE) AND p.rok = EXTRACT (YEAR FROM SYSDATE);
  baza.PRZYZNAJ_PREMIE(v_p.id, v_p.pensja - 100);
  SELECT * INTO v_premia FROM PREMIA WHERE pracownik_id = v_p.id AND miesiac = MIESIAC_STRING(SYSDATE) AND rok = EXTRACT (YEAR FROM SYSDATE);
  SYS.DBMS_OUTPUT.PUT_LINE('pracownikId = ' || v_p.id || ', premiaId=' || v_premia.id || ', wartosc=' || v_premia.wartosc );
END;

/
DECLARE
v_prac PRACOWNIK_OBJ;
v_umowa UMOWA_OBJ;
BEGIN
  v_prac := PRACOWNIK_OBJ('pracownik_test', 'nazwisko_test', '93070111111', 1666.54, '13123125SDF234', '12323526246246');
  v_umowa := UMOWA_OBJ (SYSDATE, ADD_MONTHS(SYSDATE, 12), 'B2B', 1); 
  baza.ZATRUDNIJ_PRACOWNIKA(v_prac, v_umowa);
  FOR r IN (SELECT u.id as umowaId, p.id as pracownikId, o.imie, o.nazwisko FROM PRACOWNIK p LEFT JOIN OSOBA o ON o.id = p.id 
            JOIN UMOWA u on p.id=u.pracownik_id WHERE o.imie = 'pracownik_test' 
            AND o.nazwisko = 'nazwisko_test' AND o.pesel = '93070111111' AND u.aktualna = 1 AND ROWNUM = 1)
  LOOP
     DBMS_OUTPUT.PUT_LINE('pracownik_id = ' || r.pracownikId || ', imie = ' || r.imie || ', nazwisko = ' || r.nazwisko || ', umowa_id = ' || r.umowaId);
  END LOOP;
END;
/

DECLARE
v_id_t TOWAR.id%TYPE;
v_id_k KLIENT.id%TYPE;
BEGIN
  SELECT towar_id INTO v_id_t FROM MAGAZYN_HAS_TOWAR WHERE ilosc > 0 AND ROWNUM = 1;
  SELECT klient_id INTO v_id_k FROM Zamowienie z 
  WHERE z.oplacone = 1 AND z.data_zamowienia BETWEEN ADD_MONTHS(SYSDATE, -6) AND SYSDATE AND ROWNUM = 1; 
  baza.PRZYZNAJ_RABAT(RABAT_OBJ(ADD_MONTHS(SYSDATE, 6), 20, 0, v_id_k, v_id_t));
  FOR r IN (SELECT ra.* FROM Rabat ra WHERE ra.KLIENT_ID = v_id_k AND ra.TOWAR_ID = v_id_t AND ROWNUM = 1 ORDER BY ra.ID DESC)
  LOOP
    SYS.DBMS_OUTPUT.PUT_LINE('klientId=' || r.klient_id || ', towarId=' || r.towar_id || ', termin_waz=' || r.termin_waznosci || ', procent=' || r.procent);
  END LOOP;
END;
 
