# Labra v0

10 × 10 metrin ruudukko, simuloidut kaatumiset ja kuva tapahtumamääristä.
Yksi tapahtuma kuuluu yhteen ruutuun. Sen sijainti on ruudun keskipiste.

## Tiedostot

| Tiedosto tai kansio | Tehtävä |
| --- | --- |
| `setup.R` | Vain `library(spatstat)` |
| `asetukset.R` | Aluerajaus, ruutukoko, aikaväli, tapahtumamäärä ja siemen |
| `aja.R` | Luo aineistot ja tallentaa kuvan |
| `R/luo_grid.R` | Luo ruutujen tunnisteet ja keskipisteet |
| `R/kohdista_gridiin.R` | Kohdistaa koordinaatit ruutujen keskipisteisiin |
| `R/luo_true_falls.R` | Arpoo ruudut ja tapahtuma-ajat |
| `R/piirra_grid.R` | Piirtää koko aikavälin tapahtumamäärän ruuduittain |
| `tarkista.R` | Tarkistaa kohdistuksen rajat ja simulaation perussäännöt |
| `data/alkuperainen/saa/` | Tähän itse hakemasi sääaineisto |
| `data/alkuperainen/kartta/` | Paikka myöhemmin tuotavalle taustakartalle |
| `data/johdettu/` | Ajossa syntyvät `grid.csv` ja `true_falls.csv` |
| `tulokset/` | Ajossa syntyvä `kaatumiset.png` |

## Ajo

Riippuvuudet: R ja [spatstat](https://spatstat.org/). Asenna paketti kerran R:ssä:

```r
install.packages("spatstat", repos = "https://cloud.r-project.org")
```

Aja repon juuresta:

```sh
cd If/labra/v0
Rscript aja.R
Rscript tarkista.R
```

`spatstat` ladataan valmiiksi. Nykyiset neljä funktiota käyttävät R:n perustoimintoja.
Ajot uusivat johdetut CSV:t ja kuvan. Ne jätetään Gitin ulkopuolelle;
alkuperäisiä aineistoja ajo ei käsittele.

## Ruudukko ja koordinaatit

Oletusrajaus on 500 × 500 metriä Turun keskustassa: E 240000–240500,
N 6711000–6711500. Se sisältää 2500 ruutua. Koordinaatisto on
[ETRS-TM35FIN (EPSG:3067)](https://www.maanmittauslaitos.fi/kartat-ja-paikkatieto/koordinaatit-ja-paikannus/epsg-koodit-ja-proj-muunnosohjelma),
`x` on itäkoordinaatti ja `y` pohjoiskoordinaatti metreinä.

`grid.csv`: `cell_id`, `x`, `y`. Koordinaatit ovat keskipisteitä.
Rajauksen sivujen pitää olla ruutukoon monikertoja. Rajauksen tai ruutukoon
muuttaminen muuttaa ruudukkoa ja voi muuttaa tunnisteita.

`kohdista_gridiin(x, y, grid, ruutukoko_m)` käyttää `luo_grid()`-funktion
tuottamaa ruudukkoa. Syötteen on oltava EPSG:3067-koordinaatteja.
Esimerkiksi ruudussa [240000, 240010) × [6711000, 6711010) olevat
koordinaatit kohdistuvat keskipisteeseen (240005, 6711005).
Sisärajalla valitaan oikean/ylemmän puolen ruutu. Alueen ulkopuolinen
koordinaatti aiheuttaa virheen. Koordinaattimuunnoksia ei tehdä.

## Kaatumisten simulointi

`luo_true_falls(grid, alku, loppu, maara, seed)`:

- `alku` ja `loppu`: `POSIXct`-aikahetket kokonaisten sekuntien tarkkuudella.
- `maara`: tapahtumien kiinteä kokonaismäärä.
- `seed`: satunnaissiemen; samat syötteet ja siemen toistavat aineiston.

Jokaisella ruudulla on sama valintatodennäköisyys. Ruudut arvotaan palauttaen,
joten samassa ruudussa voi olla useita tapahtumia. Aika arvotaan riippumattomasti
tasaisesti aikavälin sekunneista: alku mukana, loppu pois. Satunnaisgeneraattorin
siemen asetetaan funktiossa.

`true_falls.csv`: `fall_id`, `cell_id`, `x`, `y`, `event_at`, `is_simulated`.
`x` ja `y` ovat aina valitun ruudun keskipiste. `event_at` on UTC-aika muodossa
`2026-01-10T06:00:00Z`. `is_simulated` on aina `TRUE`.

Tämä on tasajakautunut vertailusimulaatio. Sää, kulkemisen määrä ja väylät eivät
vaikuta arvontaan. Tulokset kuvaavat simulaatiota. Kuva näyttää lukumäärän,
ei kaatumisriskiä. Ennustemallia tai taustakarttaa ei ole vielä mukana.
