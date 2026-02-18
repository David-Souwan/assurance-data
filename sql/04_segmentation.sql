

-- Q1 Segmentation clients par risk_profile et customer_segment

-- Objectif : identifier les clients les plus risqués et leur valeur

SELECT
    c.customer_segment,
    c.risk_profile,
    COUNT(DISTINCT c.client_id) AS nb_clients,
    SUM(p.annual_premium) AS total_premium,
    SUM(cl.claim_amount) FILTER (WHERE cl.claim_status = 'Approved') AS total_claims,
    SUM(p.annual_premium)
        - SUM(cl.claim_amount) FILTER (WHERE cl.claim_status = 'Approved') AS margin
FROM clients c
JOIN policies p ON c.client_id = p.client_id
LEFT JOIN claims_staging cl ON p.policy_id = cl.policy_id
GROUP BY c.customer_segment, c.risk_profile
ORDER BY margin DESC;


/* Synthèse métier globale

---Segments rentables :

SME Medium Risk → focus sur développement

Retail High Risk → rentabilité faible mais positive, surveiller

---Segments critiques / pertes :

Corporate (tous profils) → action prioritaire

SME High / Low → grande volatilité, risque élevé

Retail Medium / Low → volume élevé mais perte nette

---Recommandations stratégiques :

Ajuster pricing par segment et risque

Réviser underwriting, notamment sur Corporate et SME High Risk

Identifier les canaux d’acquisition qui apportent les clients les moins rentables

Possible cross-sell sur SME Medium Risk pour améliorer marge globale
*/

-- -- refresh commit
