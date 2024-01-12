public class lwc65_pickup_stations_ctrl {

    Public class wrapRelai {
        @AuraEnabled
        public String nom {get;set;}
        // @AuraEnabled
        // public String latitutde {get;set;}
        // @AuraEnabled
        // public String longitude {get;set;}
        @AuraEnabled
        public String distance {get;set;}
        // @AuraEnabled
        // public String infosLocalisation {get;set;}
        @AuraEnabled
        public List<String> horairesLundi {get;set;}
        @AuraEnabled
        public List<String> horairesMardi {get;set;}
        @AuraEnabled
        public List<String> horairesMercredi {get;set;}
        @AuraEnabled
        public List<String> horairesJeudi {get;set;}
        @AuraEnabled
        public List<String> horairesVendredi {get;set;}
        @AuraEnabled
        public List<String> horairesSamedi {get;set;}
        @AuraEnabled
        public List<String> horairesDimanche {get;set;}
        // @AuraEnabled
        // public String ULR_Plan {get;set;}
        // @AuraEnabled
        // public String ULR_Photo {get;set;}
        
        //pour le wraper des points google
        @AuraEnabled
        public Integer zoomLevel {get;set;}
        @AuraEnabled
        public String markersTitle {get;set;}
        @AuraEnabled
        public Boolean showFooter {get;set;}
        @AuraEnabled
        public String listView {get;set;}
        @AuraEnabled
        public String icon {get;set;}
        @AuraEnabled
        public String title {get;set;}        
        @AuraEnabled
        public String description {get;set;}
        @AuraEnabled
        public String Street {get;set;}
        @AuraEnabled
        public String City {get;set;}
        @AuraEnabled
        public String PostalCode {get;set;}
        // @AuraEnabled
        // public String State {get;set;}
        @AuraEnabled
        public String Country {get;set;}
        
        //nécessaire pour mettre dans la sauvegarde de l'order
        @AuraEnabled
        public String adresse2 {get;set;}
        @AuraEnabled
        public String adresse4 {get;set;}
        @AuraEnabled
        public String identifiant {get;set;}
        
    }

    public static String CLOSED = Label.PUS0004;
    public static String MONDAY = Label.PUS0005;
    public static String TUESDAY = Label.PUS0006;
    public static String WEDNESDAY = Label.PUS0007;
    public static String THURSDAY = Label.PUS0008;
    public static String FRIDAY = Label.PUS0009;
    public static String SATURDAY = Label.PUS0010;
    public static String SUNDAY = Label.PUS0011;
    public static String OPENING_HOURS = Label.PUS0012;

    @AuraEnabled
    public static List<wrapRelai> getInfoRelai(String codePostal, String selectedShippingModeId){
        System.debug(selectedShippingModeId);

        list<wrapRelai> listWrapRelai = new List<wrapRelai>();
        
        AP40_MondialRelayWebservice.ret_WSI3_PointRelais_Recherche pickUpStationResult = AP41_PickUpStationHandler.findPickUpStations(codePostal, selectedShippingModeId);
        if (pickUpStationResult != null) {
            for (AP40_MondialRelayWebservice.PointRelais_Details detail : pickUpStationResult.PointsRelais.PointRelais_Details) {

                // Explication :
                String Horaires_Lundi = '';
                // Si tous les horaires renvoient zéro --> on met fermé
                if(detail.Horaires_Lundi == null || (detail.Horaires_Lundi.string_x[0] == '0000' && detail.Horaires_Lundi.string_x[1] == '0000' && detail.Horaires_Lundi.string_x[2] == '0000' && detail.Horaires_Lundi.string_x[3] == '0000' )){
                    Horaires_Lundi = CLOSED;//'Fermé';   
                }
                else if (detail.Horaires_Lundi != null){
                    // Sinon, si les horaires du matin renvoient zéro, on ferme le matin
                    // Format : partie de gauche du premier horaire + 'h' + partie de droite du 1 horaire + ' : ' + partie de droite du premier horaire + 'h' etc... 
                    // Si les parties de droite sont égales à '00', on ne met rien (ça fait de la place dans la ligne)
                    Horaires_Lundi += (detail.Horaires_Lundi.string_x[0] == '0000' && detail.Horaires_Lundi.string_x[1] == '0000') ? CLOSED + ' ' : detail.Horaires_Lundi.string_x[0].left(2) + 'h' + (detail.Horaires_Lundi.string_x[0].right(2) == '00' ? '' : detail.Horaires_Lundi.string_x[0].right(2)) + ' : ' + detail.Horaires_Lundi.string_x[1].left(2) + 'h' + (detail.Horaires_Lundi.string_x[1].right(2) == '00' ? '' : detail.Horaires_Lundi.string_x[1].right(2));
                    // Ensuite si les horaires de l'après-midi renvoient zéro ET que l'horaire du matin est supérieur à 15 --> on ne met rien car le point relai a mis ses horaires de la journée dans les horaires du matin
                    // Sinon, si les horaires de l'après-midi renvoient zéro et si inférieur à 15, on met fermé
                    // Sinon on écrit les horaires de l'après-midi
                    Horaires_Lundi += (detail.Horaires_Lundi.string_x[2] == '0000' && detail.Horaires_Lundi.string_x[3] == '0000' && Integer.valueOf(detail.Horaires_Lundi.string_x[1].left(2)) >= 15) ? '' : (detail.Horaires_Lundi.string_x[2] == '0000' && detail.Horaires_Lundi.string_x[3] == '0000' && Integer.valueOf(detail.Horaires_Lundi.string_x[1].left(2)) < 15 ? ' - ' + CLOSED : ( ' - ' + detail.Horaires_Lundi.string_x[2].left(2) + 'h' + (detail.Horaires_Lundi.string_x[2].right(2) == '00' ? '' : detail.Horaires_Lundi.string_x[2].right(2))+ ' : ' + detail.Horaires_Lundi.string_x[3].left(2) + 'h' + (detail.Horaires_Lundi.string_x[3].right(2)== '00' ? '' : detail.Horaires_Lundi.string_x[3].right(2)) ));
                }

                String Horaires_Mardi = '';
                if(detail.Horaires_Mardi == null || (detail.Horaires_Mardi.string_x[0] == '0000' && detail.Horaires_Mardi.string_x[1] == '0000' && detail.Horaires_Mardi.string_x[2] == '0000' && detail.Horaires_Mardi.string_x[3] == '0000' )){
                    Horaires_Mardi = CLOSED;//'Fermé';   
                }
                else if (detail.Horaires_Mardi != null){
                    Horaires_Mardi += (detail.Horaires_Mardi.string_x[0] == '0000' && detail.Horaires_Mardi.string_x[1] == '0000') ? CLOSED + ' ' : detail.Horaires_Mardi.string_x[0].left(2) + 'h' + (detail.Horaires_Mardi.string_x[0].right(2) == '00' ? '' : detail.Horaires_Mardi.string_x[0].right(2)) + ' : ' + detail.Horaires_Mardi.string_x[1].left(2) + 'h' + (detail.Horaires_Mardi.string_x[1].right(2) == '00' ? '' : detail.Horaires_Mardi.string_x[1].right(2));
                    Horaires_Mardi += (detail.Horaires_Mardi.string_x[2] == '0000' && detail.Horaires_Mardi.string_x[3] == '0000' && Integer.valueOf(detail.Horaires_Mardi.string_x[1].left(2)) >= 15) ? '' : (detail.Horaires_Mardi.string_x[2] == '0000' && detail.Horaires_Mardi.string_x[3] == '0000' && Integer.valueOf(detail.Horaires_Mardi.string_x[1].left(2)) < 15 ? ' - ' + CLOSED : ( ' - ' +  detail.Horaires_Mardi.string_x[2].left(2) + 'h' + (detail.Horaires_Mardi.string_x[2].right(2) == '00' ? '' : detail.Horaires_Mardi.string_x[2].right(2))+ ' : ' + detail.Horaires_Mardi.string_x[3].left(2) + 'h' + (detail.Horaires_Mardi.string_x[3].right(2)== '00' ? '' : detail.Horaires_Mardi.string_x[3].right(2)) ));
                }

                String Horaires_Mercredi = '';
                if(detail.Horaires_Mercredi == null || (detail.Horaires_Mercredi.string_x[0] == '0000' && detail.Horaires_Mercredi.string_x[1] == '0000' && detail.Horaires_Mercredi.string_x[2] == '0000' && detail.Horaires_Mercredi.string_x[3] == '0000' )){
                    Horaires_Mercredi = CLOSED;//'Fermé';   
                }
                else if (detail.Horaires_Mercredi != null) {
                    Horaires_Mercredi += (detail.Horaires_Mercredi.string_x[0] == '0000' && detail.Horaires_Mercredi.string_x[1] == '0000') ? CLOSED + ' ' :detail.Horaires_Mercredi.string_x[0].left(2) + 'h' + (detail.Horaires_Mercredi.string_x[0].right(2) == '00' ? '' : detail.Horaires_Mercredi.string_x[0].right(2)) + ' : ' + detail.Horaires_Mercredi.string_x[1].left(2) + 'h' + (detail.Horaires_Mercredi.string_x[1].right(2) == '00' ? '' : detail.Horaires_Mercredi.string_x[1].right(2));
                    Horaires_Mercredi += (detail.Horaires_Mercredi.string_x[2] == '0000' && detail.Horaires_Mercredi.string_x[3] == '0000' && Integer.valueOf(detail.Horaires_Mercredi.string_x[1].left(2)) >= 15) ? '' : (detail.Horaires_Mercredi.string_x[2] == '0000' && detail.Horaires_Mercredi.string_x[3] == '0000' && Integer.valueOf(detail.Horaires_Mercredi.string_x[1].left(2)) < 15 ? ' - ' + CLOSED : ( ' - ' + detail.Horaires_Mercredi.string_x[2].left(2) + 'h' + (detail.Horaires_Mercredi.string_x[2].right(2) == '00' ? '' : detail.Horaires_Mercredi.string_x[2].right(2))+ ' : ' + detail.Horaires_Mercredi.string_x[3].left(2) + 'h' + (detail.Horaires_Mercredi.string_x[3].right(2)== '00' ? '' : detail.Horaires_Mercredi.string_x[3].right(2)) ));
                }

                String horaires_Jeudi = '';
                if(detail.horaires_Jeudi == null || (detail.horaires_Jeudi.string_x[0] == '0000' && detail.horaires_Jeudi.string_x[1] == '0000' && detail.horaires_Jeudi.string_x[2] == '0000' && detail.horaires_Jeudi.string_x[3] == '0000' )){
                    horaires_Jeudi = CLOSED;//'Fermé';   
                }
                else if (detail.horaires_Jeudi != null) {
                    horaires_Jeudi += (detail.horaires_Jeudi.string_x[0] == '0000' && detail.horaires_Jeudi.string_x[1] == '0000') ? CLOSED + ' ' : detail.horaires_Jeudi.string_x[0].left(2) + 'h' + (detail.horaires_Jeudi.string_x[0].right(2) == '00' ? '' : detail.horaires_Jeudi.string_x[0].right(2)) + ' : ' + detail.horaires_Jeudi.string_x[1].left(2) + 'h' + (detail.horaires_Jeudi.string_x[1].right(2) == '00' ? '' : detail.horaires_Jeudi.string_x[1].right(2));
                    horaires_Jeudi += (detail.horaires_Jeudi.string_x[2] == '0000' && detail.horaires_Jeudi.string_x[3] == '0000' && Integer.valueOf(detail.horaires_Jeudi.string_x[1].left(2)) >= 15) ? '' : (detail.horaires_Jeudi.string_x[2] == '0000' && detail.horaires_Jeudi.string_x[3] == '0000' && Integer.valueOf(detail.horaires_Jeudi.string_x[1].left(2)) < 15 ? ' - ' + CLOSED : ( ' - ' + detail.horaires_Jeudi.string_x[2].left(2) + 'h' + (detail.horaires_Jeudi.string_x[2].right(2) == '00' ? '' : detail.horaires_Jeudi.string_x[2].right(2))+ ' : ' + detail.horaires_Jeudi.string_x[3].left(2) + 'h' + (detail.horaires_Jeudi.string_x[3].right(2)== '00' ? '' : detail.horaires_Jeudi.string_x[3].right(2)) ));                   
                }

                String horaires_Vendredi = '';
                if(detail.horaires_Vendredi == null ||  (detail.horaires_Vendredi.string_x[0] == '0000' && detail.horaires_Vendredi.string_x[1] == '0000' && detail.horaires_Vendredi.string_x[2] == '0000' && detail.horaires_Vendredi.string_x[3] == '0000' )){
                    horaires_Vendredi = 'Fermé';   
                }
                else if (detail.horaires_Vendredi != null) {
                    horaires_Vendredi += (detail.horaires_Vendredi.string_x[0] == '0000' && detail.horaires_Vendredi.string_x[1] == '0000') ? 'Fermé ' :  detail.horaires_Vendredi.string_x[0].left(2) + 'h' + (detail.horaires_Vendredi.string_x[0].right(2) == '00' ? '' : detail.horaires_Vendredi.string_x[0].right(2)) + ' : ' + detail.horaires_Vendredi.string_x[1].left(2) + 'h' + (detail.horaires_Vendredi.string_x[1].right(2) == '00' ? '' : detail.horaires_Vendredi.string_x[1].right(2));
                    horaires_Vendredi += (detail.horaires_Vendredi.string_x[2] == '0000' && detail.horaires_Vendredi.string_x[3] == '0000' && Integer.valueOf(detail.horaires_Vendredi.string_x[1].left(2)) >= 15) ? '' : (detail.horaires_Vendredi.string_x[2] == '0000' && detail.horaires_Vendredi.string_x[3] == '0000' && Integer.valueOf(detail.horaires_Vendredi.string_x[1].left(2)) < 15 ? ' - Fermé' : ( ' - ' + detail.horaires_Vendredi.string_x[2].left(2) + 'h' + (detail.horaires_Vendredi.string_x[2].right(2) == '00' ? '' : detail.horaires_Vendredi.string_x[2].right(2))+ ' : ' + detail.horaires_Vendredi.string_x[3].left(2) + 'h' + (detail.horaires_Vendredi.string_x[3].right(2)== '00' ? '' : detail.horaires_Vendredi.string_x[3].right(2)) ));
                }

                String Horaires_Samedi = '';
                if(detail.Horaires_Samedi == null || (detail.Horaires_Samedi.string_x[0] == '0000' && detail.Horaires_Samedi.string_x[1] == '0000' && detail.Horaires_Samedi.string_x[2] == '0000' && detail.Horaires_Samedi.string_x[3] == '0000' )){
                    Horaires_Samedi = CLOSED;//'Fermé';   
                }
                else if (detail.Horaires_Samedi != null) {
                    Horaires_Samedi += (detail.Horaires_Samedi.string_x[0] == '0000' && detail.Horaires_Samedi.string_x[1] == '0000') ? CLOSED + ' ' : detail.Horaires_Samedi.string_x[0].left(2) + 'h' + (detail.Horaires_Samedi.string_x[0].right(2) == '00' ? '' : detail.Horaires_Samedi.string_x[0].right(2)) + ' : ' + detail.Horaires_Samedi.string_x[1].left(2) + 'h' + (detail.Horaires_Samedi.string_x[1].right(2) == '00' ? '' : detail.Horaires_Samedi.string_x[1].right(2));
                    Horaires_Samedi += (detail.Horaires_Samedi.string_x[2] == '0000' && detail.Horaires_Samedi.string_x[3] == '0000' && Integer.valueOf(detail.Horaires_Samedi.string_x[1].left(2)) >= 15) ? '' : (detail.Horaires_Samedi.string_x[2] == '0000' && detail.Horaires_Samedi.string_x[3] == '0000' && Integer.valueOf(detail.Horaires_Samedi.string_x[1].left(2)) < 15 ? ' - ' + CLOSED : ( ' - ' + detail.Horaires_Samedi.string_x[2].left(2) + 'h' + (detail.Horaires_Samedi.string_x[2].right(2) == '00' ? '' : detail.Horaires_Samedi.string_x[2].right(2))+ ' : ' + detail.Horaires_Samedi.string_x[3].left(2) + 'h' + (detail.Horaires_Samedi.string_x[3].right(2)== '00' ? '' : detail.Horaires_Samedi.string_x[3].right(2)) ));
                }

                String Horaires_Dimanche = '';
                if(detail.Horaires_Dimanche == null ||  (detail.Horaires_Dimanche.string_x[0] == '0000' && detail.Horaires_Dimanche.string_x[1] == '0000' && detail.Horaires_Dimanche.string_x[2] == '0000' && detail.Horaires_Dimanche.string_x[3] == '0000' )){
                    Horaires_Dimanche = CLOSED;//'Fermé';   
                }
                else if (detail.Horaires_Dimanche != null) {
                    Horaires_Dimanche += (detail.Horaires_Dimanche.string_x[0] == '0000' && detail.Horaires_Dimanche.string_x[1] == '0000') ? CLOSED + ' ' : detail.Horaires_Dimanche.string_x[0].left(2) + 'h' + (detail.Horaires_Dimanche.string_x[0].right(2) == '00' ? '' : detail.Horaires_Dimanche.string_x[0].right(2))+ ' : ' + detail.Horaires_Dimanche.string_x[1].left(2) + 'h' + (detail.Horaires_Dimanche.string_x[1].right(2)== '00' ? '' : detail.Horaires_Dimanche.string_x[1].right(2));
                    Horaires_Dimanche += (detail.Horaires_Dimanche.string_x[2] == '0000' && detail.Horaires_Dimanche.string_x[3] == '0000' && Integer.valueOf(detail.Horaires_Dimanche.string_x[1].left(2)) >= 15) ? '' : (detail.Horaires_Dimanche.string_x[2] == '0000' && detail.Horaires_Dimanche.string_x[3] == '0000' && Integer.valueOf(detail.Horaires_Dimanche.string_x[1].left(2)) < 15 ? ' - ' + CLOSED : ( ' - ' + detail.Horaires_Dimanche.string_x[2].left(2) + 'h' + (detail.Horaires_Dimanche.string_x[2].right(2) == '00' ? '' : detail.Horaires_Dimanche.string_x[2].right(2))+ ' : ' + detail.Horaires_Dimanche.string_x[3].left(2) + 'h' + (detail.Horaires_Dimanche.string_x[3].right(2)== '00' ? '' : detail.Horaires_Dimanche.string_x[3].right(2)) ));
                }

                if(detail.Informations_Dispo != null && detail.Informations_Dispo.Periode != null) {
                    for (AP40_MondialRelayWebservice.Periode periode : detail.Informations_Dispo.Periode){
                        System.debug(periode.Debut);
                        System.debug(periode.Fin);                    }

                }

                String description = 
                    OPENING_HOURS + ' : <br/> <table> <tr><td> ' + MONDAY + ' : </td><td>' + Horaires_Lundi + 
                    '</td></tr><tr><td>' + TUESDAY + ' : </td><td>' + Horaires_Mardi + 
                    '</td></tr><tr><td>' + WEDNESDAY + ' : </td><td>' + Horaires_Mercredi + 
                    '</td></tr><tr><td>' + THURSDAY + ' : </td><td>' + horaires_Jeudi + 
                    '</td></tr><tr><td>' + FRIDAY + ' : </td><td>' + horaires_Vendredi + 
                    '</td></tr><tr><td>' + SATURDAY + ' : </td><td>' + Horaires_Samedi + 
                    '</td></tr><tr><td>' + SUNDAY + ' : </td><td>' + Horaires_Dimanche + '</td></tr></tr></table>';

                wrapRelai wrap = new wrapRelai();        
                wrap.zoomLevel = 4;
                wrap.markersTitle = detail.LgAdr1;
                wrap.showFooter = false;
                wrap.listView = 'hidden';
                wrap.icon = 'utility:salesforce1';
                wrap.title = detail.LgAdr1;//'Worldwide Corporate Headquarters';
                wrap.description = description;//'Sales: 1800-NO-SOFTWARE';
                wrap.identifiant = detail.Num;//'Sales: 1800-NO-SOFTWARE';
                wrap.distance = detail.Distance;
                wrap.adresse2 = detail.LgAdr2;//'Worldwide Corporate Headquarters;
                wrap.Street= detail.LgAdr3;//'131 rue Paul bellamy';
                wrap.adresse4= detail.LgAdr4;//'131 rue Paul bellamy';
                wrap.City= detail.Ville;//'Nantes';
                wrap.PostalCode= detail.CP;//'44000';
                wrap.Country= detail.Pays;

                // Ne pas utiliser pour l'objet point Relai (sert pour les accordion)
                wrap.nom = detail.LgAdr1 + ' - ' + detail.Distance + 'm';
                System.debug(detail.LgAdr1.removeEndIgnoreCase(' ') + '-' + detail.Distance);

                listWrapRelai.add(wrap);
            }
        }

        return listWrapRelai;
    }

    @AuraEnabled
    public static VFC01_OrderAddress_France.wrapperPointRelaiSelec createPointSelected(String Street, String City, String PostalCode, String title, String Country, String identifiant, String adresse2){

        VFC01_OrderAddress_France.wrapperPointRelaiSelec pointSelected = new VFC01_OrderAddress_France.wrapperPointRelaiSelec() ;
        pointSelected.identifiant = identifiant;
        pointSelected.adresse1 = title;
        pointSelected.adresse2 = adresse2;
        pointSelected.adresse3 = Street;
        pointSelected.codePostal = PostalCode;
        pointSelected.codePays = Country;
        pointSelected.localite = City;
        pointSelected.nom = title;

        return pointSelected;
    }
}