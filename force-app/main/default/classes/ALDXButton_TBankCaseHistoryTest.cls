@isTest
public with sharing class ALDXButton_TBankCaseHistoryTest {
	@isTest
    public static void TestALDXButton_TBankCaseHistoryController() {
        Test.startTest();
        List<TBank_Case_History__c> tList = new List<TBank_Case_History__c>();
        TBank_Case_History__c t = new TBank_Case_History__c();
        tList.add(t);
        ApexPages.StandardSetController std = new ApexPages.StandardSetController(tList);
        ALDXButton_TBankCaseHistoryController ext = new ALDXButton_TBankCaseHistoryController(std);
        Test.stopTest();
    }
}