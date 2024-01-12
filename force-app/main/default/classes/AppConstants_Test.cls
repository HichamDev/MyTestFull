@isTest
public with sharing class AppConstants_Test {
    static TestMethod void testConstants(){
        Test.startTest();
        AppConstants vApp = new AppConstants();
        Test.stopTest();
    }
}