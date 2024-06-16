-- Population de la BdD collège
-- 6/06/2024
-- Raphaël Bardini, Mattéo Kervadec (1C2)
set schema 'colleges2';

-- PRÉREQUIS
--- Ce script ne fonctionne que si vous avez défini un répertoire de travail (Working directory) par défaut dans lequel se trouve votre script et les données sous forme de fichiers CSV
-- FONCTIONS TRIGGERS
--- Uniformisation : Reformatage des années en années scolaires.
create or replace function ftg_rentree4_rentree9 ()
    returns trigger
    as $$
declare
    annee_int integer;
begin
    annee_int := new.rentree_scolaire::integer;
    new.rentree_scolaire := to_char(annee_int, 'FM9999') || '-' || to_char(annee_int + 1, 'FM9999');
    return new;
end;
$$
language 'plpgsql';

--- Uniformisation : reformatage des années de session en années scolaires.
create or replace function ftg_insert_session ()
    returns trigger
    as $$
declare
    annee_session integer;
begin
    annee_session := new.session::integer;
    new.session := to_char(annee_session - 1, 'FM9999') || '-' || to_char(annee_session, 'FM9999');
    return new;
end;
$$
language 'plpgsql';

-- TABLES TEMPORAIRES
--- Données générales pour l'année 2022-2023
create table _temp_fr_en_etablissements_ep (
    uai char(8) primary key,
    ep_2022_2023 varchar(7), -- ep pour l'année 2022-2023 : REP, REP+, HORS REP. Pas utilisé a priori
    nom_etablissement varchar(108),
    type_etablissement varchar(39), -- libelle_nature
    statut_public_prive varchar(18), -- secteur
    libelle_academie varchar(16), -- lib_academie
    libelle_departement varchar(23), -- nom_departement
    nom_commune varchar(45), -- nom_de_la_commune
    libelle_region varchar(34), -- libelle_region
    uai_tete_de_reseau char(8), -- pas utilisé
    qp_a_proximite_o_n char(16), -- 'Dans QP' ou NULL
    qp_a_proximite char(8), -- code_quartier_prioritaire
    nom_du_qp varchar(85), -- nom_quartier_prioritaire
    nombre_d_eleves integer, -- effectifs
    code_postal char(5), -- code_postal
    code_commune char(5), -- code_insee_de_la_commune
    code_departement char(3), -- code_du_departement
    code_academie char(2), -- code_academie
    code_region char(2), -- code_region
    libelle_nature varchar(39), -- libelle_nature
    code_nature char(3), -- code_nature
    latitude numeric,
    longitude numeric
);

WbImport -file=./fr-en-etablissements-ep.csv
         -header=true
         -delimiter=';'
         -quoteChar='"' 
         -table=_temp_fr_en_etablissements_ep
         -schema=colleges2
         -mode=insert, update -- car il y a des doublons (toute la ligne)
         -filecolumns=uai,ep_2022_2023,nom_etablissement,type_etablissement,statut_public_prive,libelle_academie,libelle_departement,nom_commune,libelle_region,uai_tete_de_reseau,qp_a_proximite_o_n,qp_a_proximite,nom_du_qp,nombre_d_eleves,code_postal,code_commune,code_departement,code_academie,code_region,libelle_nature,code_nature,$wb_skip$,latitude,longitude
         -importColumns=uai,ep_2022_2023,nom_etablissement,type_etablissement,statut_public_prive,libelle_academie,libelle_departement,nom_commune,libelle_region,uai_tete_de_reseau,qp_a_proximite_o_n,qp_a_proximite,nom_du_qp,nombre_d_eleves,code_postal,code_commune,code_departement,code_academie,code_region,libelle_nature,code_nature,latitude,longitude
         -keyColumns=uai;

--- Données sur les effectifs de 2019-2020 à 2022-2023
create table _temp_fr_en_college_effectif_niveau_sexe_lv (
    rentree_scolaire char(9) not null,
    region_academique varchar(26) not null,
    academie varchar(16) not null,
    departement varchar(21) not null,
    commune varchar(32) not null,
    numero_college char(8) not null,
    denomination_principale varchar(30) not null,
    patronyme varchar(30),
    secteur varchar(6),
    rep numeric(1),
    rep_plus numeric(1),
    nombre_eleves_total numeric not null default 0,
    nombre_eleves_ulis numeric not null default 0,
    _6eme_total numeric not null default 0,
    _6eme_segpa numeric not null default 0,
    _6eme_ulis numeric not null default 0,
    _6eme_filles numeric not null default 0,
    _6emes_garcons numeric not null default 0,
    _6eme_lv1_allemand numeric not null default 0,
    _6eme_lv1_anglais numeric not null default 0,
    _6eme_lv1_espagnol numeric not null default 0,
    _6eme_lv1_autres numeric not null default 0,
    _6eme_lv2_allemand numeric not null default 0,
    _6eme_lv2_anglais numeric not null default 0,
    _6eme_lv2_espagnol numeric not null default 0,
    _6eme_lv2_italien numeric not null default 0,
    _6eme_lv2_autres numeric not null default 0,
    _5eme_total numeric not null default 0,
    _5eme_segpa numeric not null default 0,
    _5eme_ulis numeric not null default 0,
    _5eme_filles numeric not null default 0,
    _5emes_garcons numeric not null default 0,
    _5eme_lv1_allemand numeric not null default 0,
    _5eme_lv1_anglais numeric not null default 0,
    _5eme_lv1_espagnol numeric not null default 0,
    _5eme_lv1_autres numeric not null default 0,
    _5eme_lv2_allemand numeric not null default 0,
    _5eme_lv2_anglais numeric not null default 0,
    _5eme_lv2_espagnol numeric not null default 0,
    _5eme_lv2_italien numeric not null default 0,
    _5eme_lv2_autres numeric not null default 0,
    _4eme_total numeric not null default 0,
    _4eme_segpa numeric not null default 0,
    _4eme_ulis numeric not null default 0,
    _4eme_filles numeric not null default 0,
    _4emes_garcons numeric not null default 0,
    _4eme_lv1_allemand numeric not null default 0,
    _4eme_lv1_anglais numeric not null default 0,
    _4eme_lv1_espagnol numeric not null default 0,
    _4eme_lv1_autres numeric not null default 0,
    _4eme_lv2_allemand numeric not null default 0,
    _4eme_lv2_anglais numeric not null default 0,
    _4eme_lv2_espagnol numeric not null default 0,
    _4eme_lv2_italien numeric not null default 0,
    _4eme_lv2_autres numeric not null default 0,
    _3eme_total numeric not null default 0,
    _3eme_segpa numeric not null default 0,
    _3eme_ulis numeric not null default 0,
    _3eme_filles numeric not null default 0,
    _3emes_garcons numeric not null default 0,
    _3eme_lv1_allemand numeric not null default 0,
    _3eme_lv1_anglais numeric not null default 0,
    _3eme_lv1_espagnol numeric not null default 0,
    _3eme_lv1_autres numeric not null default 0,
    _3eme_lv2_allemand numeric not null default 0,
    _3eme_lv2_anglais numeric not null default 0,
    _3eme_lv2_espagnol numeric not null default 0,
    _3eme_lv2_italien numeric not null default 0,
    _3eme_lv2_autres numeric not null default 0,
    code_postal char(5) not null,
    constraint _temp_effectif_pk primary key (rentree_scolaire, numero_college)
);

create trigger tg_rentree4_rentree9
    before insert or update of rentree_scolaire on _temp_fr_en_college_effectif_niveau_sexe_lv for each row
    execute procedure ftg_rentree4_rentree9 ();

WbImport -file=./fr-en-college-effectifs-niveau-sexe-lv.csv
         -header=true
         -delimiter=';'
         -quotechar='"'
         -table=_temp_fr_en_college_effectif_niveau_sexe_lv
         -schema=colleges2
         -mode=INSERT,UPDATE-- car il y a des doublons (toute la ligne)
         -fileColumns=rentree_scolaire,region_academique,academie,departement,commune,numero_college,denomination_principale,patronyme,secteur,rep,rep_plus,nombre_eleves_total,$wb_skip$,nombre_eleves_segpa,nombre_eleves_ulis,_6eme_total,$wb_skip$,_6eme_segpa,_6eme_ulis,_6eme_filles,_6emes_garcons,_6eme_lv1_allemand,_6eme_lv1_anglais,_6eme_lv1_espagnol,_6eme_lv1_autres,_6eme_lv2_allemand,_6eme_lv2_anglais,_6eme_lv2_espagnol,_6eme_lv2_italien,_6eme_lv2_autres,_5eme_total,$wb_skip$,_5eme_segpa,_5eme_ulis,_5eme_filles,_5emes_garcons,_5eme_lv1_allemand,_5eme_lv1_anglais,_5eme_lv1_espagnol,_5eme_lv1_autres,_5eme_lv2_allemand,_5eme_lv2_anglais,_5eme_lv2_espagnol,_5eme_lv2_italien,_5eme_lv2_autres,_4eme_total,$wb_skip$,_4eme_segpa,_4eme_ulis,_4eme_filles,_4emes_garcons,_4eme_lv1_allemand,_4eme_lv1_anglais,_4eme_lv1_espagnol,_4eme_lv1_autres,_4eme_lv2_allemand,_4eme_lv2_anglais,_4eme_lv2_espagnol,_4eme_lv2_italien,_4eme_lv2_autres,_3eme_total,$wb_skip$,_3eme_segpa,_3eme_ulis,_3eme_filles,_3emes_garcons,_3eme_lv1_allemand,_3eme_lv1_anglais,_3eme_lv1_espagnol,_3eme_lv1_autres,_3eme_lv2_allemand,_3eme_lv2_anglais,_3eme_lv2_espagnol,_3eme_lv2_italien,_3eme_lv2_autres,code_postal
         -importColumns=rentree_scolaire,region_academique,academie,departement,commune,numero_college,denomination_principale,patronyme,secteur,rep,rep_plus,nombre_eleves_total,nombre_eleves_total_hors_segpa_hors_ulis,nombre_eleves_segpa,nombre_eleves_ulis,_6eme_total,_6eme_hors_segpa_hors_ulis,_6eme_segpa,_6eme_ulis,_6eme_filles,_6emes_garcons,_6eme_lv1_allemand,_6eme_lv1_anglais,_6eme_lv1_espagnol,_6eme_lv1_autres,_6eme_lv2_allemand,_6eme_lv2_anglais,_6eme_lv2_espagnol,_6eme_lv2_italien,_6eme_lv2_autres,_5eme_total,_5eme_hors_segpa_hors_ulis,_5eme_segpa,_5eme_ulis,_5eme_filles,_5emes_garcons,_5eme_lv1_allemand,_5eme_lv1_anglais,_5eme_lv1_espagnol,_5eme_lv1_autres,_5eme_lv2_allemand,_5eme_lv2_anglais,_5eme_lv2_espagnol,_5eme_lv2_italien,_5eme_lv2_autres,_4eme_total,_4eme_hors_segpa_hors_ulis,_4eme_segpa,_4eme_ulis,_4eme_filles,_4emes_garcons,_4eme_lv1_allemand,_4eme_lv1_anglais,_4eme_lv1_espagnol,_4eme_lv1_autres,_4eme_lv2_allemand,_4eme_lv2_anglais,_4eme_lv2_espagnol,_4eme_lv2_italien,_4eme_lv2_autres,_3eme_total,_3eme_hors_segpa_hors_ulis,_3eme_segpa,_3eme_ulis,_3eme_filles,_3emes_garcons,_3eme_lv1_allemand,_3eme_lv1_anglais,_3eme_lv1_espagnol,_3eme_lv1_autres,_3eme_lv2_allemand,_3eme_lv2_anglais,_3eme_lv2_espagnol,_3eme_lv2_italien,_3eme_lv2_autres,code_postal
         -keyColumns=rentree_scolaire,numero_college;

--- Données sur la valeur ajoutée
create table _temp_fr_en_indicateurs_valeur_ajoutee_colleges (
    session char(9),
    uai char(8),
    nom_de_l_etablissement varchar(87) not null,
    commune varchar(32) not null,
    departement varchar(21) not null,
    academie varchar(16) not null,
    secteur char(2) not null,
    nb_candidats_g numeric default 0,
    taux_de_reussite_g numeric(5, 1),
    va_du_taux_de_reussite_g numeric(5, 1),
    nb_candidats_p numeric default 0,
    taux_de_reussite_p numeric(5, 1),
    note_a_l_ecrit_g numeric(4, 1),
    va_de_la_note_g numeric(4, 1),
    note_a_l_ecrit_p numeric(4, 1),
    taux_d_acces_6eme_3eme numeric(5, 1),
    part_presents_3eme_ordinaire_total numeric(5, 1),
    part_presents_3eme_ordinaire_g numeric(5, 1),
    part_presents_3eme_ordinaire_p numeric(5, 1),
    part_presents_3eme_segpa_total numeric(5, 1),
    nb_mentions_ab_g numeric default 0,
    nb_mentions_b_g numeric default 0,
    nb_mentions_tb_g numeric default 0,
    constraint indicateurs_valeur_ajoutee_pk primary key (uai, session)
);

create trigger tg_insert_session
    before insert or update of session on _temp_fr_en_indicateurs_valeur_ajoutee_colleges for each row
    execute procedure ftg_insert_session ();

WbImport -file=./fr-en-indicateurs-valeur-ajoutee-colleges.csv
         -header=true
         -delimiter=';'
         -quotechar='"'
         -table=_temp_fr_en_indicateurs_valeur_ajoutee_colleges
         -schema=colleges2
         -mode=INSERT,UPDATE-- car il y a des doublons (toute la ligne)
         -fileColumns=SESSION,uai,nom_de_l_etablissement,commune,departement,academie,secteur,nb_candidats_g,taux_de_reussite_g,va_du_taux_de_reussite_g,nb_candidats_p,taux_de_reussite_p,note_a_l_ecrit_g,va_de_la_note_g,note_a_l_ecrit_p,taux_d_acces_6eme_3eme,part_presents_3eme_ordinaire_total,part_presents_3eme_ordinaire_g,part_presents_3eme_ordinaire_p,part_presents_3eme_segpa_total,nb_mentions_ab_g,nb_mentions_b_g,nb_mentions_tb_g
         -importColumns=SESSION,uai,nom_de_l_etablissement,commune,departement,academie,secteur,nb_candidats_g,taux_de_reussite_g,va_du_taux_de_reussite_g,nb_candidats_p,taux_de_reussite_p,note_a_l_ecrit_g,va_de_la_note_g,note_a_l_ecrit_p,taux_d_acces_6eme_3eme,part_presents_3eme_ordinaire_total,part_presents_3eme_ordinaire_g,part_presents_3eme_ordinaire_p,part_presents_3eme_segpa_total,nb_mentions_ab_g,nb_mentions_b_g,nb_mentions_tb_g
         -keyColumns=SESSION,uai;

--- Données sur IPS
create table _temp_fr_en_ips_colleges_ap2022 (
    rentree_scolaire char(9),
    academie varchar(16) not null,
    code_du_departement char(3) not null,
    departement varchar(21) not null,
    uai char(8),
    nom_de_l_etablissment varchar(79) not null,
    code_insee_de_la_commune varchar(5) not null,
    nom_de_la_commune varchar(35) not null,
    secteur varchar(18) not null,
    effectifs integer not null,
    ips numeric(5, 1) not null,
    ecart_type_de_l_ips numeric(4, 1) not null,
    constraint ips_colleges_ap2022_pk primary key (rentree_scolaire, uai)
);

WbImport -file=./fr-en-ips-colleges-ap2022.csv
         -header=true
         -delimiter=';'
         -quotechar='"'
         -table=_temp_fr_en_ips_colleges_ap2022
         -schema=colleges2
         -mode=INSERT,UPDATE-- car il y a peut-être des doublons (toute la ligne)
         -fileColumns=rentree_scolaire,academie,code_du_departement,departement,uai,nom_de_l_etablissment,code_insee_de_la_commune,nom_de_la_commune,secteur,effectifs,ips,ecart_type_de_l_ips
         -importColumns=rentree_scolaire,academie,code_du_departement,departement,uai,nom_de_l_etablissment,code_insee_de_la_commune,nom_de_la_commune,secteur,effectifs,ips,ecart_type_de_l_ips
         -keyColumns=rentree_scolaire,uai;

--- Communes
---- Difficulté sur la presentation des communes : prendre une référence
---- https://public.opendatasoft.com/explore/dataset/correspondance-code-cedex-code-insee/table/?flg=fr-fr
create table _correspondance_code_cedex_code_insee (
    Code char(5) not null,
    Libelle varchar(38),
    Code_INSEE char(5),
    type_code varchar(11) not null,
    Nom_commune varchar(45),
    Nom_departement varchar(23),
    NOM_EPCI varchar(75),
    Nom_region varchar(26)
);

WbImport -file=./correspondance-code-cedex-code-insee.csv
         -header=true
         -delimiter=';'--quoteChar='"' 
         -table=_correspondance_code_cedex_code_insee
         -schema=colleges2
         -mode=INSERT-- , update -- car il y a des doublons (toute la ligne)
         -fileColumns=Code,Libelle,Code_INSEE,type_code,Nom_commune,Nom_departement,NOM_EPCI,Nom_region
         -importColumns=Code,Libelle,Code_INSEE,type_code,Nom_commune,Nom_departement,NOM_EPCI,Nom_region
         -keyColumns=code_insee;

-- STATS SUR LES DONNEES : a décommenter pour obtenir le résultat
/*
select count(distinct uai) as nb_row_temp_fr_en_etablissements_ep
from _temp_fr_en_etablissements_ep;
-- 8500 établissements en tout

select count(distinct uai) as nb_row_colleges_temp_fr_en_etablissements_ep
from _temp_fr_en_etablissements_ep
where type_etablissement = 'Collège';
-- 1414

select count(*) as nb_row_temp_fr_en_college_effectif_niveau_sexe_lv
from _temp_fr_en_college_effectif_niveau_sexe_lv;
-- 32982 (colleges, annee)

select count(distinct numero_college) as nb_row_colleges_temp_fr_en_college_effectif_niveau_sexe_lv
from _temp_fr_en_college_effectif_niveau_sexe_lv;
-- 8337

select count(distinct uai) from  (select uai
from _temp_fr_en_etablissements_ep
where type_etablissement = 'Collège'
intersect
select numero_college as uai
from _temp_fr_en_college_effectif_niveau_sexe_lv) as intersection;
-- 1414 (1414 si pas de restriction sur type_etablissement)
-- A priori tous les colleges de fr_en_etablissements_ep
 */
-- MODIFICATION DE LA BASE
--- 1. Retirer les contraintes not null trop strictes
alter table _quartier_prioritaire
    alter nom_quartier_prioritaire drop not null;

alter table _etablissement
    alter nom_etablissement drop not null;

alter table _etablissement
    alter secteur drop not null;

alter table _etablissement
    alter code_postal drop not null;

alter table _etablissement
    alter lattitude drop not null;

alter table _etablissement
    alter longitude drop not null;

alter table _etablissement
    alter code_academie drop not null;

alter table _etablissement
    alter code_nature drop not null;

--- 2. Faire grossir les clés primaires pour englober les attributs avec des valeurs inconsistentes et éviter les clés primaires dupliquées.
---- Ex: quartier prioritaire QP093058 avec des noms différents, commune (97801, SAINT MARTIN) dans des départements différents.
---- ajout du code_du_departement à la clé primaire de _commune
alter table _etablissement
    drop constraint etablissement_fk_commune;

alter table _commune
    drop constraint commune_pk;

alter table _commune
    add constraint commune_pk primary key (code_insee_de_la_commune, nom_de_la_commune, code_du_departement);

alter table _etablissement
    add code_du_departement char(3);

alter table _etablissement
    add constraint etablissement_fk_commune foreign key (code_insee_de_la_commune, nom_de_la_commune,
    code_du_departement) references _commune (code_insee_de_la_commune, nom_de_la_commune, code_du_departement);

---- ajout du nom_quartier_prioritaire à la clé primaire de _quartier_prioritaire
alter table _est_a_proximite_de
    drop constraint est_a_proximite_de_fk_qp;

alter table _quartier_prioritaire
    drop constraint quartier_prioritaire_pk;

alter table _quartier_prioritaire
    add constraint quartier_prioritaire_pk primary key (code_quartier_prioritaire, nom_quartier_prioritaire);

alter table _est_a_proximite_de
    add nom_quartier_prioritaire varchar(85);

alter table _est_a_proximite_de
    add constraint est_a_proximite_de_fk_qp foreign key (code_quartier_prioritaire, nom_quartier_prioritaire)
    references _quartier_prioritaire (code_quartier_prioritaire, nom_quartier_prioritaire);

-- UNIFORMISATION
--- extension requise pour la fonction unaccent
create extension if not exists unaccent;

--- nom de commune => upper o replace('-', ' ')
--- nom d'académie => unnacent o upper
--- nom de département => unnacent o upper
--- todo: nom d'academie sur les 2 autres sources
update
    _temp_fr_en_college_effectif_niveau_sexe_lv
set
    commune = upper(replace(commune, '-', ' '));
    academie = upper(unaccent (academie));

update
    _temp_fr_en_ips_colleges_ap2022
set
    academie = upper(unaccent (academie));

update
    _temp_fr_en_etablissements_ep
set
    nom_commune = upper(replace(nom_commune, '-', ' ')),
    libelle_departement = upper(unaccent (libelle_departement)),
    libelle_academie = upper(unaccent (libelle_academie));

-- RÉINITIALSIATION DES DONNÉES
delete from _caracteristiques_college;

delete from _caracteristiques_selon_classe;

delete from _caracteristiques_tout_etablissement;

delete from _est_a_proximite_de;

delete from _annee;

delete from _classe;

delete from _etablissement;

delete from _quartier_prioritaire;

delete from _academie;

delete from _commune;

delete from _type;

delete from _departement;

delete from _region;

-- DISTRIBUTION DES DONNEES DANS LES TABLES
--- Le préfixe 'tmp' est utilisé pour indiquer qu'on a affaire à une des table temporaires
--- Nous avons choisi de ne pas nous inquiéter des nulls et de retirer les contraintes not null plus haut au fur et à mesure des erreurs.
--- Après tout, si il y a un null, c'est certainement intentionel et pas une erreur, il faut donc le prendre en compte.
--- Au départ, on excluait toutes les lignes qui contenaient un null, mais çela a rapidement causé un problème. Exemple :
--- 1. _etablissement : l'établissement 0061525A a un nom null. Je n'en veux pas dans ma table.
--- 2. _est_a_proximite_de : l'établissement 0061525A est près du QP006013. Je vais rajouter une ligne dans ma table. !! Aargh! Il n'y a pas d'établissement 0061525A! *mic drop*
--- Donc maintenant on exclut seulement les lignes contennat null sur les clés primaires.
--- Fonction utilitaire
---- Retourne l'unique élément distinct d'un aggrégat, ou lève une exception si il y a plusieurs éléments.
create or replace function single (anyarray)
    returns anyelement
    as $$
declare
    distinct_count int;
begin
    distinct_count := (
        select
            array_length(array ( select distinct
                        unnest($1)), 1));
    if distinct_count > 1 then
        raise exception 'plusieurs élements dans l''aggrégat';
    else
        return ( select distinct
                unnest($1));
    end if;
end;
$$
language plpgsql;

--- _region
insert into _region (code_region, libelle_region)
select
    tmp.code_region,
    single (array_agg(tmp.libelle_region))
from
    _temp_fr_en_etablissements_ep tmp
where
    tmp.code_region is not null
    and tmp.libelle_region is not null
group by
    tmp.code_region;

--- _departement
insert into _departement (code_du_departement, nom_departement, code_region)
select distinct
    tmp.code_departement,
    single (array_agg(tmp.libelle_departement)),
    single (array_agg(tmp.code_region))
from
    _temp_fr_en_etablissements_ep tmp
where
    tmp.code_departement is not null
group by
    tmp.code_departement;

---- Départements manquants
insert into _departement (code_du_departement, code_region, nom_departement)
    values ('015', '84', 'CANTAL'), ('032', '76', 'GERS'),
    ('043', '84', 'HAUTE-LOIRE'), ('048', '76', 'LOZERE');

--- _commune
with source as (
    select
        tmp.code_postal code,
        tmp.commune nom,
        d.code_du_departement dept
    from
        _temp_fr_en_college_effectif_niveau_sexe_lv tmp
        inner join _departement d on tmp.departement = d.nom_departement
union
select
    coalesce(tmp_c.code_insee, tmp_c.code) code,
    tmp.commune nom,
    d.code_du_departement dept
from
    _temp_fr_en_indicateurs_valeur_ajoutee_colleges tmp
    left outer join _correspondance_code_cedex_code_insee tmp_c on tmp.commune = tmp_c.libelle
inner join _departement d on tmp_c.nom_departement = d.nom_departement
union
select
    tmp.code_commune code,
    tmp.nom_commune nom,
    tmp.code_departement dept
from
    _temp_fr_en_etablissements_ep tmp
union
select
    tmp.code_insee_de_la_commune code,
    tmp.nom_de_la_commune nom,
    tmp.code_du_departement dept
from
    _temp_fr_en_ips_colleges_ap2022 tmp)
    insert into _commune (code_insee_de_la_commune, nom_de_la_commune, code_du_departement)
    select
        code,
        nom,
        dept
    from
        source
    where
        code is not null
        and nom is not null
        and dept is not null;

--- _academie
---- todo: 2 autres sources
with source as (
    select
        tmp.code_academie code,
        tmp.libelle_academie lib
    from
        _temp_fr_en_etablissements_ep tmp)
    insert into _academie (code_academie, lib_academie)
    select
        code,
        single (array_agg(lib))
    from
        source
    where
        code is not null
    group by
        code;

--- _type
insert into _type (code_nature, libelle_nature)
select
    tmp.code_nature,
    single (array_agg(tmp.libelle_nature))
from
    _temp_fr_en_etablissements_ep tmp
where
    tmp.code_nature is not null
group by
    tmp.code_nature;

--- _quartier_prioritaire
insert into _quartier_prioritaire (code_quartier_prioritaire, nom_quartier_prioritaire)
select distinct
    tmp.qp_a_proximite,
    tmp.nom_du_qp
from
    _temp_fr_en_etablissements_ep tmp
where
    tmp.qp_a_proximite is not null
    and tmp.nom_du_qp is not null;

--- _etablissement
insert into _etablissement (uai, nom_etablissement, secteur, code_postal, lattitude, longitude,
    code_insee_de_la_commune, nom_de_la_commune, code_academie, code_nature, code_du_departement)
select
    tmp.uai,
    tmp.nom_etablissement,
    tmp.statut_public_prive,
    tmp.code_postal,
    tmp.latitude,
    tmp.longitude,
    tmp.code_commune,
    tmp.nom_commune,
    tmp.code_academie,
    tmp.code_nature,
    tmp.code_departement
from
    _temp_fr_en_etablissements_ep tmp
group by
    uai;

--- _est_a_proximite_de
insert into _est_a_proximite_de (uai, code_quartier_prioritaire, nom_quartier_prioritaire)
select
    tmp.uai,
    single (array_agg(tmp.qp_a_proximite)),
    tmp.nom_du_qp
from
    _temp_fr_en_etablissements_ep tmp
where
    tmp.uai is not null
    and tmp.qp_a_proximite is not null
    and tmp.qp_a_proximite <> 'Hors QP'
    and tmp.nom_du_qp is not null
group by
    tmp.uai;

--- _annee
insert into _annee (annee_scolaire)
select
    -- Effectifs
    tmp.rentree_scolaire
from
    _temp_fr_en_college_effectif_niveau_sexe_lv tmp
union
-- IPS colleges
select
    tmp.rentree_scolaire
from
    _temp_fr_en_ips_colleges_ap2022 tmp
union
-- Valeur ajoutéèe
select
    tmp.session
from
    _temp_fr_en_indicateurs_valeur_ajoutee_colleges tmp;

-- NETTOYAGE
drop table _temp_fr_en_etablissements_ep cascade;

drop table _temp_fr_en_college_effectif_niveau_sexe_lv cascade;

drop table _temp_fr_en_indicateurs_valeur_ajoutee_colleges cascade;

drop table _temp_fr_en_ips_colleges_ap2022 cascade;

drop table _correspondance_code_cedex_code_insee cascade;

commit;
