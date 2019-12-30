/*
    Description: This class is basically used to save One time Apex script and we can run it whenever we want.
*/
public with sharing class OneTimeUseScripts {
    
    public OneTimeUseScripts(){}
    /*
        To Populate Policy Identifer from PEM Extraction results.
        We have more than 5000+ Root and Intermediate Certs, we can't update all certs in One update so we have to set Limit.
        we can only update 1000 in single time, in code there is condition if Policy Identifier is blank and Extraction results is populated.
    */
    /*List<Account> lstAccounts = new List<Account>([SELECT Id,Extraction_Results__c,Policy_Identifiers__c 
                                               FROM Account 
                                               WHERE
                                               RecordType.Name in ('Intermediate Certificate','Root Certificate')
                                               Order by LastModifiedDate Limit 1000 
                                              ]);
    List<Account> lstAccToUpdate = new List<Account>();
    for(Account acc: lstAccounts){
        if(acc.Extraction_Results__c != null && string.isblank(acc.Policy_Identifiers__c)){
            try {
                PEMParserClass pemclass = PEMParserClass.parse(acc.Extraction_Results__c);
                //policy indentifier
                if(pemclass != null && pemclass.x509v3Extensions.policyIdentifiers != null && pemclass.x509v3Extensions.policyIdentifiers.size() > 0){
                    Account objAcc = new Account(Id = acc.Id);
                    objAcc.Policy_Identifiers__c = string.join(pemclass.x509v3Extensions.policyIdentifiers,'; ');
                    lstAccToUpdate.add(objAcc);
                }
            } Catch (Exception ex){
                system.debug(acc.Id);
            }
        }
    }
    if(lstAccToUpdate.size() > 0){
        database.update(lstAccToUpdate);
    }*/
    
    
    /*
        To Populate Policy Identifier on CA Owner from all root and intermedaite certs
    */
    /*
        set<Id> setofCAOwnerId = new set<Id>();
        List<Account> lstAllCAOwner = new List<Account>([select Id,Name from Account Where RecordType.Name = 'CA Owner']);
        for(Account objAcc: lstAllCAOwner){
            setofCAOwnerId.add(objAcc.Id);
        }
       
        if(setofCAOwnerId.size() > 0) {
            map<Id, set<string>> mapCAOwnerwisePolicyIdentifiers = new map<Id, set<string>>();
            List<Account> lstAllRootInterCerts = new List<Account>([select Id,Name,CA_Owner_ID__c,Policy_Identifiers__c 
                            from Account Where Valid_To_GMT__c > TODAY AND (RecordType.Name = 'Root Certificate' OR 
                            (RecordType.Name = 'Intermediate Certificate' AND Revocation_Status__c = 'Not Revoked')) 
                            AND CA_Owner_ID__c =: setofCAOwnerId]);
            for(Account objAcc: lstAllRootInterCerts){
                if(objAcc.Policy_Identifiers__c != null){
                    List<string> lstPolicyIdentifiers = new List<string>();
                    if(objAcc.Policy_Identifiers__c.contains(';')){
                        lstPolicyIdentifiers = objAcc.Policy_Identifiers__c.split(';');
                    } else if(objAcc.Policy_Identifiers__c.contains(',')){
                        lstPolicyIdentifiers = objAcc.Policy_Identifiers__c.split(',');
                    } else {
                        lstPolicyIdentifiers.add(objAcc.Policy_Identifiers__c);
                    }
                    for(string str: lstPolicyIdentifiers){
                        if(string.isnotblank(str)){
                            if(mapCAOwnerwisePolicyIdentifiers.containskey(objAcc.CA_Owner_ID__c)){
                                mapCAOwnerwisePolicyIdentifiers.get(objAcc.CA_Owner_ID__c).add(str.trim());
                            } else {
                                mapCAOwnerwisePolicyIdentifiers.put(objAcc.CA_Owner_ID__c, new set<string>{str.trim()});
                            }
                        }
                    }
                }
            }
            if(mapCAOwnerwisePolicyIdentifiers.size() > 0){
                
                List<Account> lstAccToUpdate = new List<Account>();
                for(Id accid: mapCAOwnerwisePolicyIdentifiers.keyset()){
                    Account acc = new Account(Id = accId);
                    List<string> lst = new List<string>();
                    lst.addall(mapCAOwnerwisePolicyIdentifiers.get(accId));
                    lst.sort();
                    acc.Policy_Identifiers__c = '';
                    acc.Policy_Identifiers__c = string.join(lst, '; ');
                    lstAccToUpdate.add(acc);
                }
                if(lstAccToUpdate.size() > 0){
                    AccountTriggerHelper.isRecursiveUpdate = true;
                    update lstAccToUpdate;
                    AccountTriggerHelper.isRecursiveUpdate = false;
                }
            }
        }
    */
}