-- Population de la BdD collège
-- 6/06/2024
-- Raphaël Bardini, Mattéo Kervadec (1C2)
set schema 'colleges2pierre';

drop view if exists Colleges;

-- Population de la BdD collège
-- 6/06/2024
-- Raphaël Bardini, Mattéo Kervadec (1C2)
set schema 'colleges2pierre';

drop view if exists Colleges;

create view
    Colleges as (
        with
            const as (
                select
                    '2022-2023' annee
            )
        select
            e.uai,
            (
                select
                    sum(c.nbre_eleves_segpa_selon_niveau)
                from
                    _caracteristiques_selon_classe c
                where
                    c.annee_scolaire = const.annee
                    and c.uai = e.uai
            ) effectif_segpa,
            cc.ips,
            cc.ecart_type_de_l_ips,
            cc.ep::int,
            (
                select
                    sum(csc.effectifs_filles)::double precision / sum(csc.effectifs_garcons)
                from
                    _caracteristiques_selon_classe csc
                where
                    csc.uai = e.uai
                    and csc.annee_scolaire = '2022-2023'
            ) ratio_filles_garcons,
            length(e.nom_etablissement) longueur_nom_etablissement,
            case e.secteur
                when 'Privé' then 0.
                when 'Public' then 1.
                else 'NaN'
            end secteur,
            effectifs
        from
            const const
            cross join _etablissement e
            inner join _caracteristiques_college cc on cc.uai = e.uai
            and cc.annee_scolaire = const.annee
            inner join _caracteristiques_tout_etablissement cte on cte.uai = e.uai
            and cte.annee_scolaire = const.annee
        where
            e.code_nature = '340' -- COLLEGE
    );

WbExport -file=Colleges.csv
 -type=text
 -table=Colleges
 -schema=colleges2pierre
 -delimiter=','
 -types=VIEW
 -header=true;
