public class AP09_PicklistValidationModel {
	
	public String field {set;get;}
	
	public Boolean isMultiple {set;get;}
	
	public AP09_PicklistValidationModel(String field,Boolean isMultiple){

		this.field = field;

		this.isMultiple = isMultiple;
		
	}
	
	public AP09_PicklistValidationModel(String field){
		
		this.field = field;
		
		this.isMultiple = false;
		
	}

}