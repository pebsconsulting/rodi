#cd bin
cp -R bin/* .

BASEPATH=.


CLASSPATH=$CLASSPATH:$BASEPATH:$BASEPATH/lib/db2triples-1.0.2.jar:$BASEPATH/lib/openrdf-sesame-2.7.13-onejar.jar:$BASEPATH/lib/slf4j-api-1.7.4.jar:$BASEPATH/lib/slf4j-simple-1.7.4.jar:$BASEPATH/lib/commons-io-2.1.jar:$BASEPATH/lib/postgresql-9.3-1100.jdbc41.jar:$BASEPATH/lib/commons-logging-1.1.1.jar:$BASEPATH/lib/logmap2_nolibs_2016.jar:$BASEPATH/lib/owllink-bin.jar:$BASEPATH/lib/junit.jar:$BASEPATH/lib/org.mortbay.jmx.jar:$BASEPATH/lib/org.mortbay.jetty.jar:$BASEPATH/lib/javax.servlet.jar:$BASEPATH/lib/mysql-connector-java-5.1.34-bin.jar:$BASEPATH/lib/owlapi-distribution-3.4.8.jar:$BASEPATH/lib/org.semanticweb.HermiT.jar




SCENARIOS_ID[0]=cmt_renamed
SCENARIOS_ID[1]=cmt2sigkdd

BOOTSTRAPPER_ID=bootox

TOOLS_FOLDER=tools




for i in {0..1}
do

SCENARIO_ID=${SCENARIOS_ID[$i]}
echo "TESTING "$SCENARIO_ID" with "$BOOTSTRAPPER_ID

###EVAL PROCESS
#---------------

#Align ontology created by toold with scenario ontology
date
echo "Performing alignment between bootstrapped ontology and scenario ontology..."
java -cp $CLASSPATH -Xms500M -Xmx8G -DentityExpansionLimit=100000000 com.fluidops.rdb2rdfbench.alignment.LogMapAlignment --scenario=$SCENARIO_ID --bootstrapper=$BOOTSTRAPPER_ID

#Copy ontology and mappings from tool folder to correspondent folders
cp ./$TOOLS_FOLDER/$BOOTSTRAPPER_ID/$SCENARIO_ID/aligned_ontology.rdf ./ontology/ontology.rdf

date
echo "Setting up the RODI benchmark..."
java -cp $CLASSPATH -Xms500M -Xmx8G -DentityExpansionLimit=100000000 com.fluidops.rdb2rdfbench.Main --scenario=$SCENARIO_ID --setup-ontology > ./$TOOLS_FOLDER/$BOOTSTRAPPER_ID/$SCENARIO_ID/out_setup_$SCENARIO_ID 2> ./$TOOLS_FOLDER/$BOOTSTRAPPER_ID/$SCENARIO_ID/err_setup_$SCENARIO_ID

#Must be here! Mappings are removed from r2rml folder in previous step
cp ./$TOOLS_FOLDER/$BOOTSTRAPPER_ID/$SCENARIO_ID/mappings.ttl ./r2rml

date
echo "Performing the evaluation..."
java -cp $CLASSPATH -Xms2G -Xmx15G -DentityExpansionLimit=100000000 com.fluidops.rdb2rdfbench.Main --scenario=$SCENARIO_ID --title=$BOOTSTRAPPER_ID --eval --debug-queries > ./$TOOLS_FOLDER/$BOOTSTRAPPER_ID/$SCENARIO_ID/out_eval_$SCENARIO_ID"_"$BOOTSTRAPPER_ID 2> ./$TOOLS_FOLDER/$BOOTSTRAPPER_ID/$SCENARIO_ID/err_eval_$SCENARIO_ID"_"$BOOTSTRAPPER_ID
date
#/dev/null
#--eval-queries
#--debug-queries


#Remove ontology
rm ./ontology/ontology.rdf

#Remove mappings
rm ./r2rml/mappings.ttl

echo " "

done



rm -r com


