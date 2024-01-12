public with sharing class BA06_Scheduler implements Schedulable{
    public void execute(SchedulableContext sc){
        
        BA07_DeletePermissionSetUsers b = new BA07_DeletePermissionSetUsers();
        database.executeBatch(b);
        
        /*String cronexpression = '0 0 12 * * ?';
        String croneexpression2 = '0 0 24 * * ?';
        System.schedule('First', cronexpression , b); */
    }
}