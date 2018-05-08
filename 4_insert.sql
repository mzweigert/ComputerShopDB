-- AUTOR : MATEUSZ ZWEIGERT
  

INSERT INTO OSOBA (IMIE, NAZWISKO, PESEL) VALUES ('Jan', 'Kowalski', '50021100711');
  INSERT INTO OSOBA (IMIE, NAZWISKO, PESEL) VALUES ('Tadeusz', 'Nowak', '50021100712');
  INSERT INTO OSOBA (IMIE, NAZWISKO, PESEL) VALUES ('Waclaw', 'Kowal', '50021100713');
  INSERT INTO OSOBA (IMIE, NAZWISKO, PESEL) VALUES ('Marek', 'Nowakowski', '50021100714');
  INSERT INTO OSOBA (IMIE, NAZWISKO, PESEL) VALUES ('Malgorzata', 'Twardowska', '50021100705');
  INSERT INTO OSOBA (IMIE, NAZWISKO, PESEL) VALUES ('Katarzyna', 'Owaka', '50021100707');
  
  INSERT INTO OSOBA (IMIE, NAZWISKO, PESEL) VALUES ('Janina', 'Kowalska', '50021100101');
  INSERT INTO OSOBA (IMIE, NAZWISKO, PESEL) VALUES ('Tadeusz', 'Kowal', '50021100412');
  INSERT INTO OSOBA (IMIE, NAZWISKO, PESEL) VALUES ('Marysia', 'Fajna', '50021100803');
  INSERT INTO OSOBA (IMIE, NAZWISKO, PESEL) VALUES ('Marek', 'Nowakowski', '50021100514');
 
  INSERT INTO TELEFON (NR_TELEFONU, DATA_POZYSKANIA, OSOBA_ID) VALUES ('000000001', SYSDATE, 1);
  INSERT INTO TELEFON (NR_TELEFONU, DATA_POZYSKANIA, OSOBA_ID) VALUES ('000000011', SYSDATE, 1);
  INSERT INTO TELEFON (NR_TELEFONU, DATA_POZYSKANIA, OSOBA_ID) VALUES ('000000002', SYSDATE, 2);
  INSERT INTO TELEFON (NR_TELEFONU, DATA_POZYSKANIA, OSOBA_ID) VALUES ('000000003', SYSDATE, 3);
  INSERT INTO TELEFON (NR_TELEFONU, DATA_POZYSKANIA, OSOBA_ID) VALUES ('000000013', SYSDATE, 3);
  INSERT INTO TELEFON (NR_TELEFONU, DATA_POZYSKANIA, OSOBA_ID) VALUES ('000000004', SYSDATE, 4);
  INSERT INTO TELEFON (NR_TELEFONU, DATA_POZYSKANIA, OSOBA_ID) VALUES ('000000005', SYSDATE, 5);
  INSERT INTO TELEFON (NR_TELEFONU, DATA_POZYSKANIA, OSOBA_ID) VALUES ('000000015', SYSDATE, 5);
  INSERT INTO TELEFON (NR_TELEFONU, DATA_POZYSKANIA, OSOBA_ID) VALUES ('000000006', SYSDATE, 6);
  INSERT INTO TELEFON (NR_TELEFONU, DATA_POZYSKANIA, OSOBA_ID) VALUES ('000000016', SYSDATE, 6);
  INSERT INTO TELEFON (NR_TELEFONU, DATA_POZYSKANIA, OSOBA_ID) VALUES ('000000007', SYSDATE, 7);
  INSERT INTO TELEFON (NR_TELEFONU, DATA_POZYSKANIA, OSOBA_ID) VALUES ('000000008', SYSDATE, 8);
  INSERT INTO TELEFON (NR_TELEFONU, DATA_POZYSKANIA, OSOBA_ID) VALUES ('000000018', SYSDATE, 8);
  INSERT INTO TELEFON (NR_TELEFONU, DATA_POZYSKANIA, OSOBA_ID) VALUES ('000000009', SYSDATE, 9);
  INSERT INTO TELEFON (NR_TELEFONU, DATA_POZYSKANIA, OSOBA_ID) VALUES ('000000010', SYSDATE, 10);
  INSERT INTO TELEFON (NR_TELEFONU, DATA_POZYSKANIA, OSOBA_ID) VALUES ('000000110', SYSDATE, 10);
  INSERT INTO TELEFON (NR_TELEFONU, DATA_POZYSKANIA, OSOBA_ID) VALUES ('000000210', SYSDATE, 10);

  INSERT INTO PRACOWNIK(ID, PENSJA, NR_UBEZPIECZENIA, NIP) VALUES (1, 1300, '111111111111111', '000000000000001'); 
  INSERT INTO PRACOWNIK(ID, PENSJA, NR_UBEZPIECZENIA, NIP) VALUES (2, 1500, '111111111111111', '000000000000002'); 
  INSERT INTO PRACOWNIK(ID, PENSJA, NR_UBEZPIECZENIA, NIP) VALUES (3, 2000, '111111111111111', '000000000000003'); 
  INSERT INTO PRACOWNIK(ID, PENSJA, NR_UBEZPIECZENIA, NIP) VALUES (4, 3000, '111111111111111', '000000000000004'); 
  INSERT INTO PRACOWNIK(ID, PENSJA, NR_UBEZPIECZENIA, NIP) VALUES (5, 3500, '111111111111111', '000000000000005'); 
  INSERT INTO PRACOWNIK(ID, PENSJA, NR_UBEZPIECZENIA, NIP) VALUES (6, 2500, '111111111111111', '000000000000006'); 
  
  INSERT INTO UMOWA(PRACOWNIK_ID, DATA_PODPISANIA, DATA_ZAKONCZENIA, TYP, AKTUALNA) VALUES (1, ADD_MONTHS(SYSDATE, -12), ADD_MONTHS(SYSDATE, 12), 'ZLECENIE', '1'); 
  INSERT INTO UMOWA(PRACOWNIK_ID, DATA_PODPISANIA, DATA_ZAKONCZENIA, TYP, AKTUALNA) VALUES (2, ADD_MONTHS(SYSDATE, -12), ADD_MONTHS(SYSDATE, -6), 'ZLECENIE', '0'); 
  INSERT INTO UMOWA(PRACOWNIK_ID, DATA_PODPISANIA, DATA_ZAKONCZENIA, TYP, AKTUALNA) VALUES (3, ADD_MONTHS(SYSDATE, -16), NULL, 'O_PRACE', '1'); 
  INSERT INTO UMOWA(PRACOWNIK_ID, DATA_PODPISANIA, DATA_ZAKONCZENIA, TYP, AKTUALNA) VALUES (4, ADD_MONTHS(SYSDATE, -13), ADD_MONTHS(SYSDATE, 12), 'ZLECENIE', '1'); 
  INSERT INTO UMOWA(PRACOWNIK_ID, DATA_PODPISANIA, DATA_ZAKONCZENIA, TYP, AKTUALNA) VALUES (5, ADD_MONTHS(SYSDATE, -22), ADD_MONTHS(SYSDATE, 12), 'B2B', '1'); 
  INSERT INTO UMOWA(PRACOWNIK_ID, DATA_PODPISANIA, DATA_ZAKONCZENIA, TYP, AKTUALNA) VALUES (6, ADD_MONTHS(SYSDATE, -30), ADD_MONTHS(SYSDATE, 24), 'ZLECENIE', '0'); 
  INSERT INTO UMOWA(PRACOWNIK_ID, DATA_PODPISANIA, DATA_ZAKONCZENIA, TYP, AKTUALNA) VALUES (6, ADD_MONTHS(SYSDATE, -24), ADD_MONTHS(SYSDATE, 24), 'O_PRACE', '1'); 
 
  
  INSERT INTO PREMIA(WARTOSC, MIESIAC, ROK, PRACOWNIK_ID) VALUES (400, 'maj', '2016', 1);
  INSERT INTO PREMIA(WARTOSC, MIESIAC, ROK, PRACOWNIK_ID) VALUES (100, 'luty', '2011', 2);
  INSERT INTO PREMIA(WARTOSC, MIESIAC, ROK, PRACOWNIK_ID) VALUES (300, 'kwiecie�', '2011', 3);
  INSERT INTO PREMIA(WARTOSC, MIESIAC, ROK, PRACOWNIK_ID) VALUES (300, 'stycze�', '2013', 3);
  INSERT INTO PREMIA(WARTOSC, MIESIAC, ROK, PRACOWNIK_ID) VALUES (450, 'pa�dziernik', '2016', 4);
  INSERT INTO PREMIA(WARTOSC, MIESIAC, ROK, PRACOWNIK_ID) VALUES (500, 'czerwiec', '2015', 5);
  
 
  INSERT INTO KLIENT (ID, DATA_DOLACZENIA) VALUES (5, SYSDATE);
  INSERT INTO KLIENT (ID, DATA_DOLACZENIA) VALUES (6, SYSDATE);
  INSERT INTO KLIENT (ID, DATA_DOLACZENIA) VALUES (7, SYSDATE);
  INSERT INTO KLIENT (ID, DATA_DOLACZENIA) VALUES (8, SYSDATE);
  INSERT INTO KLIENT (ID, DATA_DOLACZENIA) VALUES (9, SYSDATE);
  INSERT INTO KLIENT (ID, DATA_DOLACZENIA) VALUES (10, SYSDATE);
 
  
 INSERT INTO KONTO (LOGIN, HASLO, SALT, DATA_ZALOZENIA, KLIENT_ID) VALUES('mtwardowska', 'haslo1', 'salt1', SYSDATE, 5);
 INSERT INTO KONTO (LOGIN, HASLO, SALT, DATA_ZALOZENIA, KLIENT_ID) VALUES('kowaka', 'haslo2', 'salt2', SYSDATE, 6);
 INSERT INTO KONTO (LOGIN, HASLO, SALT, DATA_ZALOZENIA, KLIENT_ID) VALUES('jkowalska', 'haslo3', 'salt3', SYSDATE, 7);
 INSERT INTO KONTO (LOGIN, HASLO, SALT, DATA_ZALOZENIA, KLIENT_ID) VALUES('tkowal', 'haslo4', 'salt4', SYSDATE, 8);
 INSERT INTO KONTO (LOGIN, HASLO, SALT, DATA_ZALOZENIA, KLIENT_ID) VALUES('mfajna', 'haslo5', 'salt5', SYSDATE, 9);
 INSERT INTO KONTO (LOGIN, HASLO, SALT, DATA_ZALOZENIA, KLIENT_ID) VALUES('mnowakowski', 'haslo6', 'salt6', SYSDATE, 10); 
 
 INSERT INTO PRODUCENT (NAZWA, OPIS) VALUES ('kompex', 'super extra sprzet komputerowy');
 INSERT INTO PRODUCENT (NAZWA, OPIS) VALUES ('kompaq', 'extra sprzet komputerowy');
 INSERT INTO PRODUCENT (NAZWA, OPIS) VALUES ('sprzetpol', 'super akcesoria komputerowe');
 INSERT INTO PRODUCENT (NAZWA, OPIS) VALUES ('kompol', 'super komputery');
 INSERT INTO PRODUCENT (NAZWA, OPIS) VALUES ('servex', 'super maszyny serverowe');
 INSERT INTO PRODUCENT (NAZWA, OPIS) VALUES ('servopol', 'super polskie komputery');


INSERT INTO KATEGORIA (OPIS) VALUES ('serwery');
INSERT INTO KATEGORIA (OPIS) VALUES ('myszki');
INSERT INTO KATEGORIA (OPIS) VALUES ('klawiatury');
INSERT INTO KATEGORIA (OPIS) VALUES ('monitory');
INSERT INTO KATEGORIA (OPIS) VALUES ('stacje komputerowe');
INSERT INTO KATEGORIA (OPIS) VALUES ('laptopy');

INSERT INTO TOWAR(NAZWA, DATA_PRODUKCJI, NUMER_SERYJNY, CENA, KATEGORIA_ID, PRODUCENT_ID) VALUES ('KOMPUTER', SYSDATE, '000000000000001', 1000, 5, 1);
INSERT INTO TOWAR(NAZWA, DATA_PRODUKCJI, NUMER_SERYJNY, CENA, KATEGORIA_ID, PRODUCENT_ID) VALUES ('MYSZKA', SYSDATE, '000000000000002', 20, 3, 3);
INSERT INTO TOWAR(NAZWA, DATA_PRODUKCJI, NUMER_SERYJNY, CENA, KATEGORIA_ID, PRODUCENT_ID) VALUES ('LAPTOP1', SYSDATE, '000000000000003', 3000, 6, 2);
INSERT INTO TOWAR(NAZWA, DATA_PRODUKCJI, NUMER_SERYJNY, CENA, KATEGORIA_ID, PRODUCENT_ID) VALUES ('LAPTOP2', SYSDATE, '000000000000004', 4000, 6, 4);
INSERT INTO TOWAR(NAZWA, DATA_PRODUKCJI, NUMER_SERYJNY, CENA, KATEGORIA_ID, PRODUCENT_ID) VALUES ('MONITOR', SYSDATE, '000000000000005', 600, 5, 6);
INSERT INTO TOWAR(NAZWA, DATA_PRODUKCJI, NUMER_SERYJNY, CENA, KATEGORIA_ID, PRODUCENT_ID) VALUES ('KOMPUTER SERWEROWY', SYSDATE, '000000000000006', 6000, 5, 5);


DECLARE
kod varchar2(20);
BEGIN
  FOR i IN 1..20 LOOP
    IF i < 10 THEN
      kod := '0' || i || '-' || '123';
    END IF;
    INSERT INTO ADRES(ULICA, MIASTO, NUMER, KOD) VALUES ('ulica' || i, 'miasto', 'numer' || i, kod);
  END LOOP;
END;

/

INSERT INTO PRODUCENT_HAS_ADRES(PRODUCENT_ID, ADRES_ID) VALUES(1, 1);
INSERT INTO PRODUCENT_HAS_ADRES(PRODUCENT_ID, ADRES_ID) VALUES(1, 2);
INSERT INTO PRODUCENT_HAS_ADRES(PRODUCENT_ID, ADRES_ID) VALUES(2, 1);
INSERT INTO PRODUCENT_HAS_ADRES(PRODUCENT_ID, ADRES_ID) VALUES(3, 3);
INSERT INTO PRODUCENT_HAS_ADRES(PRODUCENT_ID, ADRES_ID) VALUES(5, 4);
INSERT INTO PRODUCENT_HAS_ADRES(PRODUCENT_ID, ADRES_ID) VALUES(6, 5);

INSERT INTO OSOBA_HAS_ADRES(OSOBA_ID, ADRES_ID) VALUES(1, 6);
INSERT INTO OSOBA_HAS_ADRES(OSOBA_ID, ADRES_ID) VALUES(2, 6);
INSERT INTO OSOBA_HAS_ADRES(OSOBA_ID, ADRES_ID) VALUES(3, 7);
INSERT INTO OSOBA_HAS_ADRES(OSOBA_ID, ADRES_ID) VALUES(3, 8);
INSERT INTO OSOBA_HAS_ADRES(OSOBA_ID, ADRES_ID) VALUES(4, 9);
INSERT INTO OSOBA_HAS_ADRES(OSOBA_ID, ADRES_ID) VALUES(5, 9);
INSERT INTO OSOBA_HAS_ADRES(OSOBA_ID, ADRES_ID) VALUES(6, 10);
INSERT INTO OSOBA_HAS_ADRES(OSOBA_ID, ADRES_ID) VALUES(7, 10);
INSERT INTO OSOBA_HAS_ADRES(OSOBA_ID, ADRES_ID) VALUES(8, 11);
INSERT INTO OSOBA_HAS_ADRES(OSOBA_ID, ADRES_ID) VALUES(9, 12);

INSERT INTO MAGAZYN(ADRES_ID, OPIS) VALUES(13, 'magazyn1');
INSERT INTO MAGAZYN(ADRES_ID, OPIS) VALUES(14, 'magazyn2');
INSERT INTO MAGAZYN(ADRES_ID, OPIS) VALUES(15, 'magazyn3');
INSERT INTO MAGAZYN(ADRES_ID, OPIS) VALUES(16, 'magazyn4');
INSERT INTO MAGAZYN(ADRES_ID, OPIS) VALUES(17, 'magazyn5');
INSERT INTO MAGAZYN(ADRES_ID, OPIS) VALUES(18, 'magazyn6');

INSERT INTO MAGAZYN_HAS_TOWAR(MAGAZYN_ID, TOWAR_ID, ILOSC) VALUES (1, 1, 10);
INSERT INTO MAGAZYN_HAS_TOWAR(MAGAZYN_ID, TOWAR_ID, ILOSC) VALUES (1, 2, 10);
INSERT INTO MAGAZYN_HAS_TOWAR(MAGAZYN_ID, TOWAR_ID, ILOSC) VALUES (2, 1, 10);
INSERT INTO MAGAZYN_HAS_TOWAR(MAGAZYN_ID, TOWAR_ID, ILOSC) VALUES (2, 3, 10);
INSERT INTO MAGAZYN_HAS_TOWAR(MAGAZYN_ID, TOWAR_ID, ILOSC) VALUES (3, 1, 10);
INSERT INTO MAGAZYN_HAS_TOWAR(MAGAZYN_ID, TOWAR_ID, ILOSC) VALUES (3, 2, 10);
INSERT INTO MAGAZYN_HAS_TOWAR(MAGAZYN_ID, TOWAR_ID, ILOSC) VALUES (4, 1, 10);
INSERT INTO MAGAZYN_HAS_TOWAR(MAGAZYN_ID, TOWAR_ID, ILOSC) VALUES (5, 1, 10);
INSERT INTO MAGAZYN_HAS_TOWAR(MAGAZYN_ID, TOWAR_ID, ILOSC) VALUES (5, 2, 10);
INSERT INTO MAGAZYN_HAS_TOWAR(MAGAZYN_ID, TOWAR_ID, ILOSC) VALUES (6, 1, 10);

INSERT INTO ZAMOWIENIE(DATA_ZAMOWIENIA, ZREALIZOWANE, OPLACONE, KLIENT_ID) VALUES (SYSDATE, '0', '1', 5);
INSERT INTO ZAMOWIENIE(DATA_ZAMOWIENIA, ZREALIZOWANE, OPLACONE, KLIENT_ID) VALUES (SYSDATE, '1', '1', 6);
INSERT INTO ZAMOWIENIE(DATA_ZAMOWIENIA, ZREALIZOWANE, OPLACONE, KLIENT_ID) VALUES (SYSDATE, '0', '0', 7);
INSERT INTO ZAMOWIENIE(DATA_ZAMOWIENIA, ZREALIZOWANE, OPLACONE, KLIENT_ID) VALUES (SYSDATE, '0', '1', 8);
INSERT INTO ZAMOWIENIE(DATA_ZAMOWIENIA, ZREALIZOWANE, OPLACONE, KLIENT_ID) VALUES (SYSDATE, '1', '1', 8);
INSERT INTO ZAMOWIENIE(DATA_ZAMOWIENIA, ZREALIZOWANE, OPLACONE, KLIENT_ID) VALUES (SYSDATE, '1', '1', 9);

INSERT INTO FAKTURA_VAT(ZAMOWIENIE_ID, PRACOWNIK_ID, NR, DATA_WYSTAWIENIA, STATUS) VALUES (1, 6, '13445', SYSDATE, 'OPLACONA');
INSERT INTO FAKTURA_VAT(ZAMOWIENIE_ID, PRACOWNIK_ID, NR, DATA_WYSTAWIENIA, STATUS) VALUES (2, 6, '23452', SYSDATE, 'W_PRZYGOTOWANIU');
INSERT INTO FAKTURA_VAT(ZAMOWIENIE_ID, PRACOWNIK_ID, NR, DATA_WYSTAWIENIA, STATUS) VALUES (3, 5, '33545', SYSDATE, 'OPLACONA');
INSERT INTO FAKTURA_VAT(ZAMOWIENIE_ID, PRACOWNIK_ID, NR, DATA_WYSTAWIENIA, STATUS) VALUES (4, 2, '26434', SYSDATE, 'NIE_OPLACONA');
INSERT INTO FAKTURA_VAT(ZAMOWIENIE_ID, PRACOWNIK_ID, NR, DATA_WYSTAWIENIA, STATUS) VALUES (5, 1, '13745', SYSDATE, 'PRZYGOTOWANA');
INSERT INTO FAKTURA_VAT(ZAMOWIENIE_ID, PRACOWNIK_ID, NR, DATA_WYSTAWIENIA, STATUS) VALUES (6, 3, '44561', SYSDATE, 'ZREALIZOWANA');

INSERT INTO ZAMOWIENIE_HAS_TOWAR(ZAMOWIENIE_ID, TOWAR_ID, ILOSC) VALUES (1, 1, 10);
INSERT INTO ZAMOWIENIE_HAS_TOWAR(ZAMOWIENIE_ID, TOWAR_ID, ILOSC) VALUES (2, 2, 1);
INSERT INTO ZAMOWIENIE_HAS_TOWAR(ZAMOWIENIE_ID, TOWAR_ID, ILOSC) VALUES (3, 3, 7);
INSERT INTO ZAMOWIENIE_HAS_TOWAR(ZAMOWIENIE_ID, TOWAR_ID, ILOSC) VALUES (4, 3, 3);
INSERT INTO ZAMOWIENIE_HAS_TOWAR(ZAMOWIENIE_ID, TOWAR_ID, ILOSC) VALUES (5, 6, 5);
INSERT INTO ZAMOWIENIE_HAS_TOWAR(ZAMOWIENIE_ID, TOWAR_ID, ILOSC) VALUES (5, 3, 17);
INSERT INTO ZAMOWIENIE_HAS_TOWAR(ZAMOWIENIE_ID, TOWAR_ID, ILOSC) VALUES (6, 2, 11);
INSERT INTO ZAMOWIENIE_HAS_TOWAR(ZAMOWIENIE_ID, TOWAR_ID, ILOSC) VALUES (3, 1, 12);
 
INSERT INTO RABAT(TERMIN_WAZNOSCI, PROCENT, WYKORZYSTANY, KLIENT_ID, TOWAR_ID) VALUES(SYSDATE, 10, 0, 5, 1);
INSERT INTO RABAT(TERMIN_WAZNOSCI, PROCENT, WYKORZYSTANY, KLIENT_ID, TOWAR_ID) VALUES(SYSDATE, 11, 1, 6, 2);
INSERT INTO RABAT(TERMIN_WAZNOSCI, PROCENT, WYKORZYSTANY, KLIENT_ID, TOWAR_ID) VALUES(SYSDATE, 12, 0, 6, 1);
INSERT INTO RABAT(TERMIN_WAZNOSCI, PROCENT, WYKORZYSTANY, KLIENT_ID, TOWAR_ID) VALUES(SYSDATE, 14, 0, 7, 4);
INSERT INTO RABAT(TERMIN_WAZNOSCI, PROCENT, WYKORZYSTANY, KLIENT_ID, TOWAR_ID) VALUES(SYSDATE, 14, 1, 8, 3);
INSERT INTO RABAT(TERMIN_WAZNOSCI, PROCENT, WYKORZYSTANY, KLIENT_ID, TOWAR_ID) VALUES(SYSDATE, 15, 1, 9, 6);
INSERT INTO RABAT(TERMIN_WAZNOSCI, PROCENT, WYKORZYSTANY, KLIENT_ID, TOWAR_ID) VALUES(SYSDATE, 16, 1, 9, 6);
INSERT INTO RABAT(TERMIN_WAZNOSCI, PROCENT, WYKORZYSTANY, KLIENT_ID, TOWAR_ID) VALUES(SYSDATE, 11, 0, 10, 5);
INSERT INTO RABAT(TERMIN_WAZNOSCI, PROCENT, WYKORZYSTANY, KLIENT_ID, TOWAR_ID) VALUES(SYSDATE, 15, 0, 10, 4);
INSERT INTO RABAT(TERMIN_WAZNOSCI, PROCENT, WYKORZYSTANY, KLIENT_ID, TOWAR_ID) VALUES(SYSDATE, 20, 0, 5, 2);

 
INSERT INTO ZDJECIE(NAZWA, ROZSZERZENIE, DATA_UTWORZENIA, DANE, TOWAR_ID) VALUES ('zdj1', 'PNG', SYSDATE, 'DANE1', 1);
INSERT INTO ZDJECIE(NAZWA, ROZSZERZENIE, DATA_UTWORZENIA, DANE, TOWAR_ID) VALUES ('zdj2', 'JPG', SYSDATE, 'DANE2', 2);
INSERT INTO ZDJECIE(NAZWA, ROZSZERZENIE, DATA_UTWORZENIA, DANE, TOWAR_ID) VALUES ('zdj3', 'BMP', SYSDATE, 'DANE3', 3);
INSERT INTO ZDJECIE(NAZWA, ROZSZERZENIE, DATA_UTWORZENIA, DANE, TOWAR_ID) VALUES ('zdj4', 'PNG', SYSDATE, 'DANE4', 3);
INSERT INTO ZDJECIE(NAZWA, ROZSZERZENIE, DATA_UTWORZENIA, DANE, TOWAR_ID) VALUES ('zdj5', 'JPG', SYSDATE, 'DANE5', 4);
INSERT INTO ZDJECIE(NAZWA, ROZSZERZENIE, DATA_UTWORZENIA, DANE, TOWAR_ID) VALUES ('zdj6', 'BMP', SYSDATE, 'DANE6', 6);

