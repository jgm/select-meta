# select-meta

This filter allows you to import metadata from YAML and markdown
files selectively, using SQL-like queries.  The source can be
any metadata field in a markdown or YAML file.  The field's
list of values can be filtered using a condition (e.g.,
`date >= 2010`), sorted by different properties, and grouped.

Using just pandoc and this filter, one can create complex
documents, including static websites, from data in YAML
"databases."  (See [yst](https://github.com/jgm/yst) for an
earlier dedicated tool that did this.)

Example of input:

```
---
papers:
  select: articles
  from: articles.yaml
  where: 'year > 2009'
  group: author
  order: author, title asc
...
```

This filter only looks for `select` fields in the top-level
of the metadata hierachy.

To run it,

    pandoc --lua-filter select-meta.lua sample.md

