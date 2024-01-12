import { LightningElement, track } from 'lwc';

import { registerListener, unregisterAllListeners } from 'c/pubsub';

/* APEX */
import getProducts from '@salesforce/apex/lwc60_orderhome_total_ctrl.getProducts';
import getUserCountry from '@salesforce/apex/lwc60_orderhome_total_ctrl.getUserCountry';
import getContactCurrentUser from '@salesforce/apex/lwc60_orderhome_total_ctrl.getCurrentContact';

import lbl_minimumAmount from '@salesforce/label/c.LU_Orderhometotal_Minimum_Amount';
import lbl_htAmount from '@salesforce/label/c.LU_Orderhometotal_HT_Amount';
import lbl_ttcAmount from '@salesforce/label/c.LU_Orderhometotal_TTC_Amount';
import lbl_htStanhome from '@salesforce/label/c.LU_Orderhometotal_HT_Stanhome';
import lbl_htFamilyExpert from '@salesforce/label/c.LU_Orderhometotal_HT_FamilyExpert';
import lbl_htKiotis from '@salesforce/label/c.LU_Orderhometotal_HT_Kiotis';
import lbl_htFlormar from '@salesforce/label/c.LU_Orderhometotal_HT_Flormar';
import lbl_htOthers from '@salesforce/label/c.LU_Orderhometotal_HT_Others';

import lbl_totalAmountToSell from '@salesforce/label/c.LU_Ordertotal_Total_Amount_To_Sell';
import lbl_personnalUseProduts from '@salesforce/label/c.LU_Orderhometotal_Personal_Use_Product';
import lbl_giftsAmount from '@salesforce/label/c.LU_Ordertotal_Gifts_Amount';
import lbl_ProfessionalUseAmount from '@salesforce/label/c.LU_OrderTotal_ProfesionnalUse_Amount';
import lbl_OrderTotal_WorkMaterial from '@salesforce/label/c.LU_OrderTotal_WorkMaterial';

import lbl_firstTotalAmount from '@salesforce/label/c.LU_Ordertotal_First_Total_Amount';
import lbl_commissions from '@salesforce/label/c.LU_Ordertotal_Commissions';
import lbl_discountForPersonalUse from '@salesforce/label/c.LU_Ordertotal_DiscountP_Personal_Use';
import lbl_totalAmount from '@salesforce/label/c.LU_Ordertotal_Total_Amount';
import lbl_Total_Label from '@salesforce/label/c.LU_Ordertotal_Label_Total';
import lbl_HT from '@salesforce/label/c.LU_Ordertotal_HT';
import lbl_TTC from '@salesforce/label/c.LU_Ordertotal_TTC';
import lbl_minimum from '@salesforce/label/c.LU_Orderhometotal_minimum_amount_lbl';

import lbl_Offer_Type_Gift from '@salesforce/label/c.LU_Offer_Type_Gift';
import lbl_Offer_Type_ProfessionalUse from '@salesforce/label/c.LU_Offer_Type_ProfessionalUse';
import lbl_Offer_Type_PersonalUse from '@salesforce/label/c.LU_Offer_Type_PersonalUse';
import lbl_Offer_Discount_PersonalUse from '@salesforce/label/c.LU_Offer_Discount_PersonalUse';

export default class Lwc60_orderhome_total extends LightningElement {

    labels = {
        lbl_minimumAmount,
        lbl_htAmount,
        lbl_ttcAmount,
        lbl_htStanhome,
        lbl_htFamilyExpert,
        lbl_htKiotis,
        lbl_htFlormar,
        lbl_htOthers,
        lbl_totalAmountToSell,
        lbl_personnalUseProduts,
        lbl_giftsAmount,
        lbl_firstTotalAmount,
        lbl_commissions,
        lbl_discountForPersonalUse,
        lbl_totalAmount,
        lbl_Total_Label,
        lbl_HT,
        lbl_TTC,
        lbl_ProfessionalUseAmount,
        lbl_minimum,
        lbl_OrderTotal_WorkMaterial
    }

    @track isFRA = false;
    @track isITA = false;

    @track displayMore = false;
    @track contact = null;
    @track contactBasket = null;

    // France
    @track minimumAmount = 0;
    @track totalHT = 0;
    @track totalTTC = 0;
    @track htStanhome = 0;
    @track htFamilyExpert = 0;
    @track htKiotis = 0;
    @track htFlormar = 0;
    @track htOthers = 0;

    // Italy
    @track totalAmountToSell = 0;
    @track personalUseProducts = 0;
    @track giftsAmount = 0;
    @track firstTotalAmount = 0;
    @track commissions = 0;
    @track discountForPersonalUse = 0;
    @track totalAmount = 0;
    @track professionalUseAmount = 0;
    @track workMaterialAmount = 0;

    /* INIT */
    connectedCallback() {

        registerListener('updatedBasket', this.updateTotal, this);
        registerListener('OrderHomeResetTotals', this.resetTotals, this);
        registerListener('orderHomeContactSelected', this.updateBasketForWho, this);
        registerListener('lwc16_addBasket', this.resetTotals, this);

        getUserCountry()
        .then(results => {
            if(results === "FRA"){
                this.isFRA = true;
            }
            else if(results === "ITA"){
                this.isITA = true;
            }
        })
        .catch(error => {
            console.log('>>>> error :');
            console.log(error);
        });

        getContactCurrentUser()
        .then(results => {
            this.contact = results;
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

    updateTotal(event) {

        let l_id = [];

        if (event) {
            console.log('event:');
            console.log(event);
            for (let [k, v] of event){
                l_id.push(k);
            }

            console.log("event");
            console.log(l_id);

            getProducts({l_idPbe : l_id})
            .then(results => {

                console.log(results);

                if(results){
                    // France
                    if(this.isFRA){
                        // Reset the totals
                        this.minimumAmount = 0;
                        this.totalHT = 0;
                        this.totalTTC = 0;
                        this.htStanhome = 0;
                        this.htFamilyExpert = 0;
                        this.htKiotis = 0;
                        this.htFlormar = 0;
                        this.htOthers = 0;

                        for (let pbe of results) {
                            console.log('>> LOOOP');
                            console.log(pbe);

                            if (pbe.LU_Valid_For_Total_Amount_Base__c) {
                                this.minimumAmount += pbe.UnitPrice * event.get(pbe.Id).quantity;
                            }
                            this.totalHT += pbe.UnitPrice * event.get(pbe.Id).quantity;
                            this.totalTTC += pbe.LU_Public_Price__c * event.get(pbe.Id).quantity;
                            
                            if (pbe.Product2.LU_Brand_Territory__c === "Home Care") {
                                this.htStanhome += pbe.UnitPrice * event.get(pbe.Id).quantity;
                            } else if (pbe.Product2.LU_Brand_Territory__c === "Family Care") {
                                this.htFamilyExpert += pbe.UnitPrice * event.get(pbe.Id).quantity;
                            } else if (pbe.Product2.LU_Brand__c === "Kiotis") {
                                this.htKiotis += pbe.UnitPrice * event.get(pbe.Id).quantity;
                            } else if (pbe.Product2.LU_Brand__c === "Flormar") {
                                this.htFlormar += pbe.UnitPrice * event.get(pbe.Id).quantity;
                            } else {
                                this.htOthers += pbe.UnitPrice * event.get(pbe.Id).quantity;
                            }
                        }
                    }
                    if (this.isITA) {
                        // Reset the totals
                        this.giftsAmount = 0;
                        this.personalUseProducts = 0;
                        this.totalAmountToSell = 0;
                        this.firstTotalAmount = 0;
                        this.discountForPersonalUse = 0;
                        this.totalAmount = 0;
                        this.professionalUseAmount = 0;
                        this.workMaterialAmount = 0;

                        for (let pbe of results) {
                            console.log('>> LOOP');
                            console.log(pbe);

                            // Depending on the offer type, goes to different subtotals
                            if (pbe.LU_Offer_type__c === lbl_Offer_Type_Gift) { // Gift
                                this.giftsAmount += pbe.UnitPrice * event.get(pbe.Id).quantity;
                            } else if (pbe.LU_Offer_type__c == lbl_Offer_Type_ProfessionalUse && pbe.Product2.LU_Type__c == 'Product') { // SFT- 1661, Added condition pbe.Product2.LU_Type__c == 'Product'
                                this.professionalUseAmount += pbe.UnitPrice * event.get(pbe.Id).quantity;
                            } else if (pbe.LU_Offer_type__c == lbl_Offer_Type_ProfessionalUse && pbe.Product2.LU_Type__c != 'Product') { // SFT- 1661, Added condition pbe.Product2.LU_Type__c != 'Product'
                                this.workMaterialAmount += pbe.UnitPrice * event.get(pbe.Id).quantity;
                            } else if (pbe.LU_Offer_type__c == lbl_Offer_Type_PersonalUse) { // PERSONAL USE
                                if (pbe.Discount_Type__c == lbl_Offer_Discount_PersonalUse) {
                                    // this.discountForPersonalUse += event.get(pbe.Id).quantity * (pbe.LU_Dealer_Price__c - pbe.UnitPrice);
                                    this.personalUseProducts += pbe.LU_Dealer_Price__c * event.get(pbe.Id).quantity;
                                } else {
                                    this.personalUseProducts += pbe.UnitPrice * event.get(pbe.Id).quantity;
                                }
                            } else { // If sell
                                this.totalAmountToSell += pbe.UnitPrice * event.get(pbe.Id).quantity;
                            }
                        }

                        // Calculate totals
                        this.firstTotalAmount = this.totalAmountToSell + this.personalUseProducts + this.professionalUseAmount;
                        // this.discountForPersonalUse = this.personalUseProducts;
                        this.totalAmount = (this.firstTotalAmount - this.discountForPersonalUse) + this.giftsAmount + this.workMaterialAmount;

                    }
                }
            })
            .catch(error => {
                console.log('>>>> error :');
                console.log(error);
            });
        }
    }

    resetTotals(event) {

        this.giftsAmount = 0;
        this.personalUseProducts = 0;
        this.totalAmountToSell = 0;
        this.firstTotalAmount = 0;
        this.discountForPersonalUse = 0;
        this.totalAmount = 0;

        this.minimumAmount = 0;
        this.totalHT = 0;
        this.totalTTC = 0;
        this.htStanhome = 0;
        this.htFamilyExpert = 0;
        this.htKiotis = 0;
        this.htFlormar = 0;
        this.htOthers = 0;

    }

    updateBasketForWho(event) {
        this.contactBasket = event.contact;
    }

    showMore(){
        if(this.displayMore){
            this.displayMore = false;
        }
        else{
            this.displayMore = true;
        }
    }
}