-- Question 1 : Gross Written Premium (GWP) par année

-- Objectif business :
-- Mesurer le volume total de primes souscrites chaque année
-- afin d’évaluer la croissance du portefeuille d’assurances

SELECT
    EXTRACT(YEAR FROM start_date_) AS year,
    SUM(annual_premium) AS total_gwp
FROM policies
GROUP BY EXTRACT(YEAR FROM start_date_)
ORDER BY year;

-- Question 2 : Montant total des sinistres approuvés par année

-- Objectif business :
-- Mesurer le coût réel des sinistres acceptés par l’assureur,
-- afin d’évaluer la charge sinistre annuelle.

SELECT
    EXTRACT(YEAR FROM claim_date) AS year,
    SUM(claim_amount) AS total_approved_claims
FROM claims_staging 
WHERE claim_status = 'Approved'
GROUP BY EXTRACT(YEAR FROM claim_date)
ORDER BY year;


-- Question 3 : Primes effectivement encaissées par année

-- Objectif business :
-- Mesurer les flux de trésorerie entrants réels (cash in),
-- indépendamment des primes souscrites (GWP).

SELECT
    EXTRACT(YEAR FROM payment_date) AS year,
    SUM(payment_amount) AS total_collected_premium
FROM payments_staging
GROUP BY EXTRACT(YEAR FROM payment_date)
ORDER BY year;



-- Question 4 : Loss Ratio par année

-- Objectif business :
-- Mesurer la rentabilité technique du portefeuille.
-- Le Loss Ratio compare le coût des sinistres
-- aux primes souscrites (GWP).

SELECT
    EXTRACT(YEAR FROM p.start_date_) AS year,
    ROUND(SUM(c.claim_amount) FILTER (WHERE c.claim_status = 'Approved')
        / SUM(p.annual_premium),2) AS loss_ratio
FROM policies p
LEFT JOIN claims_staging c
    ON p.policy_id = c.policy_id
GROUP BY EXTRACT(YEAR FROM p.start_date_)
ORDER BY year;


-- Question 5 : Nombre de sinistres par statut et par année

-- Objectif business :
-- Comprendre la qualité du portefeuille et du process claims
-- (acceptation, refus, backlog).

SELECT
    EXTRACT(YEAR FROM c.claim_date) AS year,
    c.claim_status,
    COUNT(c.claim_id) AS nb_claims
FROM claims_staging c
GROUP BY
    EXTRACT(YEAR FROM c.claim_date),
    c.claim_status
ORDER BY year, c.claim_status;


-- Question 6 : Top 3 produits les plus rentables

-- Objectif business :
-- Identifier les produits qui génèrent le plus de valeur
-- en comparant les primes souscrites aux sinistres approuvés.

SELECT
    p.product_type,
    SUM(p.annual_premium) AS total_premium,
    SUM(c.claim_amount) FILTER (WHERE c.claim_status = 'Approved') AS total_claims,
    SUM(p.annual_premium)
        - SUM(c.claim_amount) FILTER (WHERE c.claim_status = 'Approved') AS margin
FROM policies p
LEFT JOIN claims_staging c
    ON p.policy_id = c.policy_id
GROUP BY p.product_type
ORDER BY margin DESC
LIMIT 3;


-- Question 7 : Loss Ratio par risk_profile

-- Objectif : Identifier les profils de risque les plus sinistrants

SELECT
    c.risk_profile,
    ROUND(SUM(cl.claim_amount) FILTER (WHERE cl.claim_status = 'Approved')
        / SUM(p.annual_premium),2) AS loss_ratio
FROM clients c
JOIN policies p
    ON c.client_id = p.client_id
LEFT JOIN claims_staging cl
    ON p.policy_id = cl.policy_id
GROUP BY c.risk_profile
ORDER BY loss_ratio DESC;


-- Question 8 : Ranking des canaux d’acquisition par rentabilité moyenne par client

-- Objectifs : Identifier les canaux qui créent le plus de valeur par client.

SELECT
    c.acquisition_channel,
    SUM(p.annual_premium)
      - SUM(cl.claim_amount) FILTER (WHERE cl.claim_status = 'Approved')
        AS total_margin,
    ROUND((
        SUM(p.annual_premium)
        - SUM(cl.claim_amount) FILTER (WHERE cl.claim_status = 'Approved')
    ) / COUNT(DISTINCT c.client_id), 2) AS avg_margin_per_client
FROM clients c
JOIN policies p ON c.client_id = p.client_id
LEFT JOIN claims_staging cl ON p.policy_id = cl.policy_id
GROUP BY c.acquisition_channel
ORDER BY avg_margin_per_client DESC;


-- Question 9 : Top 5 clients générant le plus de primes

-- Objectif : Identifier les clients à forte valeur brute.

SELECT
    c.client_id,
    SUM(p.annual_premium) AS total_premium
FROM clients c
JOIN policies p ON c.client_id = p.client_id
GROUP BY c.client_id
ORDER BY total_premium DESC
LIMIT 5;


-- Question 10 : Pays avec la plus forte fréquence de sinistres

-- Objectif : Comparer le risque structurel par pays.

SELECT
    c.country,
    ROUND(COUNT(DISTINCT cl.claim_id)::DECIMAL
        / COUNT(DISTINCT p.policy_id), 2) AS claim_frequency
FROM clients c
JOIN policies p ON c.client_id = p.client_id
LEFT JOIN claims_staging cl ON p.policy_id = cl.policy_id
GROUP BY c.country
ORDER BY claim_frequency DESC;


-- Question 11 : Cohortes par année d’acquisition

-- Objectif :Construire la base des analyses de rétention.

SELECT
    EXTRACT(YEAR FROM acquisition_date) AS cohort_year,
    COUNT(DISTINCT client_id) AS nb_clients
FROM clients
GROUP BY cohort_year
ORDER BY cohort_year;


-- Question 12 :Taux de rétention à 12 mois

-- Objectif : Mesurer la capacité à garder les clients.

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
    ROUND(COUNT(*) FILTER (
        WHERE last_policy_date >= c.acquisition_date + INTERVAL '12 months'
    )::DECIMAL / COUNT(*),2) AS retention_rate_12m
FROM cohort co
JOIN clients c ON c.client_id = co.client_id
GROUP BY cohort_year
ORDER BY cohort_year;


-- Question 13 : Taux de churn par produit

-- Objectif : Identifier les produits qui perdent leurs clients.

SELECT
    product_type,
    ROUND(COUNT(*) FILTER (WHERE policy_status = 'Cancelled')::DECIMAL
        / COUNT(*), 2) AS churn_rate
FROM policies
GROUP BY product_type
ORDER BY churn_rate DESC;

-- Question 14 : Évolution du Loss Ratio (cohortes 2020 vs 2023)

-- Objectif : Comparer la qualité des clients dans le temps.

SELECT
    EXTRACT(YEAR FROM c.acquisition_date) AS cohort_year,
    ROUND(SUM(cl.claim_amount) FILTER (WHERE cl.claim_status = 'Approved')
        / SUM(p.annual_premium), 2) AS loss_ratio
FROM clients c
JOIN policies p ON c.client_id = p.client_id
LEFT JOIN claims_staging cl ON p.policy_id = cl.policy_id
WHERE EXTRACT(YEAR FROM c.acquisition_date) IN (2020, 2023)
GROUP BY cohort_year
ORDER BY cohort_year;


-- Question 15 : Combinaisons critiques (Loss Ratio > 80% + marge négative)

-- Objectif: Identifier les poches de destruction de valeur.

SELECT
    c.country,
    p.product_type,
    c.risk_profile,
    ROUND(SUM(cl.claim_amount) FILTER (WHERE cl.claim_status = 'Approved')
        / SUM(p.annual_premium),2) AS loss_ratio,
    SUM(p.annual_premium)
        - SUM(cl.claim_amount) FILTER (WHERE cl.claim_status = 'Approved') AS margin
FROM clients c
JOIN policies p ON c.client_id = p.client_id
LEFT JOIN claims_staging cl ON p.policy_id = cl.policy_id
GROUP BY c.country, p.product_type, c.risk_profile
HAVING
    ROUND(SUM(cl.claim_amount) FILTER (WHERE cl.claim_status = 'Approved')
        / SUM(p.annual_premium),2) > 0.8
    AND
    SUM(p.annual_premium)
        - SUM(cl.claim_amount) FILTER (WHERE cl.claim_status = 'Approved') < 0
ORDER BY loss_ratio DESC;
