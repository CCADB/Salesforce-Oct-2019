/*
    Test class for MozillaIntermediateCertsReportController
*/
@isTest
public with sharing class MozillaIntermediateCertsReportCtrlTest {
    static testMethod void validateTest() {
        
        Account acc = TestUtils.getCAOwner();
        insert acc;
        
        Account rootacc = TestUtils.getRootCertificate(acc.Id);
        rootacc.Status__c = 'Included';
        rootacc.Trust_Bits__c = 'Websites';
        insert rootacc;
        
        Account intermediateacc = TestUtils.getIntermediateCertificate(rootacc.Id);
        intermediateacc.Revocation_Status__c = 'Not Revoked';
        intermediateacc.Valid_To_GMT__c = system.today().addDays(10);
        intermediateacc.Root_Cert_Id__c = rootacc.Id;
        intermediateacc.Subject__c = 'SSSSS';
        intermediateacc.Issuer__c = 'IIIIIII';
        intermediateacc.SHA_256_Fingerprint__c = 'AAAAAAAA';
        insert intermediateacc;
        
        MozillaIntermediateCertsReportController objReport = new MozillaIntermediateCertsReportController();
        
    }
}