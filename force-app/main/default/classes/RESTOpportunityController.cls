@RestResource(urlMapping='/Opportunity/*')
global class RESTOpportunityController {

    @HttpGet
    global static String testReturn() {
        String result = RESTOpportunityUtil.getTHDatetimeNOW();
        return result;
    } 

    @HttpPost
    global static RESTOpportunityUtil.Response createOpportunity(String expected_submit_date, String expected_complete_date, String stage, String opportunity_recordtype_id, String opportunity_name, String owner_id, String tmb_customer_id, String app_ref_no, String leadsource, String customer_name, String customer_surname, String customer_id_type, String customer_id_number, String customer_mobile_number, String customer_type) {
        DateTime startTime, endTime;

        startTime =  datetime.now();
        RESTOpportunityUtil.Request req = RESTOpportunityUtil.genReqBody(expected_submit_date, expected_complete_date, stage, opportunity_recordtype_id, opportunity_name, owner_id, tmb_customer_id, app_ref_no, leadsource, customer_name, customer_surname, customer_id_type, customer_id_number, customer_mobile_number, customer_type);

        String isValidData = RESTOpportunityUtil.checkValidData(expected_submit_date, expected_complete_date, stage, opportunity_recordtype_id, opportunity_name, owner_id, tmb_customer_id, app_ref_no, leadsource, customer_name, customer_surname, customer_id_type, customer_id_number, customer_mobile_number, customer_type);

        String TMBCustID = '';

        Boolean isSuccess = false;

        String resStatus = '';
        String resMessage = '';
        String resCRM_ID = '';
        String TrackMsg = '';
        String Accerrormsg = '', Opptyerrormsg = '', errorMessage = '';
        Id AccountID, OpptyID;

        // System.debug('TMB CUST ID : ' + tmb_customer_id);

        if(isValidData != null){
            resStatus = 'ERROR';
            resMessage = 'required parameter is missing: \'' + isValidData + '\'';
            resCRM_ID = null;
        }
        else if(tmb_customer_id != null && isValidData == null){
            TMBCustID = tmb_customer_id;
            
            String CustName = customer_name;
            String CustSurname = customer_surname;
            String CustIDtype = customer_id_type;
            String CustIDNumber = customer_id_number;
            String CustMobileNumber = customer_mobile_number;
            String CustType = customer_type;
            
            //--------------TrackMsg--------------------
            TrackMsg += '\n|' + RESTOpportunityUtil.getTHDatetimeNOW() + ': Start QueryAccount, message=tmbcustid:' + TMBCustID;
            //--------------TrackMsg--------------------

            List<Account> acc = RESTOpportunityUtil.getAccByTMBCustID(TMBCustID);
            //IF TMB CUST ID NOT DUPP
            if(acc.size() <= 0){
                //--------------TrackMsg--------------------
                TrackMsg += ' \n|' + RESTOpportunityUtil.getTHDatetimeNOW() + ': Stop QueryAccount, message=Account not found.';
                TrackMsg += ' \n|' + RESTOpportunityUtil.getTHDatetimeNOW() + ': Start CheckAccountDuplicate, message=idtype:' + CustIDtype + ',idnumber:' + CustIDNumber;
                //--------------TrackMsg--------------------

                //CHECK DUPP ID AND ID TYPE WITH nID
                Boolean CheckDup = RESTOpportunityUtil.isDupAcc(CustIDNumber, CustIDtype);
                if(!CheckDup){
                    //--------------TrackMsg--------------------
                    TrackMsg += ' \n|' + RESTOpportunityUtil.getTHDatetimeNOW() + ': Stop CheckAccountDuplicate, message=Account not duplicate.';
                    TrackMsg += ' \n|' + RESTOpportunityUtil.getTHDatetimeNOW() + ': Start InsertProspect message=idtype:' + CustIDtype + ',idnumber:' + CustIDNumber;
                    //--------------TrackMsg--------------------

                    RESTOpportunityUtil.ReturnWraperClass result = RESTOpportunityUtil.createNewAcc(CustName, CustSurname, CustIDtype, CustIDNumber, CustMobileNumber, CustType, owner_id);
                    AccountID = result.ID;
                    Accerrormsg = result.Errormsg;

                    //--------------TrackMsg--------------------
                    TrackMsg += ' \n|' + RESTOpportunityUtil.getTHDatetimeNOW() + ': Stop InsertProspect message=Id:' + AccountID;
                    //--------------TrackMsg--------------------
                }else{
                    AccountID = RESTOpportunityUtil.getAccIDWithIDAndType(CustIDNumber, CustIDtype);

                    //--------------TrackMsg--------------------
                    TrackMsg += ' \n|' + RESTOpportunityUtil.getTHDatetimeNOW() + ': Stop CheckAccountDuplicate, message=Account found id ' + AccountID;
                    //--------------TrackMsg--------------------
                }
            //IF TMB CUST ID DUPP
            }else{
                AccountID = acc[0].id;

                //--------------TrackMsg--------------------
                TrackMsg += ' \n|' + RESTOpportunityUtil.getTHDatetimeNOW() + ': Stop QueryAccount, message=accountid:' + AccountID;
                //--------------TrackMsg--------------------
            }

            if(AccountID != null){
                //--------------TrackMsg--------------------
                TrackMsg += ' \n|' + RESTOpportunityUtil.getTHDatetimeNOW() + ': Start InsertOLAPOpp, message=accoundid:' + AccountID;
                //--------------TrackMsg--------------------

                RESTOpportunityUtil.ReturnWraperClass result = RESTOpportunityUtil.createNewOppty(AccountID, expected_submit_date, expected_complete_date, stage, opportunity_recordtype_id, opportunity_name, owner_id, app_ref_no, leadsource);
                
                OpptyID = result.ID;
                Opptyerrormsg = result.Errormsg;

                if(OpptyID != null){
                    //--------------TrackMsg--------------------
                    TrackMsg += ' \n|' + RESTOpportunityUtil.getTHDatetimeNOW() + ': Stop InsertOLAPOpp, message=id:' + OpptyID;
                    //--------------TrackMsg--------------------

                    String OpptyCAID = RESTOpportunityUtil.getOpptyCAIDByOpptyID(OpptyID);
                    resStatus = 'SUCCESS';
                    resCRM_ID = OpptyCAID;
                    isSuccess = true;
                }else{
                    //--------------TrackMsg--------------------
                    TrackMsg += ' \n|' + RESTOpportunityUtil.getTHDatetimeNOW() + ': Stop InsertOLAPOpp, message=InsertOLAPOpp failed';

                    if(Opptyerrormsg.contains('App_Ref_Number__c duplicates')){
                        TrackMsg += ' \n|' + RESTOpportunityUtil.getTHDatetimeNOW() + ': Start QueryOLAPOpp, message=app_ref_no:' + app_ref_no;

                        Opportunity opty = RESTOpportunityUtil.getOpportunityByAppRefNo(app_ref_no);

                        if (opty != null) {
                            TrackMsg += ' \n|' + RESTOpportunityUtil.getTHDatetimeNOW() + ': Stop QueryOLAPOpp, message=id:' + opty.Id + ',crm_id=' + opty.CAID__c;
                            isSuccess = true;
                            resStatus = 'SUCCESS';
                            resMessage = '';
                            resCRM_ID = opty.CAID__c;
                        }else{
                            TrackMsg += ' \n|' + RESTOpportunityUtil.getTHDatetimeNOW() + ': Stop QueryOLAPOpp, message=id:,crm_id=';

                            resStatus = 'ERROR';
                            resMessage += ' Create Opportunity FAIL! : \n' + Opptyerrormsg;
                            resCRM_ID = null;
                        }
                        
                    }else{
                        resStatus = 'ERROR';
                        resMessage += ' Create Opportunity FAIL! : \n' + Opptyerrormsg;
                        resCRM_ID = null;
                    }
                }
                
            }else{
                resStatus = 'ERROR';
                resMessage = ' Create Account FAIL! : \n' + Accerrormsg;
                resCRM_ID = null; 
            }
        }

        // System.debug('xyzz tmb_customer_id' + tmb_customer_id + String.isBlank(tmb_customer_id));

        RESTOpportunityUtil.Response res = new RESTOpportunityUtil.Response();
        res.status = resStatus;
        res.message = resMessage;
        res.crm_id = resCRM_ID;

        endTime =  datetime.now();
        errorMessage = resMessage + '\n' + TrackMsg;
        System.debug('errorMessage');
        System.debug(errorMessage);

        RESTOpportunityUtil.saveToOsLog(isSuccess, AccountID, errorMessage, TMBCustID, JSON.serialize(req), JSON.serialize(res), startTime, endTime);

        return res;
    }   
}