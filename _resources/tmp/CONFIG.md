# Configuration technique — site ALISP

## Architecture

- **Site** : Quarto (type website), rendu en local
- **Hébergement** : Netlify (déploiement via `quarto publish netlify`, pas de build CI)
- **Repo** : `alisp59/site-alisp` sur GitHub (migré depuis Codeberg)
- **CMS** : Sveltia CMS (`alisp.fr/admin`)
- **Domaine** : `alisp.fr`

## Comptes et accès

| Service | Compte | Rôle |
|---|---|---|
| GitHub | `alisp59` | Propriétaire du repo, compte partagé pour l'asso et login CMS |
| GitHub | `hebstr` | Collaborateur, reçoit les notifications PR, review/merge |
| Cloudflare Workers | `asso-isp-lille` | Héberge le proxy OAuth pour Sveltia CMS |
| Netlify | — | Héberge le site, lié au repo GitHub (builds désactivés) |

## CMS — Sveltia CMS

### Fichiers

- `admin/index.html` : charge Sveltia CMS via CDN (`unpkg.com/@sveltia/cms@0.151.4`)
- `admin/config.yml` : configuration des collections et du backend

### Backend

```yaml
backend:
  name: github
  repo: alisp59/site-alisp
  branch: main
  base_url: https://sveltia-cms-auth.asso-isp-lille.workers.dev
```

Le backend `github` communique directement avec l'API GitHub via OAuth (Git Gateway deprecated par Netlify).

### OAuth

L'authentification passe par un proxy OAuth déployé sur Cloudflare Workers :
- **Worker** : `sveltia-cms-auth.asso-isp-lille.workers.dev`
- **Source** : [sveltia/sveltia-cms-auth](https://github.com/sveltia/sveltia-cms-auth)
- **Variables d'environnement** (dans Cloudflare) : `GITHUB_CLIENT_ID`, `GITHUB_CLIENT_SECRET`, `ALLOWED_DOMAINS` (`alisp.fr`)

L'OAuth App GitHub est enregistrée sur le compte `alisp59` :
- **Callback URL** : `https://sveltia-cms-auth.asso-isp-lille.workers.dev/callback`

### Collection blog

```yaml
collections:
  - name: blog
    folder: blog
    path: "{{slug}}/index"
    extension: qmd
    frontmatter_delimiter: "---"
```

Structure des articles : `blog/{slug}/index.qmd` avec frontmatter YAML (title, author, date, description, categories, image).

## Quarto

### Intégration CMS

Le dossier `admin/` est copié dans `_site/` via `resources` dans `_quarto.yml` :

```yaml
project:
  type: website
  resources:
    - admin/**
```

### Déploiement

```bash
quarto render && quarto publish netlify
```

Netlify ne build pas — il sert uniquement les fichiers déployés par `quarto publish`.
Le site Netlify est lié au repo GitHub uniquement pour que Sveltia CMS puisse créer des branches/PR.

## Notifications

- `alisp59` : notifications email désactivées (Settings > Notifications)
- `hebstr` : collaborateur sur le repo, Watch > All Activity → reçoit les notifs de PR

## SSH

Clé SSH `ed25519` configurée sur le compte `alisp59` pour les push Git depuis la machine locale.

```bash
git remote -v
# origin  git@github.com:alisp59/site-alisp.git
```

## Refaire le setup from scratch

1. Créer un repo GitHub vide
2. Configurer le remote SSH et push le code
3. Créer un compte Cloudflare Workers, déployer [sveltia-cms-auth](https://github.com/sveltia/sveltia-cms-auth) (bouton Deploy)
4. Créer une OAuth App GitHub avec callback `https://<worker-url>/callback`
5. Ajouter `GITHUB_CLIENT_ID`, `GITHUB_CLIENT_SECRET`, `ALLOWED_DOMAINS` dans les variables du worker
6. Créer `admin/index.html` et `admin/config.yml` (voir sections ci-dessus)
7. Ajouter `resources: [admin/**]` dans `_quarto.yml`
8. Connecter Netlify au repo GitHub, désactiver les builds
9. `quarto render && quarto publish netlify`
10. Tester `<domaine>/admin`
