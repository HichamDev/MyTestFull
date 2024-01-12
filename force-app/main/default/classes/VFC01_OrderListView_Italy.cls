public with sharing class VFC01_OrderListView_Italy {
/* 
----------------------------------------------------------------------
-- - Name          : VFC01_OrderListView 
-- - Author        : AMU
-- - Description   : Controller for VFP01_OrderListView Page
--                  
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 11-DEC-2012  AMU    1.0      Initial version   
-- 04-APR-2016  WCH    1.8      Review the drop down list of available filters
----------------------------------------------------------------------
**********************************************************************
*/
    /*****************************************************************/
    /***************** Instantiating Global Variable *****************/
    /*****************************************************************/
    //Global Boolean
    public Boolean isPortal {get;set;}
    public Boolean canProfileCreate {get;set;}
    //Global Id
    public Id orderId {get;set;}
    public Id dealerId {get;set;}
    public Id contactId {get;set;}
    //Global String
    public String orderStatus {get;set;}
    public String userId {get;set;}
    public String userType {get;set;}
    public String currencySymbol {get;set;}
    
    //filter
    public final List<SelectOption> filterOptions {get;set;}
    public String selectedOption {get;set;}
    public List<ORD_Order__c> theOrderList {get;set;}
    
    /*****************************************************************/
    /******************** Page Constructor ***************************/
    /*****************************************************************/
    public VFC01_OrderListView_Italy (){
        system.debug('## Class VFC01_OrderListView - START VFC01_OrderListView <<<<<'+UserInfo.getUserName()); 
        canProfileCreate=false;
        //Retrieving User ID, USer Type
        userId = UserInfo.getUserId();
        userType = UserInfo.getUserType();
        User thisUser = [select id, profile.Name from User where id=:userId];
 
        if (thisUser!=null){
         
            ObjectPermissions[] objPermissions = [SELECT Parent.Name, PermissionsRead, PermissionsCreate, PermissionsEdit FROM ObjectPermissions WHERE SobjectType = 'ORD_Order__c' and parentid in (select id from permissionset where PermissionSet.Profile.id =:thisUser.profileId)];
            if (objPermissions !=null && objPermissions.size() > 0){
 
                canProfileCreate=objPermissions[0].PermissionsCreate;
            }
        }
        system.debug('## Class VFC01_OrderListView - Can user create orders <<<<<'+canProfileCreate);
        //Checks if Portal User
        CheckUser(userType, userId);
        currencySymbol=getCurrencySymbol();
        Map<String, String> listOfFilters = new Map<String, String>{'0' => system.label.ORD00174, '1' => system.label.ORD00033, '2' => system.label.ORD00187, '3' => system.label.ORD00188, '4'=>system.label.ORD00189};
        filterOptions = new List<SelectOption>();
        integer counter=0;
        for(string theValue : listOfFilters.keySet()){
            counter++;
            filterOptions.add(new SelectOption(theValue,listOfFilters.get(theValue)));
        }
        selectedOption='0';
        getOrders();
        system.debug('## Class VFC01_OrderListView - END VFC01_OrderListView <<<<<'+UserInfo.getUserName());
    }
    
    /*****************************************************************/
    /******************** ControllerSet Init *************************/
    /*****************************************************************/
    public ApexPages.StandardSetController orderSet {   
        get {
            string theQuery=generateQuery(selectedOption);
            if(orderSet == null) {                                     
                    orderSet= new ApexPages.StandardSetController(Database.query(theQuery));
            }   

        orderSet.setPageSize(1000); 
        return orderSet;
        }
        set;
    }
    
    public void getOrders() {
        theOrderList= (List<ORD_Order__c>) orderSet.getRecords();
    }

    public string getNumberCurrencyFormat(){
    System.debug('getNumberCurrencyFormat >>>>>>>'+Userinfo.getLocale());
    if(Userinfo.getLocale().equalsIgnoreCase('es_MX')){
            return 'MXN{0, number, 0.00}';
    }else if(Userinfo.getLocale().equalsIgnoreCase('es_VE')){
            return 'VEF{0, number, 0.00}';
    }else{
        return '€{0, number, 0.00}';
    }
    
  }
    public string getCurrencySymbol(){
    System.debug('getNumberCurrencyFormat >>>>>>>'+Userinfo.getLocale());
    if(Userinfo.getLocale().equalsIgnoreCase('es_MX')){
            return 'MXN';
    }else if(Userinfo.getLocale().equalsIgnoreCase('es_VE')){
            return 'VEF';
    }else{
        return '€';
    }
    
  }
    /*****************************************************************/
    /*********************** CheckUser *******************************/
    /*****************************************************************/
    public void CheckUser(String userType, String userId){
        system.debug('## Class VFC01_OrderRecipient - START CheckUser <<<<<'+UserInfo.getUserName());
        
        User u = [SELECT Profile.Name FROM User WHERE Id =: userId LIMIT 1];
        
        //Checks if Portal User
        if (userType == 'CspLitePortal' || (u.Profile.Name.contains('DEALER_MEMBER') || u.Profile.Name.contains('DEALER_LOGIN') || 
                                            u.Profile.Name.contains('SMILE_LOGIN') || u.Profile.Name.contains('SMILE_MEMBER')) || 
                                            (u.Profile.Name.startswith('ITA_LU') && u.Profile.Name.contains('DEALER_MANAGER') )){
            isPortal = true;
            
            //Retrieving Contact ID related to user
            contactId = [Select contactID
                           From User
                          Where id = :userId
                          limit 1].contactID;
        }
        else{
            isPortal = false;
        }
    }
    
    /*****************************************************************/
    /************************ RedirectOrder **************************/
    /*****************************************************************/
    public PageReference RedirectOrder() {
        system.debug('## Class VFP01_OrderView - START RedirectOrder <<<<<'+UserInfo.getUserName());
        PageReference pageRef;
        
        for (ORD_Order__c o:[Select Id
                                    , Status__c
                                    , dealer__c
                               From ORD_Order__c
                              Where id = :orderId
                              limit 1]){
                              
                              orderStatus = o.Status__c;
                              dealerId = o.dealer__c;
        }
        
        if (orderStatus == 'Draft'){
            pageRef = Page.VFP01_OrderBasket_Italy;
            pageRef.getParameters().put('orderId',orderID);
            pageRef.getParameters().put('dealerId',dealerId);
        }
        else{
            pageRef = Page.VFP01_OrderRecap_Italy;
            pageRef.getParameters().put('orderId',orderID);
            pageRef.getParameters().put('dealerId',dealerId);
        }
        system.debug('>>>>>> orderStatus: ' + orderStatus);
        system.debug('>>>>>> pageRef: ' + pageRef);
        return PageRef;
    }

    /*****************************************************************/
    /*********** generate query for the chosen option     ************/
    /*****************************************************************/   
        public string generateQuery(string theOption){
        system.debug('## Class VFP01_OrderView - function generateQuery <<<<<'+UserInfo.getUserName());
        string theQuery='SELECT Id, Name, OrderDate__c,ShipmentFollowUp__c, OrderType__c, Dealer__c, Dealer__r.Name, Status__c , Dealer__r.OwnerId,TECH_TotalPrice__c,TECH_NumberOfArticles__c,Transporter__c,ShippingRef__c,ShipmentDate__c  FROM ORD_Order__c ';
        string selectiveQueryPart='';
        if(isPortal){
            if('0'.equals(theOption)){
                selectiveQueryPart=selectiveQueryPart+'WHERE dealer__c = :contactId ';
            }else{
                selectiveQueryPart=selectiveQueryPart+'WHERE dealer__c = :contactId and ';
            }
        }else{
            if(!'0'.equals(theOption)){
                selectiveQueryPart=selectiveQueryPart+'WHERE ';
            }
        }
       if('1'.equals(theOption)){
            selectiveQueryPart=selectiveQueryPart+'Status__c=\'Draft\' ';
        }else if('2'.equals(theOption)){
            selectiveQueryPart=selectiveQueryPart+'Status__c in (\'Shipped\', \'Processing\',\'Pending\') ';
        }else if('3'.equals(theOption)){
            selectiveQueryPart=selectiveQueryPart+'Status__c in (\'Shipped\', \'Processing\') ';
        }else if('4'.equals(theOption)){
            selectiveQueryPart=selectiveQueryPart+'Status__c=\'Draft\' and OrderType__c=\'Online\' ';
        }
        system.debug('## Class VFP01_OrderView - function generateQuery theOption:<<<<<'+theOption+' Query:'+theQuery+selectiveQueryPart+'  order by CreatedDate desc');
        return (theQuery+selectiveQueryPart+'  order by CreatedDate asc');
    }
    
    public PageReference refreshPageOLV() {
        string theQuery=generateQuery(selectedOption);
        theOrderList = database.query(theQuery);
        system.debug('>>>>>> refreshPageOLV: theOrderList'+theOrderList);
        system.debug('>>>>>> refreshPageOLV: selectedOption'+selectedOption);
        return null;
    }
}