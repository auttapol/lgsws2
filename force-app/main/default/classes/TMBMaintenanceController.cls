public class TMBMaintenanceController {
    public String TitleMsg {get;set;}
    public String HeaderMsg {get;set;}
    public String BodyMsg {get;set;}
    
    public TMBMaintenanceController() {
        List<Maintenance_Message__c> maintenanceMsg = Maintenance_Message__c.getall().values();
        if(maintenanceMsg.size() > 0) {
            TitleMsg = maintenanceMsg.get(0).Title_Message__c;
            HeaderMsg = maintenanceMsg.get(0).Header_Message__c;
            BodyMsg = maintenanceMsg.get(0).Body_Message__c;
        } else {
            TitleMsg = 'ปิดปรับปรุงระบบ';
            HeaderMsg = 'Salesforce ขอปิดระบบเพื่อทำการปรับปรุงระบบ ';
            BodyMsg = 'Salesforce ขอปิดระบบเพื่อทำการปรับปรุงระบบ จึงของดให้บริการชั่วคราว ขออภัยมา ณ ที่นี้';
        }
    }
}