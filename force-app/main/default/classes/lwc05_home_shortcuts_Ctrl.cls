public without sharing class lwc05_home_shortcuts_Ctrl {
    
    public class Item {
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled
        public String link {get;set;}
        @AuraEnabled
        public String icon {get;set;}
    }

    @AuraEnabled
    public static List<Item> getShortcuts() {

        // Variables
        List<Item> lItems = new List<Item>();

        // Get connected user contact
        Contact con = AP1002_Utils_User.getConnectedUserContact();

        if (con != null) {

            // Retrieve the SSO links accessible for this contact
            List<AP19_ApplicationResponse> lLinks = AP1005_ApplicationAccess.getSSOLinksForContact(con);

            // If the user is french
            if (con.AccountCountryCode__c == 'FRA') {

                // SSO Links to be displayed in the burger menu : all except : E-learning, boutique des championnes
                for (AP19_ApplicationResponse link : lLinks) {

                    if (link.name.contains('E-Learning') == false && link.name.contains('Boutique Championne') == false &&
                        link.name.contains('Lettre Contact') == false && link.name.contains('Stan\'Mag') == false) {
                        Item elem = new Item();
                        elem.label = link.name;
                        elem.link = link.url;
                        elem.icon = link.imageUrl;
                        lItems.add(elem);
                    }

                    // Add a link FAQ
                    /*if (link.name == 'Stan\'Mag') {
                        Item elem = new Item();
                        elem.label = Label.LU_Menu_FAQ;
                        elem.link = link.url;
                        elem.link = elem.link.replace('http://stanmag.stanhome.fr/', 'http://stanmag.stanhome.fr/faq');
                        elem.icon = link.imageUrl;
                        // elem.icon = 'https://mystan--c.eu25.content.force.com/servlet/servlet.ImageServer?id=015D0000002e7fp&oid=00DD0000000rV9g';
                        lItems.add(elem);
                    }*/

                }

            } else {

                // SSO Links to be displayed in the burger menu 
                for (AP19_ApplicationResponse link : lLinks) {
                    Item elem = new Item();
                    elem.label = link.name;
                    elem.link = link.url;
                    elem.icon = link.imageUrl;
                    lItems.add(elem);
                }

                // Manage the FAQ links
                // Item faq = new Item();
                // faq.label = Label.LU_Menu_FAQ;
                // faq.link = Label.LU_Menu_FAQ_Link;
                // faq.icon = Label.LU_Menu_FAQ_Icon;
                // lItems.add(faq);

                // Ipaper
                // Item ipaper = new Item();
                // ipaper.label = Label.LU_Menu_Ipaper;
                // ipaper.link = Label.LU_Menu_Ipaper_Link;
                // ipaper.icon = Label.LU_Menu_Ipaper_Icon;
                // lItems.add(ipaper);

                // Call center
                // Item cs = new Item();
                // cs.label = Label.Lu_Menu_CustomerService;
                // cs.link = Label.Lu_Menu_CustomerService_Link;
                // cs.icon = Label.Lu_Menu_CustomerService_Icon;
                // lItems.add(cs);

            }

        }

        return (lItems);
    }

}