trigger EmailMessage on EmailMessage (before insert) {
    if(Trigger.new.size() == 1 && Trigger.new[0].Subject != null && Trigger.new[0].Subject.contains('New case email notification')){
        List<Case> c = [SELECT Id, ExternalId__c FROM Case WHERE Id =:Trigger.new[0].ParentId OR Id =:Trigger.new[0].RelatedToId];
        if(c.size() == 1 && c[0].ExternalId__c.startsWith('FRA')) delete Trigger.new[0];
    }
    if((Trigger.new.size() > 1 && Trigger.new.size() <= 100) || Test.isRunningTest()){
        for(EmailMessage mail : Trigger.new){
            if(mail.Subject != null && mail.Subject.contains('New case email notification')){
                List<Case> c = [SELECT Id, ExternalId__c FROM Case WHERE Id =:mail.ParentId OR Id =:Trigger.new[0].RelatedToId];
                if(c.size() == 1 && c[0].ExternalId__c.startsWith('FRA'))delete mail;
            }
        }
    }

}