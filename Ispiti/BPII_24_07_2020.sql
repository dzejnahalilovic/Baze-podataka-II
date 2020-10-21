/*
Napomena:

A.
Prilikom  bodovanja rješenja prioritet ima rezultat koji upit treba da vrati (broj zapisa, vrijednosti agregatnih funkcija...).
U slučaju da rezultat upita nije tačan, a pogled, tabela... koji su rezultat tog upita se koriste u narednim zadacima, 
tada se rješenja narednih zadataka, bez obzira na tačnost koda, ne boduju punim brojem bodova, 
jer ni ta rješenja ne mogu vratiti tačan rezultat (broj zapisa, vrijednosti agregatnih funkcija...).

B.
Tokom pisanja koda obratiti posebnu pažnju na tekst zadatka i ono što se traži zadatkom. 
Prilikom pregleda rada pokreće se kod koji se nalazi u sql skripti i 
sve ono što nije urađeno prema zahtjevima zadatka ili je pogrešno urađeno predstavlja grešku. 
*/


------------------------------------------------
--1
/*
a) Kreirati bazu podataka pod vlastitim brojem indeksa.
*/

create database BPII_24_07_2020
go

use BPII_24_07_2020
go

--Prilikom kreiranja tabela voditi računa o međusobnom odnosu između tabela.
/*
b) Kreirati tabelu radnik koja će imati sljedeću strukturu:
	- radnikID, cjelobrojna varijabla, primarni ključ
	- drzavaID, 15 unicode karaktera
	- loginID, 256 unicode karaktera
	- god_rod, cjelobrojna varijabla
	- spol, 1 unicode karakter
*/

create table radnik
(
	radnikID int,
	drzavaID nvarchar(15),
	loginID nvarchar(256),
	god_rod int, 
	spol nvarchar(1),
	constraint pk_radnik primary key(radnikID)
)

/*
c) Kreirati tabelu nabavka koja će imati sljedeću strukturu:
	- nabavkaID, cjelobrojna varijabla, primarni ključ
	- status, cjelobrojna varijabla
	- radnikID, cjelobrojna varijabla
	- br_racuna, 15 unicode karaktera
	- naziv_dobavljaca, 50 unicode karaktera
	- kred_rejting, cjelobrojna varijabla
*/

create table nabavka
(
	nabavkaID int,
	status int, 
	radnikID int,
	br_racuna nvarchar(15),
	naziv_dobvaljaca nvarchar(50),
	kred_rejting int
	constraint pk_nabavka primary key(nabavkaID),
	constraint fk_radnik foreign key(radnikID) references radnik(radnikID)
)

/*
c) Kreirati tabelu prodaja koja će imati sljedeću strukturu:
	- prodajaID, cjelobrojna varijabla, primarni ključ, inkrementalno punjenje sa početnom vrijednošću 1, samo neparni brojevi
	- prodavacID, cjelobrojna varijabla
	- dtm_isporuke, datumsko-vremenska varijabla
	- vrij_poreza, novčana varijabla
	- ukup_vrij, novčana varijabla
	- online_narudzba, bit varijabla sa ograničenjem kojim se mogu unijeti samo cifre 0 ili 1
*/
--10 bodova

create table prodaja
(
	prodajaID int identity(1,2) constraint pk_prodaja primary key,
	prodavacID int,
	dtm_isporuke datetime,
	vrij_poreza money,
	ukup_vrij money,
	online_narudzba bit constraint ck_online_narudzba check(online_narudzba = 0 or online_narudzba = 1),
	constraint fk_prodavac foreign key(prodavacID) references radnik(radnikID)
)

--------------------------------------------
--2. Import podataka
/*
a) Iz tabele Employee iz šeme HumanResources baze AdventureWorks2017 u tabelu radnik importovati podatke po sljedećem pravilu:
	- BusinessEntityID -> radnikID
	- NationalIDNumber -> drzavaID
	- LoginID -> loginID
	- godina iz kolone BirthDate -> god_rod
	- Gender -> spol
*/
-------------------------------------------------

insert into radnik 
select BusinessEntityID, NationalIDNumber, LoginID, year(BirthDate), Gender
from AdventureWorks2014.HumanResources.Employee
--290

/*
b) Iz tabela PurchaseOrderHeader i Vendor šeme Purchasing baze AdventureWorks2017 u tabelu nabavka importovati podatke po sljedećem pravilu:
	- PurchaseOrderID -> dobavljanjeID
	- Status -> status
	- EmployeeID -> radnikID
	- AccountNumber -> br_racuna
	- Name -> naziv_dobavljaca
	- CreditRating -> kred_rejting
*/

insert into nabavka
select PurchaseOrderID, Status, EmployeeID, AccountNumber, Name, CreditRating
from AdventureWorks2014.Purchasing.PurchaseOrderHeader as poh 
inner join AdventureWorks2014.Purchasing.Vendor as v on poh.VendorID = v.BusinessEntityID
--4012

/*
c) Iz tabele SalesOrderHeader šeme Sales baze AdventureWorks2017
u tabelu prodaja importovati podatke po sljedećem pravilu:
	- SalesPersonID -> prodavacID
	- ShipDate -> dtm_isporuke
	- TaxAmt -> vrij_poreza
	- TotalDue -> ukup_vrij
	- OnlineOrderFlag -> online_narudzba
*/
--10 bodova

insert into prodaja
select SalesPersonID, ShipDate, TaxAmt, TotalDue, OnlineOrderFlag
from AdventureWorks2014.Sales.SalesOrderHeader as soh
--31465

------------------------------------------
--3.
/*
a) U tabeli radnik dodati kolonu st_kat (starosna kategorija), tipa 3 karaktera.
*/

alter table radnik
add st_kat nvarchar(3)

select *
from radnik

/*
b) Prethodno kreiranu kolonu popuniti po principu:
	starosna kategorija		uslov
	I						osobe do 30 godina starosti (uključuje se i 30)
	II						osobe od 31 do 49 godina starosti
	III						osobe preko 50 godina starosti
*/

update radnik
set st_kat = case
					when year(getdate()) - god_rod <= 30 then 'I'
					when year(getdate()) - god_rod between 31 and 49 then 'II'
					when year(getdate()) - god_rod >= 50 then 'III'
			 end

select *
from radnik


/*
c) Neka osoba sa navršenih 65 godina starosti odlazi u penziju.
Prebrojati koliko radnika ima 10 ili manje godina do penzije.
Rezultat upita isključivo treba biti poruka 
'Broj radnika koji imaju 10 ili manje godina do penzije je ' nakon čega slijedi prebrojani broj.
Neće se priznati rješenje koje kao rezultat upita vraća više kolona.
*/
--15 bodova

select 'Broj radnika koji imaju 10 ili manje godina do penzije je ' + convert(nvarchar, count(*))
from radnik
where 65 - (year(getdate()) - god_rod) between 1 and 10
--19

------------------------------------------
--4.
/*
a) U tabeli prodaja kreirati kolonu stopa_poreza (10 unicode karaktera)
*/

/*
b) Prethodno kreiranu kolonu popuniti kao količnik vrij_poreza i ukup_vrij,
Stopu poreza izraziti kao cijeli broj sa oznakom %, pri čemu je potrebno 
da između brojčane vrijednosti i znaka % bude prazno mjesto. (npr. 14.00 %)
*/
--10 bodova

alter table prodaja
add stopa_poreza nvarchar(10)

update prodaja
set stopa_poreza = convert(nvarchar, (vrij_poreza / ukup_vrij)*100) + ' %'

select *
from prodaja

-----------------------------------------
--5.
/*
a)
Koristeći tabelu nabavka kreirati pogled view_slova sljedeće strukture:
	- slova
	- prebrojano, prebrojani broj pojavljivanja slovnih dijelova podatka u koloni br_racuna. */

select *
from nabavka

create view view_slova
as
select left(br_racuna, charindex('0', br_racuna)-1) as slova, count(*) as prebrojano
from nabavka
group by left(br_racuna, charindex('0', br_racuna)-1) 

select *
from view_slova
--80


	/*
b)
Koristeći pogled view_slova odrediti razliku vrijednosti između prebrojanih i srednje vrijednosti kolone.
Rezultat treba da sadrži kolone slova, prebrojano i razliku.
Sortirati u rastućem redolsijedu prema razlici.
*/
--10 bodova

select slova, prebrojano, prebrojano - (select avg(prebrojano) from view_slova) as razlika
from view_slova
order by 3

-----------------------------------------
--6.
/*
a) Koristeći tabelu prodaja kreirati pogled view_stopa sljedeće strukture:
	- prodajaID
	- stopa_poreza
	- stopa_num, u kojoj će bit numerička vrijednost stope poreza */

create view view_stopa
as
select prodajaID, stopa_poreza, convert(money, left(stopa_poreza, charindex('%', stopa_poreza)-1)) as stopa_num
from prodaja

select *
from view_stopa
--31465

	/*
b)
Koristeći pogled view_stopa, a na osnovu razlike između vrijednosti u koloni stopa_num i 
srednje vrijednosti stopa poreza za svaki proizvodID navesti poruku 'manji', odnosno, 'veći'. 
*/
--12 bodova

select prodajaID, case 
			when stopa_num < (select avg(stopa_num) from view_stopa) then 'manji'
			when stopa_num > (select avg(stopa_num) from view_stopa) then 'veci'
		end
from view_stopa

------------------------------------------
--7.
/*
Koristeći pogled view_stopa_poreza kreirati proceduru proc_stopa_poreza
tako da je prilikom izvršavanja moguće unijeti bilo koji broj parametara 
(možemo ostaviti bilo koji parametar bez unijete vrijednosti),
pri čemu će se prebrojati broja zapisa po stopi poreza uz uslova 
da se dohvate samo oni zapisi u kojima je stopa poreza veća od 10 %.
Proceduru pokrenuti za sljedeće vrijednosti:
	- stopa poreza = 12, 15 i 21 
*/
--10 bodova

create procedure proc_stopa_poreza
(
	@prodajaID int = null,
	@stopa_poreza nvarchar(10) = null,
	@stopa_num money = null
)
as
begin
	select stopa_num, count(*)
	from view_stopa
	where (stopa_num > 10) and (prodajaID = @prodajaID or stopa_poreza = @stopa_poreza or stopa_num = @stopa_num)
	group by stopa_num
end

exec proc_stopa_poreza
@stopa_num = 12
--0

exec proc_stopa_poreza
@stopa_num = 15
--1

exec proc_stopa_poreza
@stopa_num = 21
--0

---------------------------------------------------------------------------------------------------
--8.
/*
Kreirati proceduru proc_prodaja kojom će se izvršiti 
promjena vrijednosti u koloni online_narudzba tabele prodaja. 
Promjena će se vršiti tako što će se 0 zamijeniti sa NO, a 1 sa YES. 
Pokrenuti proceduru kako bi se izvršile promjene, a nakon toga onemogućiti 
da se u koloni unosi bilo kakva druga vrijednost osim NO ili YES.
*/
--13 bodova

create procedure proc_prodaja
as
begin
alter table prodaja
drop constraint ck_online_narudzba
alter table prodaja
alter column online_narudzba nvarchar(3)
update prodaja 
set online_narudzba = case 
							when online_narudzba = 0 then 'NO'
							when online_narudzba = 1 then 'YES'	
					  end
end

exec proc_prodaja

select *
from prodaja

alter table prodaja
add constraint ck_online_narudzba check(online_narudzba = 'NO' or online_narudzba = 'YES')
------------------------------------------
--9.
/*
a) 
Nad kolonom god_rod tabele radnik kreirati ograničenje kojim će
se onemogućiti unos bilo koje godine iz budućnosti kao godina rođenja.
Testirati funkcionalnost kreiranog ograničenja navođenjem 
koda za insert podataka kojim će se kao godina rođenja
pokušati unijeti bilo koja godina iz budućnosti.
*/

alter table radnik 
add constraint ck_god_rod check (god_rod <= year(getdate()))

INSERT INTO radnik
VALUES (20000, 'A', 'A', 2500, 'M', 'I');

/*
b) Nad kolonom drzavaID tabele radnik kreirati ograničenje kojim će se ograničiti dužina podatka na 7 znakova. 
Ako je prethodno potrebno, izvršiti prilagodbu kolone, pri čemu nije dozvoljeno prilagođavati podatke čiji 
dužina iznosi 7 ili manje znakova.
Testirati funkcionalnost kreiranog ograničenja navođenjem koda za insert podataka 
kojim će se u drzavaID pokušati unijeti podataka duži od 7 znakova bilo koja godina iz budućnosti.
*/
--10 bodova

select *
from radnik
where len(drzavaID)>7

update radnik
set drzavaID = left(drzavaID, 7)
where len(drzavaID) > 7
--283

alter table radnik
add constraint ck_drzava check(len(drzavaID) <= 7)

INSERT INTO radnik
VALUES (20000, '12345678', 'A', 1980, 'M', 'I');

-----------------------------------------------
--10.
/*
Kreirati backup baze na default lokaciju, obrisati bazu, a zatim izvršiti restore baze. 
Uslov prihvatanja koda je da se može izvršiti.
*/
--2 boda

backup database BPII_24_07_2020
to disk = 'BPII_24_07_2020.bak'

use master

restore database BPII_24_07_2020
from disk = 'BPII_24_07_2020.bak'
with replace