# =============================================================================
# Proyecto Final - Analisis Exploratorio de Datos (EDA)
# Tema: Actividad economica, empleo y credito bancario a nivel departamental
#       en el Peru (2007 - 2021)
# Autor: [Nombre del estudiante]
# =============================================================================

# -----------------------------------------------------------------------------
# 0. LIBRERIAS
# -----------------------------------------------------------------------------
library(readxl)
library(dplyr)
library(tidyr)
library(stringr)
library(ggplot2)
library(gridExtra)
library(scales)
library(stringi)

# -----------------------------------------------------------------------------
# 1. CONTEXTO DEL CONJUNTO DE DATOS
# -----------------------------------------------------------------------------
# Institucion que proporciona los datos:
#   - Instituto Nacional de Estadistica e Informatica (INEI): PBI departamental
#     y Poblacion Economicamente Activa Ocupada (PEA ocupada).
#   - Superintendencia de Banca, Seguros y AFP (SBS): creditos directos y
#     depositos de la banca multiple por zona geografica.
#
# Objetivo / tematica:
#   Analizar como se distribuye la actividad economica (PBI), el empleo
#   (PEA ocupada) y el acceso al credito bancario entre los 24 departamentos
#   del Peru y la Provincia Constitucional del Callao, e identificar posibles
#   relaciones entre desarrollo economico y profundizacion financiera.
#
# Principales variables analizadas:
#   - departamento      : unidad geografica de analisis (25 categorias)
#   - anio              : anio de referencia
#   - pbi               : Producto Bruto Interno a precios constantes de 2007
#                          (miles de soles)
#   - pea_ocupada       : Poblacion Economicamente Activa Ocupada
#                          (miles de personas)
#   - credito_directo   : Creditos directos totales otorgados por la banca
#                          multiple (miles de soles)
#   - deposito_total    : Depositos totales captados por la banca multiple
#                          (miles de soles)

# -----------------------------------------------------------------------------
# 2. IMPORTACION DE DATOS (directo desde GitHub)
# -----------------------------------------------------------------------------
# URLs "raw" del repositorio en GitHub (usar siempre raw.githubusercontent.com,
# no el link normal de github.com que muestra la vista previa)
url_pbi      <- "https://raw.githubusercontent.com/leydimolina20/PBIdepartamental/main/pbi_peru_17.xlsx"
url_pea      <- "https://raw.githubusercontent.com/leydimolina20/PBIdepartamental/main/peao-cuad-1_3_1.xlsx"
url_creditos <- "https://raw.githubusercontent.com/leydimolina20/PBIdepartamental/main/creditos%20banca%20multiple.xlsx"

dir.create("data", showWarnings = FALSE)
ruta_pbi      <- "data/pbi_peru_17.xlsx"
ruta_pea      <- "data/peao-cuad-1_3_1.xlsx"
ruta_creditos <- "data/creditos banca multiple.xlsx"

# readxl no puede leer un .xlsx directo desde una URL: se descarga primero
# (mode = "wb" es obligatorio porque es un archivo binario)
download.file(url_pbi,      ruta_pbi,      mode = "wb", quiet = TRUE)
download.file(url_pea,      ruta_pea,      mode = "wb", quiet = TRUE)
download.file(url_creditos, ruta_creditos, mode = "wb", quiet = TRUE)

# 2.1 PBI departamental (Cuadro 1: PBI por anios, segun departamentos)
pbi_raw <- read_excel(ruta_pbi, sheet = "cuadro1", col_names = FALSE)

# 2.2 PEA Ocupada por departamento
pea_raw <- read_excel(ruta_pea, sheet = "PEAO cuad 1", col_names = FALSE)

# 2.3 Creditos y depositos de la banca multiple (se usa el anio 2017 para
#     poder relacionarlo con el ultimo anio disponible de PBI y PEA)
creditos_raw <- read_excel(ruta_creditos, sheet = "2017", col_names = FALSE)

# -----------------------------------------------------------------------------
# 3. LIMPIEZA Y PREPARACION
# -----------------------------------------------------------------------------

## 3.1 Funcion para normalizar nombres de departamento (quita tildes,
##     espacios extra y homogeneiza mayusculas/minusculas) para poder
##     cruzar las tres fuentes sin errores de codificacion de texto
normalizar_depto <- function(x) {
  x <- str_trim(x)
  x <- stri_trans_general(x, "Latin-ASCII")   # quita tildes
  x <- str_squish(x)
  x
}

## 3.2 Limpieza: PBI departamental --------------------------------------------
anios_pbi <- as.character(2007:2017)

pbi_dep <- pbi_raw[9:35, 1:12]                      # filas de departamentos
names(pbi_dep) <- c("departamento", anios_pbi)

pbi_dep <- pbi_dep %>%
  mutate(departamento = normalizar_depto(departamento)) %>%
  filter(!departamento %in% c("Region Lima", "Provincia de Lima")) %>%
  mutate(departamento = recode(departamento,
                                "Prov. Const. del Callao" = "Callao")) %>%
  pivot_longer(cols = all_of(anios_pbi), names_to = "anio", values_to = "pbi") %>%
  mutate(anio = as.integer(anio),
         pbi = as.numeric(pbi))

## 3.3 Limpieza: PEA ocupada ---------------------------------------------------
anios_pea <- as.character(2007:2017)

pea_dep <- pea_raw[19:45, 1:12]
names(pea_dep) <- c("departamento", anios_pea)

pea_dep <- pea_dep %>%
  mutate(departamento = normalizar_depto(departamento)) %>%
  filter(!departamento %in% c("Lima Metropolitana 1/", "Lima 2/")) %>%
  mutate(departamento = recode(departamento,
                                "Prov. Const.Callao" = "Callao")) %>%
  pivot_longer(cols = all_of(anios_pea), names_to = "anio", values_to = "pea_ocupada") %>%
  mutate(anio = as.integer(anio),
         pea_ocupada = as.numeric(pea_ocupada))

## 3.4 Limpieza: creditos y depositos de la banca multiple (2017) -------------
names(creditos_raw)[1:18] <- c(
  "departamento", "provincia", "distrito",
  "cd_mn", "cd_me", "credito_directo",
  "dv_mn", "dv_me", "dv_total",
  "da_mn", "da_me", "da_total",
  "dp_mn", "dp_me", "dp_total",
  "dt_mn", "dt_me", "deposito_total"
)

creditos_dep <- creditos_raw %>%
  mutate(departamento = normalizar_depto(departamento)) %>%
  filter(str_starts(departamento, "Total ")) %>%
  mutate(departamento = str_remove(departamento, "^Total ")) %>%
  filter(!departamento %in% c("Nacional", "Extranjero", "general")) %>%
  transmute(departamento,
            anio = 2017L,
            credito_directo = as.numeric(credito_directo),
            deposito_total = as.numeric(deposito_total))

## 3.5 Union de bases -----------------------------------------------------------
# Panel PBI - PEA ocupada 2007-2017 (25 departamentos x 11 anios)
panel_pbi_pea <- pbi_dep %>%
  inner_join(pea_dep, by = c("departamento", "anio")) %>%
  mutate(pbi_por_trabajador = (pbi * 1000) / (pea_ocupada * 1000))  # soles / persona

# Corte transversal 2017: PBI, PEA y credito
cross_2017 <- panel_pbi_pea %>%
  filter(anio == 2017) %>%
  inner_join(creditos_dep, by = c("departamento", "anio")) %>%
  mutate(credito_pc = (credito_directo * 1000) / (pea_ocupada * 1000),   # soles / trabajador
         credito_pbi = credito_directo / pbi)                            # ratio credito/PBI

# Nueva variable: region macro (Costa/Sierra/Selva) para agrupar
region_macro <- c(
  Amazonas = "Selva", Ancash = "Costa", Apurimac = "Sierra", Arequipa = "Costa",
  Ayacucho = "Sierra", Cajamarca = "Sierra", Callao = "Costa", Cusco = "Sierra",
  Huancavelica = "Sierra", Huanuco = "Sierra", Ica = "Costa", Junin = "Sierra",
  `La Libertad` = "Costa", Lambayeque = "Costa", Lima = "Costa", Loreto = "Selva",
  `Madre de Dios` = "Selva", Moquegua = "Costa", Pasco = "Sierra", Piura = "Costa",
  Puno = "Sierra", `San Martin` = "Selva", Tacna = "Costa", Tumbes = "Costa",
  Ucayali = "Selva"
)
panel_pbi_pea <- panel_pbi_pea %>% mutate(region = region_macro[departamento])
cross_2017    <- cross_2017    %>% mutate(region = region_macro[departamento])

## 3.6 Guardar datos limpios
write.csv(panel_pbi_pea, "data/panel_pbi_pea_2007_2017.csv", row.names = FALSE)
write.csv(cross_2017,    "data/cross_section_2017.csv",       row.names = FALSE)

# -----------------------------------------------------------------------------
# 4. ESTADISTICAS DESCRIPTIVAS
# -----------------------------------------------------------------------------
cat("\n--- Resumen general del panel PBI - PEA (2007-2017) ---\n")
print(summary(panel_pbi_pea[, c("pbi", "pea_ocupada", "pbi_por_trabajador")]))

cat("\n--- Estadisticas descriptivas por region (corte 2017) ---\n")
tabla_region <- cross_2017 %>%
  group_by(region) %>%
  summarise(
    n_departamentos   = n(),
    pbi_promedio      = mean(pbi),
    pbi_total         = sum(pbi),
    pea_promedio      = mean(pea_ocupada),
    credito_promedio  = mean(credito_directo),
    credito_pbi_prom  = mean(credito_pbi),
    .groups = "drop"
  ) %>%
  arrange(desc(pbi_total))
print(tabla_region)

cat("\n--- Departamentos con mayor y menor PBI por trabajador (2017) ---\n")
print(cross_2017 %>% arrange(desc(pbi_por_trabajador)) %>%
        select(departamento, pbi_por_trabajador) %>% head(5))
print(cross_2017 %>% arrange(pbi_por_trabajador) %>%
        select(departamento, pbi_por_trabajador) %>% head(5))

cat("\n--- Correlacion credito directo vs PBI (2017) ---\n")
print(cor(cross_2017$credito_directo, cross_2017$pbi))

# -----------------------------------------------------------------------------
# 5. VISUALIZACION DE DATOS (ggplot2)
# -----------------------------------------------------------------------------
tema_proyecto <- theme_minimal(base_size = 12) +
  theme(plot.title = element_text(face = "bold"),
        plot.subtitle = element_text(color = "gray30"),
        legend.position = "bottom")

## Grafico 1: evolucion del PBI nacional agregado 2007-2017 -------------------
pbi_nacional <- panel_pbi_pea %>%
  group_by(anio) %>%
  summarise(pbi_total = sum(pbi, na.rm = TRUE), .groups = "drop")

g1 <- ggplot(pbi_nacional, aes(x = anio, y = pbi_total / 1e6)) +
  geom_line(color = "#1f77b4", linewidth = 1.1) +
  geom_point(color = "#1f77b4", size = 2) +
  scale_x_continuous(breaks = 2007:2017) +
  labs(
    title = "Evolucion del PBI nacional, 2007-2017",
    subtitle = "Suma de los 25 departamentos, a precios constantes de 2007",
    x = "Año", y = "PBI (millones de soles)",
    caption = "Fuente: INEI"
  ) +
  tema_proyecto +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

## Grafico 2: PBI por trabajador segun region, 2017 (boxplot) -----------------
g2 <- ggplot(cross_2017, aes(x = reorder(region, pbi_por_trabajador, FUN = median),
                              y = pbi_por_trabajador, fill = region)) +
  geom_boxplot(alpha = 0.8, show.legend = FALSE) +
  geom_jitter(width = 0.15, alpha = 0.5, size = 1.8) +
  scale_y_continuous(labels = label_comma()) +
  scale_fill_brewer(palette = "Set2") +
  labs(
    title = "Productividad laboral departamental segun macrorregion, 2017",
    subtitle = "PBI por trabajador (soles por persona ocupada)",
    x = "Macrorregion", y = "PBI por trabajador (S/)",
    caption = "Fuente: INEI (PBI departamental y PEA ocupada)"
  ) +
  tema_proyecto

## Grafico 3: relacion credito directo vs PBI, 2017 (dispersión) --------------
g3 <- ggplot(cross_2017, aes(x = pbi / 1e6, y = credito_directo / 1e6, color = region)) +
  geom_point(size = 3, alpha = 0.85) +
  scale_x_log10(labels = label_comma()) +
  scale_y_log10(labels = label_comma()) +
  scale_color_brewer(palette = "Set2") +
  labs(
    title = "Credito bancario directo vs. PBI departamental, 2017",
    subtitle = "Escala logaritmica en ambos ejes",
    x = "PBI (millones de soles, escala log)",
    y = "Credito directo de la banca multiple (millones de soles, escala log)",
    color = "Macrorregion",
    caption = "Fuente: INEI y SBS"
  ) +
  tema_proyecto

## Guardar graficos individuales
ggsave("figures/01_evolucion_pbi_nacional.png", g1, width = 8, height = 5, dpi = 150)
ggsave("figures/02_pbi_trabajador_region.png",  g2, width = 8, height = 5, dpi = 150)
ggsave("figures/03_credito_vs_pbi.png",         g3, width = 8, height = 5, dpi = 150)

## Collage de graficos (requerido en figures/collage_graficos.png)
collage <- grid.arrange(g1, g2, g3, ncol = 1)
ggsave("figures/collage_graficos.png", collage, width = 8, height = 15, dpi = 150)

cat("\nEDA finalizado. Datos limpios guardados en /data y graficos en /figures.\n")
