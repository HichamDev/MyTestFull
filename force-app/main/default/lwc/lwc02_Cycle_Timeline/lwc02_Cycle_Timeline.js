/* IMPORT */
import { LightningElement, track, wire } from 'lwc';

/* IMPORT FIELDS */
import USER_ID from '@salesforce/user/Id';

/* IMPORT METHODS */
import getcurrentcycle from '@salesforce/apex/lwc02_Timeline_Ctrl.getTimelineInformation';

/* IMPORT CUSTOM LABELS */
import lbl_Days from '@salesforce/label/c.LU_Cycle_Timeline_Days';
import lbl_Day from '@salesforce/label/c.LU_Cycle_Timeline_Day';
import lbl_Hours from '@salesforce/label/c.LU_Cycle_Timeline_Hours';
import lbl_Hour from '@salesforce/label/c.LU_Cycle_Timeline_Hour';
import lbl_Minutes from '@salesforce/label/c.LU_Cycle_Timeline_Minutes';
import lbl_Minute from '@salesforce/label/c.LU_Cycle_Timeline_Minute';
import lbl_RemainingTime from '@salesforce/label/c.LU_Cycle_Timeline_RemainingTime';
import lbl_FlagGreen from '@salesforce/label/c.LU_Cycle_Flag_Green';
import lbl_FlagOrange from '@salesforce/label/c.LU_Cycle_Flag_Orange';
import lbl_FlagRed from '@salesforce/label/c.LU_Cycle_Flag_Red';

export default class Lwc02_Cycle_Timeline extends LightningElement {

    /* LABELS */
    label = { 
        lbl_Days,
        lbl_Day,
        lbl_Hours,
        lbl_Hour,
        lbl_Minutes,
        lbl_Minute,
        lbl_RemainingTime,
        lbl_FlagGreen,
        lbl_FlagOrange,
        lbl_FlagRed
    };

    /* VARIABLES */
    userId = USER_ID;
    @track cycle;
    @track error;

    /* WIRE METHODS */
    @wire(getcurrentcycle, { userId : '$userId' })
    wiredCurrentCycle({ error, data }) {
        if (data) {
            this.cycle = data;
        } else if (error) {
            this.error = error;
        }
    }

    get progressPct() {
        return (100 - ((this.cycle.daysleft / this.cycle.nbDaysInCycle) * 100));
    }


    get getCSSProgressBar() {
        const cssRounded = ';border-radius: 16px !important;';
        if (this.cycle.daysleft > 10) {
            return ('background: #02BC48 !important' + cssRounded);
        }
        if (this.cycle.daysleft > 4 && this.cycle.daysleft <= 10) {
            return ('background: #F28801 !important' + cssRounded);
        }
        return ('background: #CF3918 !important' + cssRounded);
    }

    get daysToDisplay() {
        return (this.cycle.daysleft > 0);
    }

    get txtDays() {
        if (this.cycle.daysleft === 1) {
            return (lbl_Day);
        }
        return (lbl_Days);
    }

    get hoursToDisplay() {
        return (this.cycle.hoursleft > 0);
    }

    get txtHours() {
        if (this.cycle.hoursleft === 1) {
            return (lbl_Hour);
        }
        return (lbl_Hours);
    }

    get minutesToDisplay() {
        return (this.cycle.minutesleft > 0);
    }

    get txtMinutes() {
        if (this.cycle.minutesleft === 1) {
            return (lbl_Minute);
        }
        return (lbl_Minutes);
    }

    get isGreenFlag() {
        if (this.cycle.daysleft > 10) {
            return (true);
        }
        return (false);
    }

    get isOrangeFlag() {
        if (this.cycle.daysleft > 4 && this.cycle.daysleft <= 10) {
            return (true);
        }
        return (false);
    }

    get isRedFlag() {
        if (this.cycle.daysleft <= 4) {
            return (true);
        }
        return (false);
    }

    get isIta() {
        if (this.cycle.country == 'ITA') {
            return (true);
        }
        return (false);
    }

    get isFra() {
        if (this.cycle.country == 'FRA') {
            return (true);
        }
        return (false);
    }

}