public with sharing class AP16_LoyaltyProgram {
    
    public List<String> lpAmounts;
    
    public List<String> toLpCodes;
    
    public map<String, String> mapLpCodeToLpAmount;
    
    
    public AP16_LoyaltyProgram(){
        
    }
    
    public AP16_LoyaltyProgram(String lpCodesCsv, String lpAmountsCsv){
        
        this.toLpCodes = convertCsvToList(lpCodesCsv);
        
        this.lpAmounts = convertCsvToList(lpAmountsCsv);
        
        constructMap();
        
    }
    
    public void constructMap(){
        
        mapLpCodeToLpAmount = new Map<String, String>();
        
        if(toLpCodes != null){
            for(integer i = 0; i < toLpCodes.size(); i++){
                
                mapLpCodeToLpAmount.put(this.toLpCodes.get(i), this.lpAmounts.get(i));
            }
        }   
    }
    
    public List<String> getLpAmounts(){
        
        return lpAmounts;
    }
    
    public void setLpAmounts(List<String> lpAmounts){
        
        this.lpAmounts = lpAmounts;
        
    }
    
    public List<String> getToLpCodes(){
        
        return toLpCodes;
    }
    
    
    
    public void setToLpCodes(List<String> toLpCodes){
        
        this.toLpCodes = toLpCodes;
    }
    
    
    
    public String getToLpCode(){
        
        return convertListToCsv(toLpCodes);
    }
    
    public String getLpAmount(){
        
        return convertListToCsv(lpAmounts);
    }
    
    
    public void addToLpCode(String toLpCode){
        
        if(toLpCodes == null){
            
            toLpCodes = new List<string>();
            
        }
        
        this.toLpCodes.add(toLpCode);
    }
    
    public void addLpAmount(String lpAmount){
        
        if(lpAmounts == null){
            
            lpAmounts = new List<string>();
            
        }
        
        this.lpAmounts.add(lpAmount);
        
    }
    
    public String convertListToCsv(List<String> lists){
        
        String result = '';
        if(lists != null){
            for(String val : lists){
                
                result += val + ';';
            }
            
            if(result.endsWith(';')){
                
                result = result.substring(0, result.length()-1);
            }
        }
        
        return result;
        
    }
    
    
    /**
    * Split LPcode and LPAmount and store in a List of LProgram
    */
    public static List<String> convertCsvToList(String lpCode){
        
        List<String> lps = new List<String>();
        
        if(lpCode != null && lpCode.length() > 0){
            
            List<string> lpCodes = lpCode.split(';');
           
            for(integer i = 0; i < lpCodes.size(); i++){
                
                lps.add(lpCodes[i]);
                
            }
        }
        
        return lps;
        
    }
    
    public  void adjustValues(integer delta, integer quantity){
        
        List<String> newList = new List<String>();
        
        if(this.lpAmounts != null){
        
            for(String amount : this.lpAmounts){
            	
            	system.debug('## quantity <<<<<'+ quantity);
    
                amount = ((quantity - delta) * quantity)==0 ? string.valueOf(0) : string.valueOf(double.valueOf(amount)/(quantity - delta) * quantity);
        
                newList.add(amount);    
            }
            
            lpAmounts = newList;
        }
    }
    
    public  void reverseValues(){
        system.debug('## reverseValues old <<<<<'+ lpAmounts);  
        
        List<String> newList = new List<String>();
        
        if(this.lpAmounts != null){
        
            for(String amount : this.lpAmounts){
    
                newList.add(string.valueOf(double.valueOf(amount) * -1));
            }
            
            lpAmounts = newList;
        }
        
        system.debug('## reverseValues new <<<<<'+ lpAmounts);  
    }
    public boolean hasDebit(){
        
        boolean isDebit = false;
        
        if(this.lpAmounts != null){
        
            for(String amount : this.lpAmounts){
    
                if(double.valueOf(amount) < 0){
                    
                    isDebit = true;
                }
            }
        }
        
        system.debug('## hasDebit isDebit <<<<<'+ isDebit);
        
        return isDebit;
    }
    

}