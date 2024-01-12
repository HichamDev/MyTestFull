/* eslint-disable no-console */
/* IMPORT */
import { LightningElement, track, wire, api } from 'lwc';

import FORM_FACTOR from '@salesforce/client/formFactor';

import LogoBtn from '@salesforce/resourceUrl/Lu_Icons';

import { CurrentPageReference } from 'lightning/navigation';
import { fireEvent, registerListener, unregisterAllListeners } from 'c/pubsub';

/* IMPORT METHODS APEX*/
import getCyclesInactiveFilters from '@salesforce/apex/LWC01_Listviewfilters_Ctrl.getFilterInactiveSince';
import getContactTypePicklistValue from '@salesforce/apex/LWC01_Listviewfilters_Ctrl.getContactTypePicklistValue';
import getEffectifDormantPicklistValue from '@salesforce/apex/LWC01_Listviewfilters_Ctrl.getEffectifDormantValues';
import getSegmentationPicklistValue from '@salesforce/apex/LWC01_Listviewfilters_Ctrl.getSegmentationPicklistValue';
import getNewCoachPicklistValue from '@salesforce/apex/LWC01_Listviewfilters_Ctrl.getNewCoachPicklistValue';
import getTypoPicklistValue from '@salesforce/apex/LWC01_Listviewfilters_Ctrl.getTypoPicklistValue';
import getUserCountry from '@salesforce/apex/LWC01_Listviewfilters_Ctrl.getUserCountry';
import getContact from '@salesforce/apex/LWC01_Listviewfilters_Ctrl.getCurrentContact';
import getDealerManagerSegmentationOptions from '@salesforce/apex/LWC01_Listviewfilters_Ctrl.getDealerManagerSegmentationOptions';

/* IMPORT OBJECT, FIELDS */

/* IMPORT RESOURCES */
import cssStatic from '@salesforce/resourceUrl/formFilterCSS';
import { loadStyle } from 'lightning/platformResourceLoader';

/* IMPORT CUSTOM LABELS */
import lbl_Effectif_Dormant from '@salesforce/label/c.Effectif_Dormant';
import lbl_ActiveTitle from '@salesforce/label/c.LU_List_Filters_Contact_Active';
import lbl_isActive from '@salesforce/label/c.LU_List_Filters_Contact_isActive';
import lbl_isInactive from '@salesforce/label/c.LU_List_Filters_Contact_isInactive';
import lbl_All from '@salesforce/label/c.LU_List_Filters_Contact_All';
import lbl_InactiveSince from '@salesforce/label/c.LU_List_Filters_Contact_InactiveTitle';
import lbl_AttivitaIn from '@salesforce/label/c.LU_List_Filters_Contact_AttivitaIn';
import lbl_InactiveSince6weeks from '@salesforce/label/c.LU_List_Filters_Contact_Inactive6weeksTitle';
import lbl_InactiveThisCycle from '@salesforce/label/c.LU_List_Filters_Contact_Inactive_ThisCycle';
import lbl_Inactive2Cycles from '@salesforce/label/c.LU_List_Filters_Contact_Inactive_2Cycles';
import lbl_Inactive3Cycles from '@salesforce/label/c.LU_List_Filters_Contact_Inactive_3Cycles';
import lbl_Inactive4Cycles from '@salesforce/label/c.LU_List_Filters_Contact_Inactive_4Cycles';
import lbl_Inactive5Cycles from '@salesforce/label/c.LU_List_Filters_Contact_Inactive_5Cycles';
import lbl_Inactive6Cycles from '@salesforce/label/c.LU_List_Filters_Contact_Inactive_6Cycles';
import lbl_Inactive7Cycles from '@salesforce/label/c.LU_List_Filters_Contact_Inactive_7Cycles';
import lbl_Inactive8Cycles from '@salesforce/label/c.LU_List_Filters_Contact_Inactive_8Cycles';
import lbl_Inactive9Cycles from '@salesforce/label/c.LU_List_Filters_Contact_Inactive_9Cycles';
import lbl_Filter from '@salesforce/label/c.LU_List_Filters_Action_Filter';
import lbl_Clear from '@salesforce/label/c.LU_List_Filters_Action_Clear';
import lbl_ContactType from '@salesforce/label/c.LU_TeamFilters_ContactType';
import lbl_BadDept from '@salesforce/label/c.LU_TeamFilters_BadDept';
import lbl_Segmentation from '@salesforce/label/c.LU_TeamFilters_Segmentation';
import lbl_NewCoach from '@salesforce/label/c.LU_TeamFilters_NewCoach';
import lbl_SeniorSegmentation from '@salesforce/label/c.LU_TeamFilters_SeniorSegmentation';
import lbl_Segmentation_2 from '@salesforce/label/c.LU_TeamFilters_Segmentation2';
import lbl_Typo from '@salesforce/label/c.LU_TeamFilters_Typo';
import lbl_TECH_Team from '@salesforce/label/c.LU_TECH_Contact_Team';
import lbl_FocusOnNewUsers from '@salesforce/label/c.LU_TeamFilters_Focus_On_New_Users';
import lbl_DealerManagerSegmentation from '@salesforce/label/c.LU_TeamFilters_Dealer_Manager_Segmentation';
import lbl_DealerManagerSegmentationIta from '@salesforce/label/c.LU_TeamFilters_Dealer_Manager_Segmentation_Ita';
import lbl_lastCycleRevenuesIta from '@salesforce/label/c.LU_TeamFilters_Last_Cycles_Revenues_Ita';
import lbl_Title from '@salesforce/label/c.LU_Contact_Filters_Title';
import lbl_latePayment from '@salesforce/label/c.LU_TeamFilters_LatePayment';
import lbl_OwnsEshop from '@salesforce/label/c.LU_Filtre_Owns_Eshop'; //added by Amine
import lbl_PostalCode from '@salesforce/label/c.LU_List_Filters_Contact_PostalCode';
import lbl_Potential from '@salesforce/label/c.LU_TeamFilters_Potential';

import lbl_bad_dept_label_true from '@salesforce/label/c.LU_ConFilt_BadDept_True';

import lbl_seg_ita_label_smile from '@salesforce/label/c.LU_ConFilt_Seg_Ita_Smile';
import lbl_seg_ita_label_consultant from '@salesforce/label/c.LU_ConFilt_Seg_Ita_Consultant';
import lbl_seg_ita_label_celebrity_club from '@salesforce/label/c.LU_ConFilt_Seg_Ita_Celebrity_Club';
import lbl_seg_ita_label_new_job_title from '@salesforce/label/c.LU_ConFilt_Seg_Ita_New_Job_Title';
import lbl_seg_ita_label_topazio from '@salesforce/label/c.LU_ConFilt_Seg_Ita_Topazio';
import lbl_seg_ita_label_zaffiro from '@salesforce/label/c.LU_ConFilt_Seg_Ita_Zaffiro';
import lbl_seg_ita_label_rubino from '@salesforce/label/c.LU_ConFilt_Seg_Ita_Rubino';
import lbl_seg_ita_label_diamante from '@salesforce/label/c.LU_ConFilt_Seg_Ita_Diamante';

import lbl_seg2_ita_label_capogruppo from '@salesforce/label/c.LU_ConFilt_Seg2_Ita_Capogruppo';
import lbl_seg2_ita_label_df from '@salesforce/label/c.LU_ConFilt_Seg2_Ita_DF';

import lbl_focus_new_ita_label_codificate from '@salesforce/label/c.LU_ConFilt_Focus_New_Ita_Codificate';
import lbl_focus_new_ita_label_nuova from '@salesforce/label/c.LU_ConFilt_Focus_New_Ita_Nuova';

import lbl_sales_mgt_segment_potential from '@salesforce/label/c.LU_Sales_Mgt_Segment_Ita_Potential';

import lbl_late_pay_ita_label_saldo from '@salesforce/label/c.LU_ConFilt_Late_Pay_Ita_Saldo';
import lbl_late_pay_ita_label_ordine from '@salesforce/label/c.LU_ConFilt_Late_Pay_Ita_Ordine';
import lbl_late_pay_ita_label_pratica from '@salesforce/label/c.LU_ConFilt_Late_Pay_Ita_Pratica';

import lbl_team_ita_label_pratica from '@salesforce/label/c.LU_ConFilt_Late_Pay_Ita_Pratica';

import lbl_order_by_placeholder from '@salesforce/label/c.LU_Contact_Order_By_Placeholder';
import lbl_order_alpha from '@salesforce/label/c.LU_Contact_Order_Alphabetical';
import lbl_order_lastorderdate from '@salesforce/label/c.LU_Contact_Order_LastOrderDate';
import lbl_order_job from '@salesforce/label/c.LU_Contact_Order_Job';
import lbl_order_typology from '@salesforce/label/c.LU_Contact_Order_Typology';

import lbl_dealerManagerItaZero from '@salesforce/label/c.LU_Dealer_Manager_Seg_Zero';
import lbl_dealerManagerItaNew from '@salesforce/label/c.LU_Dealer_Manager_Seg_New';
import lbl_dealerManagerItaSmart from '@salesforce/label/c.LU_Dealer_Manager_Seg_Smart';
import lbl_dealerManagerItaExpert from '@salesforce/label/c.LU_Dealer_Manager_Seg_Expert';
import lbl_dealerManagerItaMaster from '@salesforce/label/c.LU_Dealer_Manager_Seg_Master';
import lbl_dealerManagerItaTop from '@salesforce/label/c.LU_Dealer_Manager_Seg_Top';

import lbl_resigned from '@salesforce/label/c.LU_ListViewFilters_Resigned';
import lbl_non_resigned from '@salesforce/label/c.LU_ListViewFilters_NonResigned';

import lbl_senSegPros from '@salesforce/label/c.LU_SeniorSeg_Prospect';
import lbl_senSegNew from '@salesforce/label/c.LU_SeniorSeg_New';
import lbl_senSegIna4 from '@salesforce/label/c.LU_SeniorSeg_Inattiva4';
import lbl_senSegIna5 from '@salesforce/label/c.LU_SeniorSeg_Inattiva5';
import lbl_senSegIna6 from '@salesforce/label/c.LU_SeniorSeg_Inattiva6';
import lbl_senSegPersa from '@salesforce/label/c.LU_SeniorSeg_Persa';
import lbl_senSegSuperPersa from '@salesforce/label/c.LU_SeniorSeg_Super_Persa';
import lbl_senSegSpor1 from '@salesforce/label/c.LU_SeniorSeg_Sporadica1';
import lbl_senSegSpor2 from '@salesforce/label/c.LU_SeniorSeg_Sporadica2';
import lbl_senSegSpor3 from '@salesforce/label/c.LU_SeniorSeg_Sporadica3';
import lbl_senSegOccas32 from '@salesforce/label/c.LU_SeniorSeg_Occasionale32';
import lbl_senSegOccas31 from '@salesforce/label/c.LU_SeniorSeg_Occasionale31';
import lbl_senSegOccas21 from '@salesforce/label/c.LU_SeniorSeg_Occasionale21';
import lbl_senSegBronzo from '@salesforce/label/c.LU_SeniorSeg_Bronzo';
import lbl_senSegOro from '@salesforce/label/c.LU_SeniorSeg_Oro';
import lbl_senSegPlat from '@salesforce/label/c.LU_SeniorSeg_Platino';
import lbl_senSegArgen from '@salesforce/label/c.LU_SeniorSeg_Argento';
import lbl_senSegSuperStar from '@salesforce/label/c.LU_SeniorSeg_SuperStar';

import lbl_TECH_Customer from '@salesforce/label/c.LU_TECH_Contact_Customer';

import lbl_source from '@salesforce/label/c.LU_Contact_Source';
import lbl_source_Stanhome from '@salesforce/label/c.LU_Contact_Source_Stanhome';
import lbl_source_personal from '@salesforce/label/c.LU_Contact_Source_Personal';

export default class LWC01_ListView_Filters extends LightningElement {
    rebate_job_title = 'Stanlover';

    /* LABELS */
    labels = {
        lbl_Effectif_Dormant,
        lbl_ActiveTitle,
        lbl_isActive,
        lbl_isInactive,
        lbl_All,
        lbl_InactiveSince,
        lbl_AttivitaIn,
        lbl_InactiveSince6weeks,
        lbl_InactiveThisCycle,
        lbl_Inactive2Cycles,
        lbl_Inactive3Cycles,
        lbl_Inactive4Cycles,
        lbl_Inactive5Cycles,
        lbl_Inactive6Cycles,
        lbl_Inactive7Cycles,
        lbl_Inactive8Cycles,
        lbl_Inactive9Cycles,
        lbl_Filter,
        lbl_Clear,
        lbl_ContactType,
        lbl_BadDept,
        lbl_Segmentation,
        lbl_NewCoach,
        lbl_SeniorSegmentation,
        lbl_Typo,
        lbl_TECH_Team,
        lbl_Segmentation_2,
        lbl_FocusOnNewUsers,
        lbl_DealerManagerSegmentation,
        lbl_Title,
        lbl_bad_dept_label_true,
        lbl_seg_ita_label_smile,
        lbl_seg_ita_label_consultant,
        lbl_seg_ita_label_celebrity_club,
        lbl_seg_ita_label_new_job_title,
        lbl_seg_ita_label_topazio,
        lbl_seg_ita_label_zaffiro,
        lbl_seg_ita_label_rubino,
        lbl_seg_ita_label_diamante,
        lbl_seg2_ita_label_capogruppo,
        lbl_seg2_ita_label_df,
        lbl_focus_new_ita_label_codificate,
        lbl_focus_new_ita_label_nuova,
        lbl_late_pay_ita_label_saldo,
        lbl_late_pay_ita_label_ordine,
        lbl_late_pay_ita_label_pratica,
        lbl_order_by_placeholder,
        lbl_order_alpha,
        lbl_order_lastorderdate,
        lbl_order_job,
        lbl_order_typology,
        lbl_latePayment,
        lbl_dealerManagerItaZero,
        lbl_dealerManagerItaNew,
        lbl_dealerManagerItaSmart,
        lbl_dealerManagerItaExpert,
        lbl_dealerManagerItaMaster,
        lbl_dealerManagerItaTop,
        lbl_DealerManagerSegmentationIta,
        lbl_lastCycleRevenuesIta,
        lbl_OwnsEshop, //added by Amine
        lbl_PostalCode,
        lbl_resigned,
        lbl_non_resigned,
        lbl_TECH_Customer,
        lbl_source,
        lbl_source_Stanhome,
        lbl_source_personal,
        lbl_Potential,
        lbl_sales_mgt_segment_potential
    };

    btn_apply = LogoBtn + '/icons/icon_filterapply.PNG';
    btn_remove = LogoBtn + '/icons/icon_filterremove.PNG';
    btn_filters = LogoBtn + '/icons/btn_filters.png';
    icon_arrowup = LogoBtn + '/icons/arrow-up.PNG';
    icon_arrowdown = LogoBtn + '/icons/arrow-down.PNG';

    /* VARIABLES */
    @track contact;
    @track valueActive = [];
    @track valueInactive = [];
    @track valueEffectifdormant = [];
    @track valueInactiveITA = []; // ""
    @track valueInactive6weeks = [];
    @track valueAttivitaIn = [];
    @track valueBadDept = [];
    @track valueSegmentation = [];
    @track valueNewCoach = [];
    @track valueSource = [];
    @track valueSeniorSegmentation = [];
    @track valueActivPan = [];
    @track valueTypo = [];
    @track valueContactType = ['Tous'];
    @track valueDealerManagerSegmentation = [];
    @track valueDealerManagerSegmentationITA = [];  
    @track valueLatePayment = [];
    @track valueFocusOnNewUsers = [];
    @track valuePotential = [];
    @track valueSegmentation2 = [];
    @track valueTeamSelection = [];
    @track valueLastCycleRevenuesMin = [];
    @track valueLastCycleRevenuesMax = [];
    @track valueLastCycleRevenue = 0;
    @track valueOwnsEshop = [];  //added by Amine
    @track valuePostalCode = [];
    @track valueResigned = [];
    @track searchedAmountMin = "";
    @track searchedAmountMax = "";

    @track optionsInactive = [];
    @track optionsEffectifDormant = [];
    @track optionsAttivitaIn = [];
    @track optionsInactive6cycles = [];
    @track optionsContactType = [];
    @track optionsSegmentation = [];
    @track optionsNewCoach = [];
    @track optionsSource = [{label: lbl_source_personal, value: lbl_source_personal}, {label: lbl_source_Stanhome, value: lbl_source_Stanhome}];
    @track optionsTypo = [];
    @track otionOwnsEshop = []; //added by Amine
    @track optionsPostalCode = [];

    @track optionsDealerManagerSegmentationMap = [];

    @track typeContact = this.labels.lbl_TECH_Customer;
    @api typeContactMobile = '';
    @api showOnMobile = false;

    @track isFRA = false;

    @track displayFilters = false;
    @track displayClientSourceFilter = false;
    @api displayFiltersMobile = false;
    @api displaySort = false;
    @track displayPostalCodeFilter = false;

    // Accordeon filters
    @track typoOpen = false;
    @track newCoachOpen = false;
    @track segmentationOpen = false;
    @track sourceOpen = false;
    @track segmentOpen = false;
    @track seniorSegmentOpen = false;
    @track inactiveSinceOpen = false;
    @track effectifDormant = false;
    @track baddeptOpen = false;
    @track dmSegmentationOpen = false;
    @track inactiveSinceOpen2 = false;
    @track activeOpen = false;
    @track attivitaInOpen = false;
    @track OwnsEshopOpen = false; //added by Amine
    @track postalCodeOpen = false;
    @track lastRevenueOpen = false;
    @track segmentation2Open = false;
    
    @api valueOrderBy = "Alphabetical";
    @track valueOrderByLabel = lbl_order_alpha;

    /* INIT */
    @wire(CurrentPageReference) pageRef;
    connectedCallback() {

        for(let opt of this.optionsOrderBy){
            if(opt.key === this.valueOrderBy){
                this.valueOrderByLabel = opt.value;
            }
        }

        if(this.valueOrderBy === "Alphabetical"){
            this.valueOrderByLabel = this.labels.lbl_order_alpha;
        }
        else if(this.valueOrderBy === "Last order date"){
            this.valueOrderByLabel = this.labels.lbl_order_lastorderdate;
        }
        else if(this.valueOrderBy === "Job"){
            this.valueOrderByLabel = this.labels.lbl_order_job;
        }
        else if(this.valueOrderBy === "Activity Segment"){
            this.valueOrderByLabel = this.labels.lbl_order_segmentation_dealer;
        }
        else if(this.valueOrderBy !== "Typology"){
            this.valueOrderByLabel = this.labels.lbl_order_typology;
        }

        // TO HIDE THE COMPONENT ON MOBILE WHEN DISPLAYED ALONE//
        if(!this.showOnMobile && FORM_FACTOR === "Small"){
            this.template.querySelector(".filters").classList.add("hideOnMobile");
        }

        registerListener('contactTypeToggle', this.handleEvtContactTypeToggle, this);

        registerListener('l_contactsPostalCode', this.handleEvtListContactPostalCode, this);

        // Used on mobile
        console.log('xxxxxxxxxxxxxxx this.typeContact xxxxxxxxxxxxx', this.typeContact);
        console.log('xxxxxxxxxxxxxxx this.labels.lbl_TECH_Team xxxxxxxxxxxxx', this.labels.lbl_TECH_Team);
        if(this.typeContact === this.labels.lbl_TECH_Team){
            this.displayFilters = true;
        }
        else {
            this.displayFilters = false;
        }

        /* Load CSS */
        loadStyle(this, cssStatic + '/formFiltersCSS.css');

        getContact() 
        .then(contact => {
            this.contact = contact;

            if(this.contact.Title === "Zone Manager" || this.contact.Title === "Directrice de division" || this.contact.Title === "Direction de Région"){
                this.displayPostalCodeFilter = true;
            }
        })
        .catch(error => {
            console.log('>>>> error :');
            console.log(error);
        });

        getUserCountry()
            .then(results => {
                if (results === 'FRA'){
                    this.isFRA = true;
                } else {
                    // this.handleEvtContactTypeToggle(this.labels.lbl_TECH_Team);
                }
            })
            .catch(error => {
                console.log('>>>> error :');
                console.log(error);
            });

        // Get inactive filters
        getCyclesInactiveFilters()
            .then(results => {
                
                if (results) {
                    if (results.currentYear) {
                        this.optionsInactive = results.currentYear;
                    }
                    if (results.last4) {
                        console.log("last4");
                        console.log(results.last4);
                        this.optionsAttivitaIn = results.last4;
                    }
                    if (results.last6) {
                        this.optionsInactive6cycles = results.last6;
                    }
                    if (results.all) {
                        this.optionsInactiveAll = results.all;
                    }
                    if (results.fra) {
                        this.optionsInactive = results.fra;
                    }
                    
                }

            })
            .catch(error => {
                console.log('>>>> error :');
                console.log(error);
            });
            
        // Get inactive filters
        getContactTypePicklistValue()
            .then(results => {
                this.optionsContactType = results;
            })
            .catch(error => {
                console.log('>>>> error :');
                console.log(error);
            });

        // Get effectif dormant filters
        getEffectifDormantPicklistValue()
            .then(results => {
                this.optionsEffectifDormant = results;
            })
            .catch(error => {
                console.log('>>>> error :');
                console.log(error);
            });
        
        // Get Segmentation filters
        getSegmentationPicklistValue()
            .then(results => {
                this.optionsSegmentation = results; 
                console.log(' getSegmentationPicklistValue >>>> :' );
                console.log(this.optionsSegmentation );
            })
            .catch(error => {
                console.log('>>>> error :');
                console.log(error);
            });
        
        // Get New Coach filters
        getNewCoachPicklistValue()
        .then(results => {
            this.optionsNewCoach = results; 
        })
        .catch(error => {
            console.log('>>>> error :');
            console.log(error);
        });
        
        // Get Segmentation filters
        getTypoPicklistValue()
            .then(results => {
                this.optionsTypo = results;  
            })
            .catch(error => {
                console.log('>>>> error :');
                console.log(error);
            });

        getDealerManagerSegmentationOptions()
            .then(results => {
                
                this.optionsDealerManagerSegmentationMap = JSON.parse(results);
                
                this.optionsDealerManagerSegmentationMap = this.getJsonFromMap(JSON.parse(results));

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


    /* UI METHODS */

    get displayTeamFilter() {
      
        if (this.optionsDealerManagerSegmentationMap && this.optionsDealerManagerSegmentationMap.length > 0) {
            return (true);
        }
        return (false);
    }

    get displaySegmentation2() {
        
        if (this.contact) {

            if (this.contact.Title === 'Direttore di Filiale' || this.contact.Title === 'Star Leader' ||
                this.contact.Title === 'Direttore di ZONA' || this.contact.Title === 'Sales Area') {
                return (true);
            }

        }

        return (false);
    }

    get displayDealerManagerSegmentation() {

        if (this.contact) {
            if (this.contact.Title === 'Direttore di Filiale' || this.contact.Title === 'Star Leader' ||
                this.contact.Title === 'Direttore di ZONA' || this.contact.Title === 'Sales Area') {
                return (true);
            }
        }
        return (false);
    }

    get optionsDealerManagerSegmentationITA(){
        return [
            { label: this.labels.lbl_dealerManagerItaZero, value: this.labels.lbl_dealerManagerItaZero },
            { label: this.labels.lbl_dealerManagerItaNew, value: this.labels.lbl_dealerManagerItaNew },
            { label: this.labels.lbl_dealerManagerItaSmart, value: this.labels.lbl_dealerManagerItaSmart },
            { label: this.labels.lbl_dealerManagerItaExpert, value: this.labels.lbl_dealerManagerItaExpert },
            { label: this.labels.lbl_dealerManagerItaMaster, value: this.labels.lbl_dealerManagerItaMaster },
            { label: this.labels.lbl_dealerManagerItaTop, value: this.labels.lbl_dealerManagerItaTop }
        ];
    }

    get optionsOwnsEshop(){
            if(this.isFRA){
                return [
                { label: 'Oui', value: 'Oui' },
                { label: 'NON', value: 'Non' }];
            }else{
                return [
                    { label: 'SÌ', value: 'Oui' },
                    { label: 'No', value: 'Non' }];
            }
    }

    get optionsResigned(){
        return [
            { label: this.labels.lbl_non_resigned, value: this.labels.lbl_non_resigned },
            { label: this.labels.lbl_resigned, value: this.labels.lbl_resigned }
        ];
    }

    /* VALUE METHODS */

    getJsonFromMap(myMap){
        let regexLabel = /label=(.*?),/;// /(?<=label=)(.*?)(?=,)/;
        let regexValue = /value=(.*?)]/;// /(?<=value=)(.*?)(?=])/;
        let array = [];
        for(let key of Object.keys(myMap) ){
            
            let a = {
                label: regexLabel.exec(key)[1],
                value: regexValue.exec(key)[1],
                childs: this.getJsonFromMap(JSON.parse(myMap[key]))
            };
            array.push(a);
        }
        return array;
    }

    // Set Active filters values
    get optionsActive() {
        return [
            { label: this.labels.lbl_isActive, value: 'active' },
            { label: this.labels.lbl_isInactive, value: 'inactive' }
        ];
    }
    
    // Set bad dept filters values
    get optionsBadDept() {
        return [
            { label: 'CONTENTIEUX', value: "CONTENTIEUX" },
            { label: 'IMPAYE', value: "IMPAYE" }
        ];
    }

    // Set segmentation filters values
    // get optionsSegmentation() {
    //     return [
    //         { label: "Or", value: "OR" },
    //         { label: "Argent", value: "Argent" },
    //         { label: "Bronze", value: "Bronze" },
    //         { label: "Nouveau Coach < 1 an", value: "Nouveau Coach < 1 an" },
    //         { label: "Nouveau Coach < 6 mois", value: "Nouveau Coach < 6 mois" },
    //         { label: "Nouveau Coach < 1 mois", value: "Nouveau Coach < 1 mois" }
    //     ]; 
    // }

    get getIconTypo() {
        if (this.typoOpen) {
            return (this.icon_arrowup);
        }
        return (this.icon_arrowdown);
    }
    get getIconNewCoach() {
        if (this.newCoachOpen) {
            return (this.icon_arrowup);
        }
        return (this.icon_arrowdown);
    }
    get getOwnsEshop() {
        if (this.OwnsEshopOpen) {
            return (this.icon_arrowup);
        }
        return (this.icon_arrowdown);
    }
    get getIconSegmentation() {
        if (this.segmentationOpen) {
            return (this.icon_arrowup);
        }
        return (this.icon_arrowdown);
    }
    get getIconSegment() {
        if (this.segmentOpen) {
            return (this.icon_arrowup);
        }
        return (this.icon_arrowdown);
    }
    get getIconSeniorSegment() {
        if (this.seniorSegmentOpen) {
            return (this.icon_arrowup);
        }
        return (this.icon_arrowdown);
    }
    get getIconAttivitaIn() {
        if (this.attivitaInOpen) {
            return (this.icon_arrowup);
        }
        return (this.icon_arrowdown);
    }
    get getIconInactiveSince() {
        if (this.inactiveSinceOpen) {
            return (this.icon_arrowup);
        }
        return (this.icon_arrowdown);
    }
    get getIconEffectifDormant() {
        if (this.effectifDormant) {
            return (this.icon_arrowup);
        }
        return (this.icon_arrowdown);
    }
    get getIconInactiveSince2() {
        if (this.inactiveSinceOpen2) {
            return (this.icon_arrowup);
        }
        return (this.icon_arrowdown);
    }
    get getIconBadDept() {
        if (this.baddeptOpen) {
            return (this.icon_arrowup);
        }
        return (this.icon_arrowdown);
    }
    get getIconDMSegmentation() {
        if (this.dmSegmentationOpen) {
            return (this.icon_arrowup);
        }
        return (this.icon_arrowdown);
    }

    get optionSegmentationITA() {
        return [
            { label: this.labels.lbl_seg_ita_label_smile, value: "Smile" },
            { label: this.labels.lbl_seg_ita_label_consultant, value: "Sales Consultant" },
            { label: this.labels.lbl_seg_ita_label_new_job_title, value: 'Stanlover' }
            // { label: this.labels.lbl_seg_ita_label_topazio, value: "Topazio" },
            // { label: this.labels.lbl_seg_ita_label_zaffiro, value: "Zaffiro" },
            // { label: this.labels.lbl_seg_ita_label_rubino, value: "Rubino" },
            // { label: this.labels.lbl_seg_ita_label_diamante, value: "Diamante" }
        ]; 
    }

    get optionSeniorSegmentationITA() {
        return [
            { label: lbl_senSegPros, value: lbl_senSegPros },
            { label: lbl_senSegNew, value: lbl_senSegNew },
            { label: lbl_senSegIna4, value: lbl_senSegIna4 },
            { label: lbl_senSegIna5, value: lbl_senSegIna5 },
            { label: lbl_senSegIna6, value: lbl_senSegIna6 },
            { label: lbl_senSegPersa, value: lbl_senSegPersa },
            { label: lbl_senSegSuperPersa, value: lbl_senSegSuperPersa },
            { label: lbl_senSegSpor1, value: lbl_senSegSpor1 },
            { label: lbl_senSegSpor2, value: lbl_senSegSpor2 },
            { label: lbl_senSegSpor3, value: lbl_senSegSpor3 },
            { label: lbl_senSegOccas32, value: lbl_senSegOccas32 },
            { label: lbl_senSegOccas31, value: lbl_senSegOccas31 },
            { label: lbl_senSegOccas21, value: lbl_senSegOccas21 },
            { label: lbl_senSegBronzo, value: lbl_senSegBronzo },
            { label: lbl_senSegOro, value: lbl_senSegOro },
            { label: lbl_senSegPlat, value: lbl_senSegPlat },
            { label: lbl_senSegArgen, value: lbl_senSegArgen },
            { label: lbl_senSegSuperStar, value: lbl_senSegSuperStar }
        ];
    }

    get optionSegmentation2ITA() {

        let arrayOptions = [];

        arrayOptions.push({ label: this.labels.lbl_seg2_ita_label_capogruppo, value: "Capogruppo" });
        if (this.contact.Title === 'Direttore di ZONA' || this.contact.Title === 'Sales Area') {
            arrayOptions.push({ label: this.labels.lbl_seg2_ita_label_df, value: "DF" });
        }

        return (arrayOptions); 
    }

    get getFocusOnNewUsersITA() {
        return [
            { label: this.labels.lbl_focus_new_ita_label_codificate, value: "Codificate" },
            { label: this.labels.lbl_focus_new_ita_label_nuova, value: "Nuova" }
        ]; 
    }

    get getPotential() {
        return [
            { label: this.labels.lbl_sales_mgt_segment_potential, value: "Potential" }
        ]; 
    }

    get getLatePaymentITA() {
        return [
            { label: this.labels.lbl_late_pay_ita_label_saldo, value: "EXPIRED" },
            { label: this.labels.lbl_late_pay_ita_label_ordine, value: "BLOCKED" },
            { label: this.labels.lbl_late_pay_ita_label_pratica, value: "LEGAL" }
        ]; 
    }

    // get displayClientSourceFilter() {
    //      if(this.typeContact === this.labels.lbl_TECH_Customer) return true;
    //      return false;
    // }

    get isFiltersDisplayed() {
        if ( (this.displayFilters && !this.displayFiltersMobile) || (this.displayFiltersMobile && !this.displaySort) ) {
            return (true);
        }
        return (false);
    }

    get isBadDeptFilterDisplayed() {
        if (this.contact && this.contact.LU_TECH_Top_Manager__c) {
            return (true);
        }
        return (false);
    }

    get optionsOrderBy() {
        let options = [];
        if(this.isFRA){
            // options = [
            //     { label: this.labels.lbl_order_alpha , value: "Alphabetical" },
            //     { label: this.labels.lbl_order_lastorderdate, value: "Last order date" },
            //     { label: this.labels.lbl_order_job, value: "Job" },
            //     { label: this.labels.lbl_order_typology, value: "Typology" }
            // ];

            if(this.valueOrderBy !== "Alphabetical"){
                options.push({key:"Alphabetical", value:this.labels.lbl_order_alpha});
            }
            if(this.valueOrderBy !== "Last order date"){
                options.push({key:"Last order date", value:this.labels.lbl_order_lastorderdate});
            }
            if(this.valueOrderBy !== "Job"){
                options.push({key:"Job", value:this.labels.lbl_order_job});
            }
            if(this.valueOrderBy !== "Typology"){
                options.push({key:"Typology", value:this.labels.lbl_order_typology});
            }
        }
        else {
            // options = [
            //     { label: this.labels.lbl_order_alpha , value: "Alphabetical" },
            //     { label: this.labels.lbl_order_lastorderdate, value: "Last order date" },
            //     { label: this.labels.lbl_order_job, value: "Job" },
            //     // { label: this.labels.lbl_order_typology, value: "Typology" },
            //     { label: this.labels.lbl_order_segmentation_dealer, value: "Activity Segment" }
            // ];

            if(this.valueOrderBy !== "Alphabetical"){
                options.push({key:"Alphabetical", value:this.labels.lbl_order_alpha});
            }
            if(this.valueOrderBy !== "Last order date"){
                options.push({key:"Last order date", value:this.labels.lbl_order_lastorderdate});
            }
            if(this.valueOrderBy !== "Job"){
                options.push({key:"Job", value:this.labels.lbl_order_job});
            }
            if(this.valueOrderBy !== "Activity Segment"){
                options.push({key:"Activity Segment", value:this.labels.lbl_order_segmentation_dealer});
            }
        }
        return options;
    }

    /* EVENT METHODS */
    handleSliderLastCycleRevenuesChange(event) {
        this.valueLastCycleRevenue = event.target.value;
    }
    // Event - click on arrow of the filter active
    clickOnActive(event) {
        if (this.activeOpen) {
            this.activeOpen = false;
        } else {
            this.activeOpen = true;
        }
    }
    // Event - click on arrow of the filter attivita In
    clickOnAttivitaIn(event) {
        if (this.attivitaInOpen) {
            this.attivitaInOpen = false;
        } else {
            this.attivitaInOpen = true;
        }
    }
    // Event - click on arrow of postal code
    clickOnOwnsEshop(event) {
        if (this.OwnsEshopOpen) {
            this.OwnsEshopOpen = false;
        } else {
            this.OwnsEshopOpen = true;
        }
    }
    // Event - click on arrow of postal code
    clickOnPostalCode(event) {
        if (this.postalCodeOpen) {
            this.postalCodeOpen = false;
        } else {
            this.postalCodeOpen = true;
        }
    }
    // Event - click on arrow of the filter segmentation 2 italy
    clickOnSegmentation2(event) {
        if (this.segmentation2Open) {
            this.segmentation2Open = false;
        } else {
            this.segmentation2Open = true;
        }
    }
    // Event - click on arrow of the filter segmentation 2 italy
    clickOnSource(event) {
        if (this.sourceOpen) {
            this.sourceOpen = false;
        } else {
            this.sourceOpen = true;
        }
    }
    // Event - click on arrow of the filter last revenues
    clickOnLastRevenue(event) {
        if (this.lastRevenueOpen) {
            this.lastRevenueOpen = false;
        } else {
            this.lastRevenueOpen = true;
        }
    }
    // Event - click on arrow of the filter typo
    clickOnTypo(event) {
        if (this.typoOpen) {
            this.typoOpen = false;
        } else {
            this.typoOpen = true;
        }
    }
    clickOnNewCoach(event) {
        if (this.newCoachOpen) {
            this.newCoachOpen = false;
        } else {
            this.newCoachOpen = true;
        }
    }
    // Event - click on arrow of the filter segmentation
    clickOnSegmentation(event) {
        if (this.segmentationOpen) {
            this.segmentationOpen = false;
        } else {
            this.segmentationOpen = true;
        }
    }
    // Event - click on arrow of the filter segment
    clickOnSegment(event) {
        if (this.segmentOpen) {
            this.segmentOpen = false;
        } else {
            this.segmentOpen = true;
        }
    }
    // Event - click on arrow of the filter senior segment
    clickOnSeniorSegment(event) {
        if (this.seniorSegmentOpen) {
            this.seniorSegmentOpen = false;
        } else {
            this.seniorSegmentOpen = true;
        }
    }
    // Event - click on arrow of the filter inactive since
    clickOnInactiveSince(event) {
        if (this.inactiveSinceOpen) {
            this.inactiveSinceOpen = false;
        } else {
            this.inactiveSinceOpen = true;
        }
    }
    // Event - click on arrow of the filter effectif dormant
    clickOnEffectifDormant(event) {
        if (this.effectifDormant) {
            this.effectifDormant = false;
        } else {
            this.effectifDormant = true;
        }
    }
    // Event - click on arrow of the filter inactive since 2
    clickOnInactiveSince2(event) {
        if (this.inactiveSinceOpen2) {
            this.inactiveSinceOpen2 = false;
        } else {
            this.inactiveSinceOpen2 = true;
        }
    }
    // Event - click on arrow of the filter bad dept
    clickOnBadDept(event) {
        if (this.baddeptOpen) {
            this.baddeptOpen = false;
        } else {
            this.baddeptOpen = true;
        }
    }
    // Event - click on arrow of the filter DM Segmentation
    clickOnDMSegmentation(event) {
        if (this.dmSegmentationOpen) {
            this.dmSegmentationOpen = false;
        } else {
            this.dmSegmentationOpen = true;
        }
    }

    // Event - handle change on filter Inactive
    handleChangeInactive(event) {
        if(this.isFRA){
            this.valueInactive = event.detail.value; // Checkbox = already a list
        } else { // ITA
            this.valueInactive = [event.detail.value]; // Radio = so need to build a list
        }
    }
    // Event - handle change on filter Effectif dormant
    handleChangeEffectifDormant(event) {
        if(this.isFRA){
            this.valueEffectifdormant = event.detail.value; // Checkbox = already a list
        } 
        // else { // ITA
        //     this.valueEffectifdormant = [event.detail.value]; // Radio = so need to build a list
        // }
    }
    // Event - handle change on filter AttivitaIn
    handleChangeAttivitaIn(event) {
        this.valueAttivitaIn = event.detail.value; // Radio = so need to build a list
    }
    handleChangeOwnsEshop(event) {
        this.valueOwnsEshop = event.detail.value;
        console.log("this.valueOwnsEshop "+ this.valueOwnsEshop);
    }
    handleChangePostalCode(event) {
        this.valuePostalCode = event.detail.value;
    }
    handleChangeInactive6wees(event) {
        this.valueInactive6weeks = event.detail.value;
    }
    // Event - handle change on filter Active
    handleChangeActive(event) {
        this.valueActive = event.detail.value;
    }
    // Event - handle change on filter BadDept
    handleChangeBadDept(event) {
        this.valueBadDept = event.detail.value;
        console.log('this.valueBadDept', this.valueBadDept, event)
    }
    // Event - handle change on filter Segmentation
    handleChangeSegmentation(event) {
        this.valueSegmentation = event.detail.value;
    }
    handleChangeNewCoach(event) {
        this.valueNewCoach = event.detail.value;
    }
    handleChangeSource(event) {
        this.valueSource = event.detail.value;
        console.log(this.valueSource)
    }
    // Event - handle change on filter Segmentation
    handleChangeSeniorSegmentation(event) {
        this.valueSeniorSegmentation = event.detail.value;
    }
    // Event - handle change on filter Segmentation 2
    handleChangeSegmentation2(event) {
        this.valueSegmentation2 = event.detail.value;
    }
    // Event - handle change on filter ActivPan
    handleChangeActivPan(event) {
        this.valueActivPan = event.detail.value;
    }
    // Event - handle change on filter Typo
    handleChangeTypo(event) {
        this.valueTypo = event.detail.value;
    }
    // Event - handle change on filter Contact Type
    handleChangeContactType(event) {
        this.valueContactType = [event.target.value];
    }

    // Event - handle change on filter Focus on new users
    handleChangeTeamSelection(event) {
        this.valueTeamSelection = [event.target.value];
    }
    // Event - handle change on filter Late Payment
    handleChangeFocusOnNewUsers(event) {
        this.valueFocusOnNewUsers = [event.target.value];
    }
    // Event - handle change on filter Late Payment
    handleChangePotential(event) {
        this.valuePotential = [event.target.value];
    }
    // Event - handle change on filter Team Selection
    handleChangeLatePayment(event) {
        this.valueLatePayment = [event.target.value];
    }
    // Event - handle change on filter dealer Manager Segmentation
    handleChangeDealerManagerSegmentationn(event) {
        this.valueDealerManagerSegmentation = event.detail.value;
    }
    handleChangeDealerManagerSegmentationITA(event) {
        this.valueDealerManagerSegmentationITA = event.detail.value;
    }
    handleChangeSearchAmountMin(event){
        console.log(event.detail.value);
        this.searchedAmountMin = event.target.value;
    }
    handleChangeSearchAmountMax(event){
        this.searchedAmountMax = event.target.value;
    }
    
    handleEvtContactTypeToggle(value) {
        console.log('>>>> listviewfilters - handleEvtContactTypeToggle : ' + value);
        // Change the type of contact displayed
        if(value === this.labels.lbl_TECH_Team){
            this.displayFilters = true;
            this.displayClientSourceFilter = false;
        }
        else {
            this.displayFilters = false;
            this.displayClientSourceFilter = true;
        }

    }

    handleEvtListContactPostalCode(value){
        if(this.optionsPostalCode.length === 0){
            this.optionsPostalCode = value;
        }

        this.optionsPostalCode.sort((a, b) => (parseInt(a.label) > parseInt(b.label) ? 1 : -1));
    }


    // Event - click on filter button
    handleFilterClientSource(event){
        let filters = [];
        
        fireEvent(this.pageRef, 'applyFilterSource', this.valueSource);
    }
    
    handleFilter(event) {

        let filters = [];

        this.valueDealerManagerSegmentation = [];

        let checkboxes = this.template.querySelectorAll(".accordeonCheckbox");

        for (let i = 0 ; i < checkboxes.length ; i++) {
            if(checkboxes[i].checked === true){
                this.valueDealerManagerSegmentation.push(checkboxes[i].dataset.id);
            }
        }

        if(this.isFRA){
            filters = { inactive : this.valueInactive,
                effectifDormant : this.valueEffectifdormant, 
                active :this.valueActive,
                baddept : this.valueBadDept,
                segmentation : this.valueSegmentation,
                newCoach: this.valueNewCoach,
                activpan : this.valueActivPan,
                typo : this.valueTypo,
                dealerManagerSermentation : this.valueDealerManagerSegmentation,
                contacttype : this.valueContactType,
                OwnsEshop : Array.isArray(this.valueOwnsEshop) ? this.valueOwnsEshop : [this.valueOwnsEshop],  // added by Amine
                postalCode : this.valuePostalCode,
                resigned : this.valueResigned
            };
        }
        else{
            filters = { inactiveITA : this.valueInactive, //[this.valueInactive]
                attivitaIn : this.valueAttivitaIn,
                inactive6weeks : this.valueInactive6weeks,
                active :this.valueActive,
                segmentation : this.valueSegmentation,
                seniorSegmentation : this.valueSeniorSegmentation,
                OwnsEshop : Array.isArray(this.valueOwnsEshop) ? this.valueOwnsEshop : [this.valueOwnsEshop],  // added by Amine
                segmentation2 : this.valueSegmentation2,
                focusOnNewUsers : this.valueFocusOnNewUsers,
                potential : this.valuePotential,
                latePayment : this.valueLatePayment,
                teamSelection : this.valueTeamSelection,
                dealerManagerSermentation : this.valueDealerManagerSegmentation,
                dealerManagerSermentationITA : this.valueDealerManagerSegmentationITA,
                contacttype : this.valueContactType,
                lastCycleRevenues : [this.valueLastCycleRevenue],
                searchedAmountMin : [this.searchedAmountMin],
                searchedAmountMax : [this.searchedAmountMax]
            };
        }
        console.log('handleFilter', filters);
        // Send filters to parent
        // const selectedEvent = new CustomEvent('sendfilters', { detail: filters });
        // this.dispatchEvent(selectedEvent);
        fireEvent(this.pageRef, 'applyFilter', filters);
        console.log('Owns Eshop ==> '+ this.valueOwnsEshop);
        console.log(typeof(this.valueOwnsEshop));
    }

    // Event - click on clear button
    handleClear(event) {

        this.valueInactive = [];
        this.valueEffectifdormant = [];
        this.valueActive = [];
        this.valueBadDept = [];
        this.valueSegmentation = [];
        this.valueNewCoach = [];
        this.valueSeniorSegmentation = [];
        this.valueActivPan = [];
        this.valueTypo = [];
        this.valueContactType = ['Tous']; 
        this.valueInactive6weeks = [];
        this.valueInactiveITA = []; //""
        this.valueDealerManagerSegmentation = [];
        this.valueDealerManagerSegmentationITA = [];
        this.valueFocusOnNewUsers = [];
        this.valuePotential = [];
        this.valueLatePayment = [];
        this.lastCycleRevenuesMin = [];
        this.lastCycleRevenuesMax = [];
        this.valuePostalCode = [];
        this.valueResigned = [this.labels.lbl_non_resigned];
        this.valueSource = [];
        this.valueAttivitaIn = [];
        this.searchedAmountMin =  "";
        this.searchedAmountMax = "";


        // Reset picklist
        // Resigned filter : resignedFilterList
        if (this.template.querySelector('[data-id="resignedFilterList"]')) {
            this.template.querySelector('[data-id="resignedFilterList"]').value = this.labels.lbl_non_resigned;
        }
        // Contact type filter : contactTypeFilterList
        if (this.template.querySelector('[data-id="contactTypeFilterList"]')) {
            this.template.querySelector('[data-id="contactTypeFilterList"]').value = 'Tous';
        }
        // lastpayment filter : lastPaymentFilterList
        if (this.template.querySelector('[data-id="lastPaymentFilterList"]')) {
            this.template.querySelector('[data-id="lastPaymentFilterList"]').value = '--';
        }
        // focus on new user filter : FocusOnNewUserFilterList
        if (this.template.querySelector('[data-id="FocusOnNewUserFilterList"]')) {
            this.template.querySelector('[data-id="FocusOnNewUserFilterList"]').value = '--';
        }
        // focus on new user filter : PotentialFilterList
        if (this.template.querySelector('[data-id="PotentialFilterList"]')) {
            this.template.querySelector('[data-id="PotentialFilterList"]').value = '--';
        }


        // Clean the checkboxes
        let checkboxes = this.template.querySelectorAll(".accordeonCheckbox");
        for (let i = 0; i < checkboxes.length; i++) {
            checkboxes[i].checked = false;
        }

        this.handleFilter(event); 

    }
    
    handleChangeOrderBy(event) {
        this.valueOrderBy = event.target.value;
        for(let opt of this.optionsOrderBy){
            if(opt.key === this.valueOrderBy){
                this.valueOrderByLabel = opt.value;
            }
        }

        fireEvent(this.pageRef, 'changeOrderBy', this.valueOrderBy);
    }

    handleChangeLastCycleRevenuesMin(event) {
        this.valueLastCycleRevenuesMin = [event.target.value + ""];
    }

    handleChangeLastCycleRevenuesMax(event) {
        this.valueLastCycleRevenuesMax = [event.target.value + ""];
    }

    handleChangeResigned(event){
        this.valueResigned = [event.target.value];
    }
}