library(tidyverse)
library(ggplot2)
library(corrplot)
library(caret)

ICO = read.csv("data/ICO_norm.csv")

ICO_modelo <- ICO %>%
  filter(Altitude_Promedio < 4000)

modelo_lineal <- lm(Total.Cup.Points ~ Flavor + Balance + Altitude_Promedio, data = ICO_modelo)

ICO_modelo <- ICO_modelo %>%
  mutate(Cafe_Excelente = ifelse(Total.Cup.Points >= 83.5, 1, 0),
         # Es CRUCIAL que R lo entienda como un factor (categoría)
         Cafe_Excelente = as.factor(Cafe_Excelente))

table(ICO_modelo$Cafe_Excelente)


# Ajustamos el modelo logístico
ICO_modelo_logistico <- glm(Cafe_Excelente ~ Acidity + Body + Color_Clean, 
                        data = ICO_modelo, 
                        family = "binomial")

# Vemos el resumen del modelo
summary(ICO_modelo_logistico)


# 1. Obtenemos las probabilidades predichas por el modelo para cada café (van de 0 a 1)
probabilidades <- predict(ICO_modelo_logistico, type = "response")

# 2. Si la probabilidad es mayor a 0.5, clasificamos como 1 (Excelente), si no, como 0
predicciones_binarias <- ifelse(probabilidades > 0.5, 1, 0)
predicciones_binarias <- as.factor(predicciones_binarias)

# 3. Armamos la Matriz de Confusión cruzando lo real con lo predicho
matriz_confusion <- confusionMatrix(predicciones_binarias, ICO_modelo$Cafe_Excelente)
print(matriz_confusion)


##Otro modelo logistico
# Ajustamos el modelo definitivo con 2 numéricas y 1 categórica limpia
ICO_modelo_logistico_2 <- glm(Cafe_Excelente ~ Acidity + Body + Metodo_Limpio, 
                              data = ICO_modelo, 
                              family = "binomial")

# Imprimimos el resumen para revelar la verdad de los p-valores
summary(ICO_modelo_logistico_2)


##Otro modelo logistico
ICO_modelo_logistico_3 <- glm(Cafe_Excelente ~ Acidity + Body + Aroma, 
                              data = ICO_modelo, 
                              family = "binomial")

# Vemos el resumen final
summary(ICO_modelo_logistico_3)

probabilidades_finales <- predict(ICO_modelo_logistico_3, type = "response")
predicciones_finales <- as.factor(ifelse(probabilidades_finales > 0.5, 1, 0))
matriz_final <- confusionMatrix(predicciones_finales, ICO_modelo$Cafe_Excelente)
print(matriz_final)


###Analisis final: Con 2 variables (Acidity y Body) logramos un acurracy de casi el 93% y, (Sensitivity : 0.9326, Specificity : 0.9204).
###Pero para seguir la linea del TP agregamos una variable mas (Aroma) logrando un acurracy del 91% y sens. y espec. casi similares un poco menores.
###Notando q el P-value de Aroma es 4 veces mayor al de las otras 2 denotamos q muy util en el analicis pero sin problema pudimos usar 2 y haber logrado un mejor resultado.


##Prueba de modelo con mismo modelo q el EDA.
ICO_modelo_logistico_altitud <- glm(Cafe_Excelente ~ Acidity + Body + Altitude_Promedio, 
                              data = ICO_modelo, 
                              family = "binomial")
# Evaluamos los resultados
summary(ICO_modelo_logistico_altitud)

###Aunque en el EDA la altitud explica bastante bien el puntaje total, en el modelo log. para determina si un cafe es de excelencia no tiene la fuerza estadistica suficiente para definirlo como tal.
