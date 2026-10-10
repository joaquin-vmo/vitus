suppressMessages(library(vitus))
stopifnot(ggplot2::theme_get()$plot.background$fill == fondo)
stopifnot(scale_y_continuous()$labels(1000) == "1.000")

d <- data.frame(x = 1:4, y = 1:4)
corto <- ggplot(d, aes(x, y, color = letters[1:4])) + geom_point()
largo <- ggplot(d, aes(x, y, color = paste("Mercado de exportación", c("Norte", "Este", "Oeste", "Sur")))) + geom_point()
stopifnot(identical(vitus:::ajustar_guias(corto, 8, vitus:::.estilos$presentacion), corto), !identical(vitus:::ajustar_guias(largo, 8, vitus:::.estilos$presentacion), largo))

carpeta <- tempfile()
ppt(corto, "prueba", carpeta = carpeta, formato = c("png", "svg"))
stopifnot(file.exists(file.path(carpeta, paste0("prueba.", c("png", "svg")))))
svg <- readLines(file.path(carpeta, "prueba.svg"))
stopifnot(any(grepl("Georgia", svg)), !any(grepl(fondo, svg, ignore.case = TRUE))) # fuente y fondo transparente

# informe: Garamond, colores para fondo blanco, y vuelve al modo anterior
informe(corto, "prueba_informe", carpeta = carpeta, formato = c("png", "svg"))
svg <- readLines(file.path(carpeta, "prueba_informe.svg"))
stopifnot(any(grepl("Garamond", svg)), any(grepl(substring(paleta_informe[1], 2), svg, ignore.case = TRUE)))
stopifnot(ggplot2::theme_get()$plot.background$fill == fondo)

# una leyenda escondida con guides() no reaparece al guardar
oculto <- largo + guides(colour = "none")
stopifnot(identical(vitus:::ajustar_guias(oculto, 8, vitus:::.estilos$presentacion), oculto))
