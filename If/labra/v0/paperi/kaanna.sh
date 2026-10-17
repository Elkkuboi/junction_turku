#!/bin/sh
# Kääntää paperin. Fonttikartat annetaan komennossa, koska kaikissa TeX-asennuksissa
# pdfTeX:n oletuskarttaa ei ole generoitu; muualla ne ovat vain ylimääräisiä.
set -e
cd "$(dirname "$0")"
for i in 1 2 3; do
  pdflatex -interaction=nonstopmode -halt-on-error \
    '\pdfmapfile{+lm.map}\pdfmapfile{+symbols.map}\input{simulaattori}' > /dev/null
done
rm -f simulaattori.aux simulaattori.log simulaattori.out simulaattori.toc
echo "paperi/simulaattori.pdf valmis"
