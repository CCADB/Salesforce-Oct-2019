/*
    Description: Class is used for showing progress bar for audit type cases
*/
public with sharing class AuditCaseProgressBarController {
    
    //wrapper class for onboarding stages
    public List<WrapperStages> lstWrapperCaseStages {get; set;}
    
    public AuditCaseProgressBarController (Apexpages.standardcontroller controller){
        
    }
    
    public void CheckCaseProgress() {
        Id caseid = Apexpages.currentpage().getParameters().get('id');
        if(caseid != null) {
            lstWrapperCaseStages = new List<WrapperStages>();
            List<Case> lstCases = new List<Case>([select Id,Auditor_New__c,Auditor_Status_New__c,Auditor_Website_New__c,Auditor_Location_New__c,
                                Auditor_Location_Status_New__c,Auditor_Qualifications_New__c,Certificate_Policy_Link__c,Certification_Practice_Statement_Link__c,Case_Progress__c,
                                Standard_Audit_Statement_Link__c,Standard_Audit_Type__c,Standard_Audit_Statement_Date__c,Standard_Audit_Period_Start_Date__c,Standard_Audit_Period_End_Date__c,Standard_Audit_Auto_Review_Results__c,
                                Code_Signing_Audit_Statement_Link__c,Code_Signing_Audit_Type__c,Code_Signing_Audit_Statement_Date__c,Code_Signing_Audit_Period_Start_Date__c,Code_Signing_Audit_Period_End_Date__c,Code_Signing_Audit_ALV_Results__c,
                                BR_Audit_Statement_Link__c,BR_Audit_Type__c,BR_Audit_Statement_Date__c,BR_Audit_Period_Start_Date__c,BR_Audit_Period_End_Date__c,BR_Audit_Auto_Review_Results__c,
                                EV_Audit_Statement_Link__c,EV_Audit_Type__c,EV_Audit_Statement_Date__c,EV_Audit_Period_Start_Date__c,EV_Audit_Period_End_Date__c,EV_SSL_Audit_Auto_Review_Results__c,
                                EV_Code_Signing_Audit_Statement_Link__c,EV_Code_Signing_Audit_Type__c,EV_Code_Signing_Audit_Statement_Date__c,EV_Code_Signing_Audit_Period_Start_Date__c,EV_Code_Signing_Audit_Period_End_Date__c,EV_Code_Signing_Audit_AutoReviewResults__c,
                                CP_CPS_Last_Updated_Date__c, CA_Document_Repository__c, CP_CPS_Links_Verified__c,(select Id,Apply_Standard_Audit__c,Apply_BR_Audit__c,
                                Apply_EV_Audit__c,Apply_Code_Signing_Audit__c,Apply_EV_Code_Signing_Audit__c,Test_Website_Valid__c,Test_Website_Revoked__c, Auto_Review_Results__c,
                                Test_Website_Expired__c,Trust_Bits__c, Microsoft_Trust_Bits__c  from Root_Cases__r),Request_Status__c from Case Where Id =: caseId]);
            
            if(lstCases.size() > 0) {
                //map of stages and its description
                map<string,string> mapofStages = new map<string, string>();
                mapofStages.put('Add Audit/CP/CPS data','Fill in Auditor, Audit, CP/CPS sections');
                mapofStages.put('Add Root Cases','Use "Add/Update Root Cases" button (also apply audits)');
                mapofStages.put('Update Test Websites','Use "Edit Test Websites" button');
                mapofStages.put('Run ALV','Use "Audit Letter Validation [ALV]" button');
                mapofStages.put('Verification by Root Store','');
                
                Case objCase = lstCases[0];
                boolean isCurrentFound = false;
                
                Case objCaseToUpdate = new Case();
                
                for(string strStage: mapofStages.keyset()){
                    WrapperStages objWrap = new WrapperStages();
                    objWrap.stagename = strStage;
                    objWrap.description = mapofStages.get(strStage);
                    
                    if(strStage == 'Add Audit/CP/CPS data'){
                        if(objCase.Auditor_New__c != null && 
                                ((objCase.Standard_Audit_Statement_Link__c != null &&
                                objCase.Standard_Audit_Type__c != null && 
                                objCase.Standard_Audit_Statement_Date__c != null &&
                                objCase.Standard_Audit_Period_Start_Date__c != null &&
                                objCase.Standard_Audit_Period_End_Date__c != null) ||
                                (objCase.Code_Signing_Audit_Statement_Link__c != null &&
                                objCase.Code_Signing_Audit_Type__c != null && 
                                objCase.Code_Signing_Audit_Statement_Date__c != null &&
                                objCase.Code_Signing_Audit_Period_Start_Date__c != null &&
                                objCase.Code_Signing_Audit_Period_End_Date__c != null) || 
                                (objCase.BR_Audit_Statement_Link__c != null &&
                                objCase.BR_Audit_Type__c != null && 
                                objCase.BR_Audit_Statement_Date__c != null &&
                                objCase.BR_Audit_Period_Start_Date__c != null &&
                                objCase.BR_Audit_Period_End_Date__c != null) ||
                                (objCase.EV_Audit_Statement_Link__c != null &&
                                objCase.EV_Audit_Type__c != null && 
                                objCase.EV_Audit_Statement_Date__c != null &&
                                objCase.EV_Audit_Period_Start_Date__c != null &&
                                objCase.EV_Audit_Period_End_Date__c != null) ||
                                (objCase.EV_Code_Signing_Audit_Statement_Link__c != null &&
                                objCase.EV_Code_Signing_Audit_Type__c != null && 
                                objCase.EV_Code_Signing_Audit_Statement_Date__c != null &&
                                objCase.EV_Code_Signing_Audit_Period_Start_Date__c != null &&
                                objCase.EV_Code_Signing_Audit_Period_End_Date__c != null)) && 
                                (objCase.Certificate_Policy_Link__c != null || objCase.Certification_Practice_Statement_Link__c != null) 
                                && objCase.CP_CPS_Last_Updated_Date__c != null && objCase.CA_Document_Repository__c != null){
                            objWrap.isCompleted = true;
                        } else {
                            objWrap.isCurrent = true;
                            isCurrentFound = true;
                        }
                          
                    } else if(strStage == 'Add Root Cases'){
                        if(objCase.Root_Cases__r.size() > 0) {
                            boolean blnApplyAllStandardAudit = true;
                            for(Root_Case__c rootcase: objCase.Root_Cases__r){
                                if(!rootcase.Apply_Standard_Audit__c && !rootcase.Apply_Code_Signing_Audit__c && !rootcase.Apply_BR_Audit__c &&
                                    !rootcase.Apply_EV_Audit__c  && !rootcase.Apply_EV_Code_Signing_Audit__c){
                                    blnApplyAllStandardAudit = false;
                                    break;
                                }
                            }
                            if(blnApplyAllStandardAudit){
                                objWrap.isCompleted = true;
                            } else if(!isCurrentFound){
                                objWrap.isCurrent = true;
                                isCurrentFound = true;
                            }
                        } else if(!isCurrentFound){
                            objWrap.isCurrent = true;
                            isCurrentFound = true;
                        }
                    } else if(strStage == 'Update Test Websites'){
                        boolean isUpdateCompleted = true;
                        for(Root_Case__c objRC: objCase.Root_Cases__r){
                            if((objRC.Apply_BR_Audit__c || objRC.Apply_EV_Audit__c) && (string.isblank(objRC.Test_Website_Valid__c) || 
                                    string.isblank(objRC.Test_Website_Revoked__c) || string.isblank(objRC.Test_Website_Expired__c))){
                                isUpdateCompleted = false;
                            }
                            //Commented on 3rd Oct 2018
                            //if three websites are blank and check for trust bits
                            /*if(objRC.Test_Website_Valid__c == null && objRC.Test_Website_Revoked__c == null && objRC.Test_Website_Expired__c == null){
                                if((objRC.Trust_Bits__c != null && objRC.Trust_Bits__c.contains('Websites')) || 
                                        (objRC.Microsoft_Trust_Bits__c != null && objRC.Microsoft_Trust_Bits__c.contains('Server Authentication'))){
                                    isUpdateCompleted = false;
                                }
                            } else 
                                //if any of one test websites is  blank and others are populated then show messages
                                if(objRC.Test_Website_Valid__c == null || objRC.Test_Website_Revoked__c == null || objRC.Test_Website_Expired__c == null){
                                    isUpdateCompleted = false;
                            }*/
                        }
                        if(isUpdateCompleted){
                            objWrap.isCompleted = true;
                        } else if(!isCurrentFound){
                            objWrap.isCurrent = true;
                            isCurrentFound = true;
                        }
                    } else if(strStage == 'Run ALV'){
                        //instead of checking ALV result on case we need to check ALV resutls on each root case - changed on 2nd dec 2018.
                        /*if(objCase.Standard_Audit_Auto_Review_Results__c != null || objCase.Code_Signing_Audit_ALV_Results__c != null || objCase.BR_Audit_Auto_Review_Results__c != null ||
                        objCase.EV_SSL_Audit_Auto_Review_Results__c != null || objCase.EV_Code_Signing_Audit_AutoReviewResults__c != null) {
                            objWrap.isCompleted = true;
                        }*/
                        boolean isUpdateCompleted = true;
                        for(Root_Case__c objRC: objCase.Root_Cases__r){
                            if(string.isblank(objRC.Auto_Review_Results__c)){
                                isUpdateCompleted = false;
                            }
                        }
                        if(isUpdateCompleted){
                            objWrap.isCompleted = true;
                        } else if(!isCurrentFound){
                            objWrap.isCurrent = true;
                            isCurrentFound = true;
                        }
                    } else if(strStage == 'Verification by Root Store'){
                        if(objCase.Request_Status__c == 'Complete'){
                            objWrap.isCompleted = true;
                        } else if(!isCurrentFound){
                            objWrap.isCurrent = true;
                            isCurrentFound = true;
                        }
                    }
                    if(isCurrentFound) {
                        objWrap.isCompleted = false;
                    }
                    if(objWrap.isCurrent && (string.isblank(objCase.Case_Progress__c) || objCase.Case_Progress__c != strStage)) {
                        objCaseToUpdate.Id = objCase.Id;
                        objCaseToUpdate.Case_Progress__c = strStage;
                    }
                    lstWrapperCaseStages.add(objWrap);
                }
                
                //update case progress stage
                try {
                    if(objCaseToUpdate.Id != null) {
                        update objCaseToUpdate;
                    }
                } catch (Exception ex){
                    Apexpages.addMessages(ex);
                }
            }
        }
    }
    
    
    
    public class WrapperStages {
        public string stagename {get; set;}
        public boolean isCompleted {get; set;}
        public boolean isCurrent {get; set;}
        public string description {get; set;}
        public WrapperStages(){
            stagename = '';
            isCompleted = false;
            isCurrent = false;
            description = '';
        }
    }
}