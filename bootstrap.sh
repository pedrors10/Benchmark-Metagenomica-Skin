#!/bin/bash
# --- CONFIGURACIÓN FINAL ---
DB_DIR="db_skin"
TOTAL_DATA="100M"
ITERATIONS=10

# Entornos y Scripts
ENV_YEAST="yeast"
ENV_KRAKEN="/miniconda3/envs/kraken_bracken"
SIM_ILLUMINA="$HOME/yeast/simulate.sh"
SIM_NANOPORE="$HOME/yeast/simulate_badreads_metagenome.sh"

echo "=== INICIANDO EXPERIMENTO FINAL: $ITERATIONS ITERACIONES x $TOTAL_DATA ==="
echo "Hora de inicio: $(date)"

for i in $(seq 1 $ITERATIONS); do
    echo ""
    echo "========================================================"
    echo ">>> PROGRESO: [Iteración $i / $ITERATIONS] - $(date +%H:%M:%S)"
    echo "========================================================"
    
    # 1. ILLUMINA
    RUN_ILL="bootstrap_100M_illumina_run_$i"
    echo "[1/4] Simulando Illumina (ART)..."
    conda run -n "$ENV_YEAST" bash "$SIM_ILLUMINA" truth_skin_v2.tsv "$TOTAL_DATA"
    mv "truth_skin_v2_100M" "$RUN_ILL"
    
    echo "[2/4] Clasificando Illumina (Kraken2 + Bracken 150)..."
    conda run -p "$ENV_KRAKEN" kraken2 --db "$DB_DIR" --threads 16 --paired \
        --report "$RUN_ILL/report.kreport" "$RUN_ILL"/*_short_1.fastq.gz "$RUN_ILL"/*_short_2.fastq.gz > /dev/null
    conda run -p "$ENV_KRAKEN" bracken -d "$DB_DIR" -i "$RUN_ILL/report.kreport" -o "$RUN_ILL/bracken_150.txt" -r 150 -l S

    # 2. NANOPORE
    RUN_NANO="bootstrap_100M_nanopore_run_$i"
    echo "[3/4] Simulando Nanopore (Badreads)..."
    conda run -n "$ENV_YEAST" bash "$SIM_NANOPORE" truth_nanopore.tsv "$TOTAL_DATA"
    mv "truth_nanopore_100M" "$RUN_NANO"
    
    echo "[4/4] Clasificando Nanopore (Kraken2 + Bracken 1000/3000)..."
    conda run -p "$ENV_KRAKEN" kraken2 --db "$DB_DIR" --threads 16 --confidence 0.1 \
        --report "$RUN_NANO/report.kreport" "$RUN_NANO"/metagenome.combined.shuffled.fastq.gz > /dev/null
    
    # Probamos los dos proxies de Nanopore
    conda run -p "$ENV_KRAKEN" bracken -d "$DB_DIR" -i "$RUN_NANO/report.kreport" -o "$RUN_NANO/bracken_1000.txt" -r 1000 -l S
    conda run -p "$ENV_KRAKEN" bracken -d "$DB_DIR" -i "$RUN_NANO/report.kreport" -o "$RUN_NANO/bracken_3000.txt" -r 3000 -l S

    echo ">>> [OK] Iteración $i terminada con éxito a las $(date +%H:%M:%S)"
done

echo ""
echo "=== EXPERIMENTO FINALIZADO TOTALMENTE ==="
echo "Hora de fin: $(date)"
