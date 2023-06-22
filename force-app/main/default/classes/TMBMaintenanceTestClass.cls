@isTest 
private class TMBMaintenanceTestClass {
    static testMethod void TMBMaintenanceTest() {
        TMBMaintenanceController ctrl1 = new TMBMaintenanceController();
        
        Maintenance_Message__c msg = new Maintenance_Message__c();
        msg.Name = 'Test Msg';
        msg.Title_Message__c = 'Test Title';
        msg.Header_Message__c= 'Test Header';
        msg.Body_Message__c= 'Test Body';
        insert msg;
        
        TMBMaintenanceController ctrl2 = new TMBMaintenanceController();
    }
}