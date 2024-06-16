---- Version 2 : correction de la partie 2
---- Inclut les corrections de schema

drop schema if exists colleges2 cascade;

create schema colleges2;
set schema 'colleges2';

create table _region(    -- infos dans fr-en-etablissements-ep
                         -- peuplement fourni
    code_region     char(2),
    libelle_region  varchar(34)     not null,
    constraint region_pk primary key(code_region),
    constraint region_uk unique(libelle_region)
);

create table _departement( -- infos dans fr-en-etablissements-ep
                           -- peuplement fourni
    code_du_departement     char(3),
    nom_departement         varchar(23) not null,
    code_region             char(2)     not null,
    constraint departement_pk primary key(code_du_departement),
    constraint departement_uk unique(nom_departement),
    constraint departement_fk_inclut
        foreign key (code_region) 
        references _region(code_region)
);

create table _commune( -- infos à croiser dans 3 fichiers
                       -- peuplement fourni
    code_insee_de_la_commune    char(5),
    nom_de_la_commune           varchar(45)     not null,
    code_du_departement         char(3)         not null,
    constraint commune_pk primary key(code_insee_de_la_commune, nom_de_la_commune), -- changement de modélisation
    -- constraint commune_uk unique(nom_de_la_commune), -- c'est faux !!!! plusieurs code insee pour la même commune
    constraint commune_fk_se_situe
        foreign key (code_du_departement) 
        references _departement(code_du_departement)
);


create table _academie(  -- infos dans fr-en-etablissements-ep et deux autres
                         -- peuplement demandé
    code_academie   char(2),
    lib_academie    varchar(16) not null,
    constraint academie_pk primary key(code_academie),
    constraint academie_uk unique(lib_academie)
);

create table _quartier_prioritaire( -- infos dans fr-en-etablissements-ep
                                    -- peuplement demandé
    code_quartier_prioritaire   char(8),
    nom_quartier_prioritaire    varchar(85)     not null,
    constraint quartier_prioritaire_pk primary key(code_quartier_prioritaire)
);

create table _type ( -- ou Nature : infos dans fr-en-etablissement-ep 
                     -- peuplement demandé
    code_nature     char(3),
    libelle_nature  varchar(39)     not null,
    constraint type_pk primary key(code_nature)
);

create table _etablissement ( -- Aller piocher dans tous les fichiers. Pbs de NULL ?
                             -- fr-etablissements-ep
                             -- peuplement demandé
    uai                         char(8),
    nom_etablissement           varchar(108)    not null,
    secteur                     varchar(18)     not null,
    code_postal                 char(5)         not null,
    lattitude                   numeric         not null,
    longitude                   numeric         not null,
    code_insee_de_la_commune    char(5)         ,--not null -- Est-ce que cela fonctionne avec non null ?
    nom_de_la_commune           varchar(45)     , 
    code_academie               char(2)         not null,
    code_nature                 char(3)         not null,
    constraint etablissement_pk primary key (uai),
    constraint etablissement_fk_commune -- changement de modélisation
        foreign key (code_insee_de_la_commune,nom_de_la_commune)
        references _commune(code_insee_de_la_commune,nom_de_la_commune),
    constraint etablissement_fk_academie
        foreign key (code_academie)
        references _academie(code_academie),
    constraint etablissement_fk_type
        foreign key (code_nature)
        references _type(code_nature)
);

create table _est_a_proximite_de( -- peuplement demandé
    code_quartier_prioritaire   char(8)     not null,
    uai                         char(8),
    constraint est_a_proximite_de_pk primary key(uai),
    constraint est_a_proximite_de_fk_qp
        foreign key(code_quartier_prioritaire)
        references _quartier_prioritaire(code_quartier_prioritaire),
    constraint est_a_proximite_de_fk_etablissement
        foreign key (uai)
        references _etablissement(uai)
);

create table _annee ( -- peuplement demandé
    annee_scolaire char(9),
    constraint annee_pk primary key (annee_scolaire)
);

create table _caracteristiques_tout_etablissement(
    uai                         char(8),
    annee_scolaire              char(9),
    effectifs                   integer     not null,
    constraint caracteristiques_tout_etablissement_pk
        primary key (uai, annee_scolaire),
    constraint caracteristiques_tout_etablissement_fk_etablissement
        foreign key (uai) references _etablissement(uai),
    constraint caracteristiques_tout_etablissement_fk_annee
        foreign key (annee_scolaire) references _annee(annee_scolaire)
);

create table _classe (
    id_classe   char(4), -- 6eme, 5eme, 4eme, 3eme
    constraint classe_pk primary key (id_classe)
);

create table _caracteristiques_college(
    uai                                 char(8),
    annee_scolaire                      char(9),
    nbre_eleves_hors_segpa_hors_ulis    integer not null,
    nbre_eleves_segpa                   integer not null,
    nbre_eleves_ulis                    integer not null,
    -- erreur de modelisation : corrigé par rapport à la V1
    ips                                 numeric     not null,
    ecart_type_de_l_ips                 numeric     not null,
    ep                                  boolean     not null,
    constraint caracteristiques_college_pk
        primary key (uai,annee_scolaire),
    constraint caracteristiques_college_fk_classe
        foreign key (annee_scolaire) 
        references _annee(annee_scolaire),
    constraint caracteristiques_college_fk_etablissement
        foreign key (uai) 
        references _etablissement (uai)
);

create table _caracteristiques_selon_classe(
    id_classe                           char(4),
    uai                                 char(8),
    annee_scolaire                      char(9),
    nbre_eleves_hors_segpa_hors_ulis_selon_niveau   integer not null,
    nbre_eleves_segpa_selon_niveau                  integer not null,
    nbre_eleves_ulis_selon_niveau                   integer not null,
    effectifs_filles                                integer not null,
    effectifs_garcons                               integer not null,
    constraint caracteristiques_selon_classe_pk
        primary key (id_classe, uai, annee_scolaire),
    constraint caracteristiques_selon_classe_fk_classe
        foreign key (id_classe) references _classe(id_classe),
    constraint caracteristiques_selon_classe_fk_etablissement
        foreign key (uai) references _etablissement(uai),
    constraint caracteristiques_selon_classe_fk_annee
        foreign key (annee_scolaire) references _annee(annee_scolaire)
);

commit;
