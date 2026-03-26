# Journal de bord — Intégration CMS (Sveltia CMS)

## Contexte

Site Quarto statique pour l'ALISP, hébergé sur Netlify.
Repo migré de Codeberg vers **GitHub** (migration en cours).
Objectif : permettre à des membres non-tech de publier des articles via une interface WYSIWYG, sans toucher à Git ni Markdown.

## Décisions prises

| Sujet | Décision |
|---|---|
| CMS retenu | Sveltia CMS (drop-in pour Decap/Netlify CMS, même config.yml) |
| Auth | Netlify Identity + Git Gateway (email/mot de passe, pas de compte GitHub nécessaire) |
| Workflow | `editorial_workflow` : draft → review → merge (PR GitHub), toi tu valides avant publication |
| Backend | `git-gateway` (GitHub via Netlify) |
| Évolution | Publication directe possible plus tard (retirer `publish_mode`) |

## Structure blog

```
blog/
  {slug}/
    index.qmd   ← frontmatter: title, author, date, categories, description, image
```

Champs CMS mappés : `title`, `author`, `date`, `description`, `categories` (list), `image` (optionnel), `body` (markdown).

## Fichiers à créer

### `admin/index.html`

```html
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>CMS - ALISP</title>
</head>
<body>
  <script src="https://unpkg.com/@sveltia/cms/dist/sveltia-cms.js"></script>
</body>
</html>
```

### `admin/config.yml`

```yaml
backend:
  name: git-gateway
  branch: main

publish_mode: editorial_workflow

media_folder: blog/_media
public_folder: /blog/_media

collections:
  - name: blog
    label: Actualités
    label_singular: Article
    folder: blog
    path: "{{slug}}/index"
    media_folder: ""
    public_folder: ""
    create: true
    extension: qmd
    format: yaml-frontmatter
    fields:
      - { name: title,       label: Titre,       widget: string }
      - { name: author,      label: Auteur,      widget: string }
      - { name: date,        label: Date,        widget: datetime, format: "YYYY-MM-DD", date_only: true }
      - { name: description, label: Description, widget: text }
      - { name: categories,  label: Catégories,  widget: list }
      - { name: image,       label: "Image de couverture", widget: image, required: false }
      - { name: body,        label: Contenu,     widget: markdown }
```

## Configuration Netlify (à faire une fois)

1. `Site settings > Identity` → **Enable Identity**
2. `Identity > Services > Git Gateway` → **Enable Git Gateway**
3. `Identity > Invite users` → inviter les membres par email

## Workflow contributeur (une fois en place)

1. Aller sur `alisp.fr/admin`
2. Se connecter via l'invitation email reçue
3. Créer un article en WYSIWYG → "Save" (statut Draft)
4. Quand prêt : "Set status > In Review"
5. Toi tu reçois une PR GitHub → tu merges → Netlify rebuild et publie

## Prochaines étapes

- [ ] Migrer le repo Codeberg → GitHub
- [ ] Créer `admin/index.html` et `admin/config.yml`
- [ ] Activer Netlify Identity + Git Gateway
- [ ] Tester le flux complet avec un compte de test
- [ ] Inviter les membres contributeurs
