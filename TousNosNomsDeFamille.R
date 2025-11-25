# ------------------------------------------------------------------------------
# PROJET : Changement climatique et catastrophes naturelles [cite: 3]
# AUTEURS : Prénom Nom1, Prénom Nom2 [cite: 55]
# DATE LIMITE : 31 Décembre 2025 [cite: 4]
# ------------------------------------------------------------------------------

# --- 0. DOCUMENTATION DE L'IA ---
# [OBLIGATOIRE] Décrivez ici comment vous avez utilisé l'IA pour ce script.
# Exemple : "Nous avons utilisé ChatGPT pour déboguer la fonction de fusion..."
# ou "Aucune IA n'a été utilisée." [cite: 8]

# --- 1. CONFIGURATION ---
# Chargement des packages nécessaires
# La consigne recommande spécifiquement data.table pour le chargement [cite: 38]
library(data.table)

# --- 2. IMPORTATION DES DONNÉES ---
# Les données sont accessibles sur Moodle [cite: 37]
# Utilisez fread comme demandé sans manipulation supplémentaire à l'import [cite: 38]

# Importation des données Météo France
meteo <- fread("chemin_vers_votre_fichier/meteo_france.csv")

# Importation des données EM-DAT (Catastrophes naturelles)
# Note : Seules les catastrophes en France nous intéressent pour la suite [cite: 49]
emdat <- fread("chemin_vers_votre_fichier/em_dat.csv")

# Vérification rapide
head(meteo)
head(emdat)
hsvdejd
