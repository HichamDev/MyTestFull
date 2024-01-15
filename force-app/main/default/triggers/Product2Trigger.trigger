trigger Product2Trigger on Product2 (after insert) {

    /* EVENT AFTER INSERT */
    if (Trigger.isInsert && Trigger.isAfter) {
        Product2TriggerHandler.generateStandardPricebookEntry(Trigger.new);
    }

}