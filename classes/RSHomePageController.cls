/*******************************************************************************************************
 Name: RSHomePageController

 Dependencies: RSHomePageController controller class, RSHomePage vf page, RSHomePageControllerTest test class

 Description: This is Mozilla's Root Store's Task List report (added to home page). It generates
 various reports wih record count. Detail report is only displayed when the 
 record count is greater than 1.
    
    Report sections showing the following ...
    
    1) Open Leads 
    2) Open Audit Cases assigned to Mozilla which are updated by CA 
    3) Open Root Inclusion Cases which are updated by CA 
    4) Audit Data Integrity (which linked to vf page)
    5) Verify Updated Audits
    6) Verify Revoked Certst  
    7) Externally Operated Intermediate Certs missing Owner or Auditor Info
    8) Expired Root Certificates
    
 Instructions: Add the VF page to Root Store's home page
 *******************************************************************************************************
 Revision History:
 
     7/2/2019 - Created new class.
     7/12/2019 - Adding new section Externally Operated Intermediate Certs missing Owner or Auditor Info.
     8/5/2019  - Added custom sort for CRL URL column and other minor additions.
     8/13/2019 - Updated Where condition for Externally Intermediate certs Missing Info.
     8/29/2019 - Added filter for "Denied" records; IsConverted check was not sufficient.
     9/10/2019 - Found that using wrong status 'Changed Requested', so updated to 'Change Requested'
     9/23/2019 - Added a new section 'CAs Missing Emails'
 ******************************************************************************************************/
 
public with sharing class RSHomePageController {
    
    public List<Lead> lstOpenLeads {get; set;}
    public List<Case> lstAuditCases {get; set;}
    public List<Case> lstInclusionCases {get; set;}   
    public List<Account> lstVerifyUpdatedAudits {get; set;}
    public List<Account> lstVerifyRevokedCerts {get; set;}
    public List<Account> lstIntermediateCertsMissingInfo {get; set;}
    public List<Account> lstExpiredRootCertificates {get; set;}
    public List<Account> lstCAsMissingEmails {get; set;}
    
    public RSHomePageController(){
    
        lstOpenLeads = new List<Lead>([select Id, Name, Website, Company, Organization_Type__c, CP_CPS_document_URLs__c, Sponsored_By__c 
                                       from Lead where Status != 'Denied' and IsConverted = false Order by Sponsored_By__c desc]);

        List<User> lstCAUsers = new List<User>([select Id from User Where ContactID != null]);
        
        /* lstAuditCases = new List<Case>([select ID,CaseNumber,AccountId, Account.Name,Status_Summary__c,Request_Status__c,
                        Case_Assigned_To__c,Case_Assigned_To__r.Name, LastModifiedDate, LastModifiedById, LastModifiedBy.Name
                        from Case Where RecordType.Name = 'CA Audit Update Request' AND LastModifiedById =: lstCAUsers
                        AND LastModifiedDate = LAST_N_DAYS:30 and Request_Status__c != 'Complete' Order by CaseNumber,AccountId]); */
        
        /*set<Id> setofCaseIds = new set<ID>();
        for(Root_Case__c rootcase: [Select Case_No__c from Root_Case__c Where Case_No__r.Case_Assigned_To__r.Name = 'Kathleen Wilson']){
            setofCaseIds.add(rootcase.Case_No__c);
        }  */            
        lstAuditCases = new List<Case>([select ID, CaseNumber, AccountId, Account.Name, Request_Status__c,Latest_Case_Comment__c,
                        Case_Assigned_To__c, Case_Assigned_To__r.Name, Subject, LastModifiedDate, LastModifiedById, LastModifiedBy.Name
                        From Case Where RecordType.Name = 'CA Audit Update Request' AND Request_Status__c != 'Complete'
                        And Case_Assigned_To__r.Name = 'Kathleen Wilson'
                        Order by LastModifiedDate]); 
        
        set<string> setOfRequestStatuses = new set<string>();
        setOfRequestStatuses.add('Initial Request Received');
        setOfRequestStatuses.add('Information Verification in Process');
        setOfRequestStatuses.add('In Detailed CP/CPS Review');
        setOfRequestStatuses.add('In Public Discussion');
        setOfRequestStatuses.add('Pending Approval');
        setOfRequestStatuses.add('Approved, Pending Inclusion');
        setOfRequestStatuses.add('Approved, Pending Inclusion and EV');
        setOfRequestStatuses.add('Included, Pending EV');                         
        lstInclusionCases = new List<Case>([select ID,CaseNumber,AccountId, Account.Name,Status_Summary__c,Request_Status__c,
                        Case_Assigned_To__c,Case_Assigned_To__r.Name, Subject, LastModifiedDate, LastModifiedById, LastModifiedBy.Name
                        From Case Where RecordType.Name = 'CA Root Inclusion Request' AND Request_Status__c =: setOfRequestStatuses 
                        Order by Request_Status__c, LastModifiedDate]);
        
        lstVerifyUpdatedAudits = new List<Account>([select Id,Name,Standard_Audit_Statement_Date__c,Mozilla_Verified_Audit_Date__c,
                        Removal_Bug_No_or_Date__c, Comments__c, LastModifiedDate, LastModifiedBy.Name                      
                        From Account 
                        Where RecordType.Name = 'Root Certificate' 
                        AND Status__c in ('Included','Change Requested') 
                        AND Audit_Date_Same__c = false
                        Order by Name]);
        
        //verify revoked certs.
        List<wrapperRevokedCerts> lstWrapperRevokedCerts = new List<wrapperRevokedCerts>();
        List<Account> lstVerifyRevokedCertsTemp = new List<Account>([select Id,Name,ParentId,Parent.Name,Certificate_Name__c,Valid_From_GMT__c,
                        Valid_To_GMT__c,Comments__c,CRL_URL_s__c,Certificate_Serial_Number__c,SHA_256_Fingerprint__c,
                        OneCRL_Status__c,Date_of_Revocation__c,RFC_5280_Revocation_Reason_Code__c from Account Where 
                        RecordType.Name = 'Intermediate Certificate' AND 
                        Revocation_Status__c = 'Revoked' AND OneCRL_Status__c not in ('Ready to Add','Added to OneCRL','Cert Expired') 
                        AND CA_Owner_Mozilla_Status__c in ('Included','Change Requested')
                        Order by Name]);
        for(Account objAcc: lstVerifyRevokedCertsTemp){
            lstWrapperRevokedCerts.add(new wrapperRevokedCerts(objAcc.CRL_URL_s__c, objAcc));
        }
        lstWrapperRevokedCerts.sort();
        lstVerifyRevokedCerts = new List<Account>();
        for(wrapperRevokedCerts revoked: lstWrapperRevokedCerts){
            lstVerifyRevokedCerts.add(revoked.objAcc);
        }
        
        lstIntermediateCertsMissingInfo = new List<Account>([select Id,Name,CA_Owner__c,Certificate_Name__c,Valid_From_GMT__c,Revocation_Status__c ,
                        Valid_To_GMT__c,Subordinate_CA_Owner__c,Auditor_New__c,Auditor_New__r.Name,Audits_Same_as_Parent__c from Account Where 
                        RecordType.Name = 'Intermediate Certificate' 
                        AND Revocation_Status__c = 'Not Revoked' 
                        AND OneCRL_Status__c != 'Added to OneCRL'
                        AND Valid_To_GMT__c > TODAY 
                        AND Audits_Same_as_Parent__c = FALSE 
                        AND (Subordinate_CA_Owner__c = null OR Auditor_New__c = null)
                        AND Root_Cert_Id__r.Status__c In ('Included','Change Requested') 
                        AND Technically_Constrained__c = FALSE
                        Order by Name,CA_Owner__c]);
        
        lstExpiredRootCertificates = new List<Account>([select Id,Name,ParentId, Parent.Name, Valid_From_GMT__c, Valid_To_GMT__c, 
                        Trust_Bits__c, Removal_Bug_No_or_Date__c from Account WHERE RecordType.Name = 'Root Certificate' 
                        AND Status__c in ('Included','Change Requested') 
                        AND Valid_To_GMT__c < TODAY Order by Parent.Name,Name]);
                        
        lstCAsMissingEmails = new List<Account>([select Id,Name,Status__c from Account Where RecordType.Name = 'CA Owner'
                        AND Status__c in ('Included','Change Requested') AND CA_Email_Alias_1__c = null AND CA_Email_Alias_2__c = null
                        Order by Name]);
    }
    
    //wrapper class for Revoked Certs to Sort by CRLURL long text area field.
    public class wrapperRevokedCerts implements Comparable {
        public string CRLURL;
        public Account objAcc;
        public wrapperRevokedCerts (string crl, Account acc){
            this.CRLURL = crl != null ? crl : '';
            this.objAcc = acc;
        }
        public Integer compareTo(Object obj) {
            wrapperRevokedCerts revokedCert = (wrapperRevokedCerts)(obj);
            if (this.CRLURL > revokedCert.CRLURL) {
                return 1;
            }
            if (this.CRLURL == revokedCert.CRLURL) {
                return 0;
            }

            return -1;
        }
    }
}