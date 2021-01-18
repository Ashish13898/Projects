/**
* CCH_DataTableTest
* 
* @description Test Class for Data Table Classes
* ============================================================================================
* Date                Developer           Description
* -----------         ---------------     ----------------------------------------------------
* 03-Spet-2020        Ashish Dave         Test class for Data Table Classes
*/
@IsTest
public class CCH_DataTableTest {
    static testMethod void testGetField()
    {
        Case caseRecord = CCH_TestDataFactory.getCaseWithRecordType('CCH_Claim_Intake_CCH');
        insert caseRecord;
        
        Claim claimRecord = CCH_TestDataFactory.getClaim();
        claimRecord.LossDate = system.now();
        claimRecord.Name = '00000000';
        claimRecord.caseId = caseRecord.Id;
        insert claimRecord;
        
        
        Test.startTest();
        List<Map<String,String>> dataTableJSON = CCH_DataTableController.getRecordList('Claim',
                                                                               'Name,PolicyNumber.Name,CCH_Insurance_Policy_Participant__r.CCH_Certificate_Number__c,Status,LossDate,Case.CCH_Date_Time_Received__c,Id',
                                                                               'Name != null','Name','ASC',Null,100);
        Test.stopTest();
        
        system.assertEquals(claimRecord.Name, dataTableJSON[0].get('Name'), 'Claim Name Expected 00000000');
    }
}