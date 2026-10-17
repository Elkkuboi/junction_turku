# Paperin numeeriset taulukot. Aja v0-kansiosta: Rscript paperi/laske_taulukot.R
# Kirjoittaa paperi/taulukko_oletus.tex, paperi/taulukko_herkkyys.tex ja paperi/tulokset.csv.
source("tammikuu_asetukset.R")
source("asetukset.R")
source("R/luo_grid.R")
source("R/lue_saa.R")
source("R/luo_kulkupohja.R")
source("R/simuloi_tammikuu.R")
source("R/vertaa_siemenet.R")

saa <- lue_saa(list.files("data/alkuperainen/saa", pattern = "[.]csv$", full.names = TRUE))
pohja <- luo_kulkupohja(luo_grid(alue, ruutukoko_m), read.csv("data/oletukset/reitit.csv"),
                        ruutukoko_m, tammikuu$huoltoalue_m)
ytimia <- max(1, parallel::detectCores())
luku <- function(x, d = 2) sub("^-", "$-$", formatC(x, format = "f", digits = d, decimal.mark = ","))
valit <- function(x) {
  s <- 1.96 * sd(x) / sqrt(length(x))
  sprintf("%s \\,[%s; %s]", luku(mean(x)), luku(mean(x) - s), luku(mean(x) + s))
}
leveaksi <- function(d) {
  w <- reshape(d[, c("seed", "scenario", "expected_falls")], idvar = "seed",
               timevar = "scenario", direction = "wide")
  names(w) <- sub("expected_falls.", "", names(w), fixed = TRUE)
  w
}

asetelmat <- list(
  list(nimi = "Oletus ($\\rho = 0$)", muutos = list()),
  list(nimi = "$\\rho = 0{,}5$", muutos = list(pysyvyys = 0.5)),
  list(nimi = "$\\rho = 0{,}9$", muutos = list(pysyvyys = 0.9)),
  list(nimi = "Ei vaihtelua ($G = 1$)", muutos = list(liukkaustasoja = 1)),
  list(nimi = "Ei erottelua ($\\eta = \\varepsilon$)", muutos = list(tunnistus_p = 0.0002)),
  list(nimi = "$H = 12 > \\Delta$", muutos = list(huollon_kesto_h = 12))
)
siemenet <- list(1:200, 1:100, 1:100, 1:100, 1:100, 1:100)

kaikki <- list()
for (i in seq_along(asetelmat)) {
  p <- modifyList(tammikuu, asetelmat[[i]]$muutos)
  d <- vertaa_siemenet(pohja, saa, p, siemenet[[i]], ytimia)
  d$asetelma <- i
  kaikki[[i]] <- d
  message(asetelmat[[i]]$nimi, ": valmis")
}
tulokset <- do.call(rbind, kaikki)
write.csv(tulokset, "paperi/tulokset.csv", row.names = FALSE)

nimet <- c(ei_huoltoa = "\\texttt{ei\\_huoltoa}", aikataulu = "\\texttt{aikataulu}",
           kulku = "\\texttt{kulku}", tuote = "\\texttt{tuote}", oraakkeli = "\\texttt{oraakkeli}")
w <- leveaksi(kaikki[[1]])
rivit <- vapply(politiikat, function(s) {
  ero <- w$kulku - w[[s]]
  sprintf("%s & %s & %s & %s \\\\", nimet[[s]], valit(w[[s]]),
          luku(100 * (1 - mean(w[[s]]) / mean(w$ei_huoltoa)), 1),
          if (s == "kulku") "--" else valit(ero))
}, character(1))
writeLines(c(sprintf("%% Tuotettu: paperi/laske_taulukot.R, %d siementä.", nrow(w)), rivit),
           "paperi/taulukko_oletus.tex")

rivit <- vapply(seq_along(asetelmat), function(i) {
  w <- leveaksi(kaikki[[i]])
  ero <- w$kulku - w$tuote
  kuilu <- mean(w$kulku - w$oraakkeli)
  sprintf("%s & %d & %s & %s & %s & %s & %s & %s & %d & %s \\\\", asetelmat[[i]]$nimi, nrow(w),
          luku(mean(w$ei_huoltoa), 1), luku(mean(w$aikataulu), 1), luku(mean(w$kulku), 1),
          luku(mean(w$tuote), 1), luku(mean(w$oraakkeli), 1), valit(ero), sum(ero > 0),
          if (kuilu > 1e-9) paste0(luku(100 * mean(ero) / kuilu, 0), " \\%") else "--")
}, character(1))
writeLines(c("% Tuotettu: paperi/laske_taulukot.R.", rivit), "paperi/taulukko_herkkyys.tex")
message("Taulukot kirjoitettu.")
