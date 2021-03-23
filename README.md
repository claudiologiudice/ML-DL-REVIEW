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
  <li><a href="https://github.com/claudiologiudice/ML-DL-REVIEW/blob/main/table.py">table.py</a></li>
</ul>

<ul>Database
  <li><a href="https://github.com/claudiologiudice/ML-DL-REVIEW/blob/main/ML_DL_review_articles.db.tar.gz">ML_DL_review_articles.db.tar.gz</a></li>
  <br>Enable full text searching by creating a virtual table "ML_DL_review_articles_tab" based on the fts4 engine. 
  <br><b>Note.</b> These steps are mandatory in order to use any of our scripts that refer to the <a href="https://github.com/claudiologiudice/ML-DL-REVIEW/blob/main/ML_DL_review_articles.db.tar.gz">database</a>.
  <br><br>Open a terminal and type:
  <br><pre>$ sqlite3 ML_DL_review_articles.db</pre>
  <br>Inside sqlite3 interface type:
  <br><pre>sqlite> CREATE VIRTUAL TABLE ML_DL_review_articles_tab USING fts4(PMID, Title, Abstract, Date);</pre>
  <br><pre>sqlite> INSERT INTO ML_DL_review_articles_tab SELECT `PMID`, `Title`, `Abstract`, `Create Date` FROM ML_DL_review_articles;</pre>
</ul>
