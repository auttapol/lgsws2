global class SCSMessageAPIUtil {
    private static final String ALGORITHYM = 'AES256';
    public static final Integer ACCOUNT_TYPE = 10;
    public static final Integer ACCOUNT_STATUS_TYPE = 3;
    public static final Integer ACCOUNT_AGREE_STATUS_TYPE = 3;
    public static final Integer RMID_TYPE = 30;
    public enum INTEGRATE_SYSTEM {SCS, DWH, CoreHP, CoreBank, HPAPAPI, FloorPlan, EC, OneApp, Protection}

    public static String encryptMessageWithKey(String request, String encryptKey) {
 
        if (String.isNotEmpty(encryptKey)) {
            return encryptMessage(request, EncodingUtil.convertFromHex(encryptKey));
        } else {
            return null;
        }
    }
    
     public static String decryptMessageWithKey(String response, String encryptKey) {
        if (String.isNotEmpty(encryptKey)) {
            return decryptMessage(response, EncodingUtil.convertFromHex(encryptKey));
        } else {
            return null;
        }
    }
    
    /** New method for get encryption key, Configuration store in custom metadata name "Integration System".
     * @author  Auttapol Pipatpatama
     * @since   2021-09-07 
     * @param sessionId         User session id on salesforce
     * @param integrationSys    Label text in "Integration System"
     * @return Encryption Key   
     * 
    */
    public static String getEncryptKey(String sessionId, String integrationSys) {
        Map<String, Integration_System__mdt> integrationSystemMap = Integration_System__mdt.getAll();
        Integration_System__mdt integration_System = integrationSystemMap.get(integrationSys);
        if (integration_System != null) {
            return getScsEncryptKey(integration_System.Key_API__c , sessionId);
        } else {
            return null;
        } 
    }

    public static String getEncryptKey(String sessionId, INTEGRATE_SYSTEM integrationSys) {
        switch on integrationSys {
            when SCS {
                return getScsEncryptKey('get_scs_key', sessionId);
            }	
            when DWH {
                return getScsEncryptKey('get_dwh_key', sessionId);
            }
            when CoreHP {
                return getScsEncryptKey('get_corehp_key', sessionId);
            }
            when CoreBank {
                return getScsEncryptKey('get_corebank_key', sessionId);
            }
            when HPAPAPI {
                return getScsEncryptKey('get_hpap_key', sessionId);
            }
            when FloorPlan {
                return getScsEncryptKey('get_floorplan_key', sessionId);
            }
            when EC {
                return getScsEncryptKey('get_ec_key', sessionId);
            }
            when OneApp {
                return getScsEncryptKey('get_OneApp_key', sessionId);
            }
            when Protection {
                return getScsEncryptKey('get_protection_key', sessionId);
            }
        }
        
        return null;
    }
 
    public static String encryptMessage(String request, String sessionId) { 
        return encryptMessage(request, EncodingUtil.convertFromHex(getScsEncryptKey('get_scs_key', sessionId)));
    }

    public static String encryptSummaryMessage(String request, String sessionId) {
        return encryptMessage(request, EncodingUtil.convertFromHex(getScsEncryptKey('get_dwh_key', sessionId)));
    }
    
    private static String encryptMessage(String request, Blob secretKey) {
        Blob initializationVector = Crypto.generateAesKey(128);
        Blob clearData = Blob.valueOf(request);
        Blob encText = Crypto.encrypt(ALGORITHYM, secretKey, initializationVector, clearData);
        
        String initialVector = EncodingUtil.convertToHex(initializationVector);
        String encryptedData= EncodingUtil.convertToHex(encText);
        System.debug('e-->' + initialVector);
        System.debug('e-->' + encryptedData);
        SCSRequest SCSRequest = new SCSRequest(initialVector, encryptedData);
        
        // Create json message
        return JSON.serialize(SCSRequest);
    }
    
    public static String decryptMessage(String response, String sessionId) {
		return decryptMessage(response, EncodingUtil.convertFromHex(getScsEncryptKey('get_scs_key', sessionId)));
    }

    public static String decryptSummaryMessage(String response, String sessionId) {
		return decryptMessage(response, EncodingUtil.convertFromHex(getScsEncryptKey('get_dwh_key', sessionId)));
    }
    
    private static String decryptMessage(String response, Blob secretKey) {
		try {
            SCSRequest scsRequest = (SCSRequest) JSON.deserialize(response, SCSRequest.class);
            System.debug('d-->' + scsRequest.initial_vector);
            System.debug('d-->' + scsRequest.encrypted_data);
            Blob initializationVector = EncodingUtil.convertFromHex(scsRequest.initial_vector);
            Blob encryptedData = EncodingUtil.convertFromHex(scsRequest.encrypted_data);
            Blob decryptText = Crypto.decrypt(ALGORITHYM, secretKey, initializationVector, encryptedData);
            
            String decryptMessage = decryptText.toString();
            return decryptMessage;
            //return replaceRmidInt2String(decryptMessage);
  		} catch (Exception e) {
            System.debug(LoggingLevel.Error, e.getMessage());
            return null;
        }
    }

    public static String leftPadZero(String text, Integer size) {
        System.debug('leftPadZero ' + text + ' ' +  size);
        if (text.length() < size) {
            return text.leftPad(size, '0');
        } else {
            return text;
        }
    }
    
    class SCSRequest {
		private String initial_vector{get; set;}
        private String encrypted_data{get; set;}
        
        public SCSRequest(String initialVector, String encryptedData) {
            this.initial_vector = initialVector;
            this.encrypted_data = encryptedData;
        }
    }
    
    global class EncHeader {
		public String name{get; set;}
        public String callDt{get; set;}
        public String username{get; set;}
        public String uuid{get; set;}
        
        public EncHeader() {
            
        }
        public EncHeader(String name, String callDt, String username, String uuid) {
            this.name = name;
            this.callDt = callDt;
            this.username = username;
            this.uuid = uuid;
        }
    }
    
    public static EncHeader deserializeEncHeader(String h) {
        EncHeader encHeader = (EncHeader) JSON.deserialize(h, EncHeader.class);
        return encHeader;
    }
    
    public static String getScsEncryptKey(String key, String sessionId) {
        System.debug('k: ' + key);
		String value = '';
        if(String.isEmpty(key)) return value;

        Http http = new Http();
        HttpResponse response = http.send(createHttpRequest(key, sessionId));
        if (response != null) {
            if (response.getStatusCode() == 200) {
                String body = response.getBody();
                value = body.replace('"','');
                System.debug('kv:' + value);
            } else {
                System.debug('Response code --> ' + response.getStatusCode() + '::' + response.getStatus());
            }	
        } else {
            System.debug('Response is Null');
        }
        
        return value;
    }

    private static HttpRequest createHttpRequest(String key, String sessionId) {
        DateTime startTime = DateTime.now();
        Uuid uuid = new Uuid();
        String uuidValue = uuid.getValue();
        
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + sessionId);
        req.setHeader('Content-Type', 'application/json;Charset="UTF-8"');
        req.setEndpoint('callout:' + key +'?uuid=' + uuidValue);
        req.setBody('{"api_key":"{!HTMLENCODE($Credential.Password)}"}');
        req.setTimeout(120000);
        
        /* Add header for validation */
        EncHeader encHeader = new EncHeader(UserInfo.getName(), startTime.format('dd/MM/yyyy hh:mm:ss'), UserInfo.getUserName(), uuidValue);
        String header = JSON.serialize(encHeader);
        String result = EncodingUtil.Base64Encode( Blob.valueOf( header ) );
        req.setHeader('X-Salesforce-EHD', 'EHD ' + result);
        /* --------------------------------------------------- */
        
        return req;
    }

    public static String fetchUserSessionId(){
        String sessionId = '';
        // Get the content of the VF page
        String vfContent;
        String ns =  [SELECT NamespacePrefix FROM Organization].NamespacePrefix;

       try {
           String vf_url = '/apex/';
           if(String.isNotBlank(ns)) {
               vf_url += ns + '__' + 'getsessionidvf';    
           } else {
               vf_url += 'getsessionidvf';       
           }

           PageReference pg = new PageReference(vf_url);
   
           if(!test.isRunningTest()) {
               vfContent = pg.getContent().toString();
           } else {
               vfContent = String.valueOf('Start_Of_Session_Id Test End_Of_Session_Id');
           }
   
           Integer startP = vfContent.indexOf('Start_Of_Session_Id') + 'Start_Of_Session_Id'.length(),
           endP = vfContent.indexOf('End_Of_Session_Id');
           // Get the Session Id
           sessionId = vfContent.substring(startP, endP);
       } catch(Exception ex) {
           System.debug('***** ex: ' + ex);
       }

       return sessionId;
   }
}