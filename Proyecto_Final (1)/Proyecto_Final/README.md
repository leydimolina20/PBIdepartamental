# Proyecto Final: Actividad económica, empleo y crédito bancario departamental en el Perú

## 1. Contexto del conjunto de datos

**Instituciones que proporcionan los datos:**
- **Instituto Nacional de Estadística e Informática (INEI):** Producto Bruto Interno (PBI) departamental y Población Económicamente Activa (PEA) Ocupada.
- **Superintendencia de Banca, Seguros y AFP (SBS):** créditos directos y depósitos de la banca múltiple por zona geográfica.

**Objetivo / temática:**
Analizar cómo se distribuyen la actividad económica (PBI), el empleo (PEA ocupada) y el acceso al crédito bancario entre los 24 departamentos del Perú y la Provincia Constitucional del Callao, e identificar posibles relaciones entre desarrollo económico y profundización financiera.

**Principales variables analizadas:**

| Variable | Descripción | Unidad |
|---|---|---|
| `departamento` | Unidad geográfica de análisis (25 categorías) | — |
| `anio` | Año de referencia (2007-2017) | — |
| `pbi` | Producto Bruto Interno a precios constantes de 2007 | Miles de soles |
| `pea_ocupada` | Población Económicamente Activa Ocupada | Miles de personas |
| `pbi_por_trabajador` | PBI / PEA ocupada (productividad laboral aparente) | Soles por persona |
| `credito_directo` | Créditos directos otorgados por la banca múltiple (2017) | Miles de soles |
| `deposito_total` | Depósitos totales captados por la banca múltiple (2017) | Miles de soles |
| `credito_pbi` | Crédito directo / PBI (indicador de profundización financiera) | Ratio |
| `region` | Macrorregión natural (Costa, Sierra, Selva) | — |

## 2. Estructura del repositorio

```
Proyecto_Final/
│
├── data/
│   ├── pbi_peru_17.xlsx                    # datos crudos INEI (PBI)
│   ├── peao-cuad-1_3_1.xlsx                # datos crudos INEI (PEA ocupada)
│   ├── creditos banca multiple.xlsx        # datos crudos SBS (créditos y depósitos)
│   ├── panel_pbi_pea_2007_2017.csv         # panel limpio 2007-2017 (25 dptos x 11 años)
│   └── cross_section_2017.csv              # corte transversal 2017 (PBI, PEA y crédito)
│
├── figures/
│   ├── 01_evolucion_pbi_nacional.png
│   ├── 02_pbi_trabajador_region.png
│   ├── 03_credito_vs_pbi.png
│   ├── 04_credito_pbi_ranking.png
│   └── collage_graficos.png
│
├── scripts/
│   ├── EDA.R                    # Parte 1: importación, limpieza, descriptivos y gráficos
│   └── 04_analisis_final.R      # Parte 2: análisis final y conclusiones
│
└── README.md
```

## 3. Cómo ejecutar el proyecto

```r
# Desde la carpeta Proyecto_Final/
install.packages(c("readxl", "dplyr", "tidyr", "stringr", "stringi",
                    "ggplot2", "gridExtra", "scales"))

source("scripts/EDA.R")
source("scripts/04_analisis_final.R")
```

## 4. Parte 1 — Hallazgos principales del EDA

- El PBI nacional (suma de los 25 departamentos) creció de forma sostenida entre 2007 y 2017.
- La productividad laboral (PBI por trabajador) es notoriamente más alta en los departamentos de la Costa (Moquegua, Arequipa, Lima, Callao) que en la Sierra y la Selva.
- El crédito bancario directo está fuertemente correlacionado con el PBI departamental (r ≈ 0.99).

## 5. Parte 2 — Pregunta de análisis

**¿Qué tan proporcional es el acceso al crédito bancario respecto al nivel de actividad económica de cada departamento, y qué tan concentrado está el sistema financiero en Lima frente al resto del país?**

### Análisis

- Se estimó una regresión log-log `log(credito_directo) ~ log(pbi)` con los 25 departamentos (2017): la elasticidad estimada es de **≈ 1.54** (R² = 0.83), es decir, el crédito bancario crece más que proporcionalmente respecto al PBI departamental.
- Se construyó el indicador `credito_pbi` (crédito directo / PBI) para medir la profundización financiera de cada departamento. El ratio va desde **1%** en Huancavelica hasta **85%** en Lima.
- Lima concentra el **78%** del crédito directo del país con solo el **46%** del PBI nacional, mientras que departamentos de la Sierra (Huancavelica, Apurímac, Pasco, Ayacucho) reciben crédito equivalente a menos del 11% de su propio PBI.

### Conclusiones

1. Existe una relación positiva y muy fuerte entre el PBI departamental y el crédito bancario directo, con una elasticidad superior a 1, lo que indica que el sistema financiero no solo sigue el tamaño de la economía regional, sino que además tiende a concentrarse desproporcionadamente en los departamentos más grandes.
2. La profundización financiera (crédito/PBI) es marcadamente desigual entre regiones: la Costa —y en particular Lima— concentra el acceso al crédito muy por encima de su participación en el PBI nacional, mientras que la Sierra está sistemáticamente sub-bancarizada.
3. La evidencia responde a la pregunta planteada: el acceso al crédito en el Perú **no es proporcional** al nivel de actividad económica departamental; existe una brecha adicional de inclusión financiera que castiga principalmente a los departamentos con menor PBI per cápita.

---

**Repositorio del proyecto:** `https://github.com/<tu-usuario>/Proyecto_Final`

**Publicación en redes (LinkedIn/X) con el hallazgo final:** *(adjuntar captura de pantalla — ver instrucciones de entrega)*
