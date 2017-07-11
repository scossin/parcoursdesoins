
SPARQLqueries <- list(transfertMCOSSR = 
"
prefix CNTROavc: <http://www.eigsante2017.fr/CNTROavc#>
prefix eig: <http://www.eigsante2017.fr/>
prefix wgs84: <http://www.w3.org/2003/01/geo/wgs84_pos#>
SELECT ?patient ?EtabMCO ?EtabSSR ?latFROM ?longFROM ?latTO ?longTO ?difftime
WHERE {GRAPH ?patient

{?sejourMCO a CNTROavc:SejourMCO ; #SejourMCO
CNTROavc:inEtab ?EtabMCO; # Dans un Etab MCO
CNTROavc:hasValidTime ?tsejourMCO . # Durant une periode de temps
?tsejourMCO CNTROavc:hasEndTime ?endsejourMCO . # avec un date de fin MCO
?endsejourMCO CNTROavc:hasNormalizedTime ?dateendsejourMCO . # dont la forme normalisée est
?sejourSSR a CNTROavc:SejourSSR ; #SejourSSR
CNTROavc:inEtab ?EtabSSR; # Dans un Etab SSR
CNTROavc:hasValidTime ?tsejourSSR . # Durant une periode de temps
?tsejourSSR CNTROavc:hasStartTime ?startsejourSSR . # avec un date de début SSR
?startsejourSSR CNTROavc:hasNormalizedTime ?datestartsejourSSR . # dont la forme normalisée est
bind( (?datestartsejourSSR  - ?dateendsejourMCO) as ?difftime ) # différence entre date de sortie MCO et date d'entrée en SSR
FILTER(?difftime >= 0 && ?difftime < 3) # comprise entre 0 et 3 jours

SERVICE <http://127.0.0.1:8080/bigdata/namespace/geo/sparql/geo/sparql> { ### on récupère la géolocalisation
?EtabMCO wgs84:lat ?latFROM .
?EtabMCO wgs84:long ?longFROM .
?EtabSSR wgs84:lat ?latTO .
?EtabSSR wgs84:long ?longTO .    
}
}
}
ORDER BY ?patient", 

transfertEtab = 
"
prefix CNTROavc: <http://www.eigsante2017.fr/CNTROavc#>
prefix eig: <http://www.eigsante2017.fr/>
SELECT ?sejour1 ?sejour2 ?Etab1 ?Etab2 ?difftime
WHERE {
?sejour1 CNTROavc:inEtab ?Etab1; # Un Sejour dans un etab
CNTROavc:hasValidTime ?tsejour1 . # Durant une periode de temps
?tsejour1 CNTROavc:hasEndTime ?endsejour1 . # avec un date de fin 1
?endsejour1 CNTROavc:hasNormalizedTime ?dateendsejour1 . # dont la forme normalisée est
?sejour2 a CNTROavc:Sejour2 ; #Sejour2
CNTROavc:inEtab ?Etab2; # Dans un Etab 2
CNTROavc:hasValidTime ?tsejour2 . # Durant une periode de temps
?tsejour2 CNTROavc:hasStartTime ?startsejour2 . # avec un date de début 2
?startsejour2 CNTROavc:hasNormalizedTime ?datestartsejour2 . # dont la forme normalisée est
bind( (?datestartsejour2  - ?dateendsejour1) as ?difftime ) # différence entre date de sortie 1 et date d'entrée en 2
#FILTER(?difftime >= 0 && ?difftime < 100) # comprise entre 0 et 3 jours
}
",


individualtype = "SELECT ?s ?o where{?s a owl:NamedIndividual .
                  ?s a ?o .          
?o a owl:Class}", 

hierarchie= "SELECT * where{?s a owl:Class . 
?s rdfs:subClassOf ?o}", 

## Ancienne version : ne récupère pas ceux qui n'ont pas de date de fin
evenements="
prefix CNTROavc: <http://www.eigsante2017.fr/CNTROavc#>
prefix eig: <http://www.eigsante2017.fr/>
SELECT ?patient ?event ?datestartevent ?dateendevent ?lieu
WHERE {GRAPH ?patient{
?event CNTROavc:inEtab ?lieu; # Un Sejour dans un etab
CNTROavc:hasValidTime ?tevent . # Durant une periode de temps
?tevent CNTROavc:hasEndTime ?endevent . # avec un date de fin 1
?endevent CNTROavc:hasNormalizedTime ?dateendevent . # dont la forme normalisée est
?tevent CNTROavc:hasStartTime ?startevent . # avec un date de fin 1
?startevent CNTROavc:hasNormalizedTime ?datestartevent . # dont la forme normalisée est
}}
ORDER by ?patient ?datestartevent",

evenements2="
prefix CNTROavc: <http://www.eigsante2017.fr/CNTROavc#>
prefix eig: <http://www.eigsante2017.fr/>
SELECT ?patient ?event ?datestartevent ?dateendevent ?lieu ?type
WHERE {GRAPH ?patient{

?event CNTROavc:hasValidTime ?tevent ; # Durant une periode de temps
       a ?type .
?tevent CNTROavc:hasStartTime ?startevent . # avec un date de fin 1
?startevent CNTROavc:hasNormalizedTime ?datestartevent . # dont la forme normalisée est
OPTIONAL{?event CNTROavc:in ?lieu.
         }
OPTIONAL{
    ?tevent CNTROavc:hasEndTime ?endevent . # avec un date de fin 1
		?endevent CNTROavc:hasNormalizedTime ?dateendevent .} # dont la forme normalisée est} # Un Sejour dans un etab
}}
ORDER by ?patient ?datestartevent",


coordonnesGeo = "
prefix wgs84: <http://www.w3.org/2003/01/geo/wgs84_pos#>
prefix eig: <http://www.eigsante2017.fr/>
SELECT ?code ?lat ?long where {
  ?s eig:hasCode ?code ;
     wgs84:lat ?lat ;
	 wgs84:long ?long}
")

### refaire la requete pour récupérer tous les évènements: 
# rdf:type event
# après inférence
