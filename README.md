# SCINpauseAnalysis
This repository contains the matlab code analysisSCINpauseToThalamicInput.m

It's a script used in Tubert et al., 2025 (eLife) to analyze 15-second cell-attached recordings from striatal cholinergic interneurons with ChR2 expression in thalamic terminals  originating from the intralaminar thalamic nuclei. 

The input are .abf files with specific format (see code description), and it generates a table with the following columns: Baseline ISI (ms), Number of spikes during the burst, Burst duration (ms), Pause duration after burst (ms), x1 and x2 values.

Note: This script requires the function abfload.m (Harald Hentschke, 2025)
Available at: https://www.mathworks.com/matlabcentral/fileexchange/6190-abfload
