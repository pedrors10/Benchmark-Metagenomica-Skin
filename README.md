# Benchmark Metagenómico: Illumina vs Oxford Nanopore

Este repositorio contiene las herramientas de simulación y análisis desarrolladas para comparar la precisión de dos tecnologías de secuenciación en la caracterización de una comunidad microbiana sintética de la piel.

## 🚀 Contenido del Repositorio

- **`bootstrap.sh`**: Script de automatización en Bash. Ejecuta el pipeline completo de simulación (ART/Badreads), clasificación taxonómica (Kraken2) y reestimación de abundancia (Bracken) para 10 iteraciones independientes.
- **`analisis_datos.py`**: Script de procesamiento de datos en Python. Utiliza librerías estadísticas para calcular el Error L1 y la Distancia de Bray-Curtis a partir de los resultados de las 10 corridas.
- **`truth_skin.tsv`** & **`truth_nanopore.tsv`**: Archivos de configuración del "Ground Truth" que definen la composición teórica de la comunidad microbiana (9 especies, 11.11% cada una).

## 📊 Metodología Experimental
1. **Generación de datos:** 100 Mbp por tecnología (cobertura equivalente).
2. **Bootstrap:** 10 repeticiones estocásticas para evaluar la convergencia estadística.
3. **Métricas de Evaluación:**
   - **Error L1**: Medida de precisión absoluta de la abundancia.
   - **Bray-Curtis**: Índice de disimilitud para comparar perfiles ecológicos.

## 📈 Resultados Resumidos
- **Illumina (150bp PE):** Error L1 de **1.51** con una estabilidad excepcional (Std Dev: 0.009).
- **Nanopore (Long-reads):** Error L1 de **2.06** con una variabilidad mayor (Std Dev: 0.47), reflejando el impacto de la tasa de error por base en la clasificación de k-meros.
