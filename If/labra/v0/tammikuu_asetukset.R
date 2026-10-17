# Kaikki alla olevat luvut ovat simulaation oletuksia.
tammikuu <- list(
  seed = 42,
  sovelluksen_osuus = 0.25,
  paikallinen_sd = 0.8,          # 0 poistaa paikallisen vaaratason vaihtelun.
  kulkeminen_satunnainen = TRUE,
  havaintopaino = 1,            # 0 jättää kohdistuksen kulkemistiedon varaan.
  liukastuminen_p = 0.002,
  kaatuminen_liukastumisesta_p = 0.02,
  tunnistus_p = 0.8,
  virhehavainto_p = 0.0002,
  havaintoikkuna_h = 12,
  huoltovali_h = 6,
  huoltokohteita = 2,
  huoltoalue_m = 50,
  huollon_kesto_h = 12,
  huollon_teho = 0.6,
  havaintopriorin_p = 0.002
)
