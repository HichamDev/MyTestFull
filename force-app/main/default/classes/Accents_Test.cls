@IsTest
public class Accents_Test {
    
    @IsTest
    public static void removeDiacritics(){
        
        Accents.removeDiacritics(null);
        
        Accents.removeDiacritics('éèêàôûùîâ');
    }
}