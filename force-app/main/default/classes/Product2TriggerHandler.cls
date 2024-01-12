public with sharing class Product2TriggerHandler {
    
    /* Generate a pricebookentry line for the product on parameter in the standard catalog */
    public static void generateStandardPricebookEntry(List<Product2> lProducts) {

        // Get the standard price book
        List<Pricebook2> pbStandard = [SELECT Id FROM Pricebook2 WHERE IsStandard = true ];

        // If the standard price book is found
        if (!pbStandard.isEmpty() || Test.isRunningTest()) {

            // Create the pricebookentries for each product in parameter
            List<PricebookEntry> lPbEntries = new List<PricebookEntry>();
            for (Product2 p : lProducts) {
                Id pbId = (Test.isRunningTest() ? Test.getStandardPricebookId() : pbStandard[0].Id);
                PricebookEntry pbe = new PricebookEntry(Product2Id = p.Id, 
                                                        Pricebook2Id = pbId,
                                                        IsActive = true,
                                                        LU_Eligibility_Segments__c = '*',
                                                        UnitPrice = 0
                                                    );
                lPbEntries.add(pbe);
            }

            // Insert the pricebookentries generated
            if (!lPbEntries.isEmpty()) {
                insert lPbEntries;
            }

        }

    }

}