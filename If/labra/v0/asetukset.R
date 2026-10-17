# Esimerkkirajaus Turun keskustassa. ETRS-TM35FIN (EPSG:3067), metrejä.
alue <- c(xmin = 240000, xmax = 240500, ymin = 6711000, ymax = 6711500)
ruutukoko_m <- 10

alku <- as.POSIXct("2026-01-10 06:00:00", tz = "UTC")
loppu <- as.POSIXct("2026-01-10 18:00:00", tz = "UTC")
maara <- 100
seed <- 42
