# 📊 Projet Assurance Analytics – SQL (PostgreSQL)

---

## 👤 Contexte du projet

Ce projet simule une mission réelle de Data Analyst SQL au sein d’une compagnie d’assurance européenne, multi-produits et multi-pays (France, Allemagne, Espagne, Italie, Pays-Bas).  
L’objectif est d’analyser la performance financière du portefeuille, la sinistralité, la rétention client et la performance par produit, pays et canal d’acquisition entre 2020 et 2025.  

Ce projet est conçu pour démontrer mes compétences en :  
- SQL avancé (PostgreSQL)  
- Analyse financière et assurance  
- Structuration de projet data pour portfolio GitHub  
- Traduction des besoins business en requêtes analytiques concrètes  

---

## 🎯 Objectifs business

La compagnie souhaite :  
- Optimiser la **rentabilité du portefeuille**  
- Identifier les segments clients et produits **à risque ou rentables**  
- Suivre la **rétention et le churn** par cohorte d’acquisition  
- Produire des **KPI financiers** exploitables par la direction  
- Disposer d’insights stratégiques pour ajuster **pricing, underwriting et canaux d’acquisition**  

Pour ce faire, 15 questions business ont été posées et résolues exclusivement avec SQL.

---

## 🗄️ Données utilisées

Le projet repose sur 4 tables principales, fournies au format CSV.

### 1️⃣ clients
| Champ               | Description                       |
|--------------------|-----------------------------------|
| client_id           | Identifiant unique client         |
| country             | Pays de résidence                 |
| acquisition_channel | Canal d’acquisition               |
| acquisition_date    | Date d’entrée dans le portefeuille|
| customer_segment    | Retail / SME / Corporate          |
| risk_profile        | Niveau de risque underwriting     |

### 2️⃣ policies
| Champ          | Description                      |
|----------------|----------------------------------|
| policy_id      | Identifiant contrat              |
| client_id      | Client associé                   |
| product_type   | Type d’assurance (Auto, Home…)   |
| start_date_     | Date de début contrat            |
| annual_premium | Prime annuelle facturée           |
| policy_status  | Active / Cancelled / Expired      |

### 3️⃣ claims_staging
| Champ        | Description                      |
|--------------|----------------------------------|
| claim_id     | Identifiant sinistre             |
| policy_id    | Contrat concerné                 |
| claim_date   | Date de déclaration              |
| claim_amount | Montant du sinistre              |
| claim_status | Approved / Rejected / Pending    |

### 4️⃣ payments_staging
| Champ          | Description                       |
|----------------|-----------------------------------|
| payment_id     | Identifiant paiement              |
| policy_id      | Contrat concerné                  |
| payment_date   | Date transaction                  |
| payment_amount | Montant                           |
| payment_type   | Premium / Refund / Claim Payout   |

---

## 🛠️ Outils & technologies
- PostgreSQL (requêtes analytiques)
- VS Code (environnement de travail)
- SQL structuré : CTE, JOIN, agrégations, fonctions fenêtres

---

## 🔄 Transformations & enrichissement des données

Afin de rendre les données exploitables pour l’analyse assurance, plusieurs transformations ont été réalisées :  

### 📌 Colonnes calculées
- **Année d’acquisition / start_date_** → pour cohortes et KPI temporels  
- **Primes totales / annual_premium** → volume de primes par année  
- **Claims approuvés / claim_amount** → pertes réelles  
- **Marge = Primes – Claims approuvés** → profitabilité par segment  
- **Loss Ratio = Claims / Primes** → indicateur clé de sinistralité  
- **Retention & Churn** → calculés à 12 mois après acquisition  

Ces transformations permettent de produire des analyses financières, des cohortes, et des insights décisionnels.

---

## 📊 Analyses réalisées (questions business)

Les analyses réalisées couvrent notamment :  

### 1️⃣ Exploration
- Volume par table (clients, policies, claims_staging, payment_stagings)  
- Périodes couvertes : 2020-01-01 → 2025-12-31  
- Valeurs manquantes : 0 %  
- Ratios clés du modèle :  
  - Avg_policies_per_client = 1,5  
  - Avg_claims_per_policy = 0,83  
  - Avg_payments_per_policy = 1,25  

### 2️⃣ KPIs financiers
- Gross Written Premium (GWP) par année  
- Loss Ratio annuel  
- Marge brute par produit et pays  
- Claim frequency et average claim size  
- Churn et retention par cohorte  

### 3️⃣ Segmentation clients et produits
| Segment | Clients | Total Primes | Total Claims | Marge |
|---------|--------|--------------|-------------|-------|
| SME Medium Risk | 44 | 116 827 € | 98 775 € | 18 052 € |
| Retail High Risk | 63 | 192 413 € | 184 935 € | 7 478 € |
| Corporate Medium/Low/High | 63 | 169 184 € | 198 433 € | –29 249 € |
| SME High/Low | 79 | 213 504 € | 276 611 € | –63 107 € |
| Retail Medium/Low | 372 | 1 098 886 € | 1 231 167 € | –132 279 € |

**Interprétation métier** :
- **Segments rentables** : SME Medium Risk et Retail High Risk  
- **Segments déficitaires** : Corporate et Retail Medium/Low, SME High/Low → besoin d’**ajustement pricing et underwriting**  
- **Action prioritaire** : revoir acquisition sur segments High Risk ou Corporate  

### 4️⃣ Cohortes & rétention
| Année d’acquisition | Nb clients | Retention 12m | Churn |
|--------------------|-----------|---------------|-------|
| 2020 | 132 | 61 % | 13 % |
| 2021 | 126 | 71 % | 13 % |
| 2022 | 153 | 48 % | 29 % |
| 2023 | 136 | 38 % | 43 % |
| 2024 | 130 | 11 % | 67 % |
| 2025 | 123 | 0 %  | 74 % |

**Interprétation métier** :
- Cohortes 2020–2021 : fidélité élevée, bonne rentabilité  
- Cohortes 2022–2025 : rétention chute, churn augmente → alerte  
- Actions recommandées : revoir **pricing, produits, canaux acquisition**, et prioriser fidélisation  

### 5️⃣ Insights stratégiques
- Analyse combinée : `country + product_type + risk_profile`  
- Critères retenus : **Loss Ratio > 80 % & Marge négative**  
- Segments critiques identifiés :
  - Auto Insurance + High Risk + France → perte élevée  
  - SME + High Risk + Espagne → volatilité importante  
  - Corporate + High Risk + Allemagne → pertes nettes  
- Recommandations :
  1. Ajuster tarifs et franchises pour segments High Risk  
  2. Limiter acquisition sur segments à forte sinistralité  
  3. Optimiser marketing et fidélisation sur segments rentables  

---

## 📈 KPIs produits
- GWP annuel  
- Loss Ratio et Combined Ratio  
- Gross Margin par produit, pays, canal  
- Claim Frequency et Average Claim Size  
- Retention Rate 12 mois et Churn Rate  
- Segmentation clients rentable / à risque  

---

## 🧠 Insights & recommandations
- Les clients High Risk et certains segments Corporate/SME sont **déficitaires**, action prioritaire sur underwriting et pricing  
- Les Retail High Risk et SME Medium Risk sont **rentables**, focus sur fidélisation et cross-sell  
- Cohortes récentes montrent un **churn élevé**, nécessité de revoir acquisition et expérience client  
- Pays à risque : France, Espagne → prioriser contrôle du portefeuille  

---

## 👨‍💻 Auteur
**David SOUWAN**  
Data Analyst | SQL | Finance & Assurance  
Formateur Data  

---

## ✅ Pourquoi ce projet est pertinent pour un recruteur
✔ Cas métier réaliste dans le domaine Finance & Assurance  
✔ SQL avancé et structuré (CTE, JOIN, filtres, agrégations, fenêtres)  
✔ Capacité à générer des **KPIs financiers complexes**  
✔ Analyse cohérente des **cohortes, segmentation et rétention**  
✔ Production d’**insights business exploitables pour la direction**  
✔ Projet directement exploitable et présenté de manière professionnelle sur GitHub
