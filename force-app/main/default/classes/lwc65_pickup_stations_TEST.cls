@isTest
public class lwc65_pickup_stations_TEST {
    
    @isTest
    public static void getInfosPointrelai(){
        Shipping_Mode__c shippingMode = new Shipping_Mode__c();
        shippingMode.Name = 'Colissimo'  ;
        shippingMode.Profile_Applicable_for__c = 'FRA_LDS;FRA_Dealer;FRA_Leader;FRA_Dealers Manager;FRA_LU_DEALER_MEMBER;FRA_LU_DEALER_MANAGER_NEW;FRA_LU_DEALER_LOGIN;FRA_LU_DEALER_MANAGER'  ;
        shippingMode.Enseigne__c = 'BDTEST13'  ;
        shippingMode.Cle_privee__c = 'PrivateK';
        shippingMode.Action__c = '24R';
        shippingMode.Nombre_de_resultats__c = 10 ;
        shippingMode.Country__c = 'FR' ;
        shippingMode.Mode__c = 'Externe_Colissimo';
        shippingMode.Service_Login__c = '822956';
        shippingMode.Service_URL__c = 'https://ws.colissimo.fr/pointretrait-ws-cxf/PointRetraitServiceWS/2.0';
        shippingMode.UID__c = 'FRA_MondialRelay';
        shippingMode.Active__c = true;
        insert shippingMode;

        Test.startTest();
        List<lwc65_pickup_stations_ctrl.wrapRelai> listRelais = lwc65_pickup_stations_ctrl.getInfoRelai('44000', shippingMode.Id);
        Test.stopTest();
    }

    @isTest
    public static void createPointRelaiSelect() {
        Test.startTest();
        VFC01_OrderAddress_France.wrapperPointRelaiSelec pointRelaiSelec = lwc65_pickup_stations_ctrl.createPointSelected('5 rue Geroges Labeyrie', 'nantes', '44200', 'Maison Test', 'FRA', 'Maison Test', 'Chez Julie');
        Test.stopTest();

        System.assert(pointRelaiSelec.nom == 'Maison Test');
    }
}