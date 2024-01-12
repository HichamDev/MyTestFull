//Generated by wsdl2apex

global class v2PointretraitGeopostCom {
    /**
    public class findInternalPointRetraitAcheminementByIDResponse {
        public v2PointretraitGeopostCom.pointRetraitAcheminementByIDResult return_x;
        private String[] return_x_type_info = new String[]{'return','http://v2.pointretrait.geopost.com/',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://v2.pointretrait.geopost.com/','false','false'};
        private String[] field_order_type_info = new String[]{'return_x'};
    }
    public class findInternalRDVPointRetraitAcheminementResponse {
        public v2PointretraitGeopostCom.rdvPointRetraitAcheminementResult return_x;
        private String[] return_x_type_info = new String[]{'return','http://v2.pointretrait.geopost.com/',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://v2.pointretrait.geopost.com/','false','false'};
        private String[] field_order_type_info = new String[]{'return_x'};
    }
    public class findInternalPointRetraitAcheminementByID {
        public String id;
        public String reseau;
        public String langue;
        private String[] id_type_info = new String[]{'id','http://v2.pointretrait.geopost.com/',null,'0','1','false'};
        private String[] reseau_type_info = new String[]{'reseau','http://v2.pointretrait.geopost.com/',null,'0','1','false'};
        private String[] langue_type_info = new String[]{'langue','http://v2.pointretrait.geopost.com/',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://v2.pointretrait.geopost.com/','false','false'};
        private String[] field_order_type_info = new String[]{'id','reseau','langue'};
    }
**/
    public class findRDVPointRetraitAcheminementResponse {
        public v2PointretraitGeopostCom.rdvPointRetraitAcheminementResult return_x;
        private String[] return_x_type_info = new String[]{'return','http://v2.pointretrait.geopost.com/',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://v2.pointretrait.geopost.com/','false','false'};
        private String[] field_order_type_info = new String[]{'return_x'};
    }
    public class rdvPointRetraitAcheminementResult {
        public Integer errorCode;
        public String errorMessage;
        public v2PointretraitGeopostCom.pointRetraitAcheminement[] listePointRetraitAcheminement;
        public Integer qualiteReponse;
        public String wsRequestId;
        public Boolean rdv;
        private String[] errorCode_type_info = new String[]{'errorCode','http://v2.pointretrait.geopost.com/',null,'1','1','false'};
        private String[] errorMessage_type_info = new String[]{'errorMessage','http://v2.pointretrait.geopost.com/',null,'0','1','false'};
        private String[] listePointRetraitAcheminement_type_info = new String[]{'listePointRetraitAcheminement','http://v2.pointretrait.geopost.com/',null,'0','-1','true'};
        private String[] qualiteReponse_type_info = new String[]{'qualiteReponse','http://v2.pointretrait.geopost.com/',null,'1','1','false'};
        private String[] wsRequestId_type_info = new String[]{'wsRequestId','http://v2.pointretrait.geopost.com/',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://v2.pointretrait.geopost.com/','false','false'};
        private String[] field_order_type_info = new String[]{'errorCode','errorMessage','listePointRetraitAcheminement','qualiteReponse','wsRequestId','rdv'};
        private String[] rdv_type_info = new String[]{'rdv','http://v2.pointretrait.geopost.com/',null,'1','1','false'};
    }
    public class findRDVPointRetraitAcheminement {
        public String accountNumber;
        public String password;
        public String address;
        public String zipCode;
        public String city;
        public String countryCode;
        public String weight;
        public String shippingDate;
        public String filterRelay;
        public String requestId;
        public String lang;
        public String optionInter;
        private String[] accountNumber_type_info = new String[]{'accountNumber','http://v2.pointretrait.geopost.com/',null,'0','1','false'};
        private String[] password_type_info = new String[]{'password','http://v2.pointretrait.geopost.com/',null,'0','1','false'};
        private String[] address_type_info = new String[]{'address','http://v2.pointretrait.geopost.com/',null,'0','1','false'};
        private String[] zipCode_type_info = new String[]{'zipCode','http://v2.pointretrait.geopost.com/',null,'0','1','false'};
        private String[] city_type_info = new String[]{'city','http://v2.pointretrait.geopost.com/',null,'0','1','false'};
        private String[] countryCode_type_info = new String[]{'countryCode','http://v2.pointretrait.geopost.com/',null,'0','1','false'};
        private String[] weight_type_info = new String[]{'weight','http://v2.pointretrait.geopost.com/',null,'0','1','false'};
        private String[] shippingDate_type_info = new String[]{'shippingDate','http://v2.pointretrait.geopost.com/',null,'0','1','false'};
        private String[] filterRelay_type_info = new String[]{'filterRelay','http://v2.pointretrait.geopost.com/',null,'0','1','false'};
        private String[] requestId_type_info = new String[]{'requestId','http://v2.pointretrait.geopost.com/',null,'0','1','false'};
        private String[] lang_type_info = new String[]{'lang','http://v2.pointretrait.geopost.com/',null,'0','1','false'};
        private String[] optionInter_type_info = new String[]{'optionInter','http://v2.pointretrait.geopost.com/',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://v2.pointretrait.geopost.com/','false','false'};
        private String[] field_order_type_info = new String[]{'accountNumber','password','address','zipCode','city','countryCode','weight','shippingDate','filterRelay','requestId','lang','optionInter'};
    }
    /**
    public class pointRetraitAcheminementByIDResult {
        public Integer errorCode;
        public String errorMessage;
        public v2PointretraitGeopostCom.pointRetraitAcheminement pointRetraitAcheminement;
        private String[] errorCode_type_info = new String[]{'errorCode','http://v2.pointretrait.geopost.com/',null,'1','1','false'};
        private String[] errorMessage_type_info = new String[]{'errorMessage','http://v2.pointretrait.geopost.com/',null,'0','1','false'};
        private String[] pointRetraitAcheminement_type_info = new String[]{'pointRetraitAcheminement','http://v2.pointretrait.geopost.com/',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://v2.pointretrait.geopost.com/','false','false'};
        private String[] field_order_type_info = new String[]{'errorCode','errorMessage','pointRetraitAcheminement'};
    }
    public class findPointRetraitAcheminementByID {
        public String accountNumber;
        public String password;
        public String id;
        public String date_x;
        public String weight;
        public String filterRelay;
        public String reseau;
        public String langue;
        private String[] accountNumber_type_info = new String[]{'accountNumber','http://v2.pointretrait.geopost.com/',null,'0','1','false'};
        private String[] password_type_info = new String[]{'password','http://v2.pointretrait.geopost.com/',null,'0','1','false'};
        private String[] id_type_info = new String[]{'id','http://v2.pointretrait.geopost.com/',null,'0','1','false'};
        private String[] date_x_type_info = new String[]{'date','http://v2.pointretrait.geopost.com/',null,'0','1','false'};
        private String[] weight_type_info = new String[]{'weight','http://v2.pointretrait.geopost.com/',null,'0','1','false'};
        private String[] filterRelay_type_info = new String[]{'filterRelay','http://v2.pointretrait.geopost.com/',null,'0','1','false'};
        private String[] reseau_type_info = new String[]{'reseau','http://v2.pointretrait.geopost.com/',null,'0','1','false'};
        private String[] langue_type_info = new String[]{'langue','http://v2.pointretrait.geopost.com/',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://v2.pointretrait.geopost.com/','false','false'};
        private String[] field_order_type_info = new String[]{'accountNumber','password','id','date_x','weight','filterRelay','reseau','langue'};
    }
    public class findInternalRDVPointRetraitAcheminementByID {
        public String accountNumber;
        public String password;
        public String id;
        public String reseau;
        public String langue;
        public String date_x;
        public String weight;
        public String filterRelay;
        private String[] accountNumber_type_info = new String[]{'accountNumber','http://v2.pointretrait.geopost.com/',null,'0','1','false'};
        private String[] password_type_info = new String[]{'password','http://v2.pointretrait.geopost.com/',null,'0','1','false'};
        private String[] id_type_info = new String[]{'id','http://v2.pointretrait.geopost.com/',null,'0','1','false'};
        private String[] reseau_type_info = new String[]{'reseau','http://v2.pointretrait.geopost.com/',null,'0','1','false'};
        private String[] langue_type_info = new String[]{'langue','http://v2.pointretrait.geopost.com/',null,'0','1','false'};
        private String[] date_x_type_info = new String[]{'date','http://v2.pointretrait.geopost.com/',null,'0','1','false'};
        private String[] weight_type_info = new String[]{'weight','http://v2.pointretrait.geopost.com/',null,'0','1','false'};
        private String[] filterRelay_type_info = new String[]{'filterRelay','http://v2.pointretrait.geopost.com/',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://v2.pointretrait.geopost.com/','false','false'};
        private String[] field_order_type_info = new String[]{'accountNumber','password','id','reseau','langue','date_x','weight','filterRelay'};
    }
    public class findInternalRDVPointRetraitAcheminement {
        public String accountNumber;
        public String password;
        public String address;
        public String zipCode;
        public String city;
        public String countryCode;
        public String weight;
        public String shippingDate;
        public String filterRelay;
        public String requestId;
        public String lang;
        public String optionInter;
        private String[] accountNumber_type_info = new String[]{'accountNumber','http://v2.pointretrait.geopost.com/',null,'0','1','false'};
        private String[] password_type_info = new String[]{'password','http://v2.pointretrait.geopost.com/',null,'0','1','false'};
        private String[] address_type_info = new String[]{'address','http://v2.pointretrait.geopost.com/',null,'0','1','false'};
        private String[] zipCode_type_info = new String[]{'zipCode','http://v2.pointretrait.geopost.com/',null,'0','1','false'};
        private String[] city_type_info = new String[]{'city','http://v2.pointretrait.geopost.com/',null,'0','1','false'};
        private String[] countryCode_type_info = new String[]{'countryCode','http://v2.pointretrait.geopost.com/',null,'0','1','false'};
        private String[] weight_type_info = new String[]{'weight','http://v2.pointretrait.geopost.com/',null,'0','1','false'};
        private String[] shippingDate_type_info = new String[]{'shippingDate','http://v2.pointretrait.geopost.com/',null,'0','1','false'};
        private String[] filterRelay_type_info = new String[]{'filterRelay','http://v2.pointretrait.geopost.com/',null,'0','1','false'};
        private String[] requestId_type_info = new String[]{'requestId','http://v2.pointretrait.geopost.com/',null,'0','1','false'};
        private String[] lang_type_info = new String[]{'lang','http://v2.pointretrait.geopost.com/',null,'0','1','false'};
        private String[] optionInter_type_info = new String[]{'optionInter','http://v2.pointretrait.geopost.com/',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://v2.pointretrait.geopost.com/','false','false'};
        private String[] field_order_type_info = new String[]{'accountNumber','password','address','zipCode','city','countryCode','weight','shippingDate','filterRelay','requestId','lang','optionInter'};
    }
    public class pointRetraitAcheminementResult {
        public Integer errorCode;
        public String errorMessage;
        public v2PointretraitGeopostCom.pointRetraitAcheminement[] listePointRetraitAcheminement;
        public Integer qualiteReponse;
        public String wsRequestId;
        private String[] errorCode_type_info = new String[]{'errorCode','http://v2.pointretrait.geopost.com/',null,'1','1','false'};
        private String[] errorMessage_type_info = new String[]{'errorMessage','http://v2.pointretrait.geopost.com/',null,'0','1','false'};
        private String[] listePointRetraitAcheminement_type_info = new String[]{'listePointRetraitAcheminement','http://v2.pointretrait.geopost.com/',null,'0','-1','true'};
        private String[] qualiteReponse_type_info = new String[]{'qualiteReponse','http://v2.pointretrait.geopost.com/',null,'1','1','false'};
        private String[] wsRequestId_type_info = new String[]{'wsRequestId','http://v2.pointretrait.geopost.com/',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://v2.pointretrait.geopost.com/','false','false'};
        private String[] field_order_type_info = new String[]{'errorCode','errorMessage','listePointRetraitAcheminement','qualiteReponse','wsRequestId'};
    }
    public class rdvPointRetraitAcheminementByIDResult {
        public Boolean rdv;
        private String[] rdv_type_info = new String[]{'rdv','http://v2.pointretrait.geopost.com/',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://v2.pointretrait.geopost.com/','false','false'};
        private String[] field_order_type_info = new String[]{'rdv'};
    }
    public class findPointRetraitAcheminementByIDResponse {
        public v2PointretraitGeopostCom.pointRetraitAcheminementByIDResult return_x;
        private String[] return_x_type_info = new String[]{'return','http://v2.pointretrait.geopost.com/',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://v2.pointretrait.geopost.com/','false','false'};
        private String[] field_order_type_info = new String[]{'return_x'};
    }
**/
    global class pointRetraitAcheminement {
        public String markerLabel {get;set;}
        public String nomAffiche {get;set;}
        public String distributionSort {get;set;}
        public String lotAcheminement {get;set;}
        public String versionPlanTri {get;set;}
        public Boolean accesPersonneMobiliteReduite {get;set;}
        public String adresse1 {get;set;}
        public String adresse2 {get;set;}
        public String adresse3 {get;set;}
        public String codePostal {get;set;}
        public Boolean congesPartiel {get;set;}
        public Boolean congesTotal {get;set;}
        public String coordGeolocalisationLatitude {get;set;}
        public String coordGeolocalisationLongitude {get;set;}
        public Integer distanceEnMetre {get;set;}
        public String horairesOuvertureDimanche {get;set;}
        public String horairesOuvertureJeudi {get;set;}
        public String horairesOuvertureLundi {get;set;}
        public String horairesOuvertureMardi {get;set;}
        public String horairesOuvertureMercredi {get;set;}
        public String horairesOuvertureSamedi {get;set;}
        public String horairesOuvertureVendredi {get;set;}
        public String identifiant {get;set;}
        public String indiceDeLocalisation {get;set;}
        public pointretraitGeopostCom.Conges[] listeConges {get;set;}
        public String localite {get;set;}
        public String nom {get;set;}
        public String periodeActiviteHoraireDeb {get;set;}
        public String periodeActiviteHoraireFin {get;set;}
        public Integer poidsMaxi {get;set;}
        public String typeDePoint {get;set;}
        public String codePays {get;set;}
        public String langue {get;set;}
        public String libellePays {get;set;}
        public Boolean loanOfHandlingTool {get;set;}
        public Boolean parking {get;set;}
        public String reseau {get;set;}
        private String[] distributionSort_type_info = new String[]{'distributionSort','http://v2.pointretrait.geopost.com/',null,'0','1','false'};
        private String[] lotAcheminement_type_info = new String[]{'lotAcheminement','http://v2.pointretrait.geopost.com/',null,'0','1','false'};
        private String[] versionPlanTri_type_info = new String[]{'versionPlanTri','http://v2.pointretrait.geopost.com/',null,'0','1','false'};
        private String[] accesPersonneMobiliteReduite_type_info = new String[]{'accesPersonneMobiliteReduite','pointretrait.geopost.com',null,'1','1','false'};
        private String[] adresse1_type_info = new String[]{'adresse1','pointretrait.geopost.com',null,'0','1','false'};
        private String[] adresse2_type_info = new String[]{'adresse2','pointretrait.geopost.com',null,'0','1','false'};
        private String[] adresse3_type_info = new String[]{'adresse3','pointretrait.geopost.com',null,'0','1','false'};
        private String[] codePostal_type_info = new String[]{'codePostal','pointretrait.geopost.com',null,'0','1','false'};
        private String[] congesPartiel_type_info = new String[]{'congesPartiel','pointretrait.geopost.com',null,'1','1','false'};
        private String[] congesTotal_type_info = new String[]{'congesTotal','pointretrait.geopost.com',null,'1','1','false'};
        private String[] coordGeolocalisationLatitude_type_info = new String[]{'coordGeolocalisationLatitude','pointretrait.geopost.com',null,'0','1','false'};
        private String[] coordGeolocalisationLongitude_type_info = new String[]{'coordGeolocalisationLongitude','pointretrait.geopost.com',null,'0','1','false'};
        private String[] distanceEnMetre_type_info = new String[]{'distanceEnMetre','pointretrait.geopost.com',null,'1','1','false'};
        private String[] horairesOuvertureDimanche_type_info = new String[]{'horairesOuvertureDimanche','pointretrait.geopost.com',null,'0','1','false'};
        private String[] horairesOuvertureJeudi_type_info = new String[]{'horairesOuvertureJeudi','pointretrait.geopost.com',null,'0','1','false'};
        private String[] horairesOuvertureLundi_type_info = new String[]{'horairesOuvertureLundi','pointretrait.geopost.com',null,'0','1','false'};
        private String[] horairesOuvertureMardi_type_info = new String[]{'horairesOuvertureMardi','pointretrait.geopost.com',null,'0','1','false'};
        private String[] horairesOuvertureMercredi_type_info = new String[]{'horairesOuvertureMercredi','pointretrait.geopost.com',null,'0','1','false'};
        private String[] horairesOuvertureSamedi_type_info = new String[]{'horairesOuvertureSamedi','pointretrait.geopost.com',null,'0','1','false'};
        private String[] horairesOuvertureVendredi_type_info = new String[]{'horairesOuvertureVendredi','pointretrait.geopost.com',null,'0','1','false'};
        private String[] identifiant_type_info = new String[]{'identifiant','pointretrait.geopost.com',null,'0','1','false'};
        private String[] indiceDeLocalisation_type_info = new String[]{'indiceDeLocalisation','pointretrait.geopost.com',null,'0','1','false'};
        private String[] listeConges_type_info = new String[]{'listeConges','pointretrait.geopost.com',null,'0','-1','true'};
        private String[] localite_type_info = new String[]{'localite','pointretrait.geopost.com',null,'0','1','false'};
        private String[] nom_type_info = new String[]{'nom','pointretrait.geopost.com',null,'0','1','false'};
        private String[] periodeActiviteHoraireDeb_type_info = new String[]{'periodeActiviteHoraireDeb','pointretrait.geopost.com',null,'0','1','false'};
        private String[] periodeActiviteHoraireFin_type_info = new String[]{'periodeActiviteHoraireFin','pointretrait.geopost.com',null,'0','1','false'};
        private String[] poidsMaxi_type_info = new String[]{'poidsMaxi','pointretrait.geopost.com',null,'1','1','false'};
        private String[] typeDePoint_type_info = new String[]{'typeDePoint','pointretrait.geopost.com',null,'0','1','false'};
        private String[] codePays_type_info = new String[]{'codePays','pointretrait.geopost.com',null,'0','1','false'};
        private String[] libellePays_type_info = new String[]{'libellePays','pointretrait.geopost.com',null,'0','1','false'};
        private String[] langue_type_info = new String[]{'langue','pointretrait.geopost.com',null,'0','1','false'};
        private String[] loanOfHandlingTool_type_info = new String[]{'loanOfHandlingTool','pointretrait.geopost.com',null,'1','1','false'};
        private String[] parking_type_info = new String[]{'parking','pointretrait.geopost.com',null,'1','1','false'};
        private String[] reseau_type_info = new String[]{'reseau','pointretrait.geopost.com',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://v2.pointretrait.geopost.com/','false','false'};
        private String[] field_order_type_info = new String[]{'accesPersonneMobiliteReduite','adresse1','adresse2','adresse3','codePostal','congesPartiel','congesTotal','coordGeolocalisationLatitude','coordGeolocalisationLongitude','distanceEnMetre','horairesOuvertureDimanche','horairesOuvertureJeudi','horairesOuvertureLundi','horairesOuvertureMardi','horairesOuvertureMercredi','horairesOuvertureSamedi','horairesOuvertureVendredi','identifiant','indiceDeLocalisation','listeConges','localite','nom','periodeActiviteHoraireDeb','periodeActiviteHoraireFin','poidsMaxi','typeDePoint','distributionSort','lotAcheminement','versionPlanTri'};

    }
    
    /**
    public class findInternalRDVPointRetraitAcheminementByIDResponse {
        public v2PointretraitGeopostCom.rdvPointRetraitAcheminementByIDResult return_x;
        private String[] return_x_type_info = new String[]{'return','http://v2.pointretrait.geopost.com/',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://v2.pointretrait.geopost.com/','false','false'};
        private String[] field_order_type_info = new String[]{'return_x'};
    }

    public class PointRetrait {
        public String codePays;
        public String langue;
        public String libellePays;
        public Boolean loanOfHandlingTool;
        public Boolean parking;
        public String reseau;
        private String[] codePays_type_info = new String[]{'codePays','v2.pointretrait.geopost.com',null,'0','1','false'};
        private String[] langue_type_info = new String[]{'langue','v2.pointretrait.geopost.com',null,'0','1','false'};
        private String[] libellePays_type_info = new String[]{'libellePays','v2.pointretrait.geopost.com',null,'0','1','false'};
        private String[] loanOfHandlingTool_type_info = new String[]{'loanOfHandlingTool','v2.pointretrait.geopost.com',null,'1','1','false'};
        private String[] parking_type_info = new String[]{'parking','v2.pointretrait.geopost.com',null,'1','1','false'};
        private String[] reseau_type_info = new String[]{'reseau','v2.pointretrait.geopost.com',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'v2.pointretrait.geopost.com','false','false'};
        private String[] field_order_type_info = new String[]{'codePays','langue','libellePays','loanOfHandlingTool','parking','reseau'};
    }
**/
    public class PointRetraitServiceWSPort {
        public String endpoint_x = 'https://ws.colissimo.fr/pointretrait-ws-cxf/PointRetraitServiceWS/2.0';
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        private String[] ns_map_type_info = new String[]{'http://v2.pointretrait.geopost.com/', 'v2PointretraitGeopostCom', 'pointretrait.geopost.com', 'pointretraitGeopostCom', 'v2.pointretrait.geopost.com', 'v2PointretraitGeopostCom'};
  /**      public v2PointretraitGeopostCom.pointRetraitAcheminementByIDResult findInternalPointRetraitAcheminementByID(String id,String reseau,String langue) {
            v2PointretraitGeopostCom.findInternalPointRetraitAcheminementByID request_x = new v2PointretraitGeopostCom.findInternalPointRetraitAcheminementByID();
            request_x.id = id;
            request_x.reseau = reseau;
            request_x.langue = langue;
            v2PointretraitGeopostCom.findInternalPointRetraitAcheminementByIDResponse response_x;
            Map<String, v2PointretraitGeopostCom.findInternalPointRetraitAcheminementByIDResponse> response_map_x = new Map<String, v2PointretraitGeopostCom.findInternalPointRetraitAcheminementByIDResponse>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              'http://v2.pointretrait.geopost.com/',
              'findInternalPointRetraitAcheminementByID',
              'http://v2.pointretrait.geopost.com/',
              'findInternalPointRetraitAcheminementByIDResponse',
              'v2PointretraitGeopostCom.findInternalPointRetraitAcheminementByIDResponse'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.return_x;
        }
**/
        public v2PointretraitGeopostCom.rdvPointRetraitAcheminementResult findRDVPointRetraitAcheminement(String endpoint, String accountNumber,String password,String address,String zipCode,String city,String countryCode,String weight,String shippingDate,String filterRelay,String requestId,String lang,String optionInter) {
            v2PointretraitGeopostCom.findRDVPointRetraitAcheminement request_x = new v2PointretraitGeopostCom.findRDVPointRetraitAcheminement();
            request_x.accountNumber = accountNumber;
            request_x.password = password;
            request_x.address = address;
            request_x.zipCode = zipCode;
            request_x.city = city;
            request_x.countryCode = countryCode;
            request_x.weight = weight;
            request_x.shippingDate = shippingDate;
            request_x.filterRelay = filterRelay;
            request_x.requestId = requestId;
            request_x.lang = lang;
            request_x.optionInter = optionInter;
            v2PointretraitGeopostCom.findRDVPointRetraitAcheminementResponse response_x;
            Map<String, v2PointretraitGeopostCom.findRDVPointRetraitAcheminementResponse> response_map_x = new Map<String, v2PointretraitGeopostCom.findRDVPointRetraitAcheminementResponse>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint, // endpoint_x
              '',
              'http://v2.pointretrait.geopost.com/',
              'findRDVPointRetraitAcheminement',
              'http://v2.pointretrait.geopost.com/',
              'findRDVPointRetraitAcheminementResponse',
              'v2PointretraitGeopostCom.findRDVPointRetraitAcheminementResponse'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.return_x;
        }
        /**
        public v2PointretraitGeopostCom.rdvPointRetraitAcheminementByIDResult findInternalRDVPointRetraitAcheminementByID(String accountNumber,String password,String id,String reseau,String langue,String date_x,String weight,String filterRelay) {
            v2PointretraitGeopostCom.findInternalRDVPointRetraitAcheminementByID request_x = new v2PointretraitGeopostCom.findInternalRDVPointRetraitAcheminementByID();
            request_x.accountNumber = accountNumber;
            request_x.password = password;
            request_x.id = id;
            request_x.reseau = reseau;
            request_x.langue = langue;
            request_x.date_x = date_x;
            request_x.weight = weight;
            request_x.filterRelay = filterRelay;
            v2PointretraitGeopostCom.findInternalRDVPointRetraitAcheminementByIDResponse response_x;
            Map<String, v2PointretraitGeopostCom.findInternalRDVPointRetraitAcheminementByIDResponse> response_map_x = new Map<String, v2PointretraitGeopostCom.findInternalRDVPointRetraitAcheminementByIDResponse>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              'http://v2.pointretrait.geopost.com/',
              'findInternalRDVPointRetraitAcheminementByID',
              'http://v2.pointretrait.geopost.com/',
              'findInternalRDVPointRetraitAcheminementByIDResponse',
              'v2PointretraitGeopostCom.findInternalRDVPointRetraitAcheminementByIDResponse'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.return_x;
        }
        public v2PointretraitGeopostCom.rdvPointRetraitAcheminementResult findInternalRDVPointRetraitAcheminement(String accountNumber,String password,String address,String zipCode,String city,String countryCode,String weight,String shippingDate,String filterRelay,String requestId,String lang,String optionInter) {
            v2PointretraitGeopostCom.findInternalRDVPointRetraitAcheminement request_x = new v2PointretraitGeopostCom.findInternalRDVPointRetraitAcheminement();
            request_x.accountNumber = accountNumber;
            request_x.password = password;
            request_x.address = address;
            request_x.zipCode = zipCode;
            request_x.city = city;
            request_x.countryCode = countryCode;
            request_x.weight = weight;
            request_x.shippingDate = shippingDate;
            request_x.filterRelay = filterRelay;
            request_x.requestId = requestId;
            request_x.lang = lang;
            request_x.optionInter = optionInter;
            v2PointretraitGeopostCom.findInternalRDVPointRetraitAcheminementResponse response_x;
            Map<String, v2PointretraitGeopostCom.findInternalRDVPointRetraitAcheminementResponse> response_map_x = new Map<String, v2PointretraitGeopostCom.findInternalRDVPointRetraitAcheminementResponse>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              'http://v2.pointretrait.geopost.com/',
              'findInternalRDVPointRetraitAcheminement',
              'http://v2.pointretrait.geopost.com/',
              'findInternalRDVPointRetraitAcheminementResponse',
              'v2PointretraitGeopostCom.findInternalRDVPointRetraitAcheminementResponse'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.return_x;
        }
        public v2PointretraitGeopostCom.pointRetraitAcheminementByIDResult findPointRetraitAcheminementByID(String accountNumber,String password,String id,String date_x,String weight,String filterRelay,String reseau,String langue) {
            v2PointretraitGeopostCom.findPointRetraitAcheminementByID request_x = new v2PointretraitGeopostCom.findPointRetraitAcheminementByID();
            request_x.accountNumber = accountNumber;
            request_x.password = password;
            request_x.id = id;
            request_x.date_x = date_x;
            request_x.weight = weight;
            request_x.filterRelay = filterRelay;
            request_x.reseau = reseau;
            request_x.langue = langue;
            v2PointretraitGeopostCom.findPointRetraitAcheminementByIDResponse response_x;
            Map<String, v2PointretraitGeopostCom.findPointRetraitAcheminementByIDResponse> response_map_x = new Map<String, v2PointretraitGeopostCom.findPointRetraitAcheminementByIDResponse>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              'http://v2.pointretrait.geopost.com/',
              'findPointRetraitAcheminementByID',
              'http://v2.pointretrait.geopost.com/',
              'findPointRetraitAcheminementByIDResponse',
              'v2PointretraitGeopostCom.findPointRetraitAcheminementByIDResponse'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.return_x;
        }
**/
    }
}