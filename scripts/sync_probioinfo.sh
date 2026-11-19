#!/usr/bin/env bash
# =====================================================================
# Espelha o tutorial "Montagem de genomas com dados Nanopore" do
# PRO-BIOINFO (LGBIO-UFG/PRO-BIOINFO) na Parte 2 · Bioinformática do
# Curso de Montagem de Genomas de Referência com dados Nanopore.
#
# Roda automaticamente no GitHub Actions antes de gerar o site.
# Para ver o espelho localmente:  bash scripts/sync_probioinfo.sh && mkdocs serve
# (depois, descarte as alterações nos arquivos bioinformatica.md antes do commit)
# =====================================================================
set -euo pipefail

REPO="https://github.com/LGBIO-UFG/PRO-BIOINFO.git"
SRC_URL="https://lgbio-ufg.github.io/PRO-BIOINFO/cursos/nanopore/index.html"
PRO_COURSES="https://lgbio-ufg.github.io/PRO-BIOINFO/cursos"
COURSE="cursos/montagem-genomas-nanopore"
ASSETS="docs/assets/probioinfo-nanopore"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

git clone --quiet --depth 1 --filter=blob:none --sparse "$REPO" "$TMP/pro"
git -C "$TMP/pro" sparse-checkout set docs/cursos/nanopore
SRC="$TMP/pro/docs/cursos/nanopore"
SHA="$(git -C "$TMP/pro" rev-parse --short HEAD)"
DATE="$(git -C "$TMP/pro" log -1 --format=%cs)"

# Resultados (figuras, relatórios): uma cópia compartilhada pelas duas línguas
rm -rf "$ASSETS"
mkdir -p "$ASSETS"
cp -R "$SRC/outputs" "$ASSETS/"

# Corpo do tutorial: sem o título original; links ajustados ao novo local
BODY="$TMP/body.md"
tail -n +2 "$SRC/index.md" \
  | sed -E \
      -e 's#\]\(outputs/#](../../../assets/probioinfo-nanopore/outputs/#g' \
      -e 's#(src|href)="outputs/#\1="../../../assets/probioinfo-nanopore/outputs/#g' \
      -e "s#\]\(\.\./([a-zA-Z0-9_-]+)/index\.md#](${PRO_COURSES}/\1/index.html#g" \
  > "$BODY"

write_page () {
  local lang="$1" title="$2" banner="$3"
  local out="docs/${lang}/${COURSE}/bioinformatica.md"
  {
    printf '# %s\n\n' "$title"
    printf '%s\n\n' "$banner"
    cat "$BODY"
  } > "$out"
  echo "Gerado: $out"
}

write_page pt "Parte 2 · Bioinformática" \
"!!! info \"Conteúdo espelhado do PRO-BIOINFO\"
    Esta página reproduz automaticamente o tutorial [Montagem de genomas com dados Nanopore](${SRC_URL}) do Programa de Formação em Bioinformática (PRO-BIOINFO, LGBio/UFG). Versão de ${DATE} (\`${SHA}\`)."

write_page es "Parte 2 · Bioinformática" \
"!!! info \"Contenido replicado del PRO-BIOINFO (en portugués)\"
    Esta página reproduce automáticamente el tutorial [Montagem de genomas com dados Nanopore](${SRC_URL}) del Programa de Formación en Bioinformática (PRO-BIOINFO, LGBio/UFG). El contenido está en portugués. Versión del ${DATE} (\`${SHA}\`)."
