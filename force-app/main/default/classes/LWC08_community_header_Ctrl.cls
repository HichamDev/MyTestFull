public without sharing class LWC08_community_header_Ctrl {
    
    public class MenuItem {
        @AuraEnabled
        public List<Item> lBurgerItems {get;set;}
        @AuraEnabled
        public List<Item> lMenuItems {get;set;}
        @AuraEnabled
        public Item stanmag {get;set;}
    }

    public class Item {
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled
        public String link {get;set;}
        @AuraEnabled
        public String icon {get;set;}
        @AuraEnabled
        public String target {get;set;}
        @AuraEnabled
        public String textLinkIcon {get;set;}
    }

    @AuraEnabled
    public static MenuItem getMenuItems(String device) {

        // Variables
        MenuItem menu = new MenuItem();

        // Get connected user contact
        Contact con = AP1002_Utils_User.getConnectedUserContact();

        if (con != null) {

            // Retrieve the SSO links accessible for this contact
            List<AP19_ApplicationResponse> lLinks = AP1005_ApplicationAccess.getSSOLinksForContact(con);

            // Retrieve the profile of the current user
            Id userId = UserInfo.getUserId();
            User u = [SELECT Id, Profile.Name FROM User WHERE Id =: userId];
            String profileCondition = '%' + u.Profile.Name + '%';

            Set<String> profiles = new Set<String>{'*', profileCondition};
            // profiles.add(profileCondition);
            // profiles.add('*');

            // Get the main menu
            menu.lMenuItems = getMainMenu(con, lLinks, device, profiles, profileCondition);

            // Get the burger menu content
            menu.lBurgerItems = getBurgerMenuLinks(con, lLinks, device, profiles, profileCondition);

        }

        return (menu);
    }



    /* BUSINESS METHODS */

    // Build the item list of the main menu 
    public static List<Item> getMainMenu(Contact con, List<AP19_ApplicationResponse> lLinks, String device, Set<String> profiles, String profileCondition) {
        
        // Variables
        List<Item> lMenu = new List<Item>();        

        // Retrieve the list of menu to be displayed for this profile
        List<Community_Menu__mdt> lMenuItems = [SELECT Id, MasterLabel, Device__c, Icon_URL__c, URL_Target__c, URL__c, Type__c, Order__c, Icon_Text_Url__c
                                                FROM Community_Menu__mdt
                                                WHERE  Country__c =: con.AccountCountryCode__c 
                                                AND Device__c = :device
                                                AND (Profiles_Applicable__c LIKE: profiles)
                                                AND (LU_In_the_Burger_Menu__c = false)  
                                                ORDER BY Order__c ASC];
        
        /** Changement JJE */
        List<Community_Menu__mdt> lMenuItemsSpecific = [SELECT Id, MasterLabel, Device__c, Icon_URL__c, URL_Target__c, URL__c, Type__c, Order__c, Icon_Text_Url__c
                                                FROM Community_Menu__mdt
                                                WHERE  Country__c =: con.AccountCountryCode__c 
                                                AND Device__c = :device
                                                AND (LU_In_the_Burger_Menu__c = false)  
                                                AND (Profiles_Applicable__c LIKE: profileCondition )  
                                                ORDER BY Order__c ASC];
        lMenuItems.addAll(lMenuItemsSpecific);

        Set<Community_Menu__mdt> vSetCommMenu = new Set<Community_Menu__mdt>();
        vSetCommMenu.addAll(lMenuItems);
        List<Community_Menu__mdt> vListCommMenu = new List<Community_Menu__mdt>();
        vListCommMenu.addAll(vSetCommMenu);
            
        if (!vListCommMenu.isEmpty()) {
            for (Community_Menu__mdt item : vListCommMenu) {
                System.debug('>>> item : ' + item);

                Item mItem = new Item();
                mItem.label = item.MasterLabel;
                mItem.target = item.URL_Target__c;
                mItem.icon = item.Icon_URL__c;
                mItem.textLinkIcon = item.Icon_Text_Url__c;

                // If the menu item is a static link
                if (item.Type__c == 'Static') {
                    mItem.link = item.URL__c;
                }
                // If the menu item is a SSO link
                if (item.Type__c == 'SSO') {
                    for (AP19_ApplicationResponse link : lLinks) {
                        // Get the matching SSO link
                        if (link.name.contains(item.MasterLabel)) {
                            mItem.link = link.url;
                            break;
                        }
                    }                

                }                
                lMenu.add(mItem);
            }
            
            if(con.AccountCountryCode__c == 'FRA'){
                List<lwc05_home_shortcuts_Ctrl.Item> shortcuts = lwc05_home_shortcuts_Ctrl.getShortcuts();
                String eShoplink = '';
                for(lwc05_home_shortcuts_Ctrl.Item s : shortcuts){
                    if(s.label.toUppercase().contains('STANHOME.FR')){
                        eShoplink = s.link;
                    }
                }
                Item mItem = new Item();
                mItem.label = 'eShop';
                mItem.target = '_blank';
                mItem.link = eShoplink;
                mItem.icon = 'https://mystan--c.eu25.content.force.com/servlet/servlet.ImageServer?id=0152o000006fi13&oid=00DD0000000rV9g';
                // lMenu.add(mItem); Demande pierre 25/03/2021
            }
        }

        return (lMenu);

    }

    // Build the list of items to be put on the burger menu
    public static List<Item> getBurgerMenuLinks(Contact con, List<AP19_ApplicationResponse> lLinks, String device, Set<String> profiles, String profileCondition) {

        List<Community_Menu__mdt> lMenuItems = [SELECT Id, MasterLabel, Device__c, Icon_URL__c, URL_Target__c, URL__c, Type__c, Order__c, Icon_Text_Url__c
                                                FROM Community_Menu__mdt
                                                WHERE  Country__c =: con.AccountCountryCode__c 
                                                AND Device__c = :device
                                                AND ( Profiles_Applicable__c LIKE: profiles)
                                                AND (LU_In_the_Burger_Menu__c = true)  
                                                ORDER BY Order__c ASC];
        List<Community_Menu__mdt> lMenuItemsSpecific = [SELECT Id, MasterLabel, Device__c, Icon_URL__c, URL_Target__c, URL__c, Type__c, Order__c, Icon_Text_Url__c
                                                FROM Community_Menu__mdt
                                                WHERE  Country__c =: con.AccountCountryCode__c 
                                                AND Device__c = :device
                                                AND (LU_In_the_Burger_Menu__c = true) 
                                                AND (Profiles_Applicable__c LIKE: profileCondition )  
                                                ORDER BY Order__c ASC];
        lMenuItems.addAll(lMenuItemsSpecific);

        Set<Community_Menu__mdt> vSetCommMenu = new Set<Community_Menu__mdt>();
        vSetCommMenu.addAll(lMenuItems);
        List<Community_Menu__mdt> vListCommMenu = new List<Community_Menu__mdt>();
        vListCommMenu.addAll(vSetCommMenu);

        List<Item> lBurgerItems = new List<Item>();

        if (!vListCommMenu.isEmpty()) {

            for (Community_Menu__mdt item : vListCommMenu) {
                
                system.debug('>>> item : ' + item);

                Item mItem = new Item();
                mItem.label = item.MasterLabel;

                // mItem.target = item.URL_Target__c;
                // mItem.icon = item.Icon_URL__c;
                // mItem.textLinkIcon = item.Icon_Text_Url__c;

                // If the menu item is a static link
                if (item.Type__c == 'Static') {
                    mItem.link = item.URL__c;
                }
                // If the menu item is a SSO link
                if (item.Type__c == 'SSO') {
                    for (AP19_ApplicationResponse link : lLinks) {
                        // Get the matching SSO link
                        if (link.name.contains(item.MasterLabel)) {
                            mItem.link = link.url;
                            break;
                        }
                    }
                }                
                lBurgerItems.add(mItem);
            }

        }

        // If the user is french
        if (con.AccountCountryCode__c == 'FRA') {

            // Our brands
            Item brands = new Item();
            brands.label = Label.LU_Menu_OurBrands;
            brands.link = Label.LU_Menu_OurBrands_Link;
            lBurgerItems.add(brands);

            // SSO Links to be displayed in the burger menu : E-learning, boutique des championnes, FAQ
            for (AP19_ApplicationResponse link : lLinks) {

                Item elem = new Item();
                elem.label = link.name;
                elem.link = link.url;
                lBurgerItems.add(elem);
            
            }

        } else {

            // SSO Links to be displayed in the burger menu 
            for (AP19_ApplicationResponse link : lLinks) {
                Item elem = new Item();
                elem.label = link.name;
                elem.link = link.url;
                lBurgerItems.add(elem);
            }

            // Manage the FAQ links
            // Item faq = new Item();
            // faq.label = Label.LU_Menu_FAQ;
            // faq.link = Label.LU_Menu_FAQ_Link;
            // lBurgerItems.add(faq);

        }

        // Manage the logout link
        Item logout = new Item();
        logout.label = Label.LU_Menu_Logout;
        logout.link = Label.LU_Menu_Logout_URL;
        lBurgerItems.add(logout);

        return (lBurgerItems);
    }

}