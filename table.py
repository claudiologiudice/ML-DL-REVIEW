'''
Created by claudio.logiudice@uniba.it
'''
import sqlite3 as sql
import sys

try:
  db = sys.argv[1]
except:
  sys.exit('<ML_DL_review_articles.db>')
  
ML_DL_techniques = ['Naive Bayes',
 'Linear Discriminant Analysis OR LDA OR Normal Discriminant Analysis',
 'Linear regression',
 'Logistic regression OR LR OR Binomial Regression',
 'Multinomial Logistic Regression OR Softmax Regression',
 'Support Vector Machine OR SVM',
 'Perceptron',
 'Artificial Neural networks OR ANN',
 'Boosting OR Adaptive Boosting OR AdaBoost',
 'Random forest OR RF',
 'Nearest Neighbor classifier OR NN',
 'K nearest neighbor OR K-NN',
 'Deep neural networks OR DNNConvolutional Neural Networks or CNN',
 'Recurrent Neural Networks or RNN',
 'K-means',
 'K-medoids',
 'Generative adversarial networks OR GAN',
 'LASSO',
 'Autoencoder',
 'Elastic Net',
 'Self Organizing Map',
 'Ridge regression',
 'Reinforcement Learning']

biological_key_terms = ['biomarkers selection', 
'gene selection',                                                                            
'gene expression analysis',                                                                                                                                     
'gene signatures detection',                                                                                                                                   
'sex gene association',                                                                                                                                        
'disease-gene association',                                                                                                                                    
'gene prediction',                                                          
'cancer genes association',
'cancer subtypes classification',                                                                                                                              
'mutation-gene-drug relations',       
'intratumoral heterogeneity',
'tissue-selective genes',                                                                                                                                      
'drug-induced gene expression',
'cell-type classification',
'disease gene prioritization',
'pharmacogenetic prediction',
'signatures from gene-pathway',
'candidate miRNA targets',
'miRNA Signatures',
'miRNA biomarkers',
'genotype-phenotype analysis',
'risk classification',
'cell-type classification',
'transcriptome profiling',
'variant extraction',
'variant prioritization',
'genome assembly',
'genome annotation',
'Co-acting gene networks']
  
conn = sql.connect(db)
cursor = conn.cursor()  

dic_ml_dl_methods = {}
for term in sorted(ML_DL_techniques):                                                                                                                                      
	dic_ml_dl_methods.setdefault(term, map(lambda x: (x[0].encode('UTF-8'), x[1], x[2]) ,cursor.execute('select Title,PMID,Date from ML_DL_review_articles_tab where Abstract MATCH \'{}\';'.format(term)).fetchall()))                                                                                                                         
                                                                                                                                   
dic_gen_appl = {}  #biological_appl:PMIDs                                                                                                                                              
for appl in biological_key_terms:                                                                                                                                          
	dic_gen_appl.setdefault(appl, map(lambda x: x[1], cursor.execute('select Title,PMID from ML_DL_review_articles_search where Abstract MATCH \'"{}"\';'.format(appl)).fetchall()))            

dic_table = {}                                                                                                                                                  
for k,v in dic_ml_dl_methods.items():                                                                                                                                   
	a = map(lambda x: x[1] ,v)    
	for k2, v2 in dic_gen_appl.items():                                                                                                                         
		if set(a).intersection(set(v2)):                                                                                                                        
			dic_table.setdefault(k, []).append((k2.lower(), list(set(a).intersection(set(v2)))))     

header = '{},{},{}\n'.format('Tecnique', 'Biological Applications', 'Associated PMids')
with open('TABLE_OUT.txt', 'w') as f:
  f.write(header)                                                                                                                                            
  for k,v in sorted(dic_table.items()):
    f.write('{},{},{}\n'.format(k, '; '.join(map(lambda x: x[0], v)), '; '.join(map(lambda x: str(x[1]).replace(',',' -').replace('[','').replace(']',''), v))))
