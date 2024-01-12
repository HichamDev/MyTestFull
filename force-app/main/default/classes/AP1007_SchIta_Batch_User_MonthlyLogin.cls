global class AP1007_SchIta_Batch_User_MonthlyLogin implements Schedulable{
    
    global void execute (SchedulableContext sc){       
        system.debug('## Start scheduler AP1007_Batch_User_MonthlyLogin<<<<<');
        AP1007_Batch_User_MonthlyLogin batch = new AP1007_Batch_User_MonthlyLogin('ITA');
        database.executebatch(batch, 100);
        system.debug('## End scheduler AP1007_Batch_User_MonthlyLogin <<<<<');
    }

}