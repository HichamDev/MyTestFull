import { LightningElement, track } from 'lwc';
import LogoBtn from '@salesforce/resourceUrl/Lu_Icons';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'

import imageChallenge from '@salesforce/resourceUrl/LU_IC_Title';

import { registerListener, unregisterAllListeners, fireEvent } from 'c/pubsub';

/* APEX METHODS */
import getChallenges from '@salesforce/apex/Lwc85_incentive_challenge_ctrl.getChallenges';
import applyChallenges from '@salesforce/apex/Lwc85_incentive_challenge_ctrl.applyChallenges';
import getUserCountry from '@salesforce/apex/Lwc85_incentive_challenge_ctrl.getUserCountry';
import getIsChallengeActivated from '@salesforce/apex/Lwc85_incentive_challenge_ctrl.getIsChallengeActivated';

/* CUSTOM LABELS */
import lbl_incentive_and_challenge_activated from '@salesforce/label/c.LU_Incentive_And_Challenge_Activated';
import lbl_challenge_title from '@salesforce/label/c.LU_Challenge_Title';
import lbl_challenge_close_to_win from '@salesforce/label/c.LU_Challenge_Close_To_Win';
import lbl_challenge_won_message from '@salesforce/label/c.LU_Challenge_Won_Message';
import lbl_challenge_continue_shopping_button from '@salesforce/label/c.LU_Challenge_Continue_Shopping_Button';
import lbl_challenge_continue_next_button from '@salesforce/label/c.LU_Challenge_To_Checkout_Button';
import lbl_challenge_introduction from '@salesforce/label/c.LU_Challenge_Introduction';
import lbl_challenge_choose_gift_product from '@salesforce/label/c.LU_Challenge_Choose_Gift_Product';
import lbl_challenge_next_button from '@salesforce/label/c.LU_Challenge_Next_Button';
import lbl_challenge_back_button from '@salesforce/label/c.LU_Challenge_Back_Button';
import lbl_challenge_additional_informations from '@salesforce/label/c.LU_Challenge_Additional_Informations';
import lbl_challenges_selectionnes from '@salesforce/label/c.Challenges_selectionnes';

export default class Lwc85_incentive_challenge extends NavigationMixin(LightningElement) {

    imgGift = LogoBtn + '/icons/gift.png';

    @track isComponentDisplayed = false;

    @track orderId;

    @track l_challenges = [];
    @track l_giftChallWon = [];
    @track l_WebmasterChall = [];
    @track l_OfferChall = [];

    @track l_challengesWon = [];
    @track numberGiftSelected = 0;
    @track numberGifts;
    @track messageGifts1;
    @track messageGifts2;

    @track isDeliveryFree = false;

    @track isFRA = false;
    @track isITA = false;

    @track gotOrderTypeDone = false;
    @track isWebOnly = false;

    @track photoIDTitle;

    @track displayNextButton = false;

    labels = {
        lbl_incentive_and_challenge_activated,
        lbl_challenge_title,
        lbl_challenge_close_to_win,
        lbl_challenge_won_message,
        lbl_challenge_continue_shopping_button,
        lbl_challenge_continue_next_button,
        lbl_challenge_introduction,
        lbl_challenge_choose_gift_product,
        lbl_challenge_next_button,
        lbl_challenge_back_button,
        lbl_challenge_additional_informations,
        lbl_challenges_selectionnes
    };

    updateChallenge(event){
        this.setChallenge();
    }

    setChallenge() {
        getIsChallengeActivated()
        .then(isActivated => {
            if(isActivated === 'true'){
                let parameters = this.getQueryParameters();

                this.orderId = parameters.orderId;

                getChallenges({orderId : parameters.orderId})
                .then(results => {
                    let l_result = JSON.parse(results);
                    this.numberGifts = undefined;
                    this.l_giftChallWon = [];
                    this.l_giftChallWon = [];
                    this.l_challenges = [];
                    this.l_WebmasterChall = [];
                    this.l_OfferChall = [];
                    this.isDeliveryFree = false;

                    console.log('result challenges : ' + results);

                    if(l_result === null || l_result.length === 0){
                        fireEvent(this.pageRef, 'lwc85_incentive_challenge', this.isDeliveryFree);
                        return;
                    }

                    for(let i = 0; i < l_result.length; i++){
                        if(l_result[i].isWon && l_result[i].resultType === "GIFT" ){
                            if(l_result[i].l_child != null){
                                for(let j = 0; j < l_result[i].l_child.length; j++){
                                    if(l_result[i].l_child[j].imageUrl === "" || l_result[i].l_child[j].imageUrl === null || l_result[i].l_child[j].imageUrl === undefined){
                                        l_result[i].l_child[j].imageUrl = this.imgGift;
                                    }
                                    l_result[i].l_child[j].quantity = 0;
                                    console.log(l_result[i].l_child[j].numberOfArticle);
                                    //this.numberGifts = l_result[i].l_child[j].numberOfArticle;
                                    l_result[i].numberGift = l_result[i].l_child[j].numberOfArticle;
                                    l_result[i].numberGiftSelected = 0;
                                }
                                this.l_giftChallWon.push(l_result[i]);
                                this.l_challenges.push(l_result[i]);
                            }
                            console.log('test log 1');
                        }
                        else if(l_result[i].resultType === "WEBMASTER" && l_result[i].type === "PUSH"){
                            this.l_WebmasterChall.push(l_result[i]);
                            console.log('test log 2');
                        } else if(l_result[i].resultType === "OFFERS" && l_result[i].type === "PUSH"){
                            this.l_OfferChall.push(l_result[i]);
                            console.log('test log 3');
                        }
                        else{
                            this.l_challenges.push(l_result[i]);
                            this.l_OfferChall.push(l_result[i]);
                            //console.log('l_OfferChall ==> '+l_OfferChall);
                            console.log('test log 4');
                        }

                        if(l_result[i].isWon && l_result[i].resultType === "FREE_SHIPPING_FEE"){
                            this.isDeliveryFree = true;
                            console.log('test log 5');
                        }
                    }

                    this.isComponentDisplayed = true;
                })
                .catch(error => {
                    console.log('>>>> error lwc85: get challenges');
                    console.log(error);
                });

                getUserCountry()
                .then(results => {
                    if(results === 'FRA'){
                        this.isFRA = true;
                    }
                    else if(results === 'ITA'){
                        this.isITA = true;
                    }
                })
                .catch(error => {
                    console.log('>>>> error lwc16_orderhomebasket:');
                    console.log(error);
                });
            }
            else{
                this.isComponentDisplayed = false;
            fireEvent(this.pageRef, 'lwc85_incentive_challenge', this.isDeliveryFree);
            }
        })
        .catch(error => {
            console.log('>>>> error lwc16_orderhomebasket:');
            console.log(error);
        });
    }

    connectedCallback(){
        console.log("this.labels.lbl_incentive_and_challenge_activated");
        console.log(this.labels.lbl_incentive_and_challenge_activated);
        
        registerListener('updateChallenge', this.updateChallenge, this);

        //JJE 04/10/2023 - aller chercher label de messages gift
        const parts = this.labels.lbl_challenges_selectionnes.split('GIFSELECTED');

        // Vérifiez s'il y a au moins deux parties
        if (parts.length === 2) {
            this.messageGifts1 = parts[0]; // La partie avant GIFTNUMBER
            this.messageGifts2 = parts[1]; 
        }

        this.photoIDTitle = imageChallenge;
        this.setChallenge();
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

    handleGiftSelection(event){

        for(let k = 0; k < this.l_giftChallWon.length; k++){
            if(this.l_giftChallWon[k].externalId === event.target.dataset.value){

                if(event.target.checked){
                    this.l_giftChallWon[k].numberGiftSelected = this.l_giftChallWon[k].numberGiftSelected + 1;

                    //disable chall from same campaign for italy
                    if(this.isITA && this.l_giftChallWon[k].numberGiftSelected === 1 && this.l_giftChallWon[k].campaign){
                        for(let m = 0; m < this.l_giftChallWon.length; m++){
                            if(this.l_giftChallWon[m].externalId !== event.target.dataset.value && this.l_giftChallWon[k].campaign === this.l_giftChallWon[m].campaign){
                                for(let n = 0; n < this.l_giftChallWon[m].l_child.length; n++){
                                    this.l_giftChallWon[m].l_child[n].isDisabled = true;
                                }
                            }
                        }
                    }
                }
                else{
                    this.l_giftChallWon[k].numberGiftSelected = this.l_giftChallWon[k].numberGiftSelected - 1;

                    //enable chall from same campaign for italy
                    if(this.isITA && this.l_giftChallWon[k].numberGiftSelected === 0 && this.l_giftChallWon[k].campaign){
                        for(let m = 0; m < this.l_giftChallWon.length; m++){
                            if(this.l_giftChallWon[m].externalId !== event.target.dataset.value && this.l_giftChallWon[k].campaign === this.l_giftChallWon[m].campaign){
                                for(let n = 0; n < this.l_giftChallWon[m].l_child.length; n++){
                                    this.l_giftChallWon[m].l_child[n].isDisabled = false;
                                }
                            }
                        }
                    }
                }

                let maxBundleQuantity = this.l_giftChallWon[k].giftQuantity;
                let currentBundleQuantity = 0;

                for(let i = 0; i < this.l_giftChallWon[k].l_child.length; i++){
                    if(this.l_giftChallWon[k].l_child[i].id === event.target.dataset.id){
                        if(event.target.checked){
                            this.l_giftChallWon[k].l_child[i].quantity = 1;
                        }
                        else{
                            this.l_giftChallWon[k].l_child[i].quantity = 0;
                        }
                    }
                    currentBundleQuantity += this.l_giftChallWon[k].l_child[i].quantity;
                }
                if(maxBundleQuantity <= currentBundleQuantity){
                    for(let i = 0; i < this.l_giftChallWon[k].l_child.length; i++){
                        if(this.l_giftChallWon[k].l_child[i].quantity === 0){
                            this.l_giftChallWon[k].l_child[i].isDisabled = true;
                        }
                    }
                }
                else{
                    for(let i = 0; i < this.l_giftChallWon[k].l_child.length; i++){
                        this.l_giftChallWon[k].l_child[i].isDisabled = false;
                    }
                }
                break;
            }
        }
    }

    checkGiftChallengeToAllowNextStep(){

        for(let k = 0; k < this.l_giftChallWon.length; k++){
            let childQuantity = 0;

            if(this.l_giftChallWon[k].resultType === 'GIFT'){
                for(let i = 0; i < this.l_giftChallWon[k].l_child.length; i++){
                    childQuantity += this.l_giftChallWon[k].l_child[i].quantity;
                }
            } 

            if(this.l_giftChallWon[k].giftQuantity !== childQuantity){
                return false;
            }
        }

        return true;
    }

    toCheckout(){

        // T-1987 : pas d'obligation pour l'italie
        if(this.isFRA && !this.checkGiftChallengeToAllowNextStep()){
            let errorCadeau = new ShowToastEvent({
                title: 'Erreur cadeaux',
                message: 'Merci de selectionner vos cadeaux' ,
                variant: 'success'
            });
            this.dispatchEvent(errorCadeau);
            return;
        }

        for(let i = 0; i < this.l_challenges.length; i++){
            if(this.l_challenges[i].isWon && this.l_challenges[i].type !== "PUSH"){
                this.l_challengesWon.push(this.l_challenges[i]);
            }
        }
        this.l_challengesWon.push(this.l_giftChallWon);

        // T-1987 : pas d'obligation pour l'italie
        if(this.isFRA && this.numberGiftSelected != 0 && this.numberGiftSelected != this.numberGifts){ 
            let errorCadeau = new ShowToastEvent({
                title: 'Erreur cadeaux',
                message: 'Merci de sélectionner le nombre de cadeaux correspondant à l\'open set' ,
                variant: 'error'
            });
            this.dispatchEvent(errorCadeau);
        } 
        else{
            console.log(JSON.stringify(this.l_challengesWon));
            console.log(JSON.stringify(this.l_challengesWon.length));
    
            applyChallenges({l_challenges : this.l_challenges})
            .then(results => {
                this.isComponentDisplayed = false;
                fireEvent(this.pageRef, 'lwc85_incentive_challenge', this.isDeliveryFree);
            })
            .catch(error => {
                console.log('>>>> error lwc16_orderhomebasket:');
                console.log(error);
            });
        } 

    }

    handleBack(event) {

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.orderId,
                objectApiName: 'order',
                actionName: 'view'
            }
        });
    }

    gotOrderType(event) {
        console.log('gotOrderType ', event);
        console.log(event.detail);
        if(event.detail == 'B2B2C') this.isWebOnly = true;
        this.gotOrderTypeDone = true;
    }

    listenToChild(event){
        console.log('Fired up from : ' + event.detail.key1 + ' ' + event.detail.key2);
        fireEvent(this.pageRef, 'updateArticleCount', 21);
    }
}