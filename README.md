# Site web de l'ALISP

Le site [alisp.fr](https://alisp.fr) est le site de l'Association Lilloise des Internes en Santé Publique.

## Architecture

- **Site** : construit avec [Quarto](https://quarto.org/), un générateur de sites statiques
- **Hébergement** : [Netlify](https://www.netlify.com/)
- **Code source** : compte GitHub de l'association (`alisp59`)
- **CMS** : [Sveltia CMS](https://github.com/sveltia/sveltia-cms), un éditeur en ligne accessible sur [alisp.fr/admin](https://alisp.fr/admin)
- **Authentification** : via le compte GitHub `alisp59` (compte partagé de l'asso, identifiants disponibles auprès du webmaster)
- **Proxy OAuth** : hébergé sur Cloudflare Workers (`sveltia-cms-auth.asso-isp-lille.workers.dev`)

## Publier un article

1. Aller sur [alisp.fr/admin](https://alisp.fr/admin)
2. Se connecter avec le compte GitHub de l'asso (`alisp59`)
3. Rédiger l'article dans l'éditeur visuel : titre, auteur, date, description, catégories, image de couverture (facultatif), contenu
4. Cliquer sur **Save** (l'article est en brouillon)
5. Quand l'article est prêt : **Set status > In Review**
6. Le webmaster (Julien, `hebstr`) reçoit une notification GitHub, relit l'article et publie

## Rôles

- **Membres contributeurs** : rédigent et soumettent des articles via [alisp.fr/admin](https://alisp.fr/admin)
- **Webmaster** (Julien) : valide les articles soumis, met en ligne (`quarto render` + `quarto publish netlify`)

## Contact

Pour les identifiants ou toute question : contacter le webmaster.
