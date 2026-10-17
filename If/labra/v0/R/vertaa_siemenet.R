# Näyttää, kuinka paljon tulos muuttuu satunnaissiemenen mukana.
vertaa_siemenet <- function(pohja, saa, p, siemenet) {
  rivit <- lapply(siemenet, function(siemen) {
    p$seed <- siemen
    d <- simuloi_tammikuu(pohja, saa, p)$summary
    a <- d[d$scenario == "aikataulu", ]
    b <- d[d$scenario == "tuote", ]
    data.frame(seed = siemen, falls_schedule = sum(a$falls), falls_product = sum(b$falls),
               difference = sum(a$falls) - sum(b$falls),
               expected_difference = sum(a$expected_falls) - sum(b$expected_falls),
               actions_schedule = sum(a$maintenance_actions), actions_product = sum(b$maintenance_actions))
  })
  do.call(rbind, rivit)
}
