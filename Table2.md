<div class="tg-wrap"><table id="tg-lREGD">
<thead>
  <tr>
    <th>Tecnique</th>
    <th>Biological Applications</th>
    <th>Associated PMids</th>
  </tr>
</thead>
<tbody>
  <tr>
    <td>Artificial Neural networks OR ANN OR ANN</td>
    <td>gene selection; genotype-phenotype analysis; risk classification; transcriptome profiling; variant extraction</td>
    <td>29536823; 32359808; 24631783; 24820964; 25883319</td>
  </tr>
  <tr>
    <td>Autoencoder</td>
    <td>gene prediction</td>
    <td>33160303</td>
  </tr>
  <tr>
    <td>Deep neural networks OR DNNConvolutional Neural Networks or CNN</td>
    <td>mutation-gene-drug relations; gene expression analysis</td>
    <td>29368597; 31395005</td>
  </tr>
  <tr>
    <td>K nearest neighbor OR K-NN</td>
    <td>gene selection</td>
    <td>26159165</td>
  </tr>
  <tr>
    <td>K-means</td>
    <td>candidate mirna targets</td>
    <td>30973878</td>
  </tr>
  <tr>
    <td>LASSO</td>
    <td>intratumoral heterogeneity; biomarkers selection; gene selection; gene expression analysis</td>
    <td>31310640; 30458775; 31888444 - 29957558; 30458775</td>
  </tr>
  <tr>
    <td>Linear Discriminant Analysis OR LDA OR Normal Discriminant Analysis</td>
    <td>transcriptome profiling; mirna biomarkers</td>
    <td>32887275; 28361698</td>
  </tr>
  <tr>
    <td>Logistic regression OR LR OR Binomial Regression</td>
    <td>gene prediction; gene selection; drug-induced gene expression</td>
    <td>33160303; 29989970; 31664045</td>
  </tr>
  <tr>
    <td>Naive Bayes</td>
    <td>gene selection; pharmacogenetic prediction</td>
    <td>22369383; 30546092</td>
  </tr>
  <tr>
    <td>Nearest Neighbor classifier OR NN</td>
    <td>gene selection</td>
    <td>26159165</td>
  </tr>
  <tr>
    <td>Perceptron</td>
    <td>gene selection</td>
    <td>27762231</td>
  </tr>
  <tr>
    <td>Random forest OR RF</td>
    <td>tissue-selective genes; gene prediction; co-acting gene networks; gene selection; mutation-gene-drug relations; gene expression analysis; mirna biomarkers; drug-induced gene expression</td>
    <td>23369200; 23369200 - 33160303; 25527049; 24953305 - 26159165 - 22369383; 29368597; 32535186 - 30828420 - 33318199; 32473385 - 32236623; 32780735</td>
  </tr>
  <tr>
    <td>Support Vector Machine OR SVM</td>
    <td>intratumoral heterogeneity; tissue-selective genes; gene prediction; gene selection; disease-gene association; gene expression analysis; signatures from gene-pathway; disease gene prioritization; mirna signatures</td>
    <td>31310640; 23369200; 23369200 - 33160303; 23060613 - 22369383 - 27762231 - 29536823 - 26159165 - 21982277; 31825992; 29468833; 25126556; 22808075; 26466382</td>
  </tr>
</tbody>
</table></div>
<script charset="utf-8">var TGSort=window.TGSort||function(n){"use strict";function r(n){return n?n.length:0}function t(n,t,e,o=0){for(e=r(n);o<e;++o)t(n[o],o)}function e(n){return n.split("").reverse().join("")}function o(n){var e=n[0];return t(n,function(n){for(;!n.startsWith(e);)e=e.substring(0,r(e)-1)}),r(e)}function u(n,r,e=[]){return t(n,function(n){r(n)&&e.push(n)}),e}var a=parseFloat;function i(n,r){return function(t){var e="";return t.replace(n,function(n,t,o){return e=t.replace(r,"")+"."+(o||"").substring(1)}),a(e)}}var s=i(/^(?:\s*)([+-]?(?:\d+)(?:,\d{3})*)(\.\d*)?$/g,/,/g),c=i(/^(?:\s*)([+-]?(?:\d+)(?:\.\d{3})*)(,\d*)?$/g,/\./g);function f(n){var t=a(n);return!isNaN(t)&&r(""+t)+1>=r(n)?t:NaN}function d(n){var e=[],o=n;return t([f,s,c],function(u){var a=[],i=[];t(n,function(n,r){r=u(n),a.push(r),r||i.push(n)}),r(i)<r(o)&&(o=i,e=a)}),r(u(o,function(n){return n==o[0]}))==r(o)?e:[]}function v(n){if("TABLE"==n.nodeName){for(var a=function(r){var e,o,u=[],a=[];return function n(r,e){e(r),t(r.childNodes,function(r){n(r,e)})}(n,function(n){"TR"==(o=n.nodeName)?(e=[],u.push(e),a.push(n)):"TD"!=o&&"TH"!=o||e.push(n)}),[u,a]}(),i=a[0],s=a[1],c=r(i),f=c>1&&r(i[0])<r(i[1])?1:0,v=f+1,p=i[f],h=r(p),l=[],g=[],N=[],m=v;m<c;++m){for(var T=0;T<h;++T){r(g)<h&&g.push([]);var C=i[m][T],L=C.textContent||C.innerText||"";g[T].push(L.trim())}N.push(m-v)}t(p,function(n,t){l[t]=0;var a=n.classList;a.add("tg-sort-header"),n.addEventListener("click",function(){var n=l[t];!function(){for(var n=0;n<h;++n){var r=p[n].classList;r.remove("tg-sort-asc"),r.remove("tg-sort-desc"),l[n]=0}}(),(n=1==n?-1:+!n)&&a.add(n>0?"tg-sort-asc":"tg-sort-desc"),l[t]=n;var i,f=g[t],m=function(r,t){return n*f[r].localeCompare(f[t])||n*(r-t)},T=function(n){var t=d(n);if(!r(t)){var u=o(n),a=o(n.map(e));t=d(n.map(function(n){return n.substring(u,r(n)-a)}))}return t}(f);(r(T)||r(T=r(u(i=f.map(Date.parse),isNaN))?[]:i))&&(m=function(r,t){var e=T[r],o=T[t],u=isNaN(e),a=isNaN(o);return u&&a?0:u?-n:a?n:e>o?n:e<o?-n:n*(r-t)});var C,L=N.slice();L.sort(m);for(var E=v;E<c;++E)(C=s[E].parentNode).removeChild(s[E]);for(E=v;E<c;++E)C.appendChild(s[v+L[E-v]])})})}}n.addEventListener("DOMContentLoaded",function(){for(var t=n.getElementsByClassName("tg"),e=0;e<r(t);++e)try{v(t[e])}catch(n){}})}(document)</script>
