exonerate-gff3
==============

This is an exonerate fork with added gff3 support.  
Original website with user guides: http://www.ebi.ac.uk/~guy/exonerate/

New Option:
   --gff3 [FALSE]
   
Using the "--gff3 yes" option with the "--showtargetgff yes" option will output GFF3. Without the "--gff3 yes" option, everything works just as before so previous scripts relying on the old output format won’t break. 
   
Example Command:  
`exonerate -q protein.fa -t genome.fa --model protein2genome --querytype protein --targettype dna --showvulgar no --softmaskquery yes --softmasktarget yes --minintron 20 --maxintron 3000 --showalignment no --showtargetgff yes --showcigar no --geneseed 250 --score 250 --verbose 0 --gff3 yes`

Example Output:
```
Scaffold1	exonerate:protein2genome:local	match	188318	189587	649	-	.	ID=match00012;Name=EDAN000750-PA;Target=EDAN000750-PA 1 129 +;Gap=M135 D884 M251
Scaffold1	exonerate:protein2genome:local	match_part	189452	189587	.	-	.	Parent=match00012
Scaffold1	exonerate:protein2genome:local	match_part	188318	188568	.	-	.	Parent=match00012
Scaffold1	exonerate:protein2genome:local	match	183667	183897	392	-	.	ID=match00013;Name=EDAN000750-PA;Target=EDAN000750-PA 127 203;Gap=M231
Scaffold1	exonerate:protein2genome:local	match_part	183667	183897	.	-	.	Parent=match00013
Scaffold1	exonerate:protein2genome:local	match	45007	45165	265	-	.	ID=match00014;Name=EDAN000738-PA;Target=EDAN000738-PA 10 62;Gap=M159
Scaffold1	exonerate:protein2genome:local	match_part	45007	45165	.	-	.	Parent=match00014
Scaffold1	exonerate:protein2genome:local	match	218654	221996	1577	+	.	ID=match00015;Name=EDAN000753-PA;Target=EDAN000753-PA 1 337 +;Gap=M30 D61 M100 D61 M127 D373 M181 D56 M225 D1183 M189 D604 M153
Scaffold1	exonerate:protein2genome:local	match_part	218654	218685	.	+	.	Parent=match00015
Scaffold1	exonerate:protein2genome:local	match_part	218745	218846	.	+	.	Parent=match00015
Scaffold1	exonerate:protein2genome:local	match_part	218906	219034	.	+	.	Parent=match00015
Scaffold1	exonerate:protein2genome:local	match_part	219406	219586	.	+	.	Parent=match00015
Scaffold1	exonerate:protein2genome:local	match_part	219643	219867	.	+	.	Parent=match00015
Scaffold1	exonerate:protein2genome:local	match_part	221051	221239	.	+	.	Parent=match00015
Scaffold1	exonerate:protein2genome:local	match_part	221844	221996	.	+	.	Parent=match00015
```
