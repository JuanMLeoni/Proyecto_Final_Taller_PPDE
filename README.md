# Análisis de Calidad del Café y Modelos Predictivos
 
Trabajo Práctico Final — Taller de Pre-procesamiento de Datos Estructurados
 
**Autores:** Juan Martín Leoni / Facundo Rubiolo
 
---
 
## Descripción
 
Este proyecto analiza un conjunto de datos sobre evaluación internacional de la calidad del café (variedad arábica), evaluado por catadores profesionales certificados (Q-graders) bajo el protocolo de la Specialty Coffee Association (SCA).
 
A través de técnicas de pre-procesamiento, análisis exploratorio y modelado estadístico (regresión lineal múltiple y regresión logística), el trabajo busca responder dos preguntas:
 
1. **¿Qué variables sensoriales y físicas determinan el puntaje final de una taza de café?** (Total Cup Points)
2. **¿Qué factores permiten predecir si un café alcanza el grado de "Excelencia"?**
Como complemento, se incluye un análisis adicional que evalúa el efecto de la **endogeneidad** presente en los modelos principales, ajustando versiones alternativas con variables genuinamente independientes del puntaje.
 
## Fuente de datos
 
Los datos son reales y provienen del **Coffee Quality Institute (CQI)**, recopilados a través de la base pública de Kaggle *"Coffee Quality Data (CQI)"*. Cada registro corresponde a la evaluación de cata profesional de un lote de café arábica de distintos países de origen.
 
## Estructura del repositorio
 
```
├── data/
│   └── df_arabica_clean.csv     # Dataset original
│   └── ICO_norm.csv     # Dataset limpio y normalizado
├── script/
├── Final.qmd            # Notebook con el análisis completo (código R)
├── Final.html           # Reporte final renderizado (HTML)
└── README.md
```
 
## Metodología
 
### 1. Pre-procesamiento y limpieza
- Normalización de formatos (peso del bolsón, fechas de cosecha y grading).
- Recodificación de categorías con errores de tipeo o alta cardinalidad (color del grano, método de procesamiento).
- Creación de variables derivadas (altitud promedio a partir de rangos de texto).
- Detección y filtrado de outliers físicamente imposibles (altitudes superiores a 4000 msnm, producto de errores de carga manual).
### 2. Análisis exploratorio (EDA)
- Distribución del puntaje total (Total Cup Points).
- Matriz de correlación entre variables sensoriales y el puntaje total.
- Relación entre altitud y calidad, previo y posterior al tratamiento de atípicos.
### 3. Regresión Lineal Múltiple
- Selección de variables mediante procedimiento backward por criterio AIC (`stepAIC`).
- Modelo final: `Total.Cup.Points ~ Flavor + Balance + Altitude_Promedio` (R² ajustado ≈ 0.945).
- Evaluación de supuestos: multicolinealidad (VIF), homocedasticidad (Breusch-Pagan), normalidad de residuos (Anderson-Darling), independencia (Durbin-Watson) y observaciones influyentes (distancia de Cook).
### 4. Regresión Logística
- Variable respuesta binaria `Cafe_Excelente` (umbral: Total Cup Points ≥ 83.5, alineado al criterio de café de especialidad de la SCA).
- Selección de modelo entre variables sensoriales y categóricas (color, método de procesamiento).
- Modelo final: `Cafe_Excelente ~ Acidity + Body + Aroma`.
- Evaluación de capacidad predictiva: curva ROC/AUC, matriz de confusión y validación con partición train/test (70/30).
### 5. Modelo alternativo sin endogeneidad
Los modelos principales usan como predictoras variables que son, en parte, componentes directos del propio puntaje total (Flavor, Balance, Acidity, Body, Aroma), lo que infla artificialmente las métricas de ajuste y predicción.
 
Para evaluar el efecto real de características objetivas del cultivo, se ajustaron modelos alternativos utilizando exclusivamente variables independientes del puntaje: altitud, humedad, defectos de categoría 1 y 2, y proporción de granos sin madurar (*quakers*). La comparación entre ambos enfoques permite dimensionar cuánto del poder predictivo de los modelos principales se explica por circularidad y cuánto por relaciones genuinas.
 
## Resultados principales
 
| | Modelo principal | Modelo sin endogeneidad |
|---|---|---|
| Variables | Flavor, Balance, Altitud / Acidity, Body, Aroma | Altitud, Defectos cat. 2 (/ Quakers según modelo) |
| R² ajustado (lineal) | 0.945 | 0.212 |
| AUC (logístico) | 0.979 | 0.670 |
| Endogeneidad | Sí | No |
 
La caída marcada en ambas métricas confirma que gran parte del poder explicativo/predictivo de los modelos principales proviene de la relación estructural entre las variables sensoriales y el puntaje total. Aun así, el modelo sin endogeneidad identifica un efecto genuino y significativo de la altitud y la ausencia de defectos sobre la calidad del café.
 
## Limitaciones
 
- **Subjetividad de las variables predictoras**: las variables sensoriales con mayor peso predictivo son evaluaciones humanas, no mediciones físicas objetivas.
- **Calidad de los registros originales**: se detectaron errores de carga manual en variables como altitud; podrían existir anomalías similares no identificadas en otras columnas.
- **Endogeneidad parcial**: ya descripta arriba; abordada mediante el modelo complementario de la sección 5.
- **Arbitrariedad del umbral de clasificación**: el punto de corte de 83.5 puntos, si bien está fundamentado, es una decisión de diseño que podría modificar la distribución de clases si se redefiniera.
## Requisitos y ejecución
 
El análisis fue desarrollado en **R**. Librerías utilizadas:
 
```r
install.packages(c("MASS", "tidyverse", "lubridate", "ggplot2",
                    "corrplot", "caret", "knitr", "lmtest",
                    "nortest", "pROC", "car"))
```
 
Para reproducir el análisis, abrir y ejecutar `Final.qmd` en RStudio (o renderizar vía `rmarkdown::render()`), asegurando que el archivo `data/ICO_norm.csv` esté disponible en la ruta relativa esperada.
 
## Reporte completo
 
El detalle completo del análisis, incluyendo código, gráficos y resultados de cada test estadístico, está disponible en `Final.html`.
