public with sharing class AP19_ApplicationRequest {

	public String country{get;set;}
	
	public String profile{get;set;}
	
	public long timeStampMax {get;set;}
	
	public String informations {get;set;}
	
	public AP19_ApplicationRequest(String country, String profile, long timeStampMax, String informations)
	{
		this.country = country;
		this.profile = profile;
		this.timeStampMax = timeStampMax;
		this.informations = informations;
	}

}