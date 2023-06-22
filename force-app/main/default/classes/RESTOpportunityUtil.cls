global class RESTOpportunityUtil {

    global class Response {
        public String status;
        public String message;
        public String crm_id;
    }

    global class Request {
        public String expected_submit_date;
        public String expected_complete_date;
        public String stage;
        public String opportunity_recordtype_id;
        public String opportunity_name;
        public String owner_id;
        public String tmb_customer_id;
        public String app_ref_no;
        public String leadsource;
        public String customer_name;
        public String customer_surname;
        public String customer_id_type;
        public String customer_id_number;
        public String customer_mobile_number;
        public String customer_type;
    }



    global class ReturnWraperClass {
        public Id ID;
        public String Errormsg;
    }

    public RESTOpportunityUtil(){}

    public static User sfextapi{
        get{
            if(sfextapi == null){
                AppConfig__c temp = AppConfig__c.getValues('sfextapi');
                String name;
                if(temp == null){
                    name = 'sfextapi';
                }else{
                    name = temp.Value__c;
                }

                sfextapi = [SELECT Id, Employee_ID__c, IsActive FROM User WHERE Name =: name LIMIT 1];
            }
            return sfextapi;
        }
        set;
    }

    public static List<Account> getAccByTMBCustID(String TMBCustID){
        try {
            return [SELECT Id, Name, TMB_Customer_ID_PE__c 
                            FROM Account
                            WHERE TMB_Customer_ID_PE__c =: TMBCustID
                            LIMIT 1];
        } catch (Exception e) {
            System.debug(e.getMessage());
            return null;
        }
    }
    public List<Account> getAccByID(Id AccID){
        try {
            return [SELECT Id, Name, OwnerId 
                            FROM Account
                            WHERE Id =: AccID
                            LIMIT 1];
        } catch (Exception e) {
           System.debug(e.getMessage());
           return null;
        }
    }

    public static ReturnWraperClass createNewAcc(String customer_name, String customer_surname, String customer_id_type, String customer_id_number, String customer_mobile_number, String customer_type, String owner_id){
        Account newAcc = new Account();
        ReturnWraperClass res = new ReturnWraperClass();

        //--------------------Fixed data for new Account--------------------
        String NewAccTypeToInsert = 'Qualified Prospect';
        String RecordTypeToInsert = 'Prospect';   

        String RecordTypeIdToInsert = getRTID(RecordTypeToInsert);
        // System.debug(RecordTypeToInsert + ': ' + RecordTypeIdToInsert);
        Id ownerId = getUserIdByEMPId(owner_id); 
        // System.debug('OwnerID : ' + ownerId);

        if(RecordTypeIdToInsert == 'ERROR'){
            res.ID = null;
            res.Errormsg = 'Invalid RecordType';
            return res;
        }else{
            newAcc.RecordTypeId = RecordTypeIdToInsert;
        }


        if(ownerId != null){
            newAcc.OwnerId = ownerId;
        }else{
            res.ID = null;
            res.Errormsg = 'Invalid Owner_id';
            return res;
        }

        newAcc.Account_Type__c = NewAccTypeToInsert;
        newAcc.Name = customer_name + ' ' +  customer_surname;
        newAcc.ID_Type_PE__c = customer_id_type;
        newAcc.ID_Number_PE__c = customer_id_number;
        newAcc.Mobile_Number_PE__c = customer_mobile_number;
        newAcc.Customer_Type__c = customer_type;

        try {
            System.debug(newAcc);
            insert newAcc;
            res.ID = newAcc.id;
            res.Errormsg = '';
            return res;
        } catch (Exception e) {
            System.debug(e.getmessage());
            res.ID = null;
            res.Errormsg = e.getmessage();
            return res;
        }
    }

    private static String getRTID(string RecordTypeToInsert){
        try {
            return Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(RecordTypeToInsert).getRecordTypeId();
        } catch (Exception e) {
            return 'ERROR'; 
        }
    }

    public static Boolean isDupAcc(String CustIDNumber, String CustIDtype){
        String NID = splitIDtoNID(CustIDNumber);
        String newIDNumber = CustIDNumber;
        String newIDType = CustIDtype;
        
        // System.debug(NID);

        try {
            List<Account> accs = [SELECT Id, 
                            RTL_NID__c, 
                            ID_Number_PE__c, 
                            ID_Type_PE__c 
                            FROM Account
                            WHERE RTL_NID__c =: NID];
            
            if(accs.size() <= 0){
                return false;
            }else{
                for(account acc: accs){
                    if(acc.ID_Number_PE__c == newIDNumber && acc.ID_Type_PE__c == newIDType){
                        return true;
                    }
                }
            }
        } catch (Exception e) {
            System.debug(e.getmessage());
            return true;
        }
        return false;
    }

    public static Id getAccIDWithIDAndType(String CustIDNumber, String CustIDtype){
        String NID = splitIDtoNID(CustIDNumber);
        String newIDNumber = CustIDNumber;
        String newIDType = CustIDtype;
        
        try {
            List<Account> accs = [SELECT Id, 
                            RTL_NID__c, 
                            ID_Number_PE__c, 
                            ID_Type_PE__c 
                            FROM Account
                            WHERE RTL_NID__c =: NID];
            
            if(accs.size() <= 0){
                return null;
            }else{
                for(account acc: accs){
                    // System.debug(acc);
                    if(acc.ID_Number_PE__c == newIDNumber && acc.ID_Type_PE__c == newIDType){
                        return acc.Id;
                    }
                }
            }
        } catch (Exception e) {
            System.debug(e.getmessage());
            return null;
        }
        return null;
    }

    public static String splitIDtoNID(String CustIDNumber){
        String NID = '';
        String newIDNumber = CustIDNumber;
        String[] ID_Number = newIDNumber.split('');

        if(newIDNumber.length() > 5 ){
            String prefix = ID_Number[0];

            String suffix = ID_Number[ID_Number.size()-4];
            suffix += ID_Number[ID_Number.size()-3];
            suffix += ID_Number[ID_Number.size()-2];
            suffix += ID_Number[ID_Number.size()-1];

            NID = prefix + suffix;
        }else if(newIDNumber.length() <= 5 ){
            NID = newIDNumber;
        }

        return NID;
    } 

    public static ReturnWraperClass createNewOppty(Id AccountID, String expected_submit_date, String expected_complete_date, String stage, String opportunity_recordtype_id, String opportunity_name, String owner_id, String app_ref_no, String leadsource){
        Opportunity newOppty = new Opportunity();
        ReturnWraperClass res = new ReturnWraperClass();
        
        newOppty.AccountId = AccountID;

        newOppty.Expected_submit_date__c = date.valueOf(expected_submit_date);
        newOppty.CloseDate = date.valueOf(expected_complete_date);
        newOppty.StageName = stage;
        newOppty.RecordTypeId = opportunity_recordtype_id;
        newOppty.Name = opportunity_name;
        Id ownerId = getUserIdByEMPId(owner_id);

        if(ownerId != null){
            newOppty.OwnerId = ownerId;
        }else{
            res.ID = null;
            res.Errormsg = 'Invalid Owner_id';
            return res;
        }

        newOppty.App_Ref_Number__c = app_ref_no;
        newOppty.LeadSource = leadsource;
        

        try {
            insert newOppty;
            res.ID = newOppty.id;
            res.Errormsg = '';
            return res;
        } catch (Exception e) {
           System.debug(e.getmessage());
           res.ID = null;
           res.Errormsg = e.getmessage();
           return res;
        }
    }

    private static Id getUserIdByEMPId(String owner_id){
        // System.debug('OWNER ID :' + owner_id);
        try {
            User user = new User();

            if(owner_id != null && owner_id != ''){
                user = [SELECT Id, Employee_ID__c, IsActive, Title FROM User WHERE Employee_ID__c =: owner_id LIMIT 1];
            }

            if(owner_id == null || owner_id == '' || !user.IsActive){

                user = sfextapi;
            }

            System.debug('User ID :' + user.id + user.IsActive);

            if(user.id != null){
                return user.id;
            }else{
                return null;
            }
        } catch (Exception e) {
           System.debug(e.getmessage());
           return null;
        }
    }

    public static String getOpptyCAIDByOpptyID(Id OpptyId){
        try {
            Opportunity oppty = [SELECT Id, CAID__c 
                                FROM Opportunity 
                                WHERE Id =: OpptyId LIMIT 1];
            return oppty.CAID__c;
        } catch (Exception e) {
            System.debug(e.getmessage());
            return null;
        }
    }
    
    public static Request genReqBody(String expected_submit_date, String expected_complete_date, String stage, String opportunity_recordtype_id, String opportunity_name, String owner_id, String tmb_customer_id, String app_ref_no, String leadsource, String customer_name, String customer_surname, String customer_id_type, String customer_id_number, String customer_mobile_number, String customer_type){
        Request req = new Request();

        req.expected_submit_date = expected_submit_date;
        req.expected_complete_date = expected_complete_date;

        req.stage = stage;
        req.opportunity_recordtype_id = opportunity_recordtype_id;
        req.opportunity_name = opportunity_name;
        req.owner_id = owner_id;
        req.tmb_customer_id = tmb_customer_id;

        req.app_ref_no = app_ref_no;
        req.leadsource = leadsource;
        req.customer_name =  customer_name;
        req.customer_surname = customer_surname;
        req.customer_id_type = customer_id_type;
        req.customer_id_number = customer_id_number;
        req.customer_mobile_number = customer_mobile_number;
        req.customer_type = customer_type;  

        return req;
    }

    public static void saveToOsLog(Boolean isSuccess, Id AccountID, String errorMessage, String TMBCustID, String req, String res, DateTime startTime, DateTime endTime){
        // System.debug(AccountID);
        // System.debug('errorMessage' + errorMessage);
        Account acc = new Account();
        String customerName;
        try {
            acc = [SELECT id,Core_Banking_Suggested_Segment__c,name FROM Account WHERE id =: AccountID];
            
            customerName = acc.name;
        } catch (Exception e) {
            System.debug(e.getMessage());
            acc = null;
            customerName = null;
        }

        String userName = UserInfo.getName();
        String serviceName = 'OLAP-InsertOpportunity';

        RTL_CampaignUtil.saveToOnlineLog(isSuccess, customerName, errorMessage, '', userName, TMBCustID, serviceName, req, res, acc, startTime, endTime);
    }

    public static String getTHDatetimeNOW(){
        return String.valueOf(Datetime.now().dateGmt()) + 'T' + String.valueOf(Datetime.now().timeGmt().addHours(7) + '|');
    }

    public static Opportunity getOpportunityByAppRefNo(String app_ref_no){
        try {
            List<Opportunity> opty = [SELECT Id, CAID__c, App_Ref_Number__c FROM Opportunity WHERE App_Ref_Number__c =: app_ref_no LIMIT 1];
           
            if(opty.size() > 0){
                return opty[0];
            }
            return null;
        } catch (Exception e) {
            System.debug(e.getmessage());
            return null;
        }
    }

    public static String checkValidData(String expected_submit_date, String expected_complete_date, String stage, String opportunity_recordtype_id, String opportunity_name, String owner_id, String tmb_customer_id, String app_ref_no, String leadsource, String customer_name, String customer_surname, String customer_id_type, String customer_id_number, String customer_mobile_number, String customer_type){
        
        if(String.isBlank(expected_submit_date)){
            return 'expected_submit_date';
        }
        if(String.isBlank(expected_complete_date)){
            return 'expected_complete_date';
        }
        if(String.isBlank(stage)){
            return 'stage';
        }
        if(String.isBlank(opportunity_recordtype_id)){
            return 'opportunity_recordtype_id';
        }
        if(String.isBlank(opportunity_name)){
            return 'opportunity_name';
        }
        // if(String.isBlank(owner_id)){
        //     return 'owner_id;
        // }
        if(String.isBlank(tmb_customer_id)){
            return 'tmb_customer_id';
        }
        if(String.isBlank(app_ref_no)){
            return 'app_ref_no';
        }
        if(String.isBlank(leadsource)){
            return 'leadsource';
        }
        if(String.isBlank(customer_name)){
            return 'customer_name';
        }
        if(String.isBlank(customer_surname)){
            return 'customer_surname';
        }
        if(String.isBlank(customer_id_type)){
            return 'customer_id_type';
        }
        if(String.isBlank(customer_id_number)){
            return 'customer_id_number';
        }
        if(String.isBlank(customer_mobile_number)){
            return 'customer_mobile_number';
        }
        if(String.isBlank(customer_type)){
            return 'customer_type';
        }
        return null;
    }

}