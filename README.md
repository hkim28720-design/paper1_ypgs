# paper1_ypgs

Replication repository for Paper 1 of the YPGS project: **Family, Motivation and Harm**.

## Overview

This repository contains Stata code to clean, harmonize, and pool repeated cross-sectional waves of the Young People and Gambling Survey (YPGS) for 2022, 2023, and 2024, and to construct the main analysis variables used in the paper.

## Research purpose

The project studies the relationship between gambling participation patterns, gambling motives, and gambling-related harm among young people using repeated cross-sectional survey data.

## Data sources

The analysis uses YPGS survey datasets for 2022, 2023, and 2024.

- Raw files are **not** redistributed in this repository unless redistribution rights explicitly permit it.
- Users should place the original raw files in `data/raw/`.
- Supporting survey reports are stored in `docs/GC_YPGS_reports/`.

## Repository structure

- `master.do` — runs the full replication pipeline
- `dofiles/00_clean_*.do` — cleans each survey wave separately
- `dofiles/01-04_*.do` — appends waves and constructs derived variables
- `dofiles/05_analysis_main.do` — runs the main analysis
- `docs/` — survey reports and methodological notes
- `output/` — tables and figures
- `log/` — Stata log files

## Reproducibility notes

This is a repeated cross-sectional dataset created by pooling annual YPGS waves. The pooled file is constructed after harmonizing variable names across waves. Any weighting decisions used in pooling should be reported explicitly in the paper and checked against the target estimand.

## How to run

1. Clone this repository.
2. Put the raw survey files in `data/raw/`.
3. Open Stata.
4. Edit the `global root` line in `master.do`.
5. Run `master.do`.

## Outputs

The pipeline writes cleaned datasets to `data/processed/`, logs to `log/`, and analysis outputs to `output/tables/` and `output/figures/`.

## Data access and licensing

See `DATA_ACCESS.md` for details on source data access, redistribution restrictions, and documentation.
