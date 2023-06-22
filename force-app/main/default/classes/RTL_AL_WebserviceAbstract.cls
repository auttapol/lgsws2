global abstract class RTL_AL_WebserviceAbstract extends WebserviceAbstract {

    global enum SERVICENAME {
        CreateLEAD, CreateOpportunity, CreateRefer, UpdateRefer
    }

    global static String getServiceName(SERVICENAME serviceName) {
        Map<String, String> namedCredentialMap = new Map<String, String>();
        for(NamedCredential each : [SELECT Endpoint,DeveloperName FROM NamedCredential]){
            namedCredentialMap.put(each.DeveloperName, each.Endpoint);
        }

        switch on serviceName {
            when CreateLEAD {
                return 'O2O - Channel Drop Lead';
            }
            when CreateOpportunity {
                return 'HPAP - Create Opporunity';
            }
            when CreateRefer {
                return namedCredentialMap.containsKey('RTL_AL_SubmitApp_HPAP') ? namedCredentialMap.get('RTL_AL_SubmitApp_HPAP') : 'HPAP - Create Refer';
            }
            when UpdateRefer {
                return 'HPAP - Update Refer';
            }
            when else {
                return null;
            }
        }
    }

    global static String setSearch(String s) {
        String reservedCharacters = '—&|!{}[]()^~*:\\\"\'+-';
        for (Integer i = 0; i < reservedCharacters.length(); i++)
            s = s.replace(reservedCharacters.substring(i, i+1), '\\' + reservedCharacters.substring(i, i+1));
        return s;
    }

    global static String getErrorMessageException(Exception e) {
        // for getStackTraceString {0}\r\n{1}
        return String.format('{0}', new List<String>{
            e.getMessage(), e.getStackTraceString()
        });
    }

    global static String getErrorMessageException(DmlException e) {
        // for getDmlStatusCode(0) {0}\n{1}
        return String.format('{0}', new List<Object>{
            // e.getDmlStatusCode(0),
            e.getDmlMessage(0)
        });
    }

    global static Object getValueWithKeyCaseInsensitive(Map<String, Object> obj, String key) {
        if(obj != null)  {
            for (String k : obj.keySet()) {
                if(key.endsWithIgnoreCase(k)) return obj.get(k);
            }
        }
        return null;
    }

    global static SCSReqRes returnResponse(String data) {
        return (SCSReqRes)JSON.deserialize(data, SCSReqRes.class);
    }

    global static Boolean checkIsEmpty(Object obj) {
        return obj == null || obj == '';
    }
    
    global static Boolean checkIsNull(Object obj) {
        return obj == null;
    }

    global static Boolean checkIsEmpty(SObject sobj, List<String> keys) {
        for (String key : keys) {
            if(checkIsEmpty(sobj.get(key))) return true;
        }
        return false;
    }

    global static Response responseMsg(Boolean isSuccess, List<ErrorDetail> description, String recordId) {
        return new Response(
                isSuccess ? '0' : '1', 
                description, 
                !checkIsEmpty(recordId) ? recordId : ''
            );
    }

    global class ErrorDetail {
        public String error_code {get; set;}
        public String error_desc {get; set;}

        public ErrorDetail(
            String error_code,
            String error_desc
        ){
            this.error_code = error_code;
            this.error_desc = error_desc;
        }
    }

    global class Response {
        public String status_code {get; set;}
        public List<ErrorDetail> status_desc {get; set;}
        public String record_id {get; set;}

        public Response(
            String status_code,
            List<ErrorDetail> status_desc,
            String record_id
        ) {
            this.status_code = status_code;
            this.status_desc = status_desc;
            this.record_id = record_id;
        }
        
        public String getErrorMessage() {
            List<String> messages = new List<String>();
            if(this.status_desc != null) for (ErrorDetail e : this.status_desc) messages.add(e.error_desc);
            return messages.size() > 0 ? String.join(messages, '\n') : '';
        }
    }

    global class SCSReqRes {
		private String initial_vector {get; set;}
        private String encrypted_data {get; set;}
        
        public SCSReqRes(String initialVector, String encryptedData) {
            this.initial_vector = initialVector;
            this.encrypted_data = encryptedData;
        }
    }

}