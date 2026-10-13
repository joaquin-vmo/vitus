# vitus

```
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
```

Formato de figuras para presentaciones e informes El de presentaciones (fondo oscuro, Georgia) queda activo con
solo cargar el paquete. El de informes (fondo blanco, Garamond, para un Word en 11 pt)
se usa al guardar con `informe()`.

Esta guía se sigue de principio a fin con los datos sintéticos de `ejemplo/datos.rds`.

## 1. Instalar

Requiere R ≥ 4.1. Para instalar o actualizar:

```r
install.packages("remotes")
remotes::install_github("joaquin-vmo/vitus")
```

Las dependencias (`tidyverse`, `ragg`, `scales`, `svglite` y `systemfonts`) se instalan solas.

## 2. Cargar

```r
library(vitus)   # carga también tidyverse
```

Con esto queda listo:
- el tema oscuro, la fuente Georgia y la paleta de colores
- líneas y puntos más gruesos, a la escala de una diapositiva
- números con punto de miles y coma decimal en los ejes (`1.000`, `2,5`)
- un año por quiebre en los ejes de fechas
- los colores `fondo`, `texto`, `color_vline` y `paleta` (y sus versiones para informe: `texto_informe`,
  `color_vline_informe` y `paleta_informe`)

vitus reemplaza algunas escalas de ggplot2 (`scale_y_continuous()` y otras) por versiones con
su formato de números.

## 3. Gráficos

Hay que escribir el ggplot2 básico, sin personalización. Los colores salen de la paleta y en orden.

```r
datos <- readRDS("datos.rds")
list2env(datos, environment())   # trimestral, mensual, precios, ...

p <- ggplot(trimestral, aes(trimestre, kg, color = calidad)) +
  geom_line() +
  geom_point() +
  labs(title = "Cantidad por calidad", y = "Cantidad (kg)", color = "Calidad")
p
```

## 4. Guardar para el ppt

```r
ppt(p, "01_series_trimestrales")
```

`ppt()` guarda `outputs/figuras/01_series_trimestrales.png` con estas características:

- **fondo transparente**, para que la figura tome el fondo de la diapositiva
- **sin título**, porque el título va en la diapositiva (en RStudio el gráfico se muestra con título, para revisarlo)
- **8 × 5 pulgadas**
- **leyenda en dos filas** si no cabe en una

Se puede cambiar:

```r
ppt(p, "fig", carpeta = "outputs") # otra carpeta
ppt(p, "fig", ancho = 10, alto = 4) # otro tamaño, en pulgadas
ppt(p, "fig", formato = "svg") # SVG
ppt(p, "fig", formato = c("png", "svg")) # ambos
```

Para no repetirlo en cada figura, se puede fijar una vez al inicio del script

```r
options(vitus.carpeta = "outputs", vitus.formato = c("png", "svg"))
```

SVG es una mejor opción para los informes y presentaciones. 

## 5. Guardar para el informe

```r
informe(p, "01_series_trimestrales")
```

Funciona igual que `ppt()` (transparente, sin título, mismos `carpeta`, `formato` y opciones),
pero con el formato de informe:

- **fuente EB Garamond**, que viene incluida en el paquete
- **colores para fondo blanco**: `paleta_informe`, `texto_informe` y `color_vline_informe`
- **6 × 3,75 pulgadas**, que caben en el ancho de texto de una hoja carta o A4 con márgenes normales.
  Se inserta en Word al 100 %: los ejes quedan en ~9,5 pt y la leyenda en ~8,5 pt, junto a un
  texto de 11 pt.

El mismo gráfico sirve para los dos formatos, porque `ppt()` e `informe()` aplican cada uno el suyo al guardar:

```r
ppt(p, "fig")
informe(p, "fig", carpeta = "outputs/informe")
```

Para ver en RStudio cómo quedará en el informe, usa `vitus_modo("informe")`, y para volver,
`vitus_modo("presentacion")`.

Los colores que se escriben a mano no cambian solos: en un gráfico para el informe usa
`paleta_informe[2]` o `color_vline_informe` en vez de `paleta[2]` o `color_vline`.

## 6. Recetas

Todas salen de `ejemplo/ejemplos.R`.

**Porcentajes en el eje y**

```r
ggplot(margen, aes(trimestre, margen)) +
  geom_line() +
  scale_y_continuous(labels = scales::label_percent(decimal.mark = ","))
```

**Años enteros en el eje x** (si `anio` es número, el eje lo muestra como `2.019`)

```r
ggplot(mercado, aes(anio, toneladas, color = pais)) +
  geom_line() +
  scale_x_continuous(breaks = unique(mercado$anio), labels = as.character)
```

**Eje y desde cero**

```r
... + scale_y_continuous(limits = c(0, NA))
```

**Fechas cada dos años** (por defecto el eje muestra un año por quiebre)

```r
... + scale_x_date(date_breaks = "2 years")
```

**Líneas de referencia y anotaciones.** `geom_vline()` ya sale en el color de referencia del
formato, y `geom_hline()` y `annotate("text")` en el color del texto. Si no se les pone color a mano,
la misma figura sirve para el ppt y para el informe:

```r
corte <- as.Date("2024-07-01")
ggplot(precios, aes(fecha, precio, color = formato)) +
  geom_point(alpha = 0.3) +
  geom_smooth(method = "loess", se = FALSE) +
  geom_vline(xintercept = corte, linetype = "dashed") +
  geom_hline(yintercept = 3500) +
  annotate("text", x = corte, y = Inf, label = "Cambio de política", hjust = 1.05, vjust = 1.5)
```

**Barras y ranking con etiquetas.** Las barras toman la paleta, y `geom_text()` ya usa
la fuente y el color del tema:

```r
ggplot(ranking, aes(monto_mm, reorder(proveedor, monto_mm))) +
  geom_col() +
  geom_text(aes(label = monto_mm), hjust = -0.2) +
  scale_x_continuous(expand = expansion(mult = c(0, 0.12))) +
  labs(x = "Monto (MM CLP)", y = NULL)
```

**Facetas y tamaño de punto.** La leyenda de tamaño sale compacta sola:

```r
ggplot(zonas, aes(trimestre, kg, color = zona)) +
  geom_line() +
  geom_point(aes(size = proveedores)) +
  facet_wrap(vars(formato), nrow = 1, strip.position = "bottom")
```

**Etiquetas del eje inclinadas**

```r
... + theme(axis.text.x = element_text(angle = 45, hjust = 1))
```

**Elegir colores a mano**

```r
geom_line(colour = paleta[2])                       # uno de la paleta
scale_color_manual(values = c(Costaverde = paleta[1], Norlandia = paleta[3], Sudamar = paleta[5]))
```

## 7. Si algo no se ve bien

- **Un texto o una anotación se sale del gráfico:** agrega `coord_cartesian(clip = "off")` y más
  margen con `theme(plot.margin = margin(5.5, 60, 5.5, 5.5))`.
- **La leyenda quedó en dos filas y prefieres una:** acorta las etiquetas o aumenta `ancho`.
- **Aparece otra fuente:** Georgia viene con macOS y Windows. En otros sistemas R usa una de reemplazo.
  El PNG del informe siempre usa la Garamond del paquete. El SVG, en cambio, solo nombra la fuente:
  Word lo muestra con la Garamond que tenga instalada (viene con Office).
- **Quieres volver al estilo normal de ggplot2 en la sesión:** reinicia R. vitus cambia el tema y los
  defaults de toda la sesión.
