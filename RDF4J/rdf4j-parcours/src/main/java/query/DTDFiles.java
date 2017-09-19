package query;

import parameters.MainResources;

public enum DTDFiles {
	SearchQuery(MainResources.dtdSearchFile),
	DescribeQuery(MainResources.dtdDescribeFile),
	CountQuery(MainResources.dtdCountFile),
	DescribeTerminologyQuery(MainResources.dtdDescribeTerminologyFile);
	
	
	private final String filePath;
	
	public String getFilePath(){
		return(filePath);
	}
	
	private DTDFiles (String filePath) {
		this.filePath = filePath;
	}
}
