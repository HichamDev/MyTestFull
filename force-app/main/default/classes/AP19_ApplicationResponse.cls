public with sharing class AP19_ApplicationResponse {

	public String name {get;set;}
	
	public String description {get;set;}
	
	public String url {get;set;}
	
	public String imageUrl {get;set;}
	
	public AP19_ApplicationResponse()
	{
		name = '';
		description = '';
		url = '';
		imageUrl = '';
	}
	
	public AP19_ApplicationResponse(string name, string description, string url, string imageUrl)
	{
		this.name =name;
		this.description = description;
		this.url = url;
		this.imageUrl = imageUrl;
	}
}