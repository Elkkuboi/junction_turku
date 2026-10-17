# Mihin simuloitu hyöty perustuu?

Tapahtumat arvotaan toisistaan riippumattomina **ehdolla**, että paikallinen
vaarataso, sää, kulkeminen ja huoltotila tunnetaan. Eri paikoille ei kuitenkaan
anneta samaa vaaratasoa. Kunkin huoltoalueen piilevä kerroin arvotaan kerran ja
säilytetään koko kuukauden. Tämän vuoksi saman paikan aiemmat havainnot voivat
kertoa myös sen tulevista tapahtumista. Yksi liukastuminen ei aiheuta seuraavaa.

Nykyisessä mallissa odotettu kaatumismäärä on karkeasti

```
ohikulut × liukastumistodennäköisyys × kaatumistodennäköisyys liukastumisesta
```

Sama hiekoitus voi siten estää enemmän kaatumisia vilkkaassa tai vaarallisessa
paikassa. Hiekoituksen 60 prosentin vaikutus ja 12 tunnin kesto ovat oletuksia.
Näitä vaikutuksia tai paikallista vaaratason vaihtelua ei ole mitattu tästä aineistosta.
Käytössä oleva todellinen aineisto on sää ja kartta.

## Mitä nykyinen vertailu ei erottele

Aikatauluvaihtoehto kiertää kohteet järjestyksessä. Tuotevaihtoehto käyttää sekä
kulkemista että tapahtumahavaintoja. Mahdollinen ero sisältää molempien tietojen
vaikutuksen. Se ei yksin osoita tapahtumahavaintojen lisäarvoa tai Ifin tuotteen
todellista vaikuttavuutta. Aikatauluvaihtoehto ei ole Turun todellisen huollon malli.

Pelkkään kulkemiseen perustuvan kohdistuksen saa asettamalla
`havaintopaino = 0`. Arvo 1 käyttää myös tapahtumahavaintoja. Tätä vertailua
tarvitaan ennen tapahtumahavaintojen hyötyä koskevaa johtopäätöstä.

```r
source("aja_tammikuu.R")
pelkka_kulkeminen <- tammikuu
pelkka_kulkeminen$havaintopaino <- 0
ilman_havaintoja <- simuloi_tammikuu(pohja, saa, pelkka_kulkeminen)
```

Kymmenen siemenen erittely samoilla maailmoilla:

```r
source("R/vertaa_siemenet.R")
a <- vertaa_siemenet(pohja, saa, tammikuu, 1:10)
b <- vertaa_siemenet(pohja, saa, pelkka_kulkeminen, 1:10)
vertailu <- data.frame(seed = a$seed, aikataulu = a$falls_schedule,
  pelkka_kulkeminen = b$falls_product, havainnot_ja_kulkeminen = a$falls_product,
  havaintojen_odotettu_lisaarvo = a$expected_difference - b$expected_difference)
write.csv(vertailu, "tulokset/havaintojen_lisaarvo.csv", row.names = FALSE)
```

## Tasaisen vaaratason kontrolli

`Rscript tarkista_hyoty.R` asettaa kaikille ruuduille saman vaaratason ja saman
kulkemisen. Molemmissa vaihtoehdoissa on samalla hetkellä yhtä monta samankokoista
huollettua ruutua. Kontrolli tarkistaa kymmenellä siemenellä, että odotettu
kaatumismäärä on molemmissa sama. Toteutuneet arvotut määrät voivat silti erota.

Kontrollissa huollon vaikutusaika on sama kuin huoltoväli. Näin päällekkäiset
huollot eivät muuta suojattua pinta-alaa. Kuukausidemon oletuksilla sama toimimäärä
ei takaa samaa suojattua pinta-alaa: sama kohde voidaan hiekoittaa uudelleen ennen
edellisen vaikutuksen päättymistä. Tämäkin voi vaikuttaa vaihtoehtojen eroon.
