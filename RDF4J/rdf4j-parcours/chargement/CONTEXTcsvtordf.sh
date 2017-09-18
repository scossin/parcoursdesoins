path="/dist/lib/csv2rdf.jar"
JARFILE=$CSV2RDF$path
java -jar $JARFILE contextTemplate.ttl context.csv context.ttl
