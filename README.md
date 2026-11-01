# FD-FLIM-using-Unsupervised-Linear-Unmixing-and-Machine-Learning
Tumor Diagnosis of Frequency-Domain FLIM Samples by a Hybrid Approach: Unsupervised Linear Unmixing + Machine Learning
Code and data to reproduce the results of the manuscript submitted to PLOS ONE.
Authors: Daniel Ulises Campos-Delgado, Jorge D. Cardenas, Miguel Velazquez-Duran, Omar Gutierrez-Navarro, Seyed Edriss Mirnia, Carissa Huynh, Yuan Li, V. Krishnan Ramanujan and Javier A. Jo.
Contact: miguel.duran@uaslp.mx
---
Overview
This work introduces a classification pipeline for tumor diagnosis of frequency-domain fluorescence lifetime imaging microscopy (FD-FLIM) samples. Unsupervised linear unmixing (ULU) is combined with tree-based machine learning (ML) to distinguish tumor from non-tumor tissue in snap-frozen ex-vivo human specimens (kidney, adrenal gland, ureter and urachal lesions).
Dataset: 51 FD-FLIM samples labeled by histopathological evaluation.
ULU methods: EBEAE (Extended Blind Endmember and Abundance Extraction) and EBEAE-SC (with Spatial Coherence).
Classifiers: bagged trees, random forest and boosting trees (AdaBoostM1).
Validation: 5-fold and leave-one-out cross-validation.
Methodology
![Pipeline](images/pipeline.png)
The pipeline has three stages:
Background removal. EBEAE-SC with N = 2 endmembers (tissue and background; ρ = 0.01, µ = 0.1). The endmember with the lower mean calibrated absolute intensity (CAI) is assigned to the background. The binary mask is refined with morphological operations (disk, radius 8 px).
Tissue segmentation. Adaptive-order EBEAE (starts at N = 3 and reduces the order if endmembers are spatially insignificant, < 5 % of the ROI, or too similar, SAM < 10°; ρ = 0.1, µ = 0.1). Pixels are assigned to the endmember with maximum abundance. Segmented regions are labeled tumor / non-tumor from the histopathological report (±10 % tolerance). The mean 63-feature vector of each region is extracted.
ML classification. Bagged trees, random forest and boosting trees evaluated with 5-fold and leave-one-out cross-validation (accuracy, precision, recall, F1-score).
Data description
Each FD-FLIM sample is a tensor of 160 × 160 pixels × 63 features. The 63 features per pixel come from seven excitation–emission channels (four at 375 nm and three at 445 nm excitation):
Feature type	Count
Calibrated intensities (CAI, InterCNI, IntraCNI)	21
Frequency-calibrated modulation (FCM)	21
Frequency-calibrated phase (FCP)	21
Histopathological composition per sample (tumor tissue, non-neoplastic tissue, normal tissue) is given in Table I of the manuscript and in `data/histology.csv`.
Samples were obtained from patients undergoing surgery at Cedars-Sinai Medical Center (IRB Pro00043021) and imaged at the University of Oklahoma.
Main results
5-fold cross-validation (mean on test folds)
Classifier	Accuracy	Precision	Recall	F1-score
Bagged trees	85.88 %	88.97 %	90.00 %	88.56 %
Random forest	82.35 %	87.39 %	86.67 %	85.56 %
Boosting trees	82.35 %	82.47 %	89.44 %	85.17 %
Leave-one-out cross-validation
Classifier	Accuracy	Precision	Recall	F1-score
Bagged trees	87.06 %	88.00 %	89.80 %	88.89 %
Random forest	84.71 %	84.62 %	89.80 %	87.13 %
Boosting trees	84.71 %	83.33 %	91.84 %	87.38 %
Bagged trees obtained the numerically highest performance in both schemes; the Friedman test showed no statistically significant differences among classifiers in 5-fold CV.
Repository structure
> Adjust the names below to match the final files.
```
.
├── README.md
├── LICENSE
├── images/                 # Figures used in this README
├── data/
│   ├── README\_data.md      # Download instructions and file description
│   └── histology.csv       # Histopathological evaluation per sample
├── src/
│   ├── ebeae/              # EBEAE and EBEAE-SC implementations
│   ├── 01\_background\_removal.m
│   ├── 02\_tissue\_segmentation.m
│   ├── 03\_classification\_5fold.m
│   └── 04\_classification\_loocv.m
└── results/                # Output metrics and figures
```
Data availability
The FD-FLIM database (51 samples, ~1 GB) is deposited at:
[Zenodo / Figshare — DOI: 10.xxxx/xxxxx]
Download it and place the files in the `data/` folder (see `data/README\_data.md`).
Requirements
MATLAB (version used: R20XXx)
Statistics and Machine Learning Toolbox
Image Processing Toolbox
How to reproduce
Clone this repository: `git clone https://github.com/<user>/<repository>.git`
Download the dataset from the DOI above into `data/`.
In MATLAB, run in order:
```matlab
   cd src
   run('01\_background\_removal.m')    % binary masks (EBEAE-SC)
   run('02\_tissue\_segmentation.m')   % adaptive EBEAE, labels, features
   run('03\_classification\_5fold.m')  % Table III
   run('04\_classification\_loocv.m')  % Table V
   ```
Results are saved in `results/`.
Classifier settings (Table II of the manuscript): bagged trees, random forest (100 trees) and AdaBoostM1 boosting trees (learning rate 0.1, max. 10 splits).
Citation
```
Campos-Delgado D.U., Cardenas J.D., Velazquez-Duran M., Gutierrez-Navarro O., Mirnia S.E.,
Huynh C., Li Y., Ramanujan V.K., Jo J.A. Tumor Diagnosis of Frequency-Domain FLIM Samples
by a Hybrid Approach: Unsupervised Linear Unmixing + Machine Learning. PLOS ONE (submitted).
```
License
Code: [MIT / GPL-3.0 — choose]. Data: [CC BY 4.0 — choose].
