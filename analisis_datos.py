import pandas as pd
import numpy as np
import glob
import os

TRUTH_SPECIES = [
    "Staphylococcus epidermidis", "Staphylococcus warneri", "Staphylococcus capitis",
    "Staphylococcus hominis", "Corynebacterium amycolatum", "Rhodococcus erythropolis",
    "Micrococcus luteus", "Cutibacterium acnes", "Acinetobacter radioresistens"
]
THEORETICAL_PERC = 11.11  # 1/9 de la muestra

def parse_bracken(file_path):
    df = pd.read_csv(file_path, sep='\t')
    df['perc'] = df['fraction_total_reads'] * 100
    return df[['name', 'perc']]

def calculate_metrics(df_estimated):
    data = []
    for sp in TRUTH_SPECIES:
        val = df_estimated[df_estimated['name'] == sp]['perc'].values
        val = val[0] if len(val) > 0 else 0
        data.append(val)
    
    data = np.array(data)
    truth = np.full(len(TRUTH_SPECIES), THEORETICAL_PERC)
    
    # Error L1
    l1_error = np.sum(np.abs(data - truth))
    
    # Bray-Curtis
    bc_dist = np.sum(np.abs(data - truth)) / np.sum(data + truth)
    
    return l1_error, bc_dist

def summarize_runs(run_pattern):
    files = glob.glob(run_pattern)
    if not files:
        print(f"No se encontraron archivos para {run_pattern}")
        return
    
    results = []
    for f in files:
        df = parse_bracken(f)
        l1, bc = calculate_metrics(df)
        results.append({'file': f, 'L1': l1, 'Bray-Curtis': bc})
    
    res_df = pd.DataFrame(results)
    print(f"--- Resumen de {run_pattern} ---")
    print(res_df.describe().loc[['mean', 'std']])
    print("\n")

summarize_runs("bootstrap_100M_illumina_run_*/bracken_150.txt")
summarize_runs("bootstrap_100M_nanopore_run_*/bracken_1000.txt")
