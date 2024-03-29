//Generated by wsdl2apex

public class pointretraitGeopostCom {
    /**
    public class PointRetrait {
        public Boolean accesPersonneMobiliteReduite;
        public String adresse1;
        public String adresse2;
        public String adresse3;
        public String codePostal;
        public Boolean congesPartiel;
        public Boolean congesTotal;
        public String coordGeolocalisationLatitude;
        public String coordGeolocalisationLongitude;
        public Integer distanceEnMetre;
        public String horairesOuvertureDimanche;
        public String horairesOuvertureJeudi;
        public String horairesOuvertureLundi;
        public String horairesOuvertureMardi;
        public String horairesOuvertureMercredi;
        public String horairesOuvertureSamedi;
        public String horairesOuvertureVendredi;
        public String identifiant;
        public String indiceDeLocalisation;
        public pointretraitGeopostCom.Conges[] listeConges;
        public String localite;
        public String nom;
        public String periodeActiviteHoraireDeb;
        public String periodeActiviteHoraireFin;
        public Integer poidsMaxi;
        public String typeDePoint;
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
        private String[] apex_schema_type_info = new String[]{'pointretrait.geopost.com','false','false'};
        private String[] field_order_type_info = new String[]{'accesPersonneMobiliteReduite','adresse1','adresse2','adresse3','codePostal','congesPartiel','congesTotal','coordGeolocalisationLatitude','coordGeolocalisationLongitude','distanceEnMetre','horairesOuvertureDimanche','horairesOuvertureJeudi','horairesOuvertureLundi','horairesOuvertureMardi','horairesOuvertureMercredi','horairesOuvertureSamedi','horairesOuvertureVendredi','identifiant','indiceDeLocalisation','listeConges','localite','nom','periodeActiviteHoraireDeb','periodeActiviteHoraireFin','poidsMaxi','typeDePoint'};
    }**/
    public class Conges {
        public DateTime calendarDeDebut {get;set;}
        public DateTime calendarDeFin {get;set;}
        public Integer numero;
        private String[] calendarDeDebut_type_info = new String[]{'calendarDeDebut','pointretrait.geopost.com',null,'0','1','false'};
        private String[] calendarDeFin_type_info = new String[]{'calendarDeFin','pointretrait.geopost.com',null,'0','1','false'};
        private String[] numero_type_info = new String[]{'numero','pointretrait.geopost.com',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'pointretrait.geopost.com','false','false'};
        private String[] field_order_type_info = new String[]{'calendarDeDebut','calendarDeFin','numero'};

        public String formatDebut() {
            if (this.calendarDeDebut != null) {
                return (this.calendarDeDebut.format());
            }
            return (null);
        }

        public String formatFin() {
            if (this.calendarDeFin != null) {
                return (this.calendarDeFin.format());
            }
            return (null);
        }
    }
}