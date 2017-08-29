package queryFiles;

public enum FilesAvailable {

	PredicatesDescription(GetPredicateDescription.fileName, "get rdfs:comments and expected value of predicates"),
	PredicateFrequency(GetEventPredicateFrequency.fileName, "get the frequency of each predicate per event"),
	EventHierarchy4Sunburst(GetSunburstHierarchy.fileName, "get a hierarchical structure of events to make a sunburst");

	private String fileName ;
	private String comment ;
	
	public String getComment(){
		return(comment);
	}
	
	public String getFileName(){
		return(fileName);
	}
	
	private FilesAvailable(String fileName, String comment){
		this.fileName = fileName;
		this.comment = comment;
	}
}
