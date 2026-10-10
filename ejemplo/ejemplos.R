# Ejemplos de figuras con vitus, sobre datos completamente sintéticos
# (datos.rds). Correr desde esta carpeta:
#   setwd("ejemplo")
#   source("ejemplos.R")
library(vitus)
options(vitus.formato = c("png", "svg"))

# cada figura se guarda en los dos formatos. Lo único que cambia es ppt() o informe()
guardar <- function(p, nombre) {
  ppt(p, nombre, carpeta = "outputs/presentacion")
  informe(p, nombre, carpeta = "outputs/informe")
}

datos <- readRDS("datos.rds")
list2env(datos, environment()) # trimestral, mensual, precios, zonas, dispersion, margen, mercado, cuota, ranking


# 1. Series trimestrales: una línea por categoría, colores de la paleta en orden
guardar(ggplot(trimestral, aes(trimestre, kg, color = calidad)) +
          geom_line() +
          geom_point() +
          labs(y = "Cantidad (kg)", color = "Calidad"),
        "01_series_trimestrales")

# 2. Una sola serie: el color por defecto es el primero de la paleta
guardar(trimestral |>
          summarise(kg = sum(kg), .by = trimestre) |>
          ggplot(aes(trimestre, kg)) +
          geom_line() +
          geom_point() +
          labs(y = "Cantidad total (kg)"),
        "02_una_serie")

# 3. Barras apiladas por mes (geom_col toma los colores de la paleta)
guardar(ggplot(mensual, aes(mes, kg, fill = calidad)) +
          geom_col() +
          labs(y = "Cantidad (kg)", fill = "Calidad"),
        "03_barras_apiladas")

# 4. Nube de precios con tendencia por formato, línea objetivo y fecha de corte
fecha_corte <- as.Date("2024-07-01")
guardar(ggplot(precios, aes(fecha, precio, color = formato)) +
          geom_point(alpha = 0.3) +
          geom_smooth(method = "loess", span = 0.4, se = FALSE) +
          geom_hline(yintercept = 3500) +
          geom_vline(xintercept = fecha_corte, linetype = "dashed") +
          annotate("text", x = fecha_corte, y = Inf, label = "Cambio de política", hjust = 1.05, vjust = 1.5) +
          annotate("text", x = as.Date(Inf), y = 3500, label = " 3.500", hjust = 0) +
          coord_cartesian(clip = "off") +
          theme(plot.margin = margin(5.5, 60, 5.5, 5.5)) +
          labs(y = "Precio (CLP/kg)", color = "Formato"),
        "04_precios_tendencia")

# 5. Facetas, y tamaño del punto = proveedores (leyenda de tamaño automática)
guardar(ggplot(zonas, aes(trimestre, kg, color = zona)) +
          geom_line() +
          geom_point(aes(size = proveedores)) +
          facet_wrap(vars(formato), nrow = 1, strip.position = "bottom") +
          scale_x_date(date_breaks = "2 years") +
          labs(y = "Cantidad (kg)", color = "Zona", size = "Proveedores"),
        "05_facetas_y_tamano")

# 6. Eje x categórico (años como texto), línea vertical entre categorías y etiquetas inclinadas
guardar(ggplot(dispersion, aes(anio, cv, color = formato, group = formato)) +
          geom_line() +
          geom_vline(xintercept = "2023", linetype = "dashed") +
          geom_point(aes(size = proveedores)) +
          theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
          labs(x = NULL, y = "Dispersión de precios", color = "Formato", size = "Proveedores"),
        "06_eje_categorico")

# 7. Porcentajes en el eje y, línea en cero y fecha de corte
guardar(ggplot(margen, aes(trimestre, margen)) +
          geom_line() +
          geom_point() +
          geom_hline(yintercept = 0, linewidth = 0.3) +
          geom_vline(xintercept = as.Date("2023-03-23"), linetype = "dashed") +
          scale_y_continuous(labels = scales::label_percent(decimal.mark = ",")) +
          labs(y = "Margen"),
        "07_porcentajes")

# 8. Años enteros en el eje x y porcentajes con coma decimal
guardar(ggplot(cuota, aes(anio, cuota, color = destino)) +
          geom_line() +
          geom_point() +
          scale_x_continuous(breaks = unique(cuota$anio), labels = as.character) +
          scale_y_continuous(labels = scales::label_percent(decimal.mark = ","), limits = c(0, NA)) +
          labs(x = NULL, y = "% de las toneladas importadas", color = NULL),
        "08_anios_enteros")

# 9. Comparación entre países, eje y desde cero
guardar(ggplot(mercado, aes(anio, toneladas, color = pais)) +
          geom_line() +
          geom_point() +
          scale_x_continuous(breaks = unique(mercado$anio), labels = as.character) +
          scale_y_continuous(limits = c(0, NA)) +
          labs(x = NULL, y = "Toneladas", color = NULL),
        "09_comparacion_paises")

# 10. Ranking de barras horizontales con etiquetas de texto
guardar(ggplot(ranking, aes(monto_mm, reorder(proveedor, monto_mm))) +
          geom_col() +
          geom_text(aes(label = monto_mm), hjust = -0.2) +
          scale_x_continuous(expand = expansion(mult = c(0, 0.12))) +
          labs(x = "Monto (MM CLP)", y = NULL),
        "10_ranking_barras")
