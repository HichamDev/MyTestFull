public class lwc44_myprofile_changetodirectdebit_ctrl {

    @AuraEnabled
    public static Boolean getIsItalianDirettore() {

        List<String> l_direttoreName = new list<String> {'Direttore Nazionale', 'Direttore di Filiale', 'Direttore di Zona', 'Sales Area', 'Star Leader'};

        Contact con = AP1002_Utils_User.getContactFromUser(UserInfo.getUserId());

        if(AP1002_Utils_User.getUserCountry(UserInfo.getUserId()) == 'ITA' && l_direttoreName.contains(con.Title)){
            return false;
        }
        return true;
    }
}