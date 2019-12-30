/*******************************************************************************************************
 Name: RunBatchProcessesController

 Dependencies:  RunBatchProcessesController controller class, RunBatchProcesses VF page, 
 RunBatchProcessesControllerTest test class

 Description: Common controller to run any batch processes.

 Instructions: Can be accessed from 'Batch Processes' custom VF tab
    
 *******************************************************************************************************
 Revision History:
 
     7/9/2019 - Created new
  
 ******************************************************************************************************/

public with sharing class RunBatchProcessesController {
    
    public RunBatchProcessesController(){
        
    }
    
    public void RunALVBatch(){
        RunALVForInterCertsBatch batch = new RunALVForInterCertsBatch('');
        Database.executebatch(batch,1);
    }
    
    public void RunBatchToUpdateDoppelganger(){
        RunBatchToUpdateDoppelganger batch = new RunBatchToUpdateDoppelganger('');
        Database.executeBatch(batch,50);
    }

}