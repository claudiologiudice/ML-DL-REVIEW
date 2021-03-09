# ML-DL-REVIEW
This repo contains Figures, Supplementary Materials and scripts related to the review "XXXXX"

<ul>Tables
  <li><a href="https://github.com/claudiologiudice/ML-DL-REVIEW/blob/main/Table2.md">Table2</a></li>
</ul>

<ul>Figures
<li></li>
</ul>

<ul>Supplementary files
  <li><a href="https://github.com/claudiologiudice/ML-DL-REVIEW/blob/main/supplementary_material.pdf">Supplementary material</a></li>
</ul>

<ul>Scripts
<li></li>
</ul>

<ul>Database
  <li><a href="https://github.com/claudiologiudice/ML-DL-REVIEW/blob/main/ML_DL_review_articles.db.tar.gz">ML_DL_review_articles.db.tar.gz</a></li>
  <pre>Enable full text searching enable by creating a virtual table using the fts4 engine. <br>This is done like with the following commands:</pre>
  Note. These steps are mandatory in order to use any of our script that refers to the database.
  sqlite3 ML_DL_review_articles.db 
  sqlite> CREATE VIRTUAL TABLE ML_DL_review_articles_tab USING fts4(PMID, Title, Abstract, Date);
  sqlite> INSERT INTO ML_DL_review_articles_tab SELECT `PMID`, `Title`, `Abstract`, `Create Date` FROM ML_DL_review_articles;
</ul>
