/*
// StatementBeforeInsert
----------------------------------------------------------------------
-- - Name          : StatementBeforeInsert
-- - Author        : JBO
-- - Description   : Trigger before insert to check if contact is Allowed to pay by cheque 
--                   
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 28-NOV-2013  JBO    1.0      Initial version 
---------------------------------------------------------------------
**********************************************************************
*/
trigger StatementBeforeInsert on STA_Statement__c (before insert) 
{
    system.debug('## START Trigger StatementBeforeInsert <<<<<'+UserInfo.getUserName());
    
    if(PAD.cantrigger('AP31_01'))
    {
        try
        {
            // Get the record type cheque
            RecordType typeId = [SELECT r.id FROM RecordType r WHERE DeveloperName = 'cheque' and SObjectType = 'STA_Statement__c' Limit 1];           
    
            //TODO use for loop instead and make sure to retrieve query in for loop
            STA_Statement__c sta = Trigger.New[0];
    
            // If the record type is cheque
            if (sta.RecordTypeId == typeId.Id)
            {
                if (sta.Contact__c != null)
                {               
                    // Retrieve the AllowedPaymenMode of the Contact
                    Contact c = [SELECT AllowedPaymentMode__c
                                 FROM Contact
                                 WHERE Id =: sta.Contact__c
                                 LIMIT 1];
              
                    boolean canPayByCheque = false;
                    if (c.AllowedPaymentMode__c != '' && c.AllowedPaymentMode__c != null)
                    {
                        // read the values of the payment mode into an array
                        string[] allowedPaymentMode = c.AllowedPaymentMode__c.split(';',0);
                        for (integer i = 0 ; i < allowedPaymentMode.size() ; i++) 
                        {
                            if (allowedPaymentMode[i] == 'Cheque')
                                canPayByCheque = true;
                        }
                    }
                        
                    if (canPayByCheque == false)
                    {
                        string theError=Label.STA00018;
                        sta.Contact__c.addError(theError);   
                    }
                }
            }
        } catch (Exception e)
        {
            system.debug(e);
        }
    }
    system.debug('## END Trigger StatementBeforeInsert <<<<<'+UserInfo.getUserName());
}