public class MozillaIntermediateCertsReportController {

    public List<Account> lstIntermediateCerts {get;set;}
 
    //constructor method for standard controller
    public MozillaIntermediateCertsReportController() {   
          
        lstIntermediateCerts =  [select Id, Name, Subject__c, Issuer__c, SHA_256_Fingerprint__c, X_509_Certificate_PEM__c from Account
                                      where Name != '<Fill in Cert Name>' and RecordType.Name = 'Intermediate Certificate' and  
                                      Revocation_Status__c not in ('Revoked','Parent Cert Revoked') and 
                                      Root_Status__c in ('Included','Change Requested') and Valid_To_GMT__c > TODAY and
                                      Root_Cert_Id__r.Trust_Bits__c includes ('Websites')
                                      order by Name];
                                          
                                          
                                          
        // if we are generating a CSV file then we need to replace the double quotes in all text fields with null
        if((Test.IsRunningTest() || ApexPages.currentPage().getUrl().contains('CSV')) && lstIntermediateCerts !=null && lstIntermediateCerts.size() > 0)
        {
            for(Account acc: lstIntermediateCerts){
                if(acc.name !=null && acc.name.length() > 0) 
                    acc.name = acc.name.replace('"',''); 
                if(acc.Subject__c !=null && acc.Subject__c.length() > 0) 
                    acc.Subject__c = acc.Subject__c.replace('"','');
                if(acc.Issuer__c !=null && acc.Issuer__c.length() > 0) 
                    acc.Issuer__c = acc.Issuer__c.replace('"','');
                if(acc.SHA_256_Fingerprint__c !=null && acc.SHA_256_Fingerprint__c.length() > 0) 
                    acc.SHA_256_Fingerprint__c = acc.SHA_256_Fingerprint__c.replace('"','').replace(':','');
            }
        }
    }
}