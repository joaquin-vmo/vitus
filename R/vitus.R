# tidyverse va en Depends para que library(vitus) lo adjunte. El @importFrom solo calla la NOTE de R CMD check
#' vitus: formato de figuras para presentaciones e informes
#'
#' Al cargar el paquete queda activo el formato de presentaciones (tema oscuro,
#' paleta, grosores y Georgia) para todos los gráficos de ggplot2. El formato
#' de informes (fondo blanco, Garamond) se activa con [vitus_modo()] o al
#' guardar con [informe()].
#' @keywords internal
#' @importFrom tidyverse tidyverse_packages
"_PACKAGE"

#' Colores de vitus
#'
#' Presentaciones (fondo oscuro): `fondo`, `texto`, `color_vline` (líneas de
#' referencia) y `paleta` (colores de las series, en orden). Informes (fondo
#' blanco): `texto_informe`, `color_vline_informe` y `paleta_informe`.
#' @name colores
#' @aliases fondo texto color_vline paleta texto_informe color_vline_informe paleta_informe
#' @export fondo texto color_vline paleta texto_informe color_vline_informe paleta_informe
NULL

fondo <- "#232222"
texto <- "#E1D8D2"
color_vline <- "#D27F7A"
paleta <- c("#7EABCE", "#DD818A", "#7BB392", "#D4925E", "#BC92C5")

texto_informe <- "#222121"
color_vline_informe <- "#585757"
paleta_informe <- c("#009F9D", "#AD77BF", "#4C9C59", "#5391C2", "#006564", "#78318A")

# tamano: pt del texto base. En el informe (Word a 11 pt) 12 deja los ejes en ~9,5 pt y la leyenda en ~8,5 pt
.estilos <- list(
  presentacion = list(familia = "Georgia", tamano = 20, texto = texto, fondo = fondo,
                      vline = color_vline, paleta = paleta),
  informe = list(familia = "Garamond", tamano = 12, texto = texto_informe, fondo = "white",
                 vline = color_vline_informe, paleta = paleta_informe)
)
.modo <- new.env()

#' Tema de vitus
#' @param base_size tamaño base del texto, en puntos. Por defecto, el del modo.
#' @param modo `"presentacion"` o `"informe"`.
#' @return Un tema de ggplot2.
#' @export
theme_vitus <- function(base_size = NULL, modo = c("presentacion", "informe")) {
  v <- .estilos[[match.arg(modo)]]
  if (is.null(base_size)) base_size <- v$tamano
  e <- ggplot2::element_text
  ggplot2::theme_minimal(base_size = base_size, base_family = v$familia) +
    ggplot2::theme(
      text = e(colour = v$texto),
      plot.title = e(face = "bold", size = base_size + 2, hjust = 0.5),
      plot.subtitle = e(size = base_size - 1, hjust = 0.5),
      plot.caption = e(size = base_size - 3, hjust = 0),
      strip.text = e(colour = v$texto, size = ggplot2::rel(0.8), hjust = 0.5),
      strip.background = ggplot2::element_blank(),
      strip.placement = "outside",
      legend.position = "top",
      legend.box = "vertical",
      legend.spacing.y = ggplot2::unit(0, "pt"),
      legend.margin = ggplot2::margin(0, 0, 0, 0),
      legend.title = e(size = ggplot2::rel(0.75)),
      legend.text = e(size = ggplot2::rel(0.7)),
      axis.title = e(size = ggplot2::rel(0.75)),
      axis.text = e(colour = v$texto),
      panel.grid = ggplot2::element_blank(),
      plot.background = ggplot2::element_rect(fill = v$fondo, colour = NA),
      panel.background = ggplot2::element_rect(fill = v$fondo, colour = NA),
      plot.margin = ggplot2::margin(5.5, base_size * 1.25, 5.5, 5.5), # la última etiqueta del eje x no se corta
      plot.title.position = "plot",
      plot.caption.position = "plot"
    )
}

#' Cambia entre el formato de presentaciones y el de informes
#'
#' Cambia el tema, la paleta, la fuente y los grosores de los gráficos que se
#' muestren después. [ppt()] e [informe()] ya lo hacen solos al guardar. Esto
#' sirve para ver en RStudio cómo va a quedar el gráfico.
#' @param modo `"presentacion"` o `"informe"`.
#' @return El modo anterior, de forma invisible.
#' @export
vitus_modo <- function(modo = c("presentacion", "informe")) {
  modo <- match.arg(modo)
  v <- .estilos[[modo]]
  k <- v$tamano / .estilos$presentacion$tamano # grosores a escala del texto
  options(ggplot2.discrete.colour = list(v$paleta), ggplot2.discrete.fill = list(v$paleta))
  ggplot2::theme_set(theme_vitus(modo = modo))
  d <- function(geom, ...) ggplot2::update_geom_defaults(geom, list(...))
  d("point", colour = v$paleta[1], size = 2.5 * k)
  d("line", colour = v$paleta[1], linewidth = 1.5 * k)
  d("smooth", colour = v$paleta[1], linewidth = 2 * k)
  d("col", fill = v$paleta[1])
  d("hline", colour = v$texto)
  d("vline", colour = v$vline, linewidth = k)
  for (g in c("text", "label")) d(g, family = v$familia, colour = v$texto, size = 6 * k)
  anterior <- .modo$actual
  .modo$actual <- modo
  invisible(anterior)
}

.onLoad <- function(libname, pkgname) {
  f <- function(cara) system.file("fonts", paste0("EBGaramond-", cara, ".ttf"), package = pkgname)
  systemfonts::register_font("Garamond", f("Regular"), f("Bold"), f("Italic"), f("BoldItalic"))
  vitus_modo("presentacion")
}

.onAttach <- function(libname, pkgname) {
  # library() no avisa que las escalas de vitus enmascaran a las de ggplot2: es a propósito
  assign(".conflicts.OK", TRUE, envir = as.environment(paste0("package:", pkgname)))
  packageStartupMessage(r"[
         _.-'''''-._
    ___.'           '.___
    \___    _____    ___/
        \  /     \  /
        (@| o   o |@)       vitus
        (@|   >   |@)
         @ \ '-' / @
         ___\___/___
        /  \\   //  \
       /    \\_//    \
]")
}

#' Escalas de vitus
#'
#' Reemplazan a las de ggplot2 del mismo nombre: números con punto de miles y
#' coma decimal, fechas en el eje x con un quiebre por año, y leyenda de tamaño
#' compacta. Aceptan los mismos argumentos que las originales.
#' @param ... argumentos de la escala de ggplot2.
#' @param labels,name,date_breaks,date_labels,guide como en ggplot2.
#' @return Una escala de ggplot2.
#' @name escalas
NULL

numero <- function(x) scales::label_number(big.mark = ".", decimal.mark = ",")(x)

#' @rdname escalas
#' @export
scale_y_continuous <- function(..., labels = numero) ggplot2::scale_y_continuous(..., labels = labels)

#' @rdname escalas
#' @export
scale_x_continuous <- function(..., labels = numero) ggplot2::scale_x_continuous(..., labels = labels)

#' @rdname escalas
#' @export
scale_x_date <- function(..., name = NULL, date_breaks = "1 year", date_labels = "%Y") {
  ggplot2::scale_x_date(..., name = name, date_breaks = date_breaks, date_labels = date_labels)
}

guia_tamano <- function(v = .estilos[[.modo$actual]]) {
  ggplot2::guide_legend(
    override.aes = list(colour = v$texto),
    theme = ggplot2::theme(legend.title = ggplot2::element_text(size = v$tamano * 0.65),
                           legend.text = ggplot2::element_text(size = v$tamano * 0.6))
  )
}

#' @rdname escalas
#' @export
scale_size_area <- function(..., guide = guia_tamano()) ggplot2::scale_size_area(..., guide = guide)

#' @rdname escalas
#' @export
scale_size_continuous <- function(..., guide = guia_tamano()) ggplot2::scale_size_continuous(..., guide = guide)

#' @rdname escalas
#' @export
scale_size <- scale_size_continuous

# Si la leyenda de color/relleno no cabe en una fila, la pasa a dos, y rehace la
# leyenda de tamaño de vitus en el modo con que se guarda. No toca las leyendas
# que el usuario ya fijó con guides().
# ponytail: ancho estimado por nº de caracteres (no mide el texto), ajustar el 0.5 si falla con otra fuente
ajustar_guias <- function(p, ancho, v) {
  tryCatch({
    g <- list()
    for (s in ggplot2::ggplot_build(p)$plot$scales$scales) {
      if (any(s$aesthetics %in% names(p$guides$guides))) next
      if (!is.character(s$guide) && isTRUE(s$guide$params$override.aes$colour %in% c(texto, texto_informe))) g$size <- guia_tamano(v)
      if (!any(s$aesthetics %in% c("colour", "fill")) || !s$is_discrete() || identical(s$guide, "none")) next
      l <- s$get_labels()
      pt <- v$tamano * 0.7
      w <- sum(nchar(l)) * 0.5 * pt + length(l) * 2 * pt + 3 * v$tamano # texto + llaves + título
      if (w > 0.95 * ancho * 72) g[[s$aesthetics[1]]] <- ggplot2::guide_legend(nrow = 2)
    }
    if (length(g)) p + do.call(ggplot2::guides, g) else p
  }, error = function(e) p)
}

guardar <- function(p, nombre, carpeta, ancho, alto, formato, modo) {
  stopifnot(inherits(p, "ggplot"))
  formato <- match.arg(formato, c("png", "svg"), several.ok = TRUE)
  anterior <- vitus_modo(modo)
  on.exit(vitus_modo(anterior))
  dir.create(carpeta, recursive = TRUE, showWarnings = FALSE)
  p <- ajustar_guias(p, ancho, .estilos[[modo]])
  sin_fondo <- ggplot2::element_rect(fill = "transparent", colour = NA)
  q <- p + ggplot2::theme(plot.background = sin_fondo, panel.background = sin_fondo,
                           legend.background = sin_fondo, legend.key = sin_fondo) +
    ggplot2::labs(title = NULL)
  dispositivo <- list(png = ragg::agg_png, svg = svglite::svglite)
  for (f in formato)
    ggplot2::ggsave(file.path(carpeta, paste0(nombre, ".", f)), q, width = ancho, height = alto,
                    device = dispositivo[[f]], bg = "transparent")
  if (interactive()) print(p)
  invisible(p)
}

#' Guarda un gráfico transparente y sin título, para el ppt o el informe
#'
#' `ppt()` lo guarda con el formato de presentaciones y `informe()` con el de
#' informes (fondo blanco, Garamond, a la escala de un Word con letra de 11
#' pt), sin importar el modo activo. Por defecto guarda un PNG. Con `formato`
#' también SVG (vectorial, el texto queda editable). En una sesión interactiva
#' además muestra el gráfico (con título). Si la leyenda no cabe en una fila,
#' la pasa a dos.
#' @param p un gráfico de ggplot2.
#' @param nombre nombre del archivo, sin extensión.
#' @param carpeta carpeta de salida. Por defecto, `getOption("vitus.carpeta", "outputs/figuras")`.
#' @param ancho,alto tamaño en pulgadas. En el informe, 6 pulgadas caben en el
#'   ancho de texto de una hoja carta o A4 con márgenes normales.
#' @param formato `"png"`, `"svg"` o ambos. Por defecto,
#'   `getOption("vitus.formato", "png")`.
#' @return `p`, de forma invisible.
#' @export
ppt <- function(p, nombre, carpeta = getOption("vitus.carpeta", "outputs/figuras"), ancho = 8, alto = 5,
                formato = getOption("vitus.formato", "png")) {
  guardar(p, nombre, carpeta, ancho, alto, formato, "presentacion")
}

#' @rdname ppt
#' @export
informe <- function(p, nombre, carpeta = getOption("vitus.carpeta", "outputs/figuras"), ancho = 6, alto = 3.75,
                    formato = getOption("vitus.formato", "png")) {
  guardar(p, nombre, carpeta, ancho, alto, formato, "informe")
}
