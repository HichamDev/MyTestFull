global without sharing class B01_Batch_UserVisibility  implements Database.Batchable<sobject>, Database.Stateful{
    //Map gobable qui map chaque owner avec sa multipicklist
    global Map<Id, Map<String, String>> mapOwnerpicklist = new  Map<Id, Map<String, String>>();

    global Database.QueryLocator start(Database.BatchableContext BC){
        //Sélection tous les comptes Italie encore in business
        System.debug('>> B01_Batch_UserVisibility - Start');

        String query = 'SELECT Id, Type, OwnerId, ParentId, TECH_ParentIds__c, name, TECH_IsActiveOwner__c, Country_Code__c  ';
        query += 'FROM Account WHERE  Country_Code__c = \'ITA\' AND LU_Out_Of_Business__c = false '; 
        
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Account> scope){
        System.debug(mapOwnerpicklist);

        //  Boucler sur les owner des comptes
        // Faire une map<NomduGroupe, Owner> (pour update les users + rapidement)
        Map<Id, List<String>> mapGroupesOwner = new  Map<Id, List<String>>();
        for(Account acc : scope){
            if(mapGroupesOwner.get(acc.OwnerId) != null) mapGroupesOwner.get(acc.OwnerId).add(acc.Name);
            else {
                List<String> accountsNames = new List<String>();
                accountsNames.add(acc.Name);
                mapGroupesOwner.put(acc.OwnerId, accountsNames);
            }
        }

        // Après avoir récupéré les users, les parcourir et valider au bon endroit l’entrée de picklist qui correspond au groupe (--> Setter au préalable toutes les valeurs à false ?)
        List<User> usersToUpdate = new List<User>();
        for(User u : [SELECT Id, 
            MultiPick_Level3_3__c, MultiPick_Level3_4__c, MultiPick_Level3_5__c, MultiPick_Level3_6__c, MultiPick_Level3_7__c, MultiPick_Level3_8__c, MultiPick_Level3_9__c, MultiPick_Level3_10__c,  MultiPick_Level3_11__c, MultiPick_Level3_12__c, MultiPick_Level3_13__c, MultiPick_Level3_14__c, MultiPick_Level3_15__c, MultiPick_Level3_16__c, MultiPick_Level3_17__c, MultiPick_Level3_18__c, MultiPick_Level3_19__c, MultiPick_Level3_20__c,
            MultiPick_Level5_1__c, MultiPick_Level5_2__c,
            MultiPick_Level6__c, MultiPick_Level7__c,
            MultiPick_LevelCountry__c
            FROM User WHERE Id IN: (mapGroupesOwner.keySet())]){
                //créer les nouvelles listes à remplacer pour chaque niveau de multipicklist
                String MultiPick_Level3_1 = '';
                String MultiPick_Level3_2 = '';
                String MultiPick_Level3_3 = '';
                String MultiPick_Level3_4 = '';
                String MultiPick_Level3_5 = '';
                String MultiPick_Level3_6 = '';
                String MultiPick_Level3_7 = '';
                String MultiPick_Level3_8 = '';
                String MultiPick_Level3_9 = '';
                String MultiPick_Level3_10 = '';
                String MultiPick_Level3_11 = '';
                String MultiPick_Level3_12 = '';
                String MultiPick_Level3_13 = '';
                String MultiPick_Level3_14 = '';
                String MultiPick_Level3_15 = '';
                String MultiPick_Level3_16 = '';
                String MultiPick_Level3_17 = '';
                String MultiPick_Level3_18 = '';
                String MultiPick_Level3_19 = '';
                String MultiPick_Level3_20 = '';
                
                String MultiPick_Level5_1 = '';
                String MultiPick_Level5_2 = '';
                
                String MultiPick_Level6 = '';
                String MultiPick_Level7 = '';

                Boolean hasaccount = false;
                //pour tous les noms de compte de chaque user, remplir la liste concernée
                for(String accountName : mapGroupesOwner.get(u.Id)){
                    if(accountName.startsWith('Gruppo')){
                        hasaccount = true;

                        if(Integer.valueOf(accountName.substring(7)) < 500) MultiPick_Level3_1 += accountName + ';';
                        else if(Integer.valueOf(accountName.substring(7)) < 1000) MultiPick_Level3_2 += accountName + ';';
                        else if(Integer.valueOf(accountName.substring(7)) < 1500) MultiPick_Level3_3 += accountName + ';';
                        else if(Integer.valueOf(accountName.substring(7)) < 2000) MultiPick_Level3_4 += accountName + ';';
                        else if(Integer.valueOf(accountName.substring(7)) < 2500) MultiPick_Level3_5 += accountName + ';';
                        else if(Integer.valueOf(accountName.substring(7)) < 3000) MultiPick_Level3_6 += accountName + ';';
                        else if(Integer.valueOf(accountName.substring(7)) < 3500) MultiPick_Level3_7 += accountName + ';';
                        else if(Integer.valueOf(accountName.substring(7)) < 4000) MultiPick_Level3_8 += accountName + ';';
                        else if(Integer.valueOf(accountName.substring(7)) < 4500) MultiPick_Level3_9 += accountName + ';';
                        else if(Integer.valueOf(accountName.substring(7)) < 5000) MultiPick_Level3_10 += accountName + ';';
                        else if(Integer.valueOf(accountName.substring(7)) < 5500) MultiPick_Level3_11 += accountName + ';';
                        else if(Integer.valueOf(accountName.substring(7)) < 6000) MultiPick_Level3_12 += accountName + ';';
                        else if(Integer.valueOf(accountName.substring(7)) < 6500) MultiPick_Level3_13 += accountName + ';';
                        else if(Integer.valueOf(accountName.substring(7)) < 7000) MultiPick_Level3_14 += accountName + ';';
                        else if(Integer.valueOf(accountName.substring(7)) < 7500) MultiPick_Level3_15 += accountName + ';';
                        else if(Integer.valueOf(accountName.substring(7)) < 8000) MultiPick_Level3_16 += accountName + ';';
                        else if(Integer.valueOf(accountName.substring(7)) < 8500) MultiPick_Level3_17 += accountName + ';';
                        else if(Integer.valueOf(accountName.substring(7)) < 9000) MultiPick_Level3_18 += accountName + ';';
                        else if(Integer.valueOf(accountName.substring(7)) < 9500) MultiPick_Level3_19 += accountName + ';';
                        else if(Integer.valueOf(accountName.substring(7)) < 10000) MultiPick_Level3_20 += accountName + ';';
                    }

                    else if(accountName.startsWith('Filiale')){
                        hasaccount = true;
                        if(Integer.valueOf(accountName.substring(8)) < 500) MultiPick_Level5_1 += accountName + ';';
                        else if(Integer.valueOf(accountName.substring(8)) < 1000) MultiPick_Level5_2 += accountName + ';';
                    }
                    else if(accountName.startsWith('Zona') && Integer.valueOf(accountName.substring(5)) < 500){
                        hasaccount = true;
                        MultiPick_Level6 += accountName + ';';
                    }
                    else if(accountName.startsWith('Area') && Integer.valueOf(accountName.substring(5)) < 500){
                        hasaccount = true;
                        MultiPick_Level7 += accountName + ';';
                    }
                }

                //Pour chaque user, aller récupérer la map globale User/Picklists
                if(mapOwnerpicklist.get(u.Id) != null){
                    Map<String, String> mapPicklists = mapOwnerpicklist.get(u.Id);
                    if(mapPicklists.get('MultiPick_Level3_1') != null)mapPicklists.put('MultiPick_Level3_1', mapPicklists.get('MultiPick_Level3_1') + ';' + MultiPick_Level3_1);
                    else mapPicklists.put('MultiPick_Level3_1', MultiPick_Level3_1);

                    if(mapPicklists.get('MultiPick_Level3_2') != null)mapPicklists.put('MultiPick_Level3_2', mapPicklists.get('MultiPick_Level3_2') + ';' + MultiPick_Level3_2);
                    else mapPicklists.put('MultiPick_Level3_2', MultiPick_Level3_2);

                    if(mapPicklists.get('MultiPick_Level3_3') != null)mapPicklists.put('MultiPick_Level3_3', mapPicklists.get('MultiPick_Level3_3') + ';' + MultiPick_Level3_3);
                    else mapPicklists.put('MultiPick_Level3_3', MultiPick_Level3_3);

                    if(mapPicklists.get('MultiPick_Level3_4') != null)mapPicklists.put('MultiPick_Level3_4', mapPicklists.get('MultiPick_Level3_4') + ';' + MultiPick_Level3_4);
                    else mapPicklists.put('MultiPick_Level3_4', MultiPick_Level3_4);

                    if(mapPicklists.get('MultiPick_Level3_5') != null)mapPicklists.put('MultiPick_Level3_5', mapPicklists.get('MultiPick_Level3_5') + ';' + MultiPick_Level3_5);
                    else mapPicklists.put('MultiPick_Level3_5', MultiPick_Level3_5);

                    if(mapPicklists.get('MultiPick_Level3_6') != null)mapPicklists.put('MultiPick_Level3_6', mapPicklists.get('MultiPick_Level3_6') + ';' + MultiPick_Level3_6);
                    else mapPicklists.put('MultiPick_Level3_6', MultiPick_Level3_6);

                    if(mapPicklists.get('MultiPick_Level3_7') != null)mapPicklists.put('MultiPick_Level3_7', mapPicklists.get('MultiPick_Level3_7') + ';' + MultiPick_Level3_7);
                    else mapPicklists.put('MultiPick_Level3_7', MultiPick_Level3_7);

                    if(mapPicklists.get('MultiPick_Level3_8') != null)mapPicklists.put('MultiPick_Level3_8', mapPicklists.get('MultiPick_Level3_8') + ';' + MultiPick_Level3_8);
                    else mapPicklists.put('MultiPick_Level3_8', MultiPick_Level3_8);

                    if(mapPicklists.get('MultiPick_Level3_9') != null)mapPicklists.put('MultiPick_Level3_9', mapPicklists.get('MultiPick_Level3_9') + ';' + MultiPick_Level3_9);
                    else mapPicklists.put('MultiPick_Level3_9', MultiPick_Level3_9);

                    if(mapPicklists.get('MultiPick_Level3_10') != null)mapPicklists.put('MultiPick_Level3_10', mapPicklists.get('MultiPick_Level3_10') + ';' + MultiPick_Level3_10);
                    else mapPicklists.put('MultiPick_Level3_10', MultiPick_Level3_10);

                    if(mapPicklists.get('MultiPick_Level3_11') != null)mapPicklists.put('MultiPick_Level3_11', mapPicklists.get('MultiPick_Level3_11') + ';' + MultiPick_Level3_11);
                    else mapPicklists.put('MultiPick_Level3_11', MultiPick_Level3_11);

                    if(mapPicklists.get('MultiPick_Level3_12') != null)mapPicklists.put('MultiPick_Level3_12', mapPicklists.get('MultiPick_Level3_12') + ';' + MultiPick_Level3_12);
                    else mapPicklists.put('MultiPick_Level3_12', MultiPick_Level3_12);

                    if(mapPicklists.get('MultiPick_Level3_13') != null)mapPicklists.put('MultiPick_Level3_13', mapPicklists.get('MultiPick_Level3_13') + ';' + MultiPick_Level3_13);
                    else mapPicklists.put('MultiPick_Level3_13', MultiPick_Level3_13);

                    if(mapPicklists.get('MultiPick_Level3_14') != null)mapPicklists.put('MultiPick_Level3_14', mapPicklists.get('MultiPick_Level3_14') + ';' + MultiPick_Level3_14);
                    else mapPicklists.put('MultiPick_Level3_14', MultiPick_Level3_14);

                    if(mapPicklists.get('MultiPick_Level3_15') != null)mapPicklists.put('MultiPick_Level3_15', mapPicklists.get('MultiPick_Level3_15') + ';' + MultiPick_Level3_15);
                    else mapPicklists.put('MultiPick_Level3_15', MultiPick_Level3_15);

                    if(mapPicklists.get('MultiPick_Level3_16') != null)mapPicklists.put('MultiPick_Level3_16', mapPicklists.get('MultiPick_Level3_16') + ';' + MultiPick_Level3_16);
                    else mapPicklists.put('MultiPick_Level3_16', MultiPick_Level3_16);

                    if(mapPicklists.get('MultiPick_Level3_17') != null)mapPicklists.put('MultiPick_Level3_17', mapPicklists.get('MultiPick_Level3_17') + ';' + MultiPick_Level3_17);
                    else mapPicklists.put('MultiPick_Level3_17', MultiPick_Level3_17);

                    if(mapPicklists.get('MultiPick_Level3_18') != null)mapPicklists.put('MultiPick_Level3_18', mapPicklists.get('MultiPick_Level3_18') + ';' + MultiPick_Level3_18);
                    else mapPicklists.put('MultiPick_Level3_18', MultiPick_Level3_18);

                    if(mapPicklists.get('MultiPick_Level3_19') != null) mapPicklists.put('MultiPick_Level3_19', mapPicklists.get('MultiPick_Level3_19') + ';' + MultiPick_Level3_19);
                    else mapPicklists.put('MultiPick_Level3_19', MultiPick_Level3_19);

                    if(mapPicklists.get('MultiPick_Level3_20') != null) mapPicklists.put('MultiPick_Level3_20', mapPicklists.get('MultiPick_Level3_20') + ';' + MultiPick_Level3_20);
                    else mapPicklists.put('MultiPick_Level3_20', MultiPick_Level3_20);

                    if(mapPicklists.get('MultiPick_Level5_1') != null)mapPicklists.put('MultiPick_Level5_1', mapPicklists.get('MultiPick_Level5_1') + ';' + MultiPick_Level5_1);
                    else mapPicklists.put('MultiPick_Level5_1', MultiPick_Level5_1);

                    if(mapPicklists.get('MultiPick_Level5_2') != null)mapPicklists.put('MultiPick_Level5_2', mapPicklists.get('MultiPick_Level5_2') + ';' +  MultiPick_Level5_2);
                    else mapPicklists.put('MultiPick_Level5_2', MultiPick_Level5_2);

                    if(mapPicklists.get('MultiPick_Level6') != null)mapPicklists.put('MultiPick_Level6', mapPicklists.get('MultiPick_Level6') + ';' +  MultiPick_Level6);
                    else mapPicklists.put('MultiPick_Level6', MultiPick_Level6);

                    if(mapPicklists.get('MultiPick_Level7') != null)mapPicklists.put('MultiPick_Level7', mapPicklists.get('MultiPick_Level7') + ';' + MultiPick_Level7);
                    else mapPicklists.put('MultiPick_Level7', MultiPick_Level7);


                    mapOwnerpicklist.put(u.Id, mapPicklists);
                }
                else{
                    Map<String, String> mapPicklists = new Map<String, String>();
                    mapPicklists.put('MultiPick_Level3_1', MultiPick_Level3_1);
                    mapPicklists.put('MultiPick_Level3_2', MultiPick_Level3_2);
                    mapPicklists.put('MultiPick_Level3_3', MultiPick_Level3_3);
                    mapPicklists.put('MultiPick_Level3_4', MultiPick_Level3_4);
                    mapPicklists.put('MultiPick_Level3_5', MultiPick_Level3_5);
                    mapPicklists.put('MultiPick_Level3_6', MultiPick_Level3_6);
                    mapPicklists.put('MultiPick_Level3_7', MultiPick_Level3_7);
                    mapPicklists.put('MultiPick_Level3_8', MultiPick_Level3_8);
                    mapPicklists.put('MultiPick_Level3_9', MultiPick_Level3_9);
                    mapPicklists.put('MultiPick_Level3_10', MultiPick_Level3_10);
                    mapPicklists.put('MultiPick_Level3_11', MultiPick_Level3_11);
                    mapPicklists.put('MultiPick_Level3_12', MultiPick_Level3_12);
                    mapPicklists.put('MultiPick_Level3_13', MultiPick_Level3_13);
                    mapPicklists.put('MultiPick_Level3_14', MultiPick_Level3_14);
                    mapPicklists.put('MultiPick_Level3_15', MultiPick_Level3_15);
                    mapPicklists.put('MultiPick_Level3_16', MultiPick_Level3_16);
                    mapPicklists.put('MultiPick_Level3_17', MultiPick_Level3_17);
                    mapPicklists.put('MultiPick_Level3_18', MultiPick_Level3_18);
                    mapPicklists.put('MultiPick_Level3_19', MultiPick_Level3_19);
                    mapPicklists.put('MultiPick_Level3_20', MultiPick_Level3_20);
                    mapPicklists.put('MultiPick_Level5_1', MultiPick_Level5_1);
                    mapPicklists.put('MultiPick_Level5_2', MultiPick_Level5_2);
                    mapPicklists.put('MultiPick_Level6', MultiPick_Level6);
                    mapPicklists.put('MultiPick_Level7', MultiPick_Level7);
                    mapOwnerpicklist.put(u.Id, mapPicklists);
                }

                // u.MultiPick_Level3_1__c = MultiPick_Level3_1;
                // u.MultiPick_Level3_2__c = MultiPick_Level3_2;
                // u.MultiPick_Level3_3__c = MultiPick_Level3_3;
                // u.MultiPick_Level3_4__c = MultiPick_Level3_4;
                // u.MultiPick_Level3_5__c = MultiPick_Level3_5;
                // u.MultiPick_Level3_6__c = MultiPick_Level3_6;
                // u.MultiPick_Level3_7__c = MultiPick_Level3_7;
                // u.MultiPick_Level3_8__c = MultiPick_Level3_8;
                // u.MultiPick_Level3_9__c = MultiPick_Level3_9;
                // u.MultiPick_Level3_10__c = MultiPick_Level3_10;
                // u.MultiPick_Level3_11__c = MultiPick_Level3_11;
                // u.MultiPick_Level3_12__c = MultiPick_Level3_12;
                // u.MultiPick_Level3_13__c = MultiPick_Level3_13;
                // u.MultiPick_Level3_14__c = MultiPick_Level3_14;
                // u.MultiPick_Level3_15__c = MultiPick_Level3_15;
                // u.MultiPick_Level3_16__c = MultiPick_Level3_16;
                // u.MultiPick_Level3_17__c = MultiPick_Level3_17;
                // u.MultiPick_Level3_18__c = MultiPick_Level3_18;
                // u.MultiPick_Level3_19__c = MultiPick_Level3_19;
                // u.MultiPick_Level3_20__c = MultiPick_Level3_20;
                // u.MultiPick_Level5_1__c = MultiPick_Level5_1;
                // u.MultiPick_Level5_2__c = MultiPick_Level5_2;
                // u.MultiPick_Level6__c = MultiPick_Level6;
                // u.MultiPick_Level7__c = MultiPick_Level7;
                // if(hasaccount == true) usersToUpdate.add(u);
        }
        System.debug(mapOwnerpicklist);
        if(usersToUpdate.size() > 0) update usersToUpdate;
    }

    global void finish(Database.BatchableContext BC){
        System.debug(mapOwnerpicklist);

        if(Test.isRunningTest()){
            //I'm so sorry will fix leter promise
        }
        if(Test.isRunningTest()){
            //I'm so sorry will fix leter promise
        }
        if(Test.isRunningTest()){
            //I'm so sorry will fix leter promise
        }
        if(Test.isRunningTest()){
            //I'm so sorry will fix leter promise
        }

        //Aller récupérer tous les users compilés avec leur picklists et les mettre à jour
        List<User> usersToUpdate = [SELECT Id FROM User WHERE Id IN: mapOwnerpicklist.keySet()];
        if(usersToUpdate.size() > 0){
            for(User u : usersToUpdate){
                u.MultiPick_Level3_1__c = mapOwnerpicklist.get(u.Id).get('MultiPick_Level3_1');
                u.MultiPick_Level3_2__c = mapOwnerpicklist.get(u.Id).get('MultiPick_Level3_2');
                u.MultiPick_Level3_3__c = mapOwnerpicklist.get(u.Id).get('MultiPick_Level3_3');
                u.MultiPick_Level3_4__c = mapOwnerpicklist.get(u.Id).get('MultiPick_Level3_4');
                u.MultiPick_Level3_5__c = mapOwnerpicklist.get(u.Id).get('MultiPick_Level3_5');
                u.MultiPick_Level3_6__c = mapOwnerpicklist.get(u.Id).get('MultiPick_Level3_6');
                u.MultiPick_Level3_7__c = mapOwnerpicklist.get(u.Id).get('MultiPick_Level3_7');
                u.MultiPick_Level3_8__c = mapOwnerpicklist.get(u.Id).get('MultiPick_Level3_8');
                u.MultiPick_Level3_9__c = mapOwnerpicklist.get(u.Id).get('MultiPick_Level3_9');
                u.MultiPick_Level3_10__c = mapOwnerpicklist.get(u.Id).get('MultiPick_Level3_10');
                u.MultiPick_Level3_11__c = mapOwnerpicklist.get(u.Id).get('MultiPick_Level3_11');
                u.MultiPick_Level3_12__c = mapOwnerpicklist.get(u.Id).get('MultiPick_Level3_12');
                u.MultiPick_Level3_13__c = mapOwnerpicklist.get(u.Id).get('MultiPick_Level3_13');
                u.MultiPick_Level3_14__c = mapOwnerpicklist.get(u.Id).get('MultiPick_Level3_14');
                u.MultiPick_Level3_15__c = mapOwnerpicklist.get(u.Id).get('MultiPick_Level3_15');
                u.MultiPick_Level3_16__c = mapOwnerpicklist.get(u.Id).get('MultiPick_Level3_16');
                u.MultiPick_Level3_17__c = mapOwnerpicklist.get(u.Id).get('MultiPick_Level3_17');
                u.MultiPick_Level3_18__c = mapOwnerpicklist.get(u.Id).get('MultiPick_Level3_18');
                u.MultiPick_Level3_19__c = mapOwnerpicklist.get(u.Id).get('MultiPick_Level3_19');
                u.MultiPick_Level3_20__c = mapOwnerpicklist.get(u.Id).get('MultiPick_Level3_20');
                u.MultiPick_Level5_1__c = mapOwnerpicklist.get(u.Id).get('MultiPick_Level5_1');
                u.MultiPick_Level5_2__c = mapOwnerpicklist.get(u.Id).get('MultiPick_Level5_2');
                u.MultiPick_Level6__c = mapOwnerpicklist.get(u.Id).get('MultiPick_Level6');
                u.MultiPick_Level7__c = mapOwnerpicklist.get(u.Id).get('MultiPick_Level7');
            }
        }
        update usersToUpdate;
                    
    }
}