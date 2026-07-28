# Proyecto Final: PBI, empleo y crédito bancario departamental en el Perú

## 1. Contexto

- **Fuente de los datos:** INEI (PBI departamental y PEA Ocupada) y SBS (créditos y depósitos de la banca múltiple).
- **Objetivo:** analizar cómo se distribuyen el PBI, el empleo y el crédito bancario entre los departamentos del Perú, y su relación entre sí.
- **Variables principales:** departamento, año, PBI, PEA ocupada, PBI por trabajador, crédito directo, ratio crédito/PBI.

## 2. Estructura

```
data/       -> bases de datos originales y limpias (csv)
figures/    -> gráficos generados (incluye collage_graficos.png)
scripts/    -> EDA.R (Parte 1) y 04_analisis_final.R (Parte 2)
```

## 3. Cómo ejecutar

```r
install.packages(c("readxl", "dplyr", "tidyr", "stringr", "stringi",
                    "ggplot2", "gridExtra", "scales"))

source("scripts/EDA.R")
source("scripts/04_analisis_final.R")
```

## 4. Pregunta de análisis (Parte 2)

¿Qué tan proporcional es el acceso al crédito bancario respecto al PBI de cada departamento?

## 5. Conclusión principal

Lima concentra el 78% del crédito bancario del país con solo el 46% del PBI nacional. La elasticidad crédito-PBI estimada es 1.54 (R² = 0.83), lo que muestra que el crédito no solo sigue el tamaño de la economía regional, sino que además está concentrado geográficamente en la capital, dejando una brecha de inclusión financiera en la sierra.

**Repositorio:** https://github.com/tu-usuario/Proyecto_Final
Captura de Linkedin: <img width="741" height="720" alt="image" src="https://github.com/user-attachments/assets/92dcaa45-d4ae-475f-8efb-ee30945f0b01" /> <img width="770" height="846" alt="image" src="https://github.com/user-attachments/assets/4904bd17-2c0d-49a7-a08c-e195f80d82c0" />

