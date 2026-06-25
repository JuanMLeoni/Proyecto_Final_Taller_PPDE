#install.packages("tidyverse")
library(tidyverse)
library(lubridate)

#Cargando los datos
ICO = read.csv("data/df_arabica_clean.csv")

#Ver los datos
sum(sapply(ICO, is.numeric))
sum(sapply(ICO, is.character))
colSums(ICO == "")
sum(ICO$ICO.Number == "")/count(ICO)
# % de datos faltantes en la columna ICO.Number

#Normalización de los datos
ICO_norm = ICO %>%
  select(-ICO.Number, -X)
##Borro las columnas ICO.Number por el alto porcentaje de vacios y X por estar repetida con el ID.
  
ICO_norm = ICO_norm %>%
    mutate(Bag.Weight.Num.kg = parse_number(ICO_norm$Bag.Weight))
##Creo una nueva columna con el peso de la bolsa en formato numérico y sin la unidad de peso.

ICO_norm = ICO_norm %>%
    mutate(Grading_Date_Clean = mdy(Grading.Date))
##Creo una nueva columna con la fecha de calificación en formato fecha y no como texto.

ICO_norm = ICO_norm %>%
    mutate(Harvest_Year_Clean = as.numeric(str_extract(Harvest.Year, "\\d{4}$")))
##Creo una nueva columna con el año final de cosecha en formato numérico y no como texto.

ICO_norm <- ICO_norm %>%
  mutate(
    Bag.Weight.Num.kg = ifelse(
      Bag.Weight.Num.kg == 19200,
      Bag.Weight.Num.kg / 320,
      Bag.Weight.Num.kg
    )
  )
##Descubri que los valores correspondientes a los Etiopes con una cantidad de bolsas de 320 para ellos equivalen a un lote completo pero esta mal puesto el peso porque el q esta es el total de la multiplicacion.

ICO_norm = ICO_norm %>%
    mutate(
    # 1. Todo a minúsculas primero para estandarizar
    Color_Clean = str_to_lower(Color), 
    
    # 2. Atacamos los guiones: "\\s*-\\s*" busca un guion que tenga 
    # cero o más espacios a sus lados, y lo reemplaza por un guion limpio "-"
    Color_Clean = str_replace_all(Color_Clean, "\\s*-\\s*", "-"),
    
    # 3. Quitamos los espacios que sobran a la izquierda y a la derecha
    Color_Clean = str_trim(Color_Clean, side = "both"),
    
    # 4. Por si quedó algún doble espacio perdido entre otras palabras
    Color_Clean = str_squish(Color_Clean),
    
    # 5. Finalmente lo convertimos a categoría
    Color_Clean = as.factor(Color_Clean)
  )
##Corregir los errores de tipeo en la columna Color_Clean.
    
ICO_norm = ICO_norm %>%
    mutate(
    # Primero aseguramos que sea texto para poder manipularlo
    Color_Clean = as.character(Color_Clean), 
    
    # Aplicamos case_when para recodificar
    Color_Clean = case_when(
      # 1. Grupo Azules/Verdosos
      Color_Clean %in% c("blue-green", "bluish-green") ~ "bluish-green",
      
      # 2. Grupo Marrones/Verdosos (arregla el typo "browish" y el espacio faltante)
      Color_Clean %in% c("browish-green", "brownish green", "brownish-green") ~ "brownish",
      
      # 3. Grupo Amarillos/Verdosos (arregla el typo "yello" y espacios)
      Color_Clean %in% c("yello-green", "yellow-green", "yellow green") ~ "yellow-green",
      
      # 4. Grupo Amarillos (arregla typos y junta pálidos)
      Color_Clean %in% c("pale yellow", "yellowis", "yellowish", "yellow") ~ "yellow",
      
      # 5. Grupo Verdes puros
      Color_Clean %in% c("greenish", "green") ~ "green",
      
      # 6. Si hay algo más que no mapeamos arriba, lo dejamos como estaba
      TRUE ~ Color_Clean 
    ))
##Corregir estandarizar los colores en la columna Color_Clean.

ICO_norm = ICO_norm %>%
  # 1. Separamos la columna original usando el guion como punto de corte.
  # fill = "right" asegura que si hay un solo número, se quede en Alt_Min y Alt_Max quede vacío (NA).
  separate(Altitude, into = c("Alt_Min", "Alt_Max"), sep = "-", remove = FALSE, fill = "right") %>%
  
  # 2. Usamos parse_number para extraer solo los números (limpia letras como "m" o "msnm")
  mutate(
    Alt_Min = parse_number(Alt_Min),
    Alt_Max = parse_number(Alt_Max),
    
    # 3. Calculamos la nueva variable continua. 
    # Si Alt_Max es NA (era un solo número), dejamos Alt_Min. Si hay dos, promediamos.
    Altitude_Promedio = ifelse(is.na(Alt_Max), Alt_Min, (Alt_Min + Alt_Max) / 2)
  ) %>%
  
  # 4. Borramos las columnas temporales para mantener el dataset limpio
  select(-Alt_Min, -Alt_Max)
##Creo columna Altitude_Promedio con el promedio de la altura de cosecha y la hacemos numericas



# 1. Miramos qué categorías existen y cuántos registros hay de cada una
table(ICO_norm$Metodo_Limpio, useNA = "always")


ICO_norm = ICO_norm %>%
  mutate(
    # 1. Pasamos a texto para poder editar
    Metodo_Limpio = as.character(Processing.Method),
    
    # 2. Re-agrupamos usando condiciones
    Metodo_Limpio = case_when(
      # Juntamos todas las variantes de Semi-Lavado
      Metodo_Limpio %in% c("SEMI-LAVADO", "Semi Washed") ~ "Semi-Washed",
      
      # Los vacíos, los NA, o métodos raros los mandamos a "Other"
      Metodo_Limpio == "" | is.na(Metodo_Limpio) ~ "Other",
      
      # Mantenemos los clásicos (Washed / Wet, Natural / Dry, etc.)
      # Si tenés algún otro con 1 solo registro, agregalo al vector de "Other" arriba
      TRUE ~ Metodo_Limpio
    ),
    
    # 3. Volvemos a convertir en factor para el modelo
    Metodo_Limpio = as.factor(Metodo_Limpio)
  )

sum(is.na(ICO_norm$Altitude_Promedio))
ICO_norm <- ICO_norm %>% drop_na()
##Busco los valores faltantes en la columna Altitude_Promedio y lo borro ya q es solo 1

write.csv(x = ICO_norm, file = "data/ICO_norm.csv", row.names = FALSE)
