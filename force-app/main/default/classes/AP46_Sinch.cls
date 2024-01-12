public with sharing class AP46_Sinch {
    
    public class WSReturn {
        public Boolean isSuccess;
        public Integer errorCode;
        public String errorMessage;
        public Object wsResponse;
    }
    
    public class SinchAuthRes {
        public Boolean success;
        public String access_token;
        public String expires;
        
        public SinchAuthRes parse(String json) {
            return (SinchAuthRes) System.JSON.deserialize(json, SinchAuthRes.class);
        }
    }
    
    // public class SinchCreateCampaign {
    //     public String logic {get;set;} 
    //     public String logic_param {get;set;} 
    //     public String name {get;set;} 
    //     public String sender {get;set;} 
    //     public String message {get;set;} 
    //     public List<SinchContact> contacts {get;set;} 
    //     public String send_date {get;set;} 
    // }
    
    // public class SinchContact {
    //     public String msisdn {get;set;} 
    //     public String nom {get;set;} 
        
    // }
}