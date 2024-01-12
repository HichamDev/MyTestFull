public with sharing class PAD {
  public static final string bypassTrigger;
    static{
      System.Debug('## >>> PAD constructor :BEGIN <<< run by ' + UserInfo.getName());
      User user = [Select BypassApexTriggers__c from User where Id =:UserInfo.getUserId() limit 1];
      bypassTrigger = ';' + user.BypassApexTriggers__c + ';';
      System.Debug('## >>> PAD constructor : END <<<');
    }
    
  public static boolean canTrigger(string ApexName){ //If no bypass
    return(bypassTrigger.indexOf(';'+ApexName+';')==-1);
  }

}