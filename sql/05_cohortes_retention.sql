
--Objectif business

--Suivre les cohortes d’acquisition par année

--Calculer le taux de rétention et churn à 12 mois

-- Construire cohortes et rétention 12 mois

WITH cohort AS (
    SELECT
        c.client_id,
        EXTRACT(YEAR FROM c.acquisition_date) AS cohort_year,
        MAX(p.start_date_) AS last_policy_date
    FROM clients c
    LEFT JOIN policies p ON c.client_id = p.client_id
    GROUP BY c.client_id, cohort_year
)
SELECT
    co.cohort_year,
    COUNT(*) AS nb_clients,
    ROUND(COUNT(*) FILTER (WHERE last_policy_date >= c.acquisition_date + INTERVAL '12 months')::DECIMAL
        / COUNT(*),2) AS retention_rate_12m,
    ROUND(COUNT(*) FILTER (WHERE last_policy_date < c.acquisition_date + INTERVAL '12 months')::DECIMAL
        / COUNT(*),2) AS churn_rate
FROM cohort co
JOIN clients c ON c.client_id = co.client_id
GROUP BY cohort_year
ORDER BY cohort_year;


/*
Synthèse générale

--Trend alarmant : retention diminue année après année

Churn en hausse → impact direct sur chiffre d’affaires futur

--Actions à prioriser :

Revoir le pricing et les conditions produits

Analyser les canaux d’acquisition récents

Identifier les segments clients les plus perdus pour ajuster le marketing

--Signal métier fort pour un entretien :

“Les clients acquis après 2022 montrent une détérioration importante de la fidélité,
 ce qui indique des faiblesses dans l’offre ou l’acquisition. Cela justifie des
  mesures ciblées pour réduire le churn et améliorer la valeur client.”
  */

