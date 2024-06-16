# Matches

## _departement

, uniformisé (upper, normalisation)

## _academie

attr|csv file|column|notes
-|-|-|-
code_academie|fr-en-etablissements-ep|code_academie|pk
lib_academie|fr-en-etablissements-ep|libelle_academie|not null, unique

## _quartier_prioritaire

attr|csv file|column|notes
-|-|-|-
code_quartier_prioritaire|fr-en-etablissements-ep|qp_a_proximite|pk
nom_quartier_prioritaire|fr-en-etablissements-ep|nom_du_qp|not null

## _type

attr|csv file|column|notes
-|-|-|-
code_nature|fr-en-etablissements-ep|code_nature|pk
libelle_nature|fr-en-etablissements-ep|libelle_nature|not null

## _etablissement

attr|csv file|column|notes
-|-|-|-
uai|fr-en-etablissements-ep|uai|pk
nom_etablissement|fr-en-etablissements-ep|nom_etablissement|not null
secteur|fr-en-etablissements-ep|statut_public_prive|not null
code_postal|fr-en-etablissements-ep|code_postal|not null
latitude|fr-en-etablissements-ep|latitude|not null
longitude|fr-en-etablissements-ep|longitude|not null
code_insee_de_la_commune|fr-en-etablissements-ep|code_commune|not null, fk.1
nom_de_la_commune|fr-en-etablissements-ep|nom_commune|not null, fk.2, transformation requise (recup depuis _commune utilisant code_insee_de_la_commune), uniformisé (normalisation)
code_academie|fr-en-etablissements-ep|code_academie|not null, fk
code_nature|fr-en-etablissements-ep|code_nature|not null, fk

## _est_a_proximite_de

attr|csv file|column|notes
-|-|-|-
code_quartier_prioritaire|fr-en-etablissements-ep|qp_a_proximite|not null fk
uai|fr-en-etablissements-ep|uai|pk

## _annee

attr|csv file|column|notes
-|-|-|-
annee_scolaire|fr-en-college-effectifs-niveau-sexe-lv|rentree_scolaire|pk, uniformisé (anne4 &rarr; annee9)

## _caracteristiques_tout_etablissement

### Source 1

attr|csv file|column|notes
-|-|-|-
uai|fr-en-etablissements-ep|uai|
annee_scolaire|-|-|always 2022-2023
effectifs|fr-en-etablissements-ep|nombre_d_eleves|

### Source 2 (collèges)

attr|csv file|column|notes
-|-|-|-
uai|fr-en-college-effectifs-niveau-sexe-lv|numero_college|
aneee_scolaire|fr-en-college-effectifs-niveau-sexe-lv|rentree_scolaire|
effectifs|fr-en-college-effectifs-niveau-sexe-lv|nombre_eleves_total|