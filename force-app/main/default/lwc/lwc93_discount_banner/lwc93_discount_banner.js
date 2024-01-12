import { LightningElement, wire } from 'lwc';
import Id from '@salesforce/user/Id';

/* APEX METHODS */
import getContactFromUser from '@salesforce/apex/lwc93_discount_banner_ctrl.getContactFromUser';
import getOrderRuleDiscount from '@salesforce/apex/lwc93_discount_banner_ctrl.getOrderRuleDiscount';


import lbl_Discount_eligiblediscount from '@salesforce/label/c.Discount_eligiblediscount';
import lbl_Discount_forOrdersHigher from '@salesforce/label/c.Discount_forOrdersHigher';
import lbl_Discount_forOrdersBetwen from '@salesforce/label/c.Discount_forOrdersBetwen';
import lbl_WAT00032 from '@salesforce/label/c.WAT00032';



export default class Lwc93_discount_banner extends LightningElement {
    userId = Id;
    title;
    bannerVisible = true;
    orderRules = [];
    isEligible = false;

    labels = {
        lbl_Discount_eligiblediscount,
        lbl_Discount_forOrdersHigher,
        lbl_Discount_forOrdersBetwen,
        lbl_WAT00032
    }
    
    connectedCallback() {

        getContactFromUser({userId : this.userId})
        .then(result => {
            if (result != null) {
                this.title = result.Title;
                this.bannerVisible = result.AccountCountryCode__c==='ITA';
            } else {
                console.log('result is null');
            }
        })   
        .catch(error => {
            console.log('>>>> error lwc93_discount_banner:');
            console.log(error);
        });

        getOrderRuleDiscount({userId : this.userId})
        .then(result => {
            
            if (result != null) {
                console.log(result.length)
                this.isEligible = result.length>0?true:false;
                console.log(this.isEligible)
                result.forEach((orderRule,index) => {
                    this.orderRules[index] = orderRule;
                    console.log('criteria 1', orderRule.LU_Criteria_Value_1__c);
                    console.log('criteria 2', orderRule.LU_Criteria_Value_2__c);
                    this.orderRules[index].hasInferiorCriteria = orderRule.LU_Criteria_Value_1__c !== undefined;
                    this.orderRules[index].hasSuperiorCriteria = orderRule.LU_Criteria_Value_2__c !== undefined;
                });
                console.log(this.orderRules);
            } else {
                console.log('result is null');
            }
            
        })
        .catch(error => {
            console.error('>>>> error lwc93_discount_banner:');
            console.error(error);
        });
 

        
    }  
    
}