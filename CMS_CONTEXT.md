# Intégration CMS — Sveltia CMS

## Contexte

Site Quarto statique pour l'ALISP, hébergé sur Netlify.
Repo GitHub : `alisp59/site-alisp`.
Objectif : permettre à des membres non-tech de publier des articles via une interface WYSIWYG.

## Décisions

| Sujet | Décision |
|---|---|
| CMS | Sveltia CMS |
| Auth | GitHub OAuth via compte `alisp59` partagé |
| OAuth proxy | `sveltia-cms-auth.asso-isp-lille.workers.dev` (Cloudflare Workers) |
| Backend | `github` direct (Git Gateway deprecated) |
| Workflow | `editorial_workflow` : draft → review → PR → merge |

## Workflow contributeur

1. Aller sur `alisp.fr/admin`
2. Se connecter avec le compte GitHub `alisp59`
3. Créer un article en WYSIWYG → "Save" (Draft)
4. "Set status > In Review" → PR GitHub
5. Julien valide → merge → Netlify rebuild

## Prochaines étapes

- [x] Migrer le repo Codeberg → GitHub
- [x] Créer `admin/index.html` et `admin/config.yml`
- [x] Déployer sveltia-cms-auth sur Cloudflare Workers
- [x] Créer OAuth App GitHub + configurer les variables Cloudflare
- [ ] Connecter Netlify au repo GitHub
- [ ] Tester le flux complet
- [ ] Inviter les membres contributeurs
