# Negatiivinen kontrolli: havaintohistoria ei ennusta täysin tasaista vaaratasoa.
source("tammikuu_asetukset.R")
source("R/luo_grid.R")
source("R/simuloi_tammikuu.R")

pohja <- luo_grid(c(xmin = 0, xmax = 60, ymin = 0, ymax = 40), 10)
pohja$zone_id <- floor(pohja$x / 20) + 3 * floor(pohja$y / 20) + 1
pohja$ohikulkuja_h <- 100
saa <- data.frame(time_utc = as.POSIXct("2026-01-01", tz = "UTC") + 0:47 * 3600,
                  temp_c = -1, snow_cm = 2, rain_mean_mm = 0)
p <- tammikuu
p$paikallinen_sd <- 0
p$kulkeminen_satunnainen <- FALSE
p$huoltoalue_m <- 20
# Vaikutus päättyy ennen seuraavaa huoltokierrosta: sama suojattu pinta-ala kullakin tunnilla.
p$huollon_kesto_h <- p$huoltovali_h
for (siemen in 1:10) {
  p$seed <- siemen
  q <- simuloi_tammikuu(pohja, saa, p)$summary
  a <- q[q$scenario == "aikataulu", ]
  b <- q[q$scenario == "tuote", ]
  stopifnot(isTRUE(all.equal(a$expected_falls, b$expected_falls, tolerance = 1e-12)),
            identical(a$maintenance_actions, b$maintenance_actions))
}
message("Tasaisen vaaratason kontrolli läpäisty: odotettu hyöty on nolla 10 siemenellä.")
