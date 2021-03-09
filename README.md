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
  <pre text-align="center">Enable full text searching by creating a virtual table using the fts4 engine. 
  <b>Note.</b> These steps are mandatory in order to use any of our scripts that refer to the database.
  <ul>
  <li>Open a terminal and type:</li>
  sqlite3 ML_DL_review_articles.db
  <li>From sqlite3 interface type:</li>
  sqlite> CREATE VIRTUAL TABLE ML_DL_review_articles_tab USING fts4(PMID, Title, Abstract, Date);
  sqlite> INSERT INTO ML_DL_review_articles_tab SELECT `PMID`, `Title`, `Abstract`, `Create Date` FROM ML_DL_review_articles;
  </ul>
  <pre>
</ul>
