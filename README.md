# 🚔 Chicago Crimes - Guide d'installation et d'utilisation

Ce guide vous explique comment configurer et exécuter le projet **Chicago Crimes** sur votre machine locale.

---

## 🛠️ Prérequis

Avant de commencer, assurez-vous d'avoir les éléments suivants installés :

- **Télécharger les fichiers csv dans le dossier data** ([Crimes dataset](https://data.cityofchicago.org/Public-Safety/Crimes-2001-to-Present/ijzp-q8t2/data_preview), [Police Safety](https://data.cityofchicago.org/Public-Safety/Police-Sentiment-Scores/28me-84fj/about_data)) 
- **Renomer les fichiers csv** _"Crimes_2001_to_Present.csv"_ et _"Police_Sentiment_Scores.csv"_
- **Docker** (pour lancer les conteneurs)
- **Python 3.x** (pour exécuter les scripts)
- **Jupyter Notebook** (pour exécuter le notebook de seeding)

---

## 🚀 Étapes d'installation

### 1. Lancer les services avec Docker
Pour démarrer les services nécessaires (comme la base de données), exécutez la commande suivante :

```bash
docker compose up -d
```

### 2. Configurer l'environnement virtuel Python
Créez et activez un environnement virtuel pour isoler les dépendances du projet :

```python
python -m venv venv
venv\Scripts\activate
```

### 3. Installer les dépendances
Installez les packages Python requis en utilisant le fichier requirements.txt :
```bash
pip install -r requirements.txt
```

### 4. Exécuter le notebook de seeding
Lancez le notebook Jupyter pour peupler la base de données avec les données de Chicago : _jupyter notebook /scripts/Seed_chicago_crimes.ipynb_ & _jupyter notebook /scripts/Seed_chicago_crimes.ipynb_

## 🌐 Accéder à l'application
Une fois les services Docker en cours d'exécution et le seeding terminé, accédez à l'application via votre navigateur à l'adresse suivante :

👉 [lien vers rstudio](http://localhost:8787/)

Enfin lancer le script **script.R**