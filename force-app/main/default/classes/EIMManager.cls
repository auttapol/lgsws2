public class EIMManager{
    private String JSON  = 'application/json';
    private String XML   = 'application/xml';
    private String DELIMITER_NODE = '_';
    private Map<Id,String> BODY_REQUEST_MAP = new Map<Id,String>();

    private final String Request_Type  = 'Request';
    private final String Response_Type = 'Response';
    private final String Main_Response_Type = 'MainResponse';

    private List<EIM_Map__c> eimMapReqList;
    private List<EIM_Map__c> eimMapRespList;
    private List<EIM_Map__c> mainRespList;
    public Boolean isIntegrationSuccess = false;

    public Map<String,S2O_Code_Mapping__c> s2oMap;


    public EIMManager(String jobName) {
        this.eimMapReqList    = queryEIMMapList(jobName,this.Request_Type);
        this.eimMapRespList   = queryEIMMapList(jobName,this.Response_Type);
        this.mainRespList     = queryEIMMapList(jobName,this.Main_Response_Type);
    }
    // Exception
    //public class EIMManagerException extends Exception{}

    public void initS20Mapping() {
        this.s2oMap  = S2OUtil.getAllS2OCodeMap();
    }

    public List<EIM_Map__c> getEIMMapReqList() {
        return this.eimMapReqList;
    }
   
    public Map<Id,String> getBodyRequestMap() {
        //if (!this.BODY_REQUEST_MAP.isEmpty()) return this.BODY_REQUEST_MAP;
        return this.BODY_REQUEST_MAP;
        //throw new EIMManagerException('BODY_REQUEST_MAP is empty!');
    }
    
    public void getBodyRequest(Map<String,String> valueMap,String formatType) {
        
        if (formatType.equalsIgnoreCase(this.JSON)) {
            //make it as json
            this.setJSONBody(this.eimMapReqList,valueMap,null); 
        }else {
            //make it as xml
            this.setXMLBody(this.eimMapReqList,valueMap,null);
        }
    }

    public void getBodyRequest(Sobject sobj,String formatType) {
        if (formatType.equalsIgnoreCase(this.JSON)) {
            //make it as json
            this.setJSONBody(this.eimMapReqList,null,sobj);
        }else {
            //make it as xml
            this.setXMLBody(this.eimMapReqList,null,sobj);
        }
    }


    private void setJSONBody(List<EIM_Map__c> eimMapList
                                ,Map<String,String> valueMap
                                ,Sobject sobj) {
        Map<String,String> jsonMap = new Map<String,String>();

        for (EIM_Map__c field : eimMapList) {
            String sffield  = field.SF_Field__c;
            String extfield = field.External_Field__c;
            String defaultValue = (field.Default_Value__c == null ? '' : field.Default_Value__c);


            String dateFormat = field.DateFormat__c;
            Boolean isBooleanTransform = field.isBooleanTransform__c;

            /*
            String attr     = field.Attribute__c;
            String attrVal  = field.Attribute_value__c;
            String node     = field.Node__c;
            String nodeKey    = field.Node_Key__c;
            String nodeStr  = null;
            */

            if (!String.isBlank(sffield)) {
                String value = null;
                if (sffield.contains('.')) {
                    List<String> sffieldList = sffield.split('\\.');
                    
                    if (sobj != null) {
                        SObject tempSobj = null;
                        for (Integer i=0;i<sffieldList.size()-1;i++) {
                            tempSobj =  sobj.getSobject(sffieldList.get(i));
                        }                        
                        if (tempSobj != null) {
                            //value = (String)tempSobj.get(sffieldList.get(sffieldList.size()-1));
                            value = String.valueOf(tempSobj.get(sffieldList.get(sffieldList.size()-1)));
                            //value = tempSobj.get(sffieldList.get(sffieldList.size()-1));
                        }
                    } 
                }else {
                    if (sobj != null) {
                        //value = (String)sobj.get(sffield);
                        value = String.valueOf(sobj.get(sffield));
                    }else if (!valueMap.isEmpty() && valueMap.containsKey(sffield)){
                        value = valueMap.get(sffield);
                    }
                }

                if (String.isBlank(value))  {
                    jsonMap.put(extfield, defaultValue);
                } else {
                    jsonMap.put(extfield, value);
                }   

                if (!String.isBlank(dateFormat)) {
                    String dateVal = jsonMap.get(extfield);
                    if (String.isNotBlank(dateVal)) {
                        Datetime dt1 = Datetime.valueOfGMT(dateVal);
                        dateVal = dt1.format(dateFormat,Userinfo.getTimeZone().toString());
                    }
                    
                    jsonMap.put(extfield, dateVal);
                }

                if (isBooleanTransform) {
                    String booleanVal = jsonMap.get(extfield);

                    if (booleanVal!= null && booleanVal.equalsIgnoreCase('true')) {
                        booleanVal = '1';
                    }else if (booleanVal!= null && booleanVal.equalsIgnoreCase('false')) {
                        booleanVal = '0';
                    }else {
                        try {
                            Integer valInt = Integer.valueOf(booleanVal);
                            if (valInt > 0) booleanVal = '1';
                            else booleanVal = '0';
                        }catch (Exception e) {
                            booleanVal = '0';
                        }
                        
                    } 

                    jsonMap.put(extfield, booleanVal);

                }

            }
        }

        //convert map to json string
        if (!jsonMap.isEmpty()) {
            String jsonBody = System.JSON.serialize(jsonMap);
            if (sobj != null) {
                this.BODY_REQUEST_MAP.put((Id)sobj.get('Id'), jsonBody);
            }else if(!valueMap.isEmpty() && valueMap.containsKey('Id')) {
                this.BODY_REQUEST_MAP.put(valueMap.get('Id'), jsonBody);
            }
        }
    }

    private void setXMLBody(List<EIM_Map__c> eimMapList
                            ,Map<String,String> valueMap
                            ,Sobject sobj) {
        Map<String,String> itemNodeMap = new Map<String,String>();
        String XML_HEADER_NODE = '';

        for (EIM_Map__c field : eimMapList) {
            String sffield  = field.SF_Field__c;
            String extfield = field.External_Field__c;
            String attr     = field.Attribute__c;
            String attrVal  = field.Attribute_value__c;
            String node     = field.Node__c;
            String nodeKey    = field.Node_Key__c;
            String defaultValue = field.Default_Value__c;
            String nodeStr  = null;

            if (!String.isBlank(sffield)) {
                String value = null;
                if (sffield.contains('.')) {
                    List<String> sffieldList = sffield.split('\\.');
                    
                    if (sobj != null) {
                        SObject tempSobj = null;
                        for (Integer i=0;i<sffieldList.size()-1;i++) {
                            tempSobj =  sobj.getSobject(sffieldList.get(i));
                        }                        
                        if (tempSobj != null) {
                            //value = (String)tempSobj.get(sffieldList.get(sffieldList.size()-1));
                            value = String.valueOf(tempSobj.get(sffieldList.get(sffieldList.size()-1)));
                        }
                    } 

                    if (String.isBlank(value))  value = defaultValue;                          
                    nodeStr = '<'+extfield+'>'+value+'</'+extfield+'>';
                }else {
                    if (sobj != null) {
                        //value = (String)sobj.get(sffield);
                        value = String.valueOf(sobj.get(sffield));
                    }else if (!valueMap.isEmpty() && valueMap.containsKey(sffield)){
                        value = valueMap.get(sffield);
                    }

                    if (String.isBlank(value))  value = defaultValue;
                    nodeStr = '<'+extfield+'>'+value+'</'+extfield+'>';
                }
                
                if (itemNodeMap.containsKey(nodeKey)) {
                    nodeStr = itemNodeMap.get(nodeKey)+'\n'+nodeStr;
                }
            }else {
                //Find XML_HEADER_NODE
                if (!nodeKey.contains(this.DELIMITER_NODE)) 
                    XML_HEADER_NODE = nodeKey;
                //Find XML_HEADER_NODE

                //head node parent node so no append nodestr
                if (!String.isBlank(attr) && !String.isBlank(attrVal) ) {
                    nodeStr = '<'+extfield+' '+attr+'="'+attrVal+'">\n'+'{!'+node+'}'+'\n</'+extfield+'>';
                }else {
                    nodeStr = '<'+extfield+'>\n'+'{!'+node+'}'+'\n</'+extfield+'>';
                }
            }
            
            itemNodeMap.put(nodeKey, nodeStr);
        }

        //convert map to xml string
        for (String nodeKey : itemNodeMap.keySet()) {
            if (nodeKey.contains(this.DELIMITER_NODE)) {
                List<String> nodeKeyList = nodeKey.split(this.DELIMITER_NODE);
                if (nodeKeyList != null && nodeKeyList.size() > 0) {
                    String parentNode = nodeKeyList.get(0);
                    String body =  itemNodeMap.get(parentNode);
                    itemNodeMap.put(parentNode,body.replace('{!'+parentNode+'}'
                                            ,itemNodeMap.get(nodeKey)));
                }
            }
        }

        if (!String.isBlank(XML_HEADER_NODE)) {
            String xmlBody = itemNodeMap.get(XML_HEADER_NODE);
            if (sobj != null) {
                this.BODY_REQUEST_MAP.put((Id)sobj.get('Id'), xmlBody);
            }else if(!valueMap.isEmpty() && valueMap.containsKey('Id')) {
                this.BODY_REQUEST_MAP.put(valueMap.get('Id'), xmlBody);
            }
        }
    }

    public Map<String,String> getResponseInfo(String respContent,String formatType) {
        Map<String,String> fieldMap = new Map<String,String>();
        Map<String,String> fieldValueMap = new Map<String,String>();

        for (EIM_Map__c eim : this.eimMapRespList) {
            fieldMap.put(eim.External_Field__c, eim.SF_Field__c);
        }

        Map<Object, Object> dataResp = null;

        if (formatType.equalsIgnoreCase(this.XML)) {
            Dom.Document doc = new Dom.Document();
            XMLConvertUtility convertUtlity = new XMLConvertUtility();
            doc.load(respContent);
            dataResp = convertUtlity.parseXMLToMap(doc);
        }else {
            Map<String, Object> tempMap = (Map<String, Object>)System.JSON.deserializeUntyped(respContent);
            dataResp = new Map<Object, Object>();
            for (String key : tempMap.keySet()) {
                dataResp.put(key,tempMap.get(key));
            }
        }
        
        for (Object key : dataResp.keySet()) {
            if (fieldMap.containsKey((String)key)) {
                String sffield = (String)fieldMap.get((String)key);
                String value   = String.valueOf(dataResp.get(key));

                fieldValueMap.put(sffield,value);
            }else {
                //get only index 0 for Main Response
                EIM_Map__c eimMainResp = null;
                if (this.mainRespList != null && this.mainRespList.size() > 0) {
                    eimMainResp = this.mainRespList.get(0);
                }
                //get only index 0 for Main Response

                //to get main response
                if (eimMainResp != null && key == eimMainResp.External_Field__c) {
                    //String sffield = (String)fieldMap.get((String)key);
                    String sffield = (String)fieldMap.get((String)key);
                    String value   = String.valueOf(dataResp.get(key));

                    if(value.equalsIgnoreCase('true')) {
                        isIntegrationSuccess = true;
                        //fieldValueMap.put(sffield,eimMainResp.Default_Value__c);
                        fieldValueMap.put(eimMainResp.SF_Field__c,eimMainResp.Default_Value__c);
                    }
                }
            }

        }

        return fieldValueMap;
    }

    private List<EIM_Map__c> queryEIMMapList(String jobName,String fieldType) {
        List<EIM_Map__c> eimMapList = [SELECT Id
                                            ,Name
                                            ,Default_Value__c
                                            ,Attribute__c
                                            ,Attribute_value__c
                                            ,External_Field__c
                                            ,Job_Type__c
                                            ,SF_Field__c
                                            ,Node__c
                                            ,ParentNode__c
                                            ,Node_Key__c
                                            ,Object__c
                                            ,isBooleanTransform__c
                                            ,DateFormat__c
                             FROM EIM_Map__c Where Job_Type__c =: jobName 
                                  AND IsActive__c = true
                                  AND Field_Type__c =: fieldType
                             ORDER BY Field_Order__c ASC ];

        /*
        if (!eimMapList.isEmpty()) {
            return eimMapList;
        }*/
        return eimMapList;
        //throw new EIMManagerException('Not found '+jobName+' And Field Type ' + fieldType + ' in EIM Map');
    }


    public class XMLConvertUtility {
        private  Pattern
            boolPat = Pattern.compile('^(true|false)$'),
            decPat = Pattern.compile('^[-+]?\\d+(\\.\\d+)?$'), 
            datePat = Pattern.compile('^\\d{4}.\\d{2}.\\d{2}$'), 
            timePat = Pattern.compile('^\\d{4}.\\d{2}.\\d{2} '+
                                      '(\\d{2}:\\d{2}:\\d{2} ([-+]\\d{2}:\\d{2})?)?$');

        private  Map<Object, Object> parseNode(Dom.XmlNode node, Map<Object, Object> parent) {
            // Iterate over all child elements for a given node
            for(Dom.XmlNode child: node.getChildElements()) {
                // Pull out some information
                String nodeText = child.getText().trim(), name = child.getName();
                // Determine data type
                Object value = 
                    // Nothing
                    String.isBlank(nodeText)? null:
                // Try boolean
                boolPat.matcher(nodeText).find()? 
                    (Object)Boolean.valueOf(nodeText):
                // Try decimals
                decPat.matcher(nodeText).find()?
                    (Object)Decimal.valueOf(nodeText):
                // Try dates
                datePat.matcher(nodeText).find()?
                    (Object)Date.valueOf(nodeText):
                // Try times
                timePat.matcher(nodeText).find()? 
                    (Object)DateTime.valueOf(nodeText):
                // Give up, use plain text
                (Object)nodeText;
                // We have some text to process
                if(value != null) {
                    // We already have a value here, convert it to a list
                    if(parent.containsKey(name)) {
                        try {
                            // We already have a list, so just add it
                            ((List<Object>)parent.get(name)).add(value);
                        } catch(Exception e) {
                            // We don't have a list, so convert to a list
                            parent.put(name, new List<Object>{parent.get(name), value});
                        }
                    } else {
                        // Store a new value
                        parent.put(name, value);
                    }
                } else if(child.getNodeType() == Dom.XmlNodeType.ELEMENT) {
                    // If it's not a comment or text, recursively process the data
                    Map<Object, Object> temp = parseNode(child, new Map<Object, Object>());
                    // If at least one node, add a new element into the array
                    if(!temp.isEmpty()) {
                        // Again, create or update a list if we have a value
                        if(parent.containsKey(name)) {
                            try {
                                // If it's already a list, add it
                                ((List<Object>)parent.get(name)).add(temp);
                            } catch(Exception e) {
                                // Otherwise, convert the element into a list
                                parent.put(name, new List<Object> { parent.get(name), temp });
                            }
                        } else {
                            // New element
                            parent.put(name, temp);
                        }
                    }
                }
            }
            return parent;
        }

        
        public Map<Object, Object> parseXMLToMap(Dom.Document doc) {
            return parseNode(doc.getRootElement(), new Map<Object, Object>());
        }
        
        /*
        public String parseDocumentToJson(Dom.Document doc) {
            return JSON.serialize(parseXMLToMap(doc));
        }

        public Object parseDocumentToObject(Dom.Document doc, Type klass) {
            return JSON.deserialize(parseXMLToMap(doc), klass);
        }*/
    }
}