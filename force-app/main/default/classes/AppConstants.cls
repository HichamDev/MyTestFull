/**
 * Copyright (c) 2016, salesforce.com, inc.
 * All rights reserved.
 * Licensed under the BSD 3-Clause license. 
 * For full license text, see LICENSE.txt file in the repo root  or https://opensource.org/licenses/BSD-3-Clause
 */
public class AppConstants {

    @AuraEnabled(cacheable=true)
    public static AppConstants getAllConstants() {
        return new AppConstants();
    }
     
    // Contact Title
    public static final String CON_TITLE_DF = 'Direttore di Filiale';
    // Record type developername
    public static final String RT_CON_PERSONALCONTACT = 'LU_Personal_Contact';

    // Profil name
    @AuraEnabled
    public final String ITA_PROFILE_SMILEMEMBER      = 'ITA_LU_SMILE_MEMBER';
    @AuraEnabled
    public final String ITA_PROFILE_SMILELOGIN       = 'ITA_LU_SMILE_LOGIN';
    @AuraEnabled
    public final String ITA_PROFILE_AMICASTANHOMEMEMBER      = 'ITA_LU_AMICA_STANHOME_MEMBER';
    @AuraEnabled
    public final String ITA_PROFILE_AMICASTANHOMELOGIN       = 'ITA_LU_AMICA_STANHOME_LOGIN';
    @AuraEnabled
    public final String ITA_PROFILE_DEALERLOGIN      = 'ITA_LU_DEALER_LOGIN';
    @AuraEnabled
    public final String ITA_PROFILE_DEALERMEMBER     = 'ITA_LU_DEALER_MEMBER';
    @AuraEnabled
    public final String ITA_PROFILE_DEALERMANAGER    = 'ITA_LU_DEALER_MANAGER';
    @AuraEnabled
    public final String ITA_PROFILE_MANAGER          = 'ITA_LU_MANAGER';
    @AuraEnabled
    public final String ITA_PROFILE_SALESMANAGER     = 'ITA_LU_SALES_MANAGER';

    //Titles
    @AuraEnabled
    public final String ITA_TITLE_SALESCONSULTANT      = 'Sales Consultant';
    @AuraEnabled
    public final String ITA_TITLE_GROUPSALESCONSULTANT = 'Group Sales Consultant';
    
    public static final String PROFILE_ITA_DEALERMANAGER = 'ITA_LU_DEALER_MANAGER';
    public static final String PROFILE_ITA_SALESMANAGER  = 'ITA_LU_SALES_MANAGER';
    public static final String PROFILE_ITA_LUMANAGER     = 'ITA_LU_MANAGER';
    public static final String PROFILE_SYS_INTERFACE     = 'System Interface';
    public static final String PROFILE_INTERFACE         = 'Interface';

    // --- Picklist values ---
    // Order
    public static final String ORDER_STATUS_PENDING     = 'Pending';
    public static final String ORDER_STATUS_DRAFT       = 'Draft';
    public static final String ORDER_STATUS_INVOICED    = 'Invoiced';
    public static final String ORDER_STATUS_SHIPPED     = 'Shipped';
    public static final String ORDER_STATUS_PACKING     = 'Packing';
    public static final String ORDER_STATUS_PROCESSING  = 'Processing';
    public static final String ORDER_STATUS_DELIVERED   = 'Delivered';

    // LU_ProductSearchRule__mdt
    public static final String PRODSEARCHRULE_WHAT_CODE = 'LocalCode';
    public static final String PRODSEARCHRULE_WHAT_NAME = 'Name';

    //Org wide email adresses
    public static String NOREPLYITA = 'noreply Stanhome Italia';

    //Commercial Periods
    public static String COMM_PERIOD_TYPE_CYCLE = 'Cycle';
    public static String COMM_PERIOD_TYPE_WEEK = 'Week';

    //Contact - Baddept
    public static String Bad_Card_Status_Notpayed = 'Notpayed';
    public static String Bad_Card_Status_BadDebit = 'BadDebit';
    public static String Bad_Card_Status_Block = 'Block';

}