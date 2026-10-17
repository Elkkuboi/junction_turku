# Paritettu vertailu: sama sää, kulkeminen ja satunnaisluvut kummallekin politiikalle.
simuloi_tammikuu <- function(pohja, saa, p) {
  n <- nrow(pohja)
  nt <- nrow(saa)
  nz <- max(pohja$zone_id)
  stopifnot(nz >= p$huoltokohteita, p$huollon_teho >= 0, p$huollon_teho <= 1)
  set.seed(p$seed)
  # Piilevä paikallinen vaihtelu on vain simulaattorin tiedossa.
  paikallinen <- exp(rnorm(nz, mean = -0.3, sd = p$paikallinen_sd))[pohja$zone_id]
  saakerroin <- 0.7 + 1.2 * (saa$temp_c >= -3 & saa$temp_c <= 1) +
    0.6 * (saa$snow_cm > 0) + 0.5 * (saa$rain_mean_mm > 0 & saa$temp_c < 1)
  tuore <- lapply(1:2, function(i) matrix(0L, n, p$havaintoikkuna_h))
  kulkuhistoria <- matrix(0L, n, p$havaintoikkuna_h)
  huollettu <- matrix(-Inf, nz, 2)
  seuraava <- 0L
  kehykset <- vector("list", nt)
  kooste <- huolto <- tapahtumat <- kulkeminen <- list()
  nimet <- c("aikataulu", "tuote")

  for (t in seq_len(nt)) {
    tunti <- as.integer(format(saa$time_utc[t], "%H", tz = "Europe/Helsinki"))
    viikonpaiva <- as.integer(format(saa$time_utc[t], "%u", tz = "Europe/Helsinki"))
    rytmi <- (0.1 + 0.8 * exp(-((tunti - 8) / 2)^2) +
                0.9 * exp(-((tunti - 17) / 3)^2)) * ifelse(viikonpaiva >= 6, 0.7, 1)
    odotetut_ohikulut <- pohja$ohikulkuja_h * rytmi
    ohikulut <- if (p$kulkeminen_satunnainen) rpois(n, odotetut_ohikulut) else round(odotetut_ohikulut)
    app <- rbinom(n, ohikulut, p$sovelluksen_osuus)
    u <- matrix(runif(n * 6), ncol = 6)
    slotti <- (t - 1) %% p$havaintoikkuna_h + 1
    kehys <- list()
    aika <- format(saa$time_utc[t], "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")

    for (s in 1:2) {
      kohteet <- integer(0)
      if ((t - 1) %% p$huoltovali_h == 0) {
        if (s == 1) {
          kohteet <- (seuraava + seq_len(p$huoltokohteita) - 1) %% nz + 1
          seuraava <- seuraava + p$huoltokohteita
        } else {
          # Vain aiemmat havainnot ja aiemmin havaitut ohikulut vaikuttavat valintaan.
          piste <- p$havaintopaino * rowSums(tuore[[s]]) + p$havaintopriorin_p * rowSums(kulkuhistoria)
          piste <- vapply(seq_len(nz), function(z) sum(piste[pohja$zone_id == z]), numeric(1))
          piste[t - huollettu[, s] < p$huoltovali_h] <- -Inf
          kohteet <- head(order(-piste, seq_len(nz)), p$huoltokohteita)
        }
        huollettu[kohteet, s] <- t
        huolto[[length(huolto) + 1]] <- data.frame(
          scenario = nimet[s], time_utc = aika, zone_id = kohteet, is_simulated = TRUE)
      }
      voimassa <- t - huollettu[pohja$zone_id, s] < p$huollon_kesto_h
      todennakoisyys <- pmin(1, p$liukastuminen_p * saakerroin[t] * paikallinen *
                              (1 - p$huollon_teho * voimassa))
      app_liuk <- qbinom(u[, 1], app, todennakoisyys)
      muut_liuk <- qbinom(u[, 2], ohikulut - app, todennakoisyys)
      kaatumiset <- qbinom(u[, 3], app_liuk, p$kaatuminen_liukastumisesta_p) +
        qbinom(u[, 4], muut_liuk, p$kaatuminen_liukastumisesta_p)
      havainnot <- qbinom(u[, 5], app_liuk, p$tunnistus_p) +
        qbinom(u[, 6], app - app_liuk, p$virhehavainto_p)
      tuore[[s]][, slotti] <- havainnot
      kehys[[s]] <- list(havainnot = I(as.integer(rowSums(tuore[[s]]))),
                         huoltoalueet = I(which(t - huollettu[, s] < p$huollon_kesto_h)),
                         uudet = I(kohteet))
      kooste[[length(kooste) + 1]] <- data.frame(
        scenario = nimet[s], time_utc = aika, passages = sum(ohikulut),
        app_passages = sum(app), observations = sum(havainnot), falls = sum(kaatumiset),
        expected_falls = sum(ohikulut * todennakoisyys * p$kaatuminen_liukastumisesta_p),
        maintenance_actions = length(kohteet), is_simulated = TRUE)
      mukana <- havainnot > 0 | kaatumiset > 0
      tapahtumat[[length(tapahtumat) + 1]] <- data.frame(
        scenario = rep(nimet[s], sum(mukana)), time_utc = rep(aika, sum(mukana)),
        cell_id = pohja$cell_id[mukana], observations = havainnot[mukana],
        falls = kaatumiset[mukana], is_simulated = rep(TRUE, sum(mukana)))
    }
    kulkuhistoria[, slotti] <- app
    kulkeminen[[t]] <- data.frame(time_utc = aika, cell_id = pohja$cell_id,
                                  passages = ohikulut, app_passages = app, is_simulated = TRUE)
    kehykset[[t]] <- kehys
  }
  list(frames = kehykset, summary = do.call(rbind, kooste),
       maintenance = do.call(rbind, huolto), events = do.call(rbind, tapahtumat),
       passages = do.call(rbind, kulkeminen), weather_factor = saakerroin)
}
