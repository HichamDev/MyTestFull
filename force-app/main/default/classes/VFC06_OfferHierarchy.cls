public with sharing class VFC06_OfferHierarchy {
/*
----------------------------------------------------------------------
-- - Name          : VFC06_OfferHierarchy 
-- - Author        : AMU
-- - Description   : Class for view offer hierarchy BR 06.
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 29-AUG-2012  AMU    1.0      Initial version                           
----------------------------------------------------------------------
**********************************************************************
*/
	//Declare variables
    public String currentId;
    public List<ObjectStructureMap> asm ;
    public Map<String, ObjectStructureMap> masm;
    public List<Integer> maxLevel;
    
    /*
     * Contructor
     */
    public VFC06_OfferHierarchy() {
    	this.asm = new List<ObjectStructureMap>{};
    	this.masm = new Map<String, ObjectStructureMap>{};
    	this.maxLevel = new List<Integer>{};
    }
    
    /*
     * Allow page to set the current ID
     */
    public void setcurrentId( String cid ){
        currentId = cid;
    }

    /**
    * Return ObjectStructureMap to page
    * @return asm
    */
    public List<ObjectStructureMap> getObjectStructure(){
        asm.clear();
        if ( currentId == null ) {
            currentId = System.currentPageReference().getParameters().get( 'id' );
        }
        
        System.assertNotEquals( currentId, null, 'sObject ID must be provided' );
        asm = formatObjectStructure( CurrentId );
        system.debug('>>>>>>>currentId: '+currentId);
        system.debug('>>>>>>>asm: '+asm);
        return asm;
    }

    /**
    * Query Offer from top down to build the ObjectStructureMap
    * @param currentId
    * @return asm
    */
    public ObjectStructureMap[] formatObjectStructure( String currentId ){
    
        List<ObjectStructureMap> asm = new List<ObjectStructureMap>{};
        masm.clear();

        //Change below
        List<KIT_Kit__c> al         = new List<KIT_Kit__c>{};
        List<ID> currentParent      = new List<ID>{};
        Map<ID, String> nodeList    = new Map<ID, String>{};
        List<String> nodeSortList   = new List<String>{};
        List<Boolean> levelFlag     = new List<Boolean>{};
        List<Boolean> closeFlag     = new List<Boolean>{};
        String nodeId               = '0';
        String nodeType             = 'child';
        Integer count               = 0;
        Integer level               = 0;
        Boolean endOfStructure      = false;
        
        //Find highest level obejct in the structure
        //currentParent.add( GetTopElement( currentId ) );
		currentParent.add(currentId);
		system.debug('>>>>>>>currentParent: '+currentParent);

        //Loop though all children
        while ( !endOfStructure ){

            if( level == 0 ){
                //Change below     
                //al = [ SELECT Article__r.Name, a.Id, a.ParentArticle__c FROM KIT_Kit__c a WHERE a.ParentArticle__c IN : CurrentParent ORDER BY a.Article__r.Name ];
                KIT_Kit__c al1 = new KIT_Kit__c(Article__c = currentId, ParentArticle__c=currentId, KitType__c='Closed Set');
                al.add(al1);
                system.debug('>>>>>>> al LEVEL 0 : '+al);
            } 
            else {
                //Change below      
                al = [ SELECT Article__r.Name, a.Id, a.ParentArticle__c FROM KIT_Kit__c a WHERE a.ParentArticle__c IN : CurrentParent ORDER BY a.Article__r.Name ];
                system.debug('>>>>>>> al LEVEL ++ : '+al);
            }

            if( al.size() == 0 ){
                endOfStructure = true;
            }
            else{
                currentParent.clear();
                for ( Integer i = 0 ; i < al.size(); i++ ){
                    //Change below
                    KIT_Kit__c a = al[i];
                    nodeId = ( level > 0 ) ? NodeList.get( a.ParentArticle__c )+'.'+String.valueOf( i ) : String.valueOf( i );
                    masm.put( NodeID, new ObjectStructureMap( nodeID, levelFlag, closeFlag, nodeType, false, false, a ) );
                    currentParent.add( a.Article__c );
                    nodeList.put( a.Article__c,nodeId );
                    nodeSortList.add( nodeId );
                }
                system.debug('>>>>>>>currentParent after Loop: '+currentParent);
                maxLevel.add( level );                
                level++;
            }
        }
        
        //Account structure must now be formatted
        NodeSortList.sort();
        system.debug('>>>>>>>NodeSortList: '+NodeSortList); 
        system.debug('>>>>>>>NodeSortList size: '+NodeSortList.size());
        for( Integer i = 0; i < NodeSortList.size(); i++ ){
            List<String> pnl = new List<String> {};
            List<String> cnl = new List<String> {};
            List<String> nnl = new List<String> {};
            
            if ( i > 0 ){
                String pn 	= NodeSortList[i-1];
                pnl 		= pn.split( '\\.', -1 );
            }

            String cn 	= NodeSortList[i];
            cnl 		= cn.split( '\\.', -1 );

            if( i < NodeSortList.size()-1 ){
                String nn = NodeSortList[i+1];
                nnl = nn.split( '\\.', -1 );
            }
            
            ObjectStructureMap tasm = masm.get( cn );
            if ( cnl.size() < nnl.size() ){
                //Parent
                tasm.nodeType = ( isLastNode( cnl ) ) ? 'parent_end' : 'parent';
            }
            else if( cnl.size() > nnl.size() ){
                tasm.nodeType 	= 'child_end';
                tasm.closeFlag 	= setcloseFlag( cnl, nnl, tasm.nodeType );
            }
            else{
                tasm.nodeType = 'child';
            }
            
            tasm.levelFlag = setlevelFlag( cnl, tasm.nodeType ); 
            
            //Change below
            if ( tasm.account.id == currentId ) {
                tasm.currentNode = true;
            }
            asm.add( tasm );
        }
        
        asm[0].nodeType 			= 'start';
        asm[asm.size()-1].nodeType 	= 'end';
        
        return asm;
    }
    
    /**
    * Determin parent elements relationship to current element
    * @return flagList
    */
    public List<Boolean> setlevelFlag( List<String> nodeElements, String nodeType ){
    	
        List<Boolean> flagList = new List<Boolean>{};
        String searchNode 	= '';
        String workNode 	= '';
        Integer cn 			= 0;
       
        system.debug('>>>>>>>nodeElements:' + nodeElements);
        system.debug('>>>>>>>nodeElements size:' + nodeElements.size());
        
        for( Integer i = 0; i < nodeElements.size() - 1; i++ ){
            cn = Integer.valueOf( nodeElements[i] );
            cn++;
            searchNode 	= workNode + String.valueOf( cn );
            workNode 	= workNode + nodeElements[i] + '.';
            if ( masm.containsKey( searchNode ) ){
                flagList.add( true );
            }
            else {
                flagList.add( false );
            }
        }
        
        return flagList;
    }
    
    /**
    * Determin if the element is a closing element
    * @return flagList
    */
    public List<Boolean> setcloseFlag( List<String> cnl, List<String> nnl, String nodeType ){
    	
        List<Boolean> flagList = new List<Boolean>{};
        String searchNode 	= '';
        String workNode 	= '';
        Integer cn 			= 0;
        
        for( Integer i = nnl.size(); i < cnl.size(); i++ ){
        	flagList.add( true );
        }
        
        return flagList;
    }
    
    /**
    * Determin if Element is the bottom node  
    * @return Boolean
    */
    public Boolean isLastNode( List<String> nodeElements ){
    	
        String searchNode 	= '';
        Integer cn 			= 0;
        
        for( Integer i = 0; i < nodeElements.size(); i++ ){
            if ( i == nodeElements.size()-1 ){
                cn = Integer.valueOf( nodeElements[i] );
                cn++;
                searchNode = searchNode + String.valueOf( cn );
            }
            else {
                searchNode = searchNode + nodeElements[i] + '.';
            }
        }
        if ( masm.containsKey( searchNode ) ){
            return false;
        }
        else{
            return true;
        }
    }
    
    /**
    * Find the tom most element in Heirarchy  
    * @return objId
    */
    /*public String GetTopElement( String objId ){
    	
        Boolean top = false;
        while ( !top ) {
            //Change below
            Account a = [ Select a.Id, a.ParentId From Account a where a.Id =: objId limit 1 ];
            
            if ( a.ParentID != null ) {
                objId = a.ParentID;
            }
            else {
                top = true;
            }
        }
        return objId ;
    }*/
    
	/**
    * Wrapper class
    */
    public with sharing class ObjectStructureMap{

        public String nodeId;
        public Boolean[] levelFlag = new Boolean[]{};
        public Boolean[] closeFlag = new Boolean[]{};
        public String nodeType;
        public Boolean currentNode;
        
        /**
        * @Change this to your sObject
        */
        public KIT_Kit__c account;
        
        public String getnodeId() { return nodeId; }
        public Boolean[] getlevelFlag() { return levelFlag; }
        public Boolean[] getcloseFlag() { return closeFlag; }
        public String getnodeType() { return nodeType; }
        public Boolean getcurrentNode() { return currentNode; }


        /**
        * @Change this to your sObject
        */
        public KIT_Kit__c getaccount() { return account; }
        
        public void setnodeId( String n ) { this.nodeId = n; }
        public void setlevelFlag( Boolean l ) { this.levelFlag.add(l); }
        public void setlcloseFlag( Boolean l ) { this.closeFlag.add(l); }
        public void setnodeType( String nt ) { this.nodeType = nt; }
        public void setcurrentNode( Boolean cn ) { this.currentNode = cn; }

        /**
        * @Change this to your sObject
        */
        public void setaccount( KIT_Kit__c a ) { this.account = a; }

        /**
        * @Change the parameters to your sObject
        */
        public ObjectStructureMap( String nodeId, Boolean[] levelFlag,Boolean[] closeFlag , String nodeType, Boolean lastNode, Boolean currentNode, KIT_Kit__c a ){
            
            this.nodeId         = nodeId;
            this.levelFlag      = levelFlag; 
            this.closeFlag      = closeFlag;
            this.nodeType       = nodeType;
            this.currentNode    = currentNode;

            //Change this to your sObject  
            this.account = a;
        }
    }
}