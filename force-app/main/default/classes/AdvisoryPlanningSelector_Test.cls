@isTest
public without sharing class AdvisoryPlanningSelector_Test {
    @isTest
    private static void Test_getAdvisoryPlanningItemByItemType() {
       
        Test.startTest();
        AdvisoryPlanningSelector.getAdvisoryPlanningItemByItemType(new Set<String>(), new Set<String>{'Return'});
        Test.stopTest();
    }
}