public class AP1006_Reminder {
	
    @AuraEnabled
    public String iconUrl {get;set;}
    @AuraEnabled
    public String title {get;set;}
    @AuraEnabled
    public String message {get;set;}
    @AuraEnabled
    public String messageCut {get;set;}
    @AuraEnabled
    public List<Contact> l_contacts {get;set;}
    @AuraEnabled
    public Boolean displayEmailButton {get;set;}
    
    public AP1006_Reminder() {}
    
    public AP1006_Reminder(String title, String message) {
        this.title = title;
        this.message = message;
       
        if (this.message.length() > 100) {
            this.messageCut = this.message.substring(0, 99) + '...';
        } else {
            this.messageCut = this.message ;
        }

        this.displayEmailButton = false;

    }
    public AP1006_Reminder(String iconUrl, String title, String message) {
        this.iconUrl = iconUrl;
        this.title = title;
        this.message = message;
        if (this.message.length() > 100) {
            this.messageCut = this.message.substring(0, 99) + '...';
        } else {
            this.messageCut = this.message ;
        }

        this.displayEmailButton = false;
    }
}