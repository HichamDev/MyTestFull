public with sharing class TestUtilities {
	
	public Contact 		aContac			{get; set;}
	public Attachment 	aAttachment		{get; set;}
	
	public void generateContact(){

	    this.aContac 				= new Contact();
	    this.aContac.firstName 		= 'Test';
	    this.aContac.LastName 		= 'Test'; 
	    this.aContac.MinOrderFreeTransportFees__c = 100;
	    this.aContac.STHID__c ='Test123';
	    
	    insert this.aContac;

	    this.aAttachment = new Attachment();
	    this.aAttachment.Body = Blob.valueOf('String');
	}
	
	public static TestUtilities generateTest(){
		TestUtilities e = new TestUtilities();
		e.generateContact();
		return e;
	}
}