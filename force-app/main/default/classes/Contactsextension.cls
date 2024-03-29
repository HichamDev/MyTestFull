/**
* @author Matias Menafra
* @createdDate 03/08/2010
*/
public with sharing class Contactsextension{

    private final Integer MAX_SIZE          = 131072; // 128Kb
    private final Integer MAX_LENGTH_NAME   = 71;
    private final String  ERROR_NO_SAVE     = 'Please select a file to upload and try again.';
    private final String  ERROR_IMG_TYPE    = 'The image must be .jpg, .gif or .png';   

    
    private Set<String> imagesTypes         = new Set<String> {'image/jpeg', 'image/jpg', 'image/pjpeg', 'image/png', 'image/x-png', 'image/gif'};
    private Set<String> notAllowedTypes     = new Set<String> {'application/octet-stream'};
    
    public Attachment   newAttach           { set; get; }
    public Attachment   file                { set; get; }
    public String      parentId            { set; get; }
    public String       postAction          { set; get; }
    public String       error               { set; get; }
    public Boolean      hasPicture          { set; get; }
    public Boolean      canRefresh          { set; get; }
    
    /**
    * Constructor
    */ 
    public Contactsextension( ApexPages.StandardController stdController ){
        
        this.parentId       = stdController.getId();
        this.hasPicture     = false;
        this.newAttach      = new Attachment();
        this.error          = '';
        this.canRefresh     = false;
        
        List<Attachment> attList = [ Select ParentId, Name, Id, ContentType, BodyLength From Attachment where ParentId =: this.parentId and name = 'Contact Picture' limit 1];
        if( attList.size() > 0 ){
            this.file               = attList.get( 0 );
            this.hasPicture         = true;
        }
    }
    
    /**
    * Upload action, store the file or replace if exists
    * @return thePage
    */
    public PageReference uploadAction(){
        canRefresh     = false;
        PageReference thePage = new PageReference( '/'+ parentId );
        //thePage.setRedirect( true );
        if( this.validate() ){
            if(this.saveCurrentPicture()){
                canRefresh=true;
                system.debug('save ok wchy test::');
                return null;
            }
            else{
            	system.debug('save KO wchy test::');
                return null;
            }

        }
        else{
            this.newAttach = new Attachment();
            system.debug('validate KO wchy test::');
            return null;
        }
    }
    
    
    /**
    * Save the New Attachment as Contact Picture
    * @return : boolean
    */
    public Boolean saveCurrentPicture(){
        Savepoint sp = Database.setSavepoint();
        try{
            delete [ Select Id From Attachment where ParentId =: this.parentId and name = 'Contact Picture' limit 1 ];
            this.newAttach.parentId = this.parentId;
            this.newAttach.name = 'Contact Picture';
            insert this.newAttach;
            return true;
        } 
        catch( Exception e ){
            this.error += ERROR_NO_SAVE+'<br/>';
            Database.rollback( sp );
            return false;
        }
    }
    
    
    /**
    * Detele action, delete the curren image
    * @return thePage
    */
    public PageReference deleteAction(){
        canRefresh     = true;
        PageReference thePage = new PageReference( '/'+ parentId );
        thePage.setRedirect( true );
        delete this.file;
        return null;
    }
    
    /**
    * Run all verification for the file to upload
    * @return ret
    */
    private Boolean validate(){
        Boolean ret = true;
        this.error = '';
        if( !imagesTypes.contains( newAttach.ContentType ) ){
            this.error += ERROR_IMG_TYPE+'<br/>';
            ret = false;
            system.debug('error for image JPEG uploaded wchy test::'+ ret);
        }
        return ret;
    }
    
    /**
    * Cancel action
    * @return thePage a page reference
    */
    public PageReference cancel(){
        PageReference thePage = new PageReference( '/'+ parentId);
        thePage.setRedirect( true );
        system.debug('####thePage>>>'+ thePage);
        return thePage;
    }
    
    /**
    * Test cases for rigth image types and a wrong type
    */
    public static testMethod void testImageTypes(){
        TestUtilities tu = TestUtilities.generateTest();
        
        ApexPages.StandardController sc;
        Contactsextension cTest;
        
        Contact myContact = tu.aContac;
    
        List<String> types = new List<String>{'image/jpeg', 'image/pjpeg', 'image/png', 'image/x-png', 'image/gif'};
    
        Attachment tempAtt = new Attachment();
        
        Test.startTest();
            for( String aType: types ){
                sc = new ApexPages.StandardController(myContact);
                cTest = new Contactsextension( sc );
                cTest.newAttach.Name = 'Picture-' + sc.getId();
                cTest.newAttach.Body = Blob.valueOf('String');
                cTest.newAttach.ContentType = aType;
                cTest.uploadAction();
                
                cTest.newAttach.Body = Blob.valueOf('String');
                
                System.assert( cTest.newAttach.name == 'Contact Picture', 'Name not equals' );
                System.assert( cTest.newAttach.ContentType == aType, 'Types not equals' );
                        
            }

            sc = new ApexPages.StandardController(myContact);
            cTest = new Contactsextension( sc );
            cTest.newAttach.Name = 'Picture-' + sc.getId();
            cTest.newAttach.Body = Blob.valueOf('String');
            cTest.newAttach.ContentType = 'image/YYY';
            cTest.uploadAction();
            System.assert( cTest.error == 'The image must be .jpg, .gif or .png<br/>', 'Error in error message.' + cTest.error);

            cTest = new Contactsextension( sc );
            cTest.uploadAction();
            
        Test.stopTest();
    } 
    
    /**
    *Test upload picture with no picture at the start.
    *
    */
    public static testMethod void testNoPicture(){
        TestUtilities tu = TestUtilities.generateTest();
        
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController( tu.aContac );
        Contactsextension cTest = new Contactsextension( sc );
        cTest.newAttach.Name = 'Picture-' + sc.getId();
        cTest.newAttach.Body = Blob.valueOf('String');
        cTest.newAttach.ContentType = 'image/jpeg';
        cTest.uploadAction();

        Attachment attUploaded = [ SELECT name, parentId, body, ContentType FROM Attachment WHERE parentId =: sc.getId() AND name = 'Contact Picture'];
        System.assert( attUploaded != null, 'No attachment uploaded.' );
        System.assert( attUploaded.name == 'Contact Picture', 'Name not equals.' );
        System.assert( attUploaded.Body.toString() == Blob.valueOf('String').toString(), 'Bodys not equals.' );
        System.assert( attUploaded.ContentType == 'image/jpeg', 'Types not equals.' );

        
        // Replace string
        sc = new ApexPages.StandardController( tu.aContac );
        cTest = new Contactsextension( sc );
        cTest.newAttach.Name = 'Picture-' + sc.getId();
        cTest.newAttach.Body = Blob.valueOf('Other String For Replacement');
        cTest.newAttach.ContentType = 'image/png';
        cTest.uploadAction();
        
        attUploaded = [ SELECT name, parentId, body, ContentType FROM Attachment WHERE parentId =: sc.getId() AND name = 'Contact Picture'];
        System.assert( attUploaded != null, 'No attachment uploaded.' );
        System.assert( attUploaded.name == 'Contact Picture', 'Name not equals.' );
        System.assert( attUploaded.Body.toString() == Blob.valueOf('Other String For Replacement').toString(), 'Bodys not equals.' );
        System.assert( attUploaded.ContentType == 'image/png', 'Types not equals.' );
        
        
        Id stroringAttIdForRetreve = cTest.newAttach.id;
        cTest = new Contactsextension( sc );
        cTest.deleteAction();
        List<Attachment> attUploadedList = [ SELECT id FROM Attachment WHERE id =: stroringAttIdForRetreve ];

        System.assert( attUploadedList.size() == 0, 'Attachment not deleted !!!' );
        
        Test.stopTest();    
    }
    
    /**
    * Code coverage for cancel action
    */
    public static testMethod void testCancelAction(){
        TestUtilities tu = TestUtilities.generateTest();
        
        Test.startTest();
            ApexPages.StandardController sc = new ApexPages.StandardController( tu.aContac );
            Contactsextension cTest = new Contactsextension( sc );
            cTest.cancel();         
            System.assert( cTest.cancel() != null, 'Some error occurs with PageReference Method is called' );
        Test.stopTest();
    }
}