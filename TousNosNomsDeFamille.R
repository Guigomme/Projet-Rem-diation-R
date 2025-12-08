# ------------------------------------------------------------------------------
# PROJET : Changement climatique et catastrophes naturelles [cite: 3]
# AUTEURS : Prénom Nom1, Prénom Nom2 [cite: 55]
# DATE LIMITE : 31 Décembre 2025 [cite: 4]
# ------------------------------------------------------------------------------

# --- 0. DOCUMENTATION DE L'IA ---
# [OBLIGATOIRE] Décrivez ici comment vous avez utilisé l'IA pour ce script.
# Exemple : "Nous avons utilisé ChatGPT pour déboguer la fonction de fusion..."
# ou "Aucune IA n'a été utilisée." [cite: 8]

# ==============================================================================
# PHASE 1 : GESTION DES DONNÉES
# Objectif : Créer une table mensuelle liant climat et catastrophes
# ==============================================================================

library(data.table)

# --- 0. Chargement des données ---
# Adaptez les noms de fichiers si nécessaire (ex: "synop.csv.gz" ou "meteo_france.csv")
meteo <- fread("data/synop.csv.gz") 
emdat <- fread("data/catastrophes.csv")

# ==============================================================================
# ÉTAPE 1 : TRAITEMENT MÉTÉO
# ==============================================================================

# 1. Conversion Kelvin -> Celsius [cite: 25, 44]
# On crée une nouvelle colonne 'temp_celsius'
meteo[, temp_celsius := t - 273.15]

# 2. Agrégation mensuelle [cite: 44]
# On calcule la moyenne de température par Année et par Mois
meteo_mensuel <- meteo[, .(
  temp_moy = mean(temp_celsius, na.rm = TRUE)
), by = .(year, month)]

# 3. Calcul de l'écart (Le Gap) 
# a) On calcule d'abord la moyenne historique pour chaque mois (Janvier, Février...)
#    Cela nous donne la "Normale saisonnière"
normale_saisonniere <- meteo_mensuel[, .(
  temp_ref = mean(temp_moy, na.rm = TRUE)
), by = month]

# b) On fusionne cette référence avec notre table mensuelle
meteo_finale <- merge(meteo_mensuel, normale_saisonniere, by = "month")

# c) On calcule la différence : Température du mois - Moyenne historique
meteo_finale[, gap_temp := temp_moy - temp_ref]

# Nettoyage : On ne garde que les colonnes demandées
# On trie aussi par année et mois pour que ce soit propre
setorder(meteo_finale, year, month)
meteo_finale <- meteo_finale[, .(year, month, temp_moy, gap_temp)]

# ==============================================================================
# ÉTAPE 2 : TRAITEMENT EM-DAT (CORRIGÉ AVEC VOS COLONNES)
# ==============================================================================

# 1. Filtrage France
# On ne garde que les catastrophes survenues en France
emdat_fr <- emdat[country == "France"]

# 2. Préparation des variables de temps
# On utilise directement vos colonnes start_year et start_month
emdat_fr[, year := as.integer(start_year)]
emdat_fr[, month := as.integer(start_month)]

# Nettoyage : On supprime les lignes où le mois ou l'année est inconnu
emdat_fr <- emdat_fr[!is.na(year) & !is.na(month)]

# 3. Agrégation par mois
catastrophes_mensuel <- emdat_fr[, .(
  nb_disasters = .N,                                     # Compte le nombre de lignes
  nb_deaths = sum(total_deaths, na.rm = TRUE),           # Somme des morts (votre colonne est total_deaths)
  total_damages = sum(total_damages_thousand_usd, na.rm = TRUE) * 1000 # On convertit en dollars
), by = .(year, month)]

# Vérification rapide (Vous devriez voir des chiffres maintenant !)
print("Aperçu des catastrophes agrégées :")
print(head(catastrophes_mensuel))

# ==============================================================================
# ÉTAPE 3 : FUSION FINALE (MERGE)
# ==============================================================================

# 1. Fusion
# meteo_finale est la base (tous les mois), on y colle les catastrophes
data_finale <- merge(meteo_finale, catastrophes_mensuel, 
                     by = c("year", "month"), 
                     all.x = TRUE)

# 2. Remplacement des NA par des 0
# S'il n'y a pas de correspondance, c'est qu'il n'y a eu aucun dégât ce mois-là.
data_finale[is.na(nb_disasters), nb_disasters := 0]
data_finale[is.na(nb_deaths), nb_deaths := 0]
data_finale[is.na(total_damages), total_damages := 0]

# --- VÉRIFICATION FINALE ---
print("Résumé final :")
summary(data_finale)


test 