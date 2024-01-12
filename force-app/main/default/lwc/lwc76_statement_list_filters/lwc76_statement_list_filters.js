import { LightningElement, track } from 'lwc';
import LogoBtn from '@salesforce/resourceUrl/Lu_Icons';

import { fireEvent } from 'c/pubsub';

import getUserCountry from '@salesforce/apex/lwc76_statement_list_filters_ctrl.getUserCountry';

import lbl_statementFilterTitle from '@salesforce/label/c.LU_Statement_Filter_Title';
import lbl_search from '@salesforce/label/c.LU_Order_Filter_Search';

import lbl_type from '@salesforce/label/c.LU_Statement_Filter_Type';
import lbl_type_order from '@salesforce/label/c.LU_Statement_Filter_Type_Order';
import lbl_type_regularisation from '@salesforce/label/c.LU_Statement_Filter_Type_Regularisation';
import lbl_type_credit from '@salesforce/label/c.LU_Statement_Filter_Type_Credit';
import lbl_type_pup from '@salesforce/label/c.LU_Statement_Filter_Type_Pup';

import lbl_forWho from '@salesforce/label/c.LU_Order_Filter_For_Who';
import lbl_forWho_me from '@salesforce/label/c.LU_Order_Filter_For_Who_me';
import lbl_forWho_myTeam from '@salesforce/label/c.LU_Order_Filter_For_Who_my_team';
import lbl_forWho_all from '@salesforce/label/c.LU_Order_Filter_For_Who_all';

export default class Lwc76_statement_list_filters extends LightningElement {
    iconUp = LogoBtn + '/icons/arrow-up.svg';
    iconDown = LogoBtn + '/icons/arrow-down.svg';

    @track userCountry;

    @track isFRA = false;
    @track isITA = false;

    @track statementType = [];
    @track forWho = [];

    @track displayStatementType = false;
    @track displayForWho = false;

    @track orderSearchedTerms = "";

    labels = {
        lbl_search,
        lbl_statementFilterTitle,
        lbl_type,
        lbl_type_order,
        lbl_type_regularisation,
        lbl_type_credit,
        lbl_type_pup,
        lbl_forWho,
        lbl_forWho_me,
        lbl_forWho_myTeam,
        lbl_forWho_all
    };

    connectedCallback(){

        getUserCountry()
            .then(results => {
                this.userCountry = results;
                if (results === 'FRA'){
                    this.isFRA = true;
                } 
                else if (results === 'ITA'){
                    this.isITA = true;
                }
            })
            .catch(error => {
                console.log('>>>> error :');
                console.log(error);
            });
    }

    sendFiltersFRA(){
        let filters = {
            statementType : this.statementType,
            forWho : this.forWho
        };

        fireEvent(this.pageRef, 'lwc76_statement_list_filters', JSON.stringify(filters));
    }

    updateDisplayStatementType(event){
        if(this.displayStatementType === true){
            this.displayStatementType = false;
            event.target.src = this.iconDown;
        }
        else{
            this.displayStatementType = true;
            event.target.src = this.iconUp;
        }
    }
    updateDisplayForWho(event){
        if(this.displayForWho === true){
            this.displayForWho = false;
            event.target.src = this.iconDown;
        }
        else{
            this.displayForWho = true;
            event.target.src = this.iconUp;
        }
    }

    get optionsStatementType(){
        return [
            this.labels.lbl_type_order,
            this.labels.lbl_type_regularisation,
            this.labels.lbl_type_credit,
            this.labels.lbl_type_pup
        ];
    }
    get optionsForWho(){
        return [
            this.labels.lbl_forWho_me,
            this.labels.lbl_forWho_myTeam,
            this.labels.lbl_forWho_all
        ];
    }

    updateStatementTypeValue(){
        this.statementType = [];
        let checkboxes = this.template.querySelectorAll(".statementType");

        for (let i = 0; i < checkboxes.length; i++) {
            if (checkboxes[i].checked === true) {
                this.statementType.push(checkboxes[i].value);
            }
        }

        this.sendFiltersFRA();
    }
    updateForWhoValue(){
        this.forWho = [];
        let checkboxes = this.template.querySelectorAll(".forWho");

        for (let i = 0; i < checkboxes.length; i++) {
            if (checkboxes[i].checked === true) {
                this.forWho.push(checkboxes[i].value);
            }
        }

        this.sendFiltersFRA();
    }

    updateOrderSearchedTerms(event){
        this.orderSearchedTerms = event.target.value;
        fireEvent(this.pageRef, 'lwc76_searchStatement', this.orderSearchedTerms);
    }
}