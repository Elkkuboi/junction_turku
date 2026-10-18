# Vertailee demon kuukausia eri siemenillä. Aja v0-kansiosta: Rscript etsi_siemen.R [siemeniä]
# Tulostaa ja tallentaa (tulokset/siemenet.csv) jokaisesta siemenestä kohdistetun ja
# aikataulun mukaisen huollon kaatumiset sekä sen, miten "estetyt kaatumiset" -laskuri kehittyy.
# Valitse demoon edustava siemen, jonka tulos on lähellä keskiarvoa, ja kerro siemen demossa.
source("asetukset.R")
source("tammikuu_asetukset.R")
source("R/luo_grid.R")
source("R/lue_saa.R")
source("R/luo_kulkupohja.R")
source("R/simuloi_tammikuu.R")

options(width = 200)
argumentit <- commandArgs(trailingOnly = TRUE)
n <- if (length(argumentit)) as.integer(argumentit[1]) else 100
saa <- lue_saa(list.files("data/alkuperainen/saa", pattern = "[.]csv$", full.names = TRUE))
pohja <- luo_kulkupohja(luo_grid(alue, ruutukoko_m), read.csv("data/oletukset/reitit.csv"),
                        ruutukoko_m, tammikuu$huoltoalue_m)

rivit <- parallel::mclapply(seq_len(n), function(siemen) {
  p <- tammikuu
  p$seed <- siemen
  q <- simuloi_tammikuu(pohja, saa, p)$summary
  a <- q[q$scenario == "aikataulu", ]
  b <- q[q$scenario == "tuote", ]
  laskuri <- cumsum(a$falls - b$falls)   # demon "Falls prevented" tunti tunnilta
  data.frame(seed = siemen, falls_rotation = sum(a$falls), falls_pito = sum(b$falls),
             prevented = tail(laskuri, 1),
             expected_prevented = round(sum(a$expected_falls - b$expected_falls), 2),
             counter_min = min(laskuri), hours_negative = sum(laskuri < 0),
             falls_no_grit = sum(q$falls[q$scenario == "ei_huoltoa"]))
}, mc.cores = max(1, parallel::detectCores()))
d <- do.call(rbind, rivit)
keskiarvo <- mean(d$expected_prevented)
d$distance_from_mean <- round(abs(d$prevented - keskiarvo), 2)
d <- d[order(d$distance_from_mean, d$hours_negative), ]
dir.create("tulokset", showWarnings = FALSE)
write.csv(d, "tulokset/siemenet.csv", row.names = FALSE)
cat(sprintf("Odotettu estettyjen kaatumisten keskiarvo %d siemenellä: %.2f\n", n, keskiarvo))
cat("Edustavimmat siemenet (toteutunut ero lähellä keskiarvoa, laskuri harvoin negatiivinen):\n")
print(head(d, 12), row.names = FALSE)
cat("Kaikki siemenet: tulokset/siemenet.csv\n")
