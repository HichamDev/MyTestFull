public class AP55_ContactHandler {
    
    public static void createLeadFromContact(List<Contact> l_con){

        List<Lead> l_lead = new List<Lead>();

        for(Contact con : l_con){
            Lead l = new Lead(
                Email = con.Email,
                FirstName = con.FirstName,
                LastName = con.LastName,
                SubscribeMode__c = 'Online',
                Company = '[[Unknown]]',
                Devenez_Coach_URL_Formulaire__c = con.Devenez_Coach_URL_Formulaire__c,
                Coach_Referent__c = con.Coach_Referent__c,
                Pardot_Nb_soumission__c = con.Pardot_Nb_soumission__c,
                City = con.MailingCity,
                Country = con.MailingCountry,
                Latitude =  con.MailingLatitude,
                Longitude = con.MailingLongitude,
                PostalCode = con.MailingPostalCode,
                State = con.MailingState,
                Street = con.MailingStreet,
                Description = con.Description,
                OwnerId = con.OwnerId,
                LeadSource  = con.LeadSource,
                Phone = con.Phone,
                Title = con.Title,
                Salutation = con.Salutation
            );
            l_lead.add(l);
        }

        insert l_lead;
    }
}