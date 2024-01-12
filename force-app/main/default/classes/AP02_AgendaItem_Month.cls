public with sharing class AP02_AgendaItem_Month{

/* 
------------------------------------------------------------
-- - Name          : AP02_AgendaItem_Month
-- - Author        : ASE
-- - Description   : Class used to display day, month and year of the calender
--
-- Maintenance History: 
--
-- Date         Name   Version  Remarks 
-- -----------  ----  -------  -----------------------------
-- 23-AUG-2012  ASE    1.0    Initial version
-- 26-NOV-2012  NGO    1.1    Change the display in 3 categories and
                              Correction to make agenda display on several days
------------------------------------------------------------
*/      
    private List<Week> weeks; 
    
    public Map<Id,User> userMaps{get;set;}
    public Date firstDate; // always the first of the month
    private Date upperLeft; 
   
    public list<PER_Period__c> period{get;set;}

   
   public List<Date> getValidDateRange() { 
        system.debug('>>>>>>>>>>>>>>>>>>>>>>>9. Start of getValidDateRange: ');
        // return one date from the upper left, and one from the lower right
        List<Date> ret = new List<Date>();
        ret.add(upperLeft);
        ret.add(upperLeft.addDays(5*7) );
        system.debug('>>>>>>>>>>>>>>>>>>>>>>>ValidDateRange: '+ret);
        system.debug('>>>>>>>>>>>>>>>>>>>>>>>9. End of getValidDateRange: ');
        return ret;
        
        
    }
    
    public String getMonthName() { 
        
        system.debug('>>>>>>>>>>>>>>>>>>>>>>> 17. Start of getMonthName: ');
        
        String month = DateTime.newInstance(firstDate.year(),firstdate.month(),firstdate.day()).format('MMMM');
        
        system.debug(getMonthTranslation(month));
        
        return getMonthTranslation(month);
       
    } 
    
    private String getMonthTranslation(String month){


        if(month.equalsIgnoreCase(SHW_IBZ_Constants.MONTH_JANUARY)){ //january
            return system.label.AGI00017;
        }else if(month.equalsIgnoreCase(SHW_IBZ_Constants.MONTH_FEBRUARY)){ //febuary
            return system.label.AGI00018;
        }else if(month.equalsIgnoreCase(SHW_IBZ_Constants.MONTH_MARCH)){ //march
            return system.label.AGI00019;
        }else if(month.equalsIgnoreCase(SHW_IBZ_Constants.MONTH_APRIL)){ //april
            return system.label.AGI00020;
        }else if(month.equalsIgnoreCase(SHW_IBZ_Constants.MONTH_MAY)){ //may
            return system.label.AGI00021;
        }else if(month.equalsIgnoreCase(SHW_IBZ_Constants.MONTH_JUNE)){ // june
            return system.label.AGI00022;
        }else if(month.equalsIgnoreCase(SHW_IBZ_Constants.MONTH_JULY)){ //july
            return system.label.AGI00023;
        }else if(month.equalsIgnoreCase(SHW_IBZ_Constants.MONTH_AUGUST)){// august
            return system.label.AGI00024;
        }else if(month.equalsIgnoreCase(SHW_IBZ_Constants.MONTH_SEPTEMBER)){//september
            return system.label.AGI00025;
        }else if(month.equalsIgnoreCase(SHW_IBZ_Constants.MONTH_OCTOBER)){//october
            return system.label.AGI00026;
        }else if(month.equalsIgnoreCase(SHW_IBZ_Constants.MONTH_NOVEMBER)){ //november
            return system.label.AGI00027;
        }else if(month.equalsIgnoreCase(SHW_IBZ_Constants.MONTH_DECEMBER)){ //december
            return system.label.AGI00028;
        }else{
            return month;
        }
    
        
    }
    
    public String getYearName() { 
        system.debug('>>>>>>>>>>>>>>>>>>>>>>>18. Start of getYearName: ');
        system.debug(+DateTime.newInstance(
        firstDate.year(),firstdate.month(),firstdate.day()).format('yyyy'));
        return DateTime.newInstance(firstDate.year(),firstdate.month(),firstdate.day()).format('yyyy');
        //system.debug('>>>>>>>>>>>>>>>>>>>>>>>End of getYearName: ');
    } 
    
    public String[] getWeekdayNames() { 
        system.debug('>>>>>>>>>>>>>>>>>>>>>>>Start of getWeekdayNames: ');
        Date today = system.today().toStartOfWeek();
        system.debug('>>>>>>>>>>>>>>>>>>>>>>>today: '+today);
        
        DateTime dt = DateTime.newInstanceGmt(today.year(),today.month(),today.day());
        system.debug('>>>>>>>>>>>>>>>>>>>>>>>DateTime: '+dt);       
        list<String> ret = new list<String>();
        for(Integer i = 0; i < 7;i++) { 
            ret.add( dt.formatgmt('EEEE') );
            dt= dt.addDays(1);
        } 
        return ret;
        //system.debug('>>>>>>>>>>>>>>>>>>>>>>>WeekdayNames: '+ret);
        //system.debug('>>>>>>>>>>>>>>>>>>>>>>>End of getWeekdayNames: ');
    }
    
    public Date getfirstDate() {
        system.debug('>>>>>>>>>>>>>>>>>>>>>>>Start of getfirstDate: ');
         return firstDate; 
         //system.debug('>>>>>>>>>>>>>>>>>>>>>>>End of getfirstDate: ');
    } 


    public list<PER_Period__c> getPeriod() {
            
         return period; 
        
    }
    
    public AP02_AgendaItem_Month( Date value ) {
        
        system.debug('>>>>>>>>>>>>>>>>>>>>>>>3. Start of AP02_AgendaItem_Month: ');
        weeks = new List<Week>();
        system.debug('>>>>>>>>>>>>>>>>>>>>>>>weeks: '+weeks);   
        firstDate = value.toStartOfMonth(); //Monthly calender format
        system.debug('>>>>>>>>>>>>>>>>>>>>>>>4.firstDate: '+firstDate); 
        upperLeft = firstDate.toStartOfWeek();
        system.debug('>>>>>>>>>>>>>>>>>>>>>>>5. upperLeft: '+upperLeft);    
        Date tmp = upperLeft;
        
        Id recTypeBusinessPeriod = [select Id from RecordType 
                                        where DeveloperName =: system.label.PER00001
                                        and SobjectType=: SHW_IBZ_Constants.PER].Id;
                                        
                                        
        // select all business period
        list <PER_Period__c> period =  [    select  StartDate__c, Name, Id, EndDate__c, ColourCode__c 
                                            From PER_Period__c 
                                            where RecordTypeId  = :recTypeBusinessPeriod];  
                                            
        system.debug('>>>>>>>>>>>>>>>>>>period' +period);   
        
        for (Integer i = 0; i < 5; i++) { 
            system.debug('>>>>>>>>>>>>>>>>>>>>>>> 6.call public Week(Integer value,Date sunday,Integer month)');
            Week w = new Week(i+1,tmp,value.month(), period); //  6.call public Week(Integer value,Date sunday,Integer month)
            system.assert(w!=null); 
            this.weeks.add( w );
            tmp = tmp.addDays(7);
            system.debug('>>>>>>>>>>>>>>>>>>>>>>>8. tmp: '+tmp);
        }
        
        system.debug('>>>>>>>>>>>>>>>>>>>>>>>End of AP02_AgendaItem_Month: ');
    }
 
    public void setEvents(List<AGI_AgendaItem__c> ev, Map<Id, User> userMap) {
        string colorCode = system.label.AGI00004;
        
        this.userMaps = userMap;
        
        system.debug('>>>>>>>>>>>>>>>>>>>>>>>11. Start of setEvents: '); 

        // merge these events into the proper day
        system.debug('Start of for(AGI_AgendaItem__c e:ev)'); 
       
            
        system.debug('Start of for(Week w:weeks)'); 
        system.debug('Start of for(Week w:weeks)' + weeks); 
        for(Week w:weeks) { 
            system.debug('Start of for(Day c: w.getDays() )'); 
            system.debug('Start of for(Week w:weeks)' + w.days); 
            for(Day c: w.days ) { 
                system.debug('>>>>>>>>>>>>>>>>>>>>>>>getDays: '+ c); 
                system.debug('>>>>>>>>>>>>>>>>>>>>>>>getTheDay: '+ c.theDate); 
                for(AGI_AgendaItem__c e:ev) { 
                    
                    if (isBetweenDate(c.theDate, e.Start__c, e.End__c ))  {
                        system.debug('>>>>>>>>>>>>>>>>>>>>>>>12. add this event to this calendar date and call  public AP02_AgendaItem_Event(AGI_AgendaItem__c e)');  
                    
                        dispatchEvent(e, c);
                        
                    } 
                }
            } 
        } 

        system.debug('>>>>>>>>>>>>>>>>>>>>>>>End of setEvents: '); 
    }
    
    
    private void dispatchEvent(AGI_AgendaItem__c event, Day c){

        c.eventsTodayInvited.add(new AP02_AgendaItem_Event(event, getUserContactFromMap(event.OwnerId)));
            
    }
    
    private String getUserContactFromMap(Id owner){
        
        system.debug('>>>>>>>>>>>>>>>>>>>>>>> owner AgendaItem Id: '+owner);
        
        if(owner == Userinfo.getUserId()){

            return 'Me';
            
        }else if(userMaps != null && userMaps.containsKey(owner)){
            
            User user   = userMaps.get(owner);
        
            return user.Name;
            
            
        } else {
            
            return 'Manager';
        }
    }
    /*
    private boolean isReportsTo(AGI_AgendaItem__c event){
        
        if(event.TECH_IsReportsTo__c && isForConnectedUser(event)){
            
            return true;
            
        }else{
            
            return false;
            
        }

    }
    
    private boolean isInvited(AGI_AgendaItem__c event){
        
        if(!event.TECH_IsReportsTo__c && isForConnectedUser(event)){
            
            return true;
            
        }else{
            
            return false;
            
        }
    }
    
    private boolean isOwnerAgendaItem(AGI_AgendaItem__c event){
        
        if(event.TECH_Parent_AGI__c == null){
            
            return true;
            
        }else{
            
            return false;
            
        }
    }
    
    
    private boolean isForConnectedUser(AGI_AgendaItem__c event){
        
        if(event.TECH_Contact__c == getConnectedUserContact()){
            return true;
        }else{
            return false;
        }
    }
    
    private Id getConnectedUserContact(){
    
        return [select ContactId from user where id =:UserInfo.getUserId() limit 1][0].ContactId;
    }
    */
    private boolean isBetweenDate(Date day, DateTime startDate, DateTime endDate){
        
        if(day >=  startDate  && day <= endDate ){
            
            return true;
            
        } else if(startDate.date().isSameDay(day)){
            
            return true;
            
        }else{
            
            return false;
        }
  
        
    }
    
    public List<Week> getWeeks() { 
        system.debug('>>>>>>>>>>>>>>>>>>>>>>>14. Start of List<Week> getWeeks()'); 
        system.assert(weeks!=null,'could not create weeks list');
        system.debug('>>>>>>>>>>>>>>>>>>>>>>>getWeeks(): '+ this.weeks); 
        return this.weeks; 
    }
        

    /* 
     * helper classes to define a month in terms of week and day
     */
     
    public class Week {

        public List<Day> days {set; get;} 
        
        public Integer weekNumber {set; get;} 
        
        public Date startingDate {set; get;}  
              
         
        public Week () { 
            
            days = new List<Day>();     
        }
        
        public Week(Integer value,Date sunday,Integer month, list <PER_Period__c> period) {
              
            this();
            system.debug('>>>>>>>>>>>>>>>>>>>>>>>6. Start of constructor Week(): ');
            
            weekNumber = value;
            
            // the date that the first of this week is on sunday
            startingDate = sunday;
            
            Date tmp = startingDate;
            
                   
            for (Integer i = 0; i < 7; i++) {
                system.debug('>>>>>>>>>>>>>>>>>>>>>>> 7.public Day(Date value,Integer vmonth)');
                Day d = new Day( tmp,month,period); //7. call public Day(Date value,Integer vmonth)
                system.debug('>>>>>>>>>>>>>>>>>>>>>>>Day : '+d); 
                tmp = tmp.addDays(1);
                d.dayOfWeek = i+1;              
                days.add(d);
            }   
            system.debug('>>>>>>>>>>>>>>>>>>>>>>>End of constructor Week(): ')   ;  
         }
         

    }
    
    public class Day {
            
         
        public Date         theDate;
        
        // list of owned events for this date
        /*public List<AP02_AgendaItem_EventContact>  eventsToday {get; set;}*/
        
        
        // list of inivted events for this date
        public List<AP02_AgendaItem_Event>  eventsTodayInvited {get; set;} 
        
        // list of events for this date
        /*public List<AP02_AgendaItem_EventOthers>  eventsTodayOthers {get; set;} */ 
        
        
        public Integer      month, dayOfWeek;
        public String       formatedDate; // for the formated time  
        private String      cssclass = 'calActive';
        private String      bgcolor = 'none';
       
                    
       public Date getDate() { 
            system.debug('>>>>>>>>>>>>>>>>>>>>>>>18. Start of getDate(): '+theDate);
            return theDate;
        }
        
        public Integer getDayOfMonth() { 
            system.debug('>>>>>>>>>>>>>>>>>>>>>>>19. Start of getDayOfMonth(): ');
            return theDate.day(); 
        }
        
        public String getDayOfMonth2() { 
            system.debug('>>>>>>>>>>>>>>>>>>>>>>>Start of getDayOfMonth2(): ');
            
            if ( theDate.day() <= 9 ) 
                return '0'+theDate.day(); 
                
            return String.valueof( theDate.day()); 
        }
        
        public Integer getDayOfYear() { 
            system.debug('>>>>>>>>>>>>>>>>>>>>>>>Start of getDayOfYear(): ');
            return theDate.dayOfYear(); 
        }
       
        
        public String getFormatedDate() { 
            system.debug('>>>>>>>>>>>>>>>>>>>>>>>20. Start of getFormatedDate(): '+formatedDate);
            return formatedDate; 
        }
        public Integer getDayNumber() { 
            system.debug('>>>>>>>>>>>>>>>>>>>>>>>Start of getDayNumber(): '+dayOfWeek);
            return dayOfWeek; 
        }
        
        public String getCSSName() {
            return cssclass; 
        }
        
        public String getBgcolor(){
            return bgcolor;
        }
        
        public Day(Date value,Integer vmonth, list<PER_Period__c> period) { 
            theDate=value; month=vmonth;        
            formatedDate = '12 28 08';// time range..
            //9:00 AM - 1:00 PM
            /*eventsToday = new List<AP02_AgendaItem_EventContact>();  */
            
            eventsTodayInvited = new List<AP02_AgendaItem_Event>();
            
            /*eventsTodayOthers = new List<AP02_AgendaItem_EventOthers>();*/
            
            // three possible Inactive,Today,Active  
            if ( theDate.daysBetween(System.today()) == 0 ) 
                cssclass ='calToday';
            // define inactive, is the date in the month?
            if ( theDate.month() != month)
                cssclass = 'calInactive';
            
                
            if (period.size()>0){   
                for (PER_Period__c p:period) {  
                    if ( theDate >= p.StartDate__c && theDate <= p.EndDate__c)
                        bgcolor = p.ColourCode__c; 
                }
            }
            else {
                bgcolor = 'none';
            }   
           
            
               
        }
                    
    }
}