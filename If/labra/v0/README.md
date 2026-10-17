# Labra v0

Turun kartta, 10 × 10 metrin ruudut ja tammikuun 2026 toistettava simulaatio.
Laskenta on R:ssä. Ruutu on pienin sijaintiyksikkö; tapahtuman koordinaatti on keskipiste.

## Ajo

Riippuvuudet: R, `spatstat`, `png` ja `jsonlite`. Asenna kerran R:ssä:

```r
install.packages(c("spatstat", "png", "jsonlite"), repos = "https://cloud.r-project.org")
```

Linuxissa `png`-paketin kääntäminen tarvitsee libpng-kehitystiedostot.
`setup.R` sisältää vain `library(spatstat)`. Muut paketit kutsutaan nimellään.

Aja repon juuresta:

```sh
cd If/labra/v0
Rscript aja_tammikuu.R
Rscript tarkista.R
Rscript tarkista_tammikuu.R
```

Avaa `tulokset/tammikuu.html` selaimessa. Tiedosto sisältää kartan ja tulokset;
se toimii ilman palvelinta tai verkkoyhteyttä. Toista, pysäytä tai siirrä aikajanaa.
Yksi askel vastaa yhtä tuntia. Karttojen luvut ovat näytetyn tunnin lopun tilanteita.

Alkuperäinen tasainen arvonta ja sen karttakuva: `Rscript aja.R`.
Se tuottaa `grid.csv`, `true_falls.csv` ja `tulokset/kaatumiset.png`.

## Tiedostot

| Tiedosto tai kansio | Tehtävä |
| --- | --- |
| `asetukset.R` | Aluerajaus ja alkuperäisen tasaisen arvonnan asetukset |
| `tammikuu_asetukset.R` | Tammikuun simulaation oletukset ja satunnaissiemen |
| `aja_tammikuu.R` | Lukee aineistot, laskee vertailun ja kirjoittaa tulokset |
| `R/luo_grid.R` | Luo ruudut ja niiden keskipisteet |
| `R/kohdista_gridiin.R` | Kohdistaa tarkat koordinaatit ruutuihin |
| `R/luo_true_falls.R` | Alkuperäinen tasainen ruutu- ja aika-arvonta |
| `R/piirra_grid.R`, `R/lue_kartta.R` | Staattinen karttakuva ja kartan rajauksen tarkistus |
| `R/lue_saa.R` | Sää-CSV:n luku ja tuntikeskiarvot |
| `R/luo_kulkupohja.R` | Reittien lähellä olevat ruudut ja oletetut kulkemismäärät |
| `R/simuloi_tammikuu.R` | Paritettu huoltovaihtoehtojen simulaatio |
| `R/vertaa_siemenet.R` | Toistaa vertailun eri satunnaissiemenillä |
| `R/kirjoita_toisto.R`, `toisto/` | Tulosten esittäminen selaimessa; ei mallilaskentaa |
| `lataa_kartta.R` | Kartan lataaminen uudelleen, jos aluerajausta muutetaan |
| `tarkista.R`, `tarkista_tammikuu.R` | Kohdistuksen ja simulaation kontrollikokeet |
| `data/alkuperainen/` | Ladattu kartta ja käyttäjän toimittama sää-CSV |
| `data/oletukset/reitit.csv` | Käsin hahmotellut esimerkkireitit ja oletetut tuntimäärät |
| `data/johdettu/`, `tulokset/` | Uudelleen tuotettavat tulokset, Gitin ulkopuolella |

## Kartta ja sijainti

Rajaus on 300 × 300 metriä VPK-talon ympärillä (Eskelinkatu 5):
E 239280–239580, N 6710600–6710900, ETRS-TM35FIN (EPSG:3067).
`x` on itäkoordinaatti ja `y` pohjoiskoordinaatti metreinä. Ruudukossa on 900 ruutua.
Joki jää rajauksen ulkopuolelle. Sijainnin lähde: [Suomi.fi, Turun VPK](https://www.suomi.fi/palvelut/palvelupiste/turun-vpk-varsinais-suomen-pelastuslaitos/4fbf2d65-d776-4e3b-8bb5-22e978113125).

Taustakartta: [Maanmittauslaitoksen taustakarttasarja Kapsin WMS-palvelusta](https://kartat.kapsi.fi/),
CC BY 4.0. `data/alkuperainen/kartta/turku.json` sisältää lähdeosoitteen,
hakuajan, koordinaatiston, rajauksen ja kuvan tiivisteen. Kartalla on täsmälleen
sama rajaus kuin ruudukolla. Rajauksen muuttamisen jälkeen aja `Rscript lataa_kartta.R`.

`kohdista_gridiin(x, y, grid, ruutukoko_m)` käyttää `luo_grid()`-funktion ruudukkoa.
Syötteen pitää olla EPSG:3067-koordinaatteja. Ruudun minimi kuuluu mukaan ja maksimi
seuraavaan ruutuun. Alueen ulkopuolinen koordinaatti aiheuttaa virheen.
Rajauksen tai ruutukoon muuttaminen voi muuttaa tunnisteita.

## Mitattu sää ja oletettu kulkeminen

Sääkansiossa pitää olla yksi käyttäjän toimittama CSV. Nyt käytössä on
Turku Artukainen 1.–31.1.2026: 4464 kymmenen minuutin aikaleimaa, joista
28:lta puuttuvat sääarvot. Paikallinen aika tulkitaan `Europe/Helsinki`-ajaksi
ja laskennan aika on UTC. Tunteja on 744.

Lämpötilasta, lumensyvyydestä ja sadearvoista lasketaan tunnin aritmeettinen
keskiarvo saatavilla olevista mittauksista. `rain_mean_mm` on keskiarvo,
ei tunnin sadekertymä. `valid_10min` kertoo täydellisten mittausrivien määrän.
Kokonaan puuttuva tuntiarvo korvattaisiin aiemmalla tuntiarvolla ja merkittäisiin
`filled = TRUE`; tässä aineistossa tällaisia tunteja ei ole.

Ohikulut ovat simuloituja. Neljä reittiä on hahmoteltu kartalta käsin;
ne eivät ole virallinen väyläaineisto. Reitin lähellä olevan ruudun kulkeminen
arvotaan Poisson-jakaumasta. Oletettu määrä vaihtelee reitin, kellonajan ja
viikonpäivän mukaan. Kyse on ruutujen ohikuluista, ei yksilöllisten ihmisten määrästä.

Mahdollinen oikea lähde on [Digitrafficin Turun kävely- ja pyöräilylaskentapistedata](https://www.digitraffic.fi/en/road-traffic/#walking-and-cycling-counting-site-values).
Laskentapisteet eivät suoraan kata kaikkia ruutuja. Metatietokysely palautti tässä
ympäristössä HTTP 406; tammikuun laskuridataa ei ole ladattu.

## Mitä simulaatio vertaa

1. Molemmilla vaihtoehdoilla on samat sääolot, ohikulut ja satunnaisluvut.
2. Liukastumisen todennäköisyys riippuu lähtötasosta, säästä ja simulaattorin
   piilevästä paikallisesta vaihtelusta. Sääkerroin on oma kokeellinen sääntö
   tiedostossa `R/simuloi_tammikuu.R`. Sitä ei ole kalibroitu tienpinnan havaintoihin.
3. Oletusotoksessa 25 % ohikuluista havaitaan sovelluksella. Liukastumisista
   tunnistetaan oletuksena 80 %; mukana on myös virhehavaintoja.
   Oletuksena 2 % simuloiduista liukastumisista johtaa kaatumiseen.
4. Molemmissa huolletaan kaksi 50 × 50 metrin kohdetta kuuden tunnin välein:
   tammikuussa 248 toimea kummassakin. Tämä yhtäläistää toimien määrän ja pinta-alan;
   todellisia työaikoja, siirtymiä tai kustannuksia ei mallinneta.
5. Aikatauluvaihtoehto kiertää kohteita järjestyksessä. Tuotevaihtoehto valitsee
   suurimman pistemäärän: edeltävien 12 tunnin havainnot + 0.002 × saman ajan
   sovelluksessa havaitut ohikulut. Määrää käytetään priorisointiin. Piilevä
   liukkaus ja tulevat havainnot eivät ole ohjauksen käytössä.
6. Hiekoitus pienentää liukastumisen todennäköisyyttä oletuksena 60 % ajaksi
   12 tuntia. Havaintomäärä syntyy tämän jälkeen arvonnasta. Aiempia havaintoja
   ei poisteta huollon kohdalla.

Kartalla väri kertoo viimeisten 12 tunnin havaintomäärän samalla asteikolla
molemmille vaihtoehdoille. Vihreä rajaus kertoo voimassa olevan simuloidun
hiekoituksen ja H uuden huoltotoimen. Kaatumisten kertymä sisältää myös
sovellusotoksen ulkopuoliset simuloidut kaatumiset.

`vertailu_tunti.csv` sisältää toteutuneet ja odotetut kaatumismäärät sekä huoltotoimien
määrän. Odotusarvo lasketaan simulaattorin todennäköisyyksistä arviointia varten.
Muut tulokset: `saa_tunti.csv`, `kulkupohja.csv`, `ohikulut.csv`,
`tapahtumat_tunti.csv`, `huoltotoimet.csv`, `tammikuu.rds` ja `ajotiedot.json`.
Viimeinen sisältää asetukset, R-version ja syötteiden tiivisteet.

Kaikki huolto on simuloitua: aikatauluvaihtoehto ei kuvaa Turun todellista toimintaa.
Ifin asiakkaita tai euroja ei ole eroteltu. Hyötymittari on kaatumistapahtumien erotus
samalla toimimäärällä. Yksi ajo ei osoita tuotteen todellista vaikuttavuutta;
vaihda siementä ja vaikutusoletuksia tuloksen herkkyyden tutkimiseksi.

Hyödyn oletukset, vertailun rajoitus ja tasaisen vaaratason kontrolli:
[HYOTY.md](HYOTY.md). Kontrollin voi ajaa komennolla `Rscript tarkista_hyoty.R`.

Esimerkiksi kymmenen siementä R:ssä v0-kansiosta:

```r
source("aja_tammikuu.R")
source("R/vertaa_siemenet.R")
herkkyys <- vertaa_siemenet(pohja, saa, tammikuu, 1:10)
write.csv(herkkyys, "tulokset/herkkyys.csv", row.names = FALSE)
```
