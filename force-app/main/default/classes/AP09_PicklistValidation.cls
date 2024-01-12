/* 
------------------------------------------------------------
-- - Name          : AP09_PicklistValidation 
-- - Author        : noor.goolamnabee@businessdecision.com
-- - Description   : Class used to enforce picklist values when importing data to salesforce 
--
-- Maintenance History: 
--
-- Date         Name   Version  Remarks 
-- -----------  ----  -------  -----------------------------
-- 11-OCT-2012  NGO    1.0    Initial version
-- 07-NOV-2012	NGO	   1.1	  Optimization, keep pickListValues in map	
-- 05-DEC-2012	 NGO   1.2		 Correction according to code review by salesforce 	
------------------------------------------------------------
*/	
public class AP09_PicklistValidation {

	/**
	* Map containing the picklist values for each field to avoid to call the describe method
	*/
	Map<string, List<string>> pickListMapValues;
	
	
	
	
	/**
	* Check if value is present in the picklist field.
	* isMutiple indicates if field is multipicklist value or not
	*/
	private  Boolean validate(SObject obj, String field, String value, Boolean isMultiple){
     
     	System.debug('***** Field '+ field + ' value '+ value);
     
		if(value != null && value.length() > 0){
		
			if(isMultiple){
		
				return validateValues(obj, field, value);
		   			
			}else{
		   			
				return validateValue(obj, field, value);			
			}	
		}else{
			
			return true;
		}
	}
   
   
	private  Boolean validateValue(SObject obj, String fld, String value){
		   
		List<string> pickListValues = getPicklistValuesInMap(obj, fld);
		   
		return checkIfContains(value, pickListValues);
	   
	}
	
	private  Boolean checkIfContains(String value, List<string> pickListValues){
		   
		
		Boolean isValid = false;
		   
		for(String pickListValue : pickListValues){
		   	
			if(pickListValue == value){
			   			
			isValid = true;
			
			break;
			
			}
		}
		   
		return isValid;
	   
	}
	
	/**
	* Build a unique for the field
	*/
	private string getKey(SObject obj, String fld){
		//Since this class is for a trigger the field name will be unique
		return fld;
	}
	
	private  List<string> getPicklistValuesInMap(SObject obj, String fld){
		
		String key = getKey(obj, fld);
		
		System.debug('Key name map : '+key);
		
		if(this.pickListMapValues== null){
			
			this.pickListMapValues = new Map<string, List<string>>();	
			
		}
		
		//check if list is in map
		
		if(this.pickListMapValues.containsKey(key)){
			
			System.debug('Key present in map : '+key);
			
			return pickListMapValues.get(key);
		
		}else{
			
			System.debug('Key created in map : '+key);
			
			List<string> pickListValues = SHW_IBZ_Utils.getPicklistValues(obj, fld);
			
			pickListMapValues.put(key, pickListValues);
			
			return pickListValues;
			
		}

	}
	
	
	
   // Get a list of picklist values from an existing object field.
	private  Boolean validateValues(SObject obj, String fld, String value){
	     
		Boolean isValid = false;
		   
		List<string> pickListValues = getPicklistValuesInMap(obj, fld);
		
		System.debug('***Multi value pick list value list ' +value +' List of picklist '+ pickListValues);
		
		List<string> values = new List<string>();
		
		values.add(value);
		
		if(value.indexOf(';') > 0){
		
			values = value.split(';');
			
		}   
		 
		for(String single :values){
			
			System.debug(single+' checkIfContains ' +checkIfContains(value, pickListValues));
			
			if(checkIfContains(single, pickListValues)){
			   				
				isValid = true;
			   				
			}else{
			   				
				isValid = false;
				break;
			}
		}
		   		
		return isValid;
	   
	}
	
	
	public void runValidations(List<AP09_PicklistValidationModel> validations, List<SObject> newObjects){
		
		for(SObject obj: newObjects){
			
			for(AP09_PicklistValidationModel validation: validations){
				
				if(!validate(obj, validation.field, String.valueOf(obj.get(validation.field)), validation.isMultiple)){
				
					obj.addError('The value ' + obj.get(validation.field) + ' for picklist field ' + validation.field +' is not valid');
					
				}
			}
		}
	}
	
	

}