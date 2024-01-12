global with sharing class AP42_SchFra_BatchSuperMemberMigration implements Schedulable{

    global void execute (SchedulableContext sc){       
        system.debug('## Start scheduler AP42_SchFra_BatchSuperMemberMigration<<<<<');
        AP42_BatchSuperMemberMigration batch = new AP42_BatchSuperMemberMigration('FRA');
        database.executebatch(batch);
        system.debug('## End scheduler AP42_SchFra_BatchSuperMemberMigration <<<<<');
    }
}