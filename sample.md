---
lang: fr-FR
glaces:
  select: flavors
  from: 'ice-cream.yaml'
  where: 'introduced >= 1960-01-01'
  order: date desc, name
  group: type
new:
  select: flavors
  from: ice-cream.yaml
  order: date desc, name
  limit: 3
...

