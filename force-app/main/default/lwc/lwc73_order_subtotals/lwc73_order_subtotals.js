import { LightningElement, track } from 'lwc';

import { registerListener, unregisterAllListeners } from 'c/pubsub';

/* APEX METHODS */
import getUserCountry from '@salesforce/apex/lwc73_order_subtotals_ctrl.getUserCountry';
import getOrder from '@salesforce/apex/lwc73_order_subtotals_ctrl.getOrder';
import getChallengesContact from '@salesforce/apex/lwc73_order_subtotals_ctrl.getChallenges';
import rebateDiscountOnPersonalUse from '@salesforce/apex/AP44_OrderHandler.rebateDiscountOnPersonalUse';

/* LABELS */
import lbl_minimumAmount from '@salesforce/label/c.LU_Orderhometotal_Minimum_Amount';
import lbl_htAmount from '@salesforce/label/c.LU_Orderhometotal_HT_Amount';
import lbl_ttcAmount from '@salesforce/label/c.LU_Orderhometotal_TTC_Amount';
import lbl_htStanhome from '@salesforce/label/c.LU_Orderhometotal_HT_Stanhome';
import lbl_htFamilyExpert from '@salesforce/label/c.LU_Orderhometotal_HT_FamilyExpert';
import lbl_htKiotis from '@salesforce/label/c.LU_Orderhometotal_HT_Kiotis';
import lbl_htFlormar from '@salesforce/label/c.LU_Orderhometotal_HT_Flormar';
import lbl_htOthers from '@salesforce/label/c.LU_Orderhometotal_HT_Others';
import lbl_numberArticles from '@salesforce/label/c.LU_Ordertotal_Number_Articles';
import lbl_commission from '@salesforce/label/c.LU_Ordertotal_Commission';
import lbl_totalTVA from '@salesforce/label/c.LU_Ordertotal_TotalTVA';
import lbl_transportFees from '@salesforce/label/c.LU_Ordertotal_Transport_Fees';
import lbl_totalToPay from '@salesforce/label/c.LU_Ordertotal_Total_To_Pay';
import lbl_loadProvisions from '@salesforce/label/c.LU_Ordertotal_Load_Provisions';

import lbl_ProfessionalUseAmount from '@salesforce/label/c.LU_OrderTotal_ProfesionnalUse_Amount';
import lbl_totalAmountToSell from '@salesforce/label/c.LU_Ordertotal_Total_Amount_To_Sell';
import lbl_personnalUseProduts from '@salesforce/label/c.LU_Orderhometotal_Personal_Use_Product';
import lbl_giftsAmount from '@salesforce/label/c.LU_Ordertotal_Gifts_Amount';
import lbl_firstTotalAmount from '@salesforce/label/c.LU_Ordertotal_First_Total_Amount';
import lbl_commissions from '@salesforce/label/c.LU_Ordertotal_Commissions';
import lbl_discountForPersonalUse from '@salesforce/label/c.LU_Ordertotal_DiscountP_Personal_Use';
import lbl_discount from '@salesforce/label/c.Discount';
import lbl_discountHelptext from '@salesforce/label/c.DiscountHelpText';
import lbl_totalAmount from '@salesforce/label/c.LU_Ordertotal_Total_Amount';
import lbl_invoiceDetails from '@salesforce/label/c.LU_Order_Invoice_Title';
import lbl_challengeDiscount from '@salesforce/label/c.LU_Ordertotal_Challenge_Discount';
import lbl_OrderTotal_WorkMaterial from '@salesforce/label/c.LU_OrderTotal_WorkMaterial';
import lbl_OrderTotal_FiscalPayment from '@salesforce/label/c.LU_Ordertotal_FiscalPayment';
import lbl_commission_account from '@salesforce/label/c.LU_Ordertotal_Commissions_Account';


import lbl_ttc from '@salesforce/label/c.LU_TTC';
import MailingPostalCode from '@salesforce/schema/Contact.MailingPostalCode';

export default class Lwc73_order_subtotals extends LightningElement {

    labels = {
        lbl_ttc,
        lbl_minimumAmount,
        lbl_htAmount,
        lbl_ttcAmount,
        lbl_htStanhome,
        lbl_htFamilyExpert,
        lbl_htKiotis,
        lbl_htFlormar,
        lbl_htOthers,
        lbl_numberArticles,
        lbl_commission,
        lbl_totalTVA,
        lbl_transportFees,
        lbl_totalToPay,
        lbl_ProfessionalUseAmount,
        lbl_loadProvisions,
        lbl_totalAmountToSell,
        lbl_personnalUseProduts,
        lbl_giftsAmount,
        lbl_firstTotalAmount,
        lbl_commissions,
        lbl_discountForPersonalUse,
        lbl_discount,
        lbl_discountHelptext,
        lbl_totalAmount,
        lbl_invoiceDetails,
        lbl_challengeDiscount,
        lbl_OrderTotal_WorkMaterial,
        lbl_OrderTotal_FiscalPayment,
        lbl_commission_account
    }

    path_OrderObject = "/order/";
    path_OrderCheckout = "/order-checkout";

    @track orderId;

    @track isFRA = false;
    @track isITA = false;

    @track isOLA = true;

    @track displayMore = false;
    @track displayMoreIC = false;

    @track isOrderDetailPage = false;
    @track isOrderCheckoutPage = false;

    @track displayShippingFees = false;
    @track displayChallengeDiscount = false;

    @track minimumAmount = 0;
    @track challengesTable;
    @track mapChallengesNames;
    @track totalHT = 0;
    @track totalTTC = 0;
    @track htStanhome = 0;
    @track htFamilyExpert = 0;
    @track htKiotis = 0;
    @track htFlormar = 0;
    @track htOthers = 0;
    @track numberArticles = 0;
    @track commission = 0;
    @track totalTVA = 0;
    @track transportFees = 0;
    @track totalToPay = 0;
    @track loadProvisions = 0;

    @track displayBoTotal = false;
    @track orderBoTaxes = 0;
    @track orderBoCommission = 0;
    @track orderBoTotalAmountToPay = 0;

    @track totalAmountToSell = 0;
    @track personnalUseProduts = 0;
    @track giftsAmount = 0;
    @track firstTotalAmount = 0;
    @track commissions = 0;
    @track discountForPersonalUse = 0;
    @track discount = 0;
    @track displayDiscount = false;
    @track totalAmount = 0;
    @track professionalUseAmount = 0;
    @track workMaterialAmount = 0;
    @track fiscalPayment = 0;


    /* INIT */
    connectedCallback() {

        registerListener('basketUpdated', this.updateTotals, this);
        registerListener('lwc85_incentive_challenge', this.updateTotals, this);

        // Get order id in the URL
        // let pageUrl = new URL(window.location.href);
        // let pathname = pageUrl.pathname;

        let pathname = window.location.href;

        if (pathname.includes(this.path_OrderObject)) {

            let indexOf_OrderObject = pathname.indexOf(this.path_OrderObject);
            let str_withId = pathname.substr(indexOf_OrderObject + this.path_OrderObject.length);
            let indexOf_slash = str_withId.indexOf("/");
            this.orderId = str_withId.substring(0, indexOf_slash);

            this.isOrderDetailPage = true;
        }
        else if (pathname.includes(this.path_OrderCheckout)) {
            let parameters = this.getQueryParameters();
            if(parameters.orderId){
                this.orderId = parameters.orderId;
            }

            this.isOrderCheckoutPage = true;
        }

        getUserCountry()
        .then(results => {
            if(results === "FRA"){
                this.isFRA = true;
            }
            else if(results === "ITA"){
                this.isITA = true;
            }

            if (this.orderId != null && (this.isFRA || this.isITA) ) {
                this.updateTotals();
            }
        })
        .catch(error => {
            console.log('>>>> error :');
            console.log(error);
        });
    }
	disconnectedCallback() {
		// unsubscribe from events
		unregisterAllListeners(this);
    }

    updateTotals(){

        getOrder({orderId : this.orderId, isITA : this.isITA})
        .then(results => {
            console.log("lwc733333333333333333333333333333333333333333333333");
            console.log(results);
            if(this.isFRA && results){
                this.numberArticles = results.LU_Number_Of_Articles__c;
                this.totalHT = results.LU_Total_Price_Without_Taxes__c;
                this.htStanhome = results.LU_Total_Amount_Brand_Stanhome__c;
                this.htFamilyExpert = results.Total_Amount_Brand_Family_Expert__c;
                this.htKiotis = results.Total_Amount_Brand_Kiotis__c;
                this.htFlormar = results.LU_Total_Amount_Brand_Flormar__c;
                this.htOthers = results.Total_Amount_Others__c;

                this.orderBoTotalWithoutTaxes = results.BO_TOTAL_WITHOUT_TAXES__c;
                this.orderBoTaxes = results.BO_TAXES__c;
                this.orderBoCommission = results.BO_COMMISSION__c;
                this.orderBoTotalAmountToPay = results.BO_TOTAL_AMOUNT_TO_PAY__c;

                // if(results.Status === 'Invoiced' || results.Status === 'Shipped' || results.Status === 'Archived' || results.Status === 'Cancelled' || results.Status === 'Blocked'){
                //     if(this.isFRA){
                //         this.displayBoTotal = true;
                //     }
                // }


                if(
                    this.isFRA &&
                    // (this.orderBoTotalWithoutTaxes !== null && this.orderBoTotalWithoutTaxes > 0) || 
                    (this.orderBoTaxes !== null && this.orderBoTaxes != 0) ||
                    (this.orderBoCommission !== null && this.orderBoCommission != 0) ||
                    (this.orderBoTotalAmountToPay !== null && this.orderBoTotalAmountToPay != 0)){
                        this.displayBoTotal = true;
                }
                
                //JJE - 15/04/2021
                //Recalcul des montants challenge --> Récupération des produits concernés par un challenge
                this.minimumAmount = 0;
                this.challengesTable = new Map();
                for(let i in results.OrderItems){
                    if(results.OrderItems[i].PricebookEntry.LU_Valid_For_Challenge__c == true){
                        this.minimumAmount += results.OrderItems[i].LU_TECH_UsedForMinAmount__c;

                        //Récupérer dans une map les montant de chaque challenge
                        if(results.OrderItems[i].PricebookEntry.LU_Challenges_Ids__c != null){
                            let challengesId = [];
                            challengesId = results.OrderItems[i].PricebookEntry.LU_Challenges_Ids__c.split('#');
                            if(results.OrderItems[i].PricebookEntry.LU_Challenges_Ids_Bis__c != null){
                                challengesId.push.apply(challengesId, results.OrderItems[i].PricebookEntry.LU_Challenges_Ids_Bis__c.split('#'));
                            }
                            for(let j in challengesId){
                                if( this.challengesTable.get(challengesId[j]) != null){
                                    let amountPerChallenge =  this.challengesTable.get(challengesId[j]);
                                    amountPerChallenge += results.OrderItems[i].LU_TECH_UsedForMinAmount__c;
                                    this.challengesTable.set(challengesId[j], amountPerChallenge);
                                }
                                else  this.challengesTable.set(challengesId[j], results.OrderItems[i].LU_TECH_UsedForMinAmount__c);
                            }
                        }
                    }
                }
                console.log('challenges présents sur les produits : ');
                console.log( this.challengesTable);

                // this.minimumAmount = results.LU_Total_Amount_For_Valid_Base__c;
                this.totalTTC = results.LU_Total_Amount_With_Taxes__c;
                this.commission = results.LU_Commission_Total_Amount__c;
                this.totalTVA = results.LU_Tax_Amount__c;
                this.loadProvisions = results.LU_Admin_Fees_Total_Amount__c;
                this.transportFees = results.LU_Transport_Fees__c;
                this.totalToPay = results.LU_Total_Amount_To_Pay__c; //results.TotalAmount + results.LU_Commission_Total_Amount__c + results.LU_Admin_Fees_Total_Amount__c + results.LU_Transport_Fees__c;

                if(this.challengesTable.size > 1) {
                    this.getContactChallenges();
                }
            }
            else if(this.isITA && results){
                if(results.Type !== "B2C"){
                    this.isOLA = false;
                }

                this.totalAmountToSell = results.Total_Amount_Total_Sell__c;
                this.personnalUseProduts = results.Total_Amount_Total_Personal_Use__c ;
                this.giftsAmount = results.LU_Total_Amount_Gifts__c;
                this.professionalUseAmount = results.LU_Total_Amount_Professional_Use__c;
                this.firstTotalAmount = this.totalAmountToSell + this.personnalUseProduts + this.professionalUseAmount;
                
                //SFT-1661, Added LU_Total_Amount_Material_Work__c to below query
                this.workMaterialAmount = results.LU_Total_Amount_Material_Work__c;
                this.commissions = results.LU_Commission_Total_Amount__c;
                //alert(results.LU_Fiscal_Payment_Total_Amount__c);
                this.fiscalPayment = results.LU_Fiscal_Payment_Total_Amount__c;

                
                this.transportFees = results.LU_Transport_Fees__c;
                
                // JJE 23/11/2022 - test sur les challenges IT - récupérer les order items non comptés de type Challenge
                this.amountChallenge = 0;
                for(let i in results.OrderItems){
                    if(results.OrderItems[i].PricebookEntry.LU_Offer_type__c == 'Challenge'){
                        this.amountChallenge += results.OrderItems[i].LU_Total_Price__c;
                    }
                }
                this.workMaterialAmount += this.amountChallenge;
                this.updateRebateDiscount(results);
                // this.totalAmount = this.firstTotalAmount - this.commissions - this.discountForPersonalUse + results.LU_Transport_Fees__c + this.giftsAmount + this.workMaterialAmount + this.fiscalPayment; 
            }


        })
        .catch(error => {
            console.log('>>>> error :');
            console.log(error);
        });
    }

    showMore(){
        if(this.displayMore){
            this.displayMore = false;
        }
        else{
            this.displayMore = true;
        }
    }
    showMoreIC(){
        console.log('lwc73 - display more IC' +  this.displayMoreIC);
        if(this.displayMoreIC){
            this.displayMoreIC = false;
        }
        else{
            this.displayMoreIC = true;
        }
    }

    getQueryParameters() {
        var params = {};
        var search = location.search.substring(1);

        if (search) {
            params = JSON.parse('{"' + search.replace(/&/g, '","').replace(/=/g, '":"') + '"}', (key, value) => {
                return key === "" ? value : decodeURIComponent(value)
            });
        }

        return params;
    }

    getContactChallenges(){
        getChallengesContact()
        .then(results => {
            console.log('lwc 73 - challenges en cours :');
            console.log(results);
            this.mapChallengesNames = [];
            let mapResults = new Map();
            let challengesIds = [];
            // Construire une liste d'ids et une map avec les results <IdExterne, Nom>
            for(let i in results){
                challengesIds.push(i);
                mapResults.set(i, results[i]);
            }
            // Récupérer dans une map le nom du challenge avec le montant associé
            for(let i in challengesIds){
                if(this.challengesTable.get(challengesIds[i])){
                    this.mapChallengesNames.push({
                        key : mapResults.get(challengesIds[i]), 
                        value : this.challengesTable.get(challengesIds[i])
                    });
                }
            }
        })
        .catch(error => {
            console.log('>>>> error :');
            console.log(error);
        });
    }

    updateRebateDiscount(order){
        rebateDiscountOnPersonalUse({newOrder: order})
        .then(results => {
            let values = results.split('##');
            console.log(values);
            this.discountForPersonalUse = values[0];
            this.discount = values[1];
            if(this.personnalUseProduts != null && this.personnalUseProduts > 0) this.displayDiscount = true;
            this.totalAmount = this.firstTotalAmount - this.commissions - this.discountForPersonalUse + order.LU_Transport_Fees__c + this.giftsAmount + this.workMaterialAmount + this.fiscalPayment; 
        })
        .catch(error => {
            console.log('>>>> error :');
            console.log(error);
        });
    }

}