@isTest
global class ApprovalsControllerTest{

    static testMethod void testMyApprovals() {
        ApprovalsController.runningInTestMode = true;
        ApprovalsController c= new ApprovalsController();        
    }
}