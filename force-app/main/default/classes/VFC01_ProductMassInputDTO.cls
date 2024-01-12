public with sharing class VFC01_ProductMassInputDTO {
	
	public static final Integer numberOfLines = 20;
	
	public Integer index {get; set;}
	
	public CTA_CatalogArticle__c CTA {get; set;}
	
	public String productName {get; set;}
	
	public String quantity {get; set;}
	
	public String errMsg {get; set;}
	
	VFC01_ProductMassInputDTO(Integer index){
		this.productName=null;
		this.quantity=null;
		this.errMsg=null;
		this.index = index;
	}
	
	
	public static  List<VFC01_ProductMassInputDTO> initialiseList(){
		
		List<VFC01_ProductMassInputDTO>  massInputs = new List<VFC01_ProductMassInputDTO>();
		
		for(integer i = 0; i < numberOfLines; i++){
			
			massInputs.add(new VFC01_ProductMassInputDTO(i+1));
		}	
		
		return massInputs;
	}
	
	
	

}