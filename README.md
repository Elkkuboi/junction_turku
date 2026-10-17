# Junction Hackathon

Eliaksen henkilökohtainen repositorio hackathonin materiaalien ja kehitystyön kokoamiseen.
GitHub-repositorio: [Elkkuboi/junction_turku](https://github.com/Elkkuboi/junction_turku).

## Nykyinen sisältö

Repossa on haasteiden taustamateriaaleja sekä synteettinen mikrobiologia-aineisto.
Varsinaista palvelusovellusta ei ole vielä toteutettu. If-materiaalien rinnalla
on paikallinen HTML-työkalu datan formaattien ja yksinkertaisten mallien tutkimiseen.

| Polku | Sisältö |
| --- | --- |
| `If/` | If-haasteen PDF-materiaalit |
| [If/research/data-model-map/](If/research/data-model-map/README.md) | Interaktiivinen data- ja mallikartta, esimerkit ja ajokomennot |
| [If/labra/v0/](If/labra/v0/README.md) | R: 10 metrin ruudukko, kaatumisten perussimulaatio ja kuva; ajo-ohje README:ssä |
| `redstone/` | Redstone / A'Pelago -haasteen PDF-materiaali |
| `tyx-mylab/` | Tyks x Mylab -haasteen PDF-materiaalit ja osallistujaopas |
| `tyx-mylab/data/` | Synteettinen mikrobiologia-aineisto CSV-muodossa ja sen kuvaus |
| `AGENTS.md` | Ohjeet tässä repossa työskenteleville AI-agenteille |

Aineiston rakenne, sarakkeet ja rajoitukset on kuvattu tiedostossa
[tyx-mylab/data/README.md](tyx-mylab/data/README.md).
Kuvauksen mukaan kaikki aineiston potilaat, näytteet ja tulokset ovat keksittyjä.

## Työskentely

- Pidä tehtävät pieninä ja määrittele, mistä valmistumisen tunnistaa.
- Tallenna vahvistetut päätökset ja tarvittavat käyttöohjeet repoon, jotta ne löytyvät myöhemminkin.
- Erottele lähdemateriaalin tiedot, omat oletukset ja tehdyt päätökset toisistaan.
- Säilytä alkuperäiset haasteaineistot. Tallenna käsitellyt aineistot ja tuotetut tulokset erikseen.
- Lisää asennus-, käynnistys- ja tarkistuskomennot tähän README-tiedostoon, kun toteutus on olemassa.

## Git-käytännöt

Tarkista muutokset ennen committia:

```sh
git status --short
git diff
git diff --cached
```

Lisää committiin vain kyseiseen tehtävään kuuluvat tiedostot. Suosi pieniä,
selkeästi nimettyjä committeja, jotta muutokset on helppo tarkistaa ja tarvittaessa perua.

Älä lisää repoon API-avaimia, salasanoja tai paikallisia salaisuuksia sisältäviä asetustiedostoja.
Kun toteutus tarvitsee ympäristömuuttujia, dokumentoi niiden nimet ja tarkoitus;
esimerkkiarvojen tulee olla keinotekoisia.

## AI-työkalujen käyttö

AI-työkalun voi valita tehtävän mukaan. Kaikkien käytettävissä olevien palvelujen
käyttäminen ei ole edellytys, eikä tiettyä palvelua ole määrätty pakolliseksi.

Anna agentille tavoite, tarvittavat lähdetiedostot, rajaukset ja valmistumiskriteerit.
Pidä pysyvät ohjeet ja päätökset repossa: eri palvelujen tai keskustelujen ei pidä
olettaa tuntevan toistensa keskusteluhistoriaa.

Jos useampi koodia muokkaava agentti työskentelee yhtä aikaa, käytä erillisiä
työkopioita tai Git-worktree-kansioita. Tarkista ja yhdistä muutokset hallitusti.
AI:n tuottama koodi ja väitteet tarkistetaan tehtävän edellyttämällä tavalla.
