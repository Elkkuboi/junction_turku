# Pienet kontrollikokeet: sama työmäärä, paritus ja tulevan tiedon rajaaminen.
source("tammikuu_asetukset.R")
source("R/luo_grid.R")
source("R/luo_kulkupohja.R")
source("R/simuloi_tammikuu.R")

grid <- luo_grid(c(xmin = 0, xmax = 60, ymin = 0, ymax = 40), 10)
reitit <- data.frame(reitti = rep(c("a", "b"), each = 2), jarjestys = rep(1:2, 2),
                     x = c(0, 60, 0, 60), y = c(5, 5, 25, 25), ohikulkuja_h = 100)
p <- tammikuu
p$huoltoalue_m <- 20
p$liukastuminen_p <- 0.2
p$kaatuminen_liukastumisesta_p <- 0.5
p$virhehavainto_p <- 0
pohja <- luo_kulkupohja(grid, reitit, 10, p$huoltoalue_m)
saa <- data.frame(time_utc = as.POSIXct("2026-01-01", tz = "UTC") + 0:7 * 3600,
                  temp_c = -1, snow_cm = 2, rain_mean_mm = 0)
tulos <- simuloi_tammikuu(pohja, saa, p)
stopifnot(identical(tulos, simuloi_tammikuu(pohja, saa, p)))
q <- tulos$summary
stopifnot(sum(q$maintenance_actions[q$scenario == "aikataulu"]) ==
            sum(q$maintenance_actions[q$scenario == "tuote"]),
          identical(q$passages[q$scenario == "aikataulu"], q$passages[q$scenario == "tuote"]))

# Tulevan sään muuttaminen ei muuta jo laskettua historiaa.
muutettu <- saa
muutettu$temp_c[5:8] <- 10
toinen <- simuloi_tammikuu(pohja, muutettu, p)
stopifnot(identical(tulos$frames[1:4], toinen$frames[1:4]),
          identical(head(tulos$summary, 8), head(toinen$summary, 8)))

# Nollavaikutuksella vaihtoehtojen tapahtumat ovat samoja huoltopaikoista riippumatta.
p$huollon_teho <- 0
nolla <- simuloi_tammikuu(pohja, saa, p)$summary
stopifnot(identical(nolla$falls[nolla$scenario == "aikataulu"],
                    nolla$falls[nolla$scenario == "tuote"]),
          identical(nolla$observations[nolla$scenario == "aikataulu"],
                    nolla$observations[nolla$scenario == "tuote"]))

# Täysi vaikutus kaikkialla poistaa simuloidut liukastumiset ja kaatumiset.
p$huollon_teho <- 1
p$huoltokohteita <- max(pohja$zone_id)
kaikki <- simuloi_tammikuu(pohja, saa, p)$summary
stopifnot(all(kaikki$falls == 0), all(kaikki$observations == 0))
message("Tammikuun kontrollikokeet läpäisty.")
