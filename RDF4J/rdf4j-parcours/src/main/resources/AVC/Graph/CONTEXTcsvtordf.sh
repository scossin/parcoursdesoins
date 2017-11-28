path="/dist/lib/csv2rdf.jar"
JARFILE=$CSV2RDF$path
java -jar $JARFILE CONTEXTtemplate.ttl context.csv CONTEXT.ttl
