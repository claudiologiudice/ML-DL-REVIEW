# ML-DL-REVIEW
This repo contains Tables, Supplementary Materials, data and scripts related to the review "A primer on state-of-the-art machine learning techniques for genomic applications"

### Tables
<a href="https://github.com/claudiologiudice/ML-DL-REVIEW/blob/main/Table2.md">Table2</a>

### Supplementary files
<a href="https://github.com/claudiologiudice/ML-DL-REVIEW/blob/main/supplementary_material.pdf">supplementary_material.pdf</a>

### Data
Folder data contains data used to perform the analysis reported in section 8 of the paper.

### Scripts
Folder code containr R code used to perform the analysis reported in section 8 of the paper.
Otehr scripts include:
<a href="https://github.com/claudiologiudice/ML-DL-REVIEW/blob/main/table.py">table.py</a><br>
<a href="https://github.com/claudiologiudice/ML-DL-REVIEW/blob/main/figures.ipynb">figures.ipynb</a>

### Database
<a href="https://github.com/claudiologiudice/ML-DL-REVIEW/blob/main/ML_DL_review_articles.db.tar.gz">ML_DL_review_articles.db.tar.gz</a>
<br>Enable full text searching by creating a virtual table "ML_DL_review_articles_tab" based on the fts4 engine. 
#### Note
These steps are mandatory in order to use script <a href="https://github.com/claudiologiudice/ML-DL-REVIEW/blob/main/table.py">table.py</a>.
<br>Open a terminal and type:

```
$ sqlite3 ML_DL_review_articles.db
```
Inside thesqlite3 interface type:

```
sqlite> CREATE VIRTUAL TABLE ML_DL_review_articles_tab USING fts4(PMID, Title, Abstract, Date);
sqlite> INSERT INTO ML_DL_review_articles_tab SELECT `PMID`, `Title`, `Abstract`, `Create Date` FROM ML_DL_review_articles;
```

