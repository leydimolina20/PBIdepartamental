# =============================================================================
# 04_analisis_final.R
# Parte 2: Analisis a partir de los hallazgos del EDA
# =============================================================================
# Este script asume que ya se ejecuto scripts/EDA.R y que existen los archivos
# data/panel_pbi_pea_2007_2017.csv y data/cross_section_2017.csv

library(dplyr)
library(ggplot2)
library(scales)

cross_2017 <- read.csv("data/cross_section_2017.csv", stringsAsFactors = FALSE)

# -----------------------------------------------------------------------------
# 1. PREGUNTA DE ANALISIS
# -----------------------------------------------------------------------------
# Durante el EDA se observo que el credito directo otorgado por la banca
# multiple esta altamente correlacionado con el PBI departamental (r = 0.99),
# pero tambien que el ratio credito/PBI varia enormemente entre departamentos
# (desde 1% en Huancavelica hasta 85% en Lima). A partir de este hallazgo se
# plantea la siguiente pregunta:
#
#   ¿Que tan proporcional es el acceso al credito bancario respecto al nivel
#   de actividad economica de cada departamento, y que tan concentrado esta
#   el sistema financiero en Lima frente al resto del pais?

# -----------------------------------------------------------------------------
# 2. ANALISIS DE LA RELACION ENTRE VARIABLES
# -----------------------------------------------------------------------------

## 2.1 Relacion PBI - credito directo (regresion log-log) ---------------------
# Se usa una especificacion log-log porque ambas variables tienen una
# distribucion muy asimetrica (Lima concentra una fraccion muy alta del PBI
# y del credito nacional), y el coeficiente log-log se interpreta como una
# elasticidad credito-PBI.
modelo <- lm(log(credito_directo) ~ log(pbi), data = cross_2017)
cat("\n--- Regresion log(credito_directo) ~ log(pbi), 25 departamentos, 2017 ---\n")
print(summary(modelo))

elasticidad <- coef(modelo)[["log(pbi)"]]
r2 <- summary(modelo)$r.squared
cat(sprintf("\nElasticidad estimada credito/PBI: %.2f\n", elasticidad))
cat(sprintf("R-cuadrado del modelo: %.3f\n", r2))

## 2.2 Indicador de profundizacion financiera (credito / PBI) -----------------
tabla_ratio <- cross_2017 %>%
  mutate(es_lima = departamento == "Lima") %>%
  select(departamento, pbi, credito_directo, credito_pbi, pbi_por_trabajador) %>%
  arrange(desc(credito_pbi))

cat("\n--- Ranking de profundizacion financiera (credito directo / PBI), 2017 ---\n")
print(tabla_ratio)

## 2.3 Lima vs. resto del pais --------------------------------------------------
comparacion_lima <- cross_2017 %>%
  mutate(grupo = ifelse(departamento == "Lima", "Lima", "Resto del pais")) %>%
  group_by(grupo) %>%
  summarise(
    pbi_total       = sum(pbi),
    credito_total   = sum(credito_directo),
    participacion_pbi     = NA_real_,
    participacion_credito = NA_real_,
    .groups = "drop"
  )
comparacion_lima$participacion_pbi     <- comparacion_lima$pbi_total / sum(cross_2017$pbi)
comparacion_lima$participacion_credito <- comparacion_lima$credito_total / sum(cross_2017$credito_directo)

cat("\n--- Participacion de Lima frente al resto del pais (PBI y credito), 2017 ---\n")
print(comparacion_lima)

# -----------------------------------------------------------------------------
# 3. VISUALIZACION PARA EL ANALISIS FINAL
# -----------------------------------------------------------------------------
tema_proyecto <- theme_minimal(base_size = 12) +
  theme(plot.title = element_text(face = "bold"),
        plot.subtitle = element_text(color = "gray30"),
        legend.position = "bottom")

g4 <- ggplot(cross_2017,
             aes(x = reorder(departamento, credito_pbi), y = credito_pbi, fill = region)) +
  geom_col() +
  geom_hline(yintercept = mean(cross_2017$credito_pbi), linetype = "dashed",
             color = "gray30") +
  coord_flip() +
  scale_y_continuous(labels = percent_format(accuracy = 1)) +
  scale_fill_brewer(palette = "Set2") +
  labs(
    title = "Profundizacion financiera departamental, Peru 2017",
    subtitle = "Credito directo de la banca multiple como proporcion del PBI departamental",
    x = NULL, y = "Credito directo / PBI",
    fill = "Macrorregion",
    caption = "Linea punteada = promedio de los 25 departamentos | Fuente: INEI y SBS"
  ) +
  tema_proyecto

ggsave("figures/04_credito_pbi_ranking.png", g4, width = 8, height = 7, dpi = 150)

# -----------------------------------------------------------------------------
# 4. CONCLUSIONES
# -----------------------------------------------------------------------------
cat("\n=================== CONCLUSIONES ===================\n")
pct_credito_lima <- round(comparacion_lima$participacion_credito[comparacion_lima$grupo == "Lima"] * 100, 0)
pct_pbi_lima     <- round(comparacion_lima$participacion_pbi[comparacion_lima$grupo == "Lima"] * 100, 0)
cat(
"1. Existe una relacion positiva y muy fuerte entre el PBI departamental y el\n",
"   credito directo otorgado por la banca multiple (r = 0.99 en niveles). La\n",
"   regresion log-log arroja una elasticidad credito/PBI cercana a ", round(elasticidad, 2), ",\n",
"   lo que indica que un incremento porcentual en el PBI de un departamento\n",
"   se asocia, en promedio, con un incremento mas que proporcional en el\n",
"   credito bancario que recibe.\n\n",
"2. Sin embargo, el ratio credito/PBI muestra una fuerte disparidad: Lima\n",
"   concentra alrededor del ", pct_credito_lima,
"% del credito directo del pais con solo el ", pct_pbi_lima,
"% del PBI nacional, mientras que departamentos como Huancavelica, Apurimac\n",
"   y Pasco reciben credito equivalente a menos del 6% de su PBI. Esto sugiere\n",
"   que el credito bancario no solo sigue el tamaño de la economia regional,\n",
"   sino que esta ademas concentrado geograficamente en la capital.\n\n",
"3. En conjunto, la evidencia responde a la pregunta planteada: el acceso al\n",
"   credito bancario en el Peru es solo parcialmente proporcional al nivel de\n",
"   actividad economica departamental; existe una brecha adicional de\n",
"   profundizacion financiera que castiga principalmente a los departamentos\n",
"   de la sierra (Huancavelica, Apurimac, Ayacucho), los cuales combinan bajo\n",
"   PBI per capita y bajo acceso relativo al sistema bancario formal.\n",
sep = "")
