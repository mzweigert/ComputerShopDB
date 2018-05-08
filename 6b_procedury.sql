-- AUTOR : MATEUSZ ZWEIGERT
  

-------------------------------------------------------------------------------------------------------------------
-- PROCEDURA ZAPISUJACA DANE KLIENTA DO BAZY Tj. JEGO DANE OSOBOWE ORAZ TWORZY DLA NIEGO KONTO DO LOGOWANIA
CREATE OR REPLACE PROCEDURE ZAREJESTRUJ (
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

BEGIN
  ZAREJESTRUJ('mzweigert', 'tajnehaslo', 'Mateusz', 'Zweigert');
  FOR r IN (SELECT o.imie, o.nazwisko, ko.login, ko.haslo FROM Osoba o JOIN Klient k on o.id=k.id JOIN Konto ko on ko.klient_id=k.id WHERE o.imie = 'Mateusz' AND o.nazwisko = 'Zweigert')
  LOOP
    SYS.DBMS_OUTPUT.PUT_LINE('imie = ' || r.imie || ', nazwisko=' || r.nazwisko || ', login=' || r.login || ', haslo=' || r.haslo);
  END LOOP;
END;
-------------------------------------------------------------------------------------------------------------------
-- PROCEDURA DODAJ¥CA TOWAR DO ZAMOWIENIA KTORE CHCE ZREALIZOWAÆ KLIENT

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
/
DECLARE
v_zht ZAMOWIENIE_HAS_TOWAR%ROWTYPE;
v_k_id INTEGER;
v_t_id INTEGER;
BEGIN
  SELECT id INTO v_k_id FROM KLIENT WHERE ROWNUM = 1;
  SELECT id INTO v_t_id FROM TOWAR WHERE ROWNUM = 1;
  KUP_TOWAR(v_t_id, v_k_id, 1);
  FOR r IN (SELECT zht.*, z.* FROM ZAMOWIENIE_HAS_TOWAR zht 
            JOIN ZAMOWIENIE z on zht.zamowienie_id=z.id 
            WHERE  z.klient_id = v_k_id AND z.zrealizowane ='0' 
            AND z.oplacone ='0'  AND zht.towar_id = v_t_id AND ROWNUM = 1)
  LOOP
    SYS.DBMS_OUTPUT.PUT_LINE('towarId=' || r.towar_id || ', klientId = ' || r.klient_id || ', zamowienieId = ' || r.zamowienie_id || ', ilosc= ' || r.ilosc);
  END LOOP;

END;

CREATE OR REPLACE PROCEDURE PRZYZNAJ_PREMIE (
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
/
DECLARE
v_p PRACOWNIK%ROWTYPE;
v_premia PREMIA%ROWTYPE;
BEGIN
  SELECT pra.* INTO v_p FROM PRACOWNIK pra JOIN PREMIA pre ON pra.id=pre.pracownik_id WHERE ILOSC_WYSTAWIONYCH_FAKTUR(pra.id, ADD_MONTHS(SYSDATE, - 6)) > 0 AND ROWNUM = 1;
  DELETE FROM PREMIA p WHERE p.pracownik_id = v_p.id AND p.miesiac = MIESIAC_STRING(SYSDATE) AND p.rok = EXTRACT (YEAR FROM SYSDATE);
  PRZYZNAJ_PREMIE(v_p.id, v_p.pensja - 100);
  SELECT * INTO v_premia FROM PREMIA WHERE pracownik_id = v_p.id AND miesiac = MIESIAC_STRING(SYSDATE) AND rok = EXTRACT (YEAR FROM SYSDATE);
  SYS.DBMS_OUTPUT.PUT_LINE('pracownikId = ' || v_p.id || ', premiaId=' || v_premia.id || ', wartosc=' || v_premia.wartosc );
END;

-------------------------------------------------------------------------------------------------------------------
-- PROCEDURA DODAJ¥CA DANE PRACOWNIKA DO BAZY TJ. DANE OSOBOWE ORAZ UMOWE KTOR¥ PODPISA£
create or replace TYPE PRACOWNIK_OBJ IS OBJECT (imie VARCHAR2(200) , nazwisko VARCHAR2(200), pesel CHAR (11 CHAR), pensja NUMBER(10,2)  , nr_ubezpieczenia CHAR (15) , NIP CHAR(15)) ;
/
create or replace TYPE UMOWA_OBJ IS OBJECT (data_podpisania DATE , data_zakonczenia DATE , typ VARCHAR2(20), aktualna CHAR(1)) ;
/

CREATE OR REPLACE PROCEDURE ZATRUDNIJ_PRACOWNIKA (
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

/
DECLARE
v_prac PRACOWNIK_OBJ;
v_umowa UMOWA_OBJ;
BEGIN
  v_prac := PRACOWNIK_OBJ('pracownik_test', 'nazwisko_test', '93070111111', 1666.54, '13123125SDF234', '12323526246246');
  v_umowa := UMOWA_OBJ (SYSDATE, ADD_MONTHS(SYSDATE, 12), 'B2B', 1); 
  ZATRUDNIJ_PRACOWNIKA(v_prac, v_umowa);
  FOR r IN (SELECT u.id as umowaId, p.id as pracownikId, o.imie, o.nazwisko FROM PRACOWNIK p LEFT JOIN OSOBA o ON o.id = p.id 
            JOIN UMOWA u on p.id=u.pracownik_id WHERE o.imie = 'pracownik_test' 
            AND o.nazwisko = 'nazwisko_test' AND o.pesel = '93070111111' AND u.aktualna = 1 AND ROWNUM = 1)
  LOOP
     DBMS_OUTPUT.PUT_LINE('pracownik_id = ' || r.pracownikId || ', imie = ' || r.imie || ', nazwisko = ' || r.nazwisko || ', umowa_id = ' || r.umowaId);
  END LOOP;
END;

-------------------------------------------------------------------------------------------------------------------
-- PROCEDURA PRZYZNAJACA RABAT DLA UZYTKOWNIKA KTORY JEST AKTYWNY ( CZYLI POSIADA PRZYNAJMNIEJ JEDNA DOKONANA TRANSAKCJE W OSTANIM POLROCZU) 
create or replace TYPE RABAT_OBJ IS OBJECT (termin_waznosci DATE , procent INTEGER, wykorzystany CHAR(1), Klient_id INTEGER, Towar_id INTEGER) ;
/
    
CREATE OR REPLACE PROCEDURE PRZYZNAJ_RABAT (
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

DECLARE
v_id_t TOWAR.id%TYPE;
v_id_k KLIENT.id%TYPE;
BEGIN
  SELECT towar_id INTO v_id_t FROM MAGAZYN_HAS_TOWAR WHERE ilosc > 0 AND ROWNUM = 1;
  SELECT klient_id INTO v_id_k FROM Zamowienie z 
  WHERE z.oplacone = 1 AND z.data_zamowienia BETWEEN ADD_MONTHS(SYSDATE, -6) AND SYSDATE AND ROWNUM = 1; 
  PRZYZNAJ_RABAT(RABAT_OBJ(ADD_MONTHS(SYSDATE, 6), 20, 0, v_id_k, v_id_t));
  FOR r IN (SELECT ra.* FROM Rabat ra WHERE ra.KLIENT_ID = v_id_k AND ra.TOWAR_ID = v_id_t AND ROWNUM = 1 ORDER BY ra.ID DESC)
  LOOP
    SYS.DBMS_OUTPUT.PUT_LINE('klientId=' || r.klient_id || ', towarId=' || r.towar_id || ', termin_waz=' || r.termin_waznosci || ', procent=' || r.procent);
  END LOOP;
END;
 