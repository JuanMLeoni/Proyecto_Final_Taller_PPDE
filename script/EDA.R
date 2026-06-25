library(tidyverse)
library(ggplot2)
library(corrplot)


ICO = read.csv("data/ICO_norm.csv")

ICO %>%
  select(Total.Cup.Points, Aroma, Flavor, Acidity, Body, Moisture.Percentage, Altitude_Promedio) %>%
  summary()

ggplot(ICO, aes(x = Total.Cup.Points)) +
  geom_histogram(aes(y = ..density..), bins = 20, fill = "steelblue", color = "white") +
  geom_density(color = "red", size = 1) +
  theme_minimal() +
  labs(title = "Distribución de Total Cup Points",
       x = "Puntaje Total", y = "Densidad")
##Grafico de dispersión de Total Cup Points


# Filtramos solo las columnas numéricas que te interesan
variables_num <- ICO %>% 
  select(Total.Cup.Points, Aroma, Flavor, Acidity, Body, Balance, Moisture.Percentage)
# Calculamos la matriz de correlación
matriz_cor <- cor(variables_num)
# Graficamos
corrplot(matriz_cor, method = "color", type = "upper", 
         addCoef.col = "black", tl.col = "black", number.cex = 0.8)
##Grafico de correlaciones entre variables numéricas


ggplot(ICO, aes(x = Color_Clean, y = Total.Cup.Points, fill = Color_Clean)) +
  geom_boxplot(alpha = 0.7) +
  theme_minimal() +
  labs(title = "Puntaje Total por Color del Grano",
       x = "Color del Grano", y = "Total Cup Points") +
  theme(legend.position = "none")
##Grafico de cajas de Total Cup Points por Color del Grano


ggplot(ICO, aes(x = Altitude_Promedio)) +
  geom_density(fill = "forestgreen", alpha = 0.5, color = "darkgreen", size = 1) +
  theme_minimal() +
  labs(title = "Función de Densidad de la Altitud",
       x = "Altitud Promedio (metros)", 
       y = "Densidad")
##Grafico de densidad de Altitude_Promedio


ggplot(ICO, aes(x = log(Altitude_Promedio), y = Total.Cup.Points)) +
  geom_point(color = "darkblue", alpha = 0.5) +
  geom_smooth(method = "lm", color = "red", se = TRUE) + # Agrega la recta de regresión
  theme_minimal() +
  labs(title = "Relación entre Altitud y Puntaje Total",
       x = "Altitud Promedio (metros)", 
       y = "Total Cup Points")
##Grafico de dispersión de Altitude_Promedio vs Total.Cup.Points con recta de regresión




##Correcion de valores atipicos en la columna Altitude_Promedio
ICO_modelo <- ICO %>%
  filter(Altitude_Promedio < 4000)
##Mismos graficos pero sin outliers

ggplot(ICO_modelo, aes(x = Altitude_Promedio)) +
  geom_density(fill = "forestgreen", alpha = 0.5, color = "darkgreen", size = 1) +
  theme_minimal() +
  labs(title = "Función de Densidad de la Altitud",
       x = "Altitud Promedio (metros)", 
       y = "Densidad")
##Grafico de densidad de Altitude_Promedio


ggplot(ICO_modelo, aes(x = Altitude_Promedio, y = Total.Cup.Points)) +
  geom_point(color = "darkblue", alpha = 0.5) +
  geom_smooth(method = "lm", color = "red", se = TRUE) + # Agrega la recta de regresión
  theme_minimal() +
  labs(title = "Relación entre Altitud y Puntaje Total",
       x = "Altitud Promedio (metros)", 
       y = "Total Cup Points")
##Grafico de dispersión de Altitude_Promedio vs Total.Cup.Points con recta de regresión


##Otro modelo.
modelo_lineal <- lm(Total.Cup.Points ~ Flavor + Balance + Altitude_Promedio, data = ICO_modelo)

# 2. Imprimimos el resumen estadístico
summary(modelo_lineal)


par(mfrow = c(2, 2))
# Graficamos el modelo
plot(modelo_lineal)
# Restauramos la pantalla a su estado normal
par(mfrow = c(1, 1))
##Valores residuales y diagnostico del modelo lineal