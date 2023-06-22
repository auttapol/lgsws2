public class RTL_ReportUtility {
    public final static String INTERNAL_SERVER_ERROR = 'INTERNAL_SERVER_ERROR. Please contact Admin.';
    public final static String INVALID_ATTACHMENT_NUMBERS = 'INVALID_ATTACHMENT_NUMBERS';
    public final static String INVALID_CSV_EXTENTSION = 'INVALID_CSV_EXTENTSION';
    public final static String INVALID_UTF8_ENCODING = 'INVALID_UTF8_ENCODING_OR_IMPORT_FILE_INVALID_FORMAT';

    public final static String NOT_UPDATE_FIELD = 'NOT_UPDATE_FIELD';



    public static Integer getRecordCountFromReport(String reportDevName){
        String recordCountString = '';
        Integer recordCount = 0;

        try
        {
            // Get the report ID
            List <Report> reportList = [SELECT Id,DeveloperName FROM Report where
            DeveloperName = :reportDevName];
            String reportId = (String)reportList.get(0).get('Id');
       
            // Run a report
            Reports.reportResults results = Reports.ReportManager.runReport(reportId, true);
       
            // Get the first down-grouping in the report
            Reports.Dimension dim = results.getGroupingsDown();
        
            //System.debug('DIM :: '+dim);

            //Reports.GroupingValue groupingVal = dim.getGroupings()[0];
            for(Reports.GroupingValue groupingVal :  dim.getGroupings()){
                //System.debug('Key: ' + groupingVal.getKey());
                //System.debug('Label: ' + groupingVal.getLabel());
                //System.debug('Value: ' + groupingVal.getValue());
            
                // Construct a fact map key, using the grouping key value
                String factMapKey = groupingVal.getKey() + '!T';
            
                // Get the fact map from the report results
                Reports.ReportFactWithDetails factDetails =
                    (Reports.ReportFactWithDetails)results.getFactMap().get(factMapKey);
            
                // Get the first summary amount from the fact map
                Reports.SummaryValue sumVal = factDetails.getAggregates()[0];
                //get record count from report
                recordCountString = sumVal.getLabel();
                recordCount += Integer.ValueOf(recordCountString);

                //System.debug('Summary Value: ' + recordCount); 
            }
        }catch(Exception e){
            System.debug('Error get report information ::: '+e.getLineNumber() + '  ' + e.getMessage());
        }
     
        return  recordCount; 
    }

    public static Integer getRecordCountFromTabularReport(String reportDevName){
        try
        {
            // Get the report ID
            List <Report> reportList = [SELECT Id,DeveloperName FROM Report where
            DeveloperName = :reportDevName];
            String reportId = (String)reportList.get(0).get('Id');
            // Run a report
            Reports.reportResults results = Reports.ReportManager.runReport(reportId, true);
            MAP<String,Reports.ReportFact>  reportFactMap = results.getFactMap();
            LIST<Reports.SummaryValue> sumValues = reportFactMap.get('T!T').getAggregates();
            return Integer.valueOf(sumValues.get(0).getValue());
        }catch(Exception e){
            System.debug('Error get report information ::: '+e.getLineNumber() + '  ' + e.getMessage());
        }
        return  0; 
    }

    public static List<String> isValidCSVUTF8Encoding(String dataString,String sobjType) {
         if (dataString.indexOf('\n') == -1) return null;
            String header   = dataString.substringBefore('\n');
            String firstRow = dataString.substring(header.length()+1
                                                    ,dataString.length()).substringBefore('\n');

            String[] csvFieldNames = header.split(',');
            Map<String,Integer> fieldNumMap = new Map<String,Integer>();

            for (Integer i = 0; i < csvFieldNames.size(); i++) {
                fieldNumMap.put(csvFieldNames[i], i);
            }

            List<String> columnHeaders = new List<String>();
            Map<String,String> valMap = new Map<String,String>();

            List<String> csvRecordData = firstRow.split(',');

            if (firstRow.length()-1 == firstRow.lastIndexOf(','))  {
                csvRecordData.add('');
            }

            
            for (String fieldName: csvFieldNames) {
                Integer fieldNumber = fieldNumMap.get(fieldName);
                String fieldValue = csvRecordData.get(fieldNumber);
                valMap.put(fieldName.trim().replace('\r',''), fieldValue.trim().replace('\r',''));
                columnHeaders.add(fieldName.trim().replace('\r',''));
            }

            Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe()
                                                                .get(sobjType).getDescribe()
                                                                .fields.getMap();

            for (String colName : columnHeaders) {
                //must have value in all fields
                Schema.SObjectField sfield = objectFields.get(colName);
                if (sfield == null) {
                    return null;
                }
            }

            return columnHeaders;
    }

    public static List<String> isValidCSVUTF8Encoding(String dataString
                                                     ,List<String> colMigrateLst) {
        
        try {
            if (dataString.indexOf('\n') == -1) return null;

            String header   = dataString.substringBefore('\n');
            String firstRow = dataString.substring(header.length()+1
                                                    ,dataString.length()).substringBefore('\n');

            String[] csvFieldNames = header.split(',');
            Map<String,Integer> fieldNumMap = new Map<String,Integer>();

            for (Integer i = 0; i < csvFieldNames.size(); i++) {
                fieldNumMap.put(csvFieldNames[i], i);
            }

            List<String> columnHeaders = new List<String>();
            Map<String,String> valMap = new Map<String,String>();

            List<String> csvRecordData = firstRow.split(',');

            if (firstRow.length()-1 == firstRow.lastIndexOf(','))  {
                csvRecordData.add('');
            }

            for (String fieldName: csvFieldNames) {
                Integer fieldNumber = fieldNumMap.get(fieldName);
                String fieldValue = csvRecordData.get(fieldNumber);
                valMap.put(fieldName.trim().replace('\r',''), fieldValue.trim().replace('\r',''));
                columnHeaders.add(fieldName.trim().replace('\r',''));
            }

            for (String colName : columnHeaders) {
                //must have value in all fields
                if (!colMigrateLst.contains(colName)) {
                    return null;
                }
            }

            return columnHeaders;
        }catch (Exception e) {
            return null;
        }
    }

    public static String replaceNewLineForCSV(String source) {
        if (!source.substring(source.length()-1,source.length()).equals('\n')) return source+'\n';
        return source;
    }

    public static Map<String,List<Map<String,String>>> readCSVToMap(String dataString
                                                            ,List<String> colHeaderList
                                                            ,Integer batchSize) {
      Map<String,Integer> fieldNumMap = new Map<String,Integer>();

      for (Integer i = 0; i < colHeaderList.size(); i++) {
            fieldNumMap.put(colHeaderList.get(i), i);
      }

      return readCSVToMap(dataString
                         ,colHeaderList
                         ,batchSize
                         ,fieldNumMap);   
    }


    public static String DELIMETER_FOR_REPORT = '@_@';

    public static String getCSVReadableReport(String dataString) {
        
        if (dataString.contains(DELIMETER_FOR_REPORT)) {
            return dataString.replaceALl(DELIMETER_FOR_REPORT,' ');
        }


        String header = dataString.substringBefore('\n');
        List<String> csvFieldNamesLst = header.split(',');

        String contentCSV    = dataString.substring(header.length()+1
                                                    ,dataString.length());
        
        contentCSV    =  contentCSV.substringBefore('\n\n');

        List<String> dataLines = new List<String>();
        Integer STRING_LENGTH_LIMIT = 500000;
        Integer lengthBody = contentCSV.length();
        Integer lengthCount = 0;

        while(lengthCount < lengthBody) {
               String  subStr = null;

               if (contentCSV.length() >= STRING_LENGTH_LIMIT) {
                    subStr = contentCSV.substring(0, STRING_LENGTH_LIMIT);
                } else {
                    subStr = contentCSV.substring(0, contentCSV.length());
                }

                subStr = subStr.substringBeforeLast('\n');

                dataLines.addAll(subStr.split('\n'));

                lengthCount   += subStr.length()+1;

                if (contentCSV.length() >= subStr.length()+1) {
                    contentCSV = contentCSV.substring(subStr.length()+1, contentCSV.length());
                }
                
        }

        List<String> newdataLines = new List<String>();

        for (String line: dataLines) {
            List<String> rowLst = line.split(',');
            List<String> newrowLst = new List<String>();
            
            for (String row : rowLst) {
                if (newrowLst.size() > 0 && row.startswith(' ')) {
                    newrowLst[newrowLst.size() - 1] = newrowLst[newrowLst.size() - 1]+' '+row;
                }else {
                    
                    if (row != null && row.length() > 0 && !row.startsWith('"') && !row.endsWith('"')) {
                        row = '"'+row+'"';
                    }

                    if (row != null && row.length() > 0) {
                        row = '='+row;
                    }
                    newrowLst.add(row);
                }
            }

            newdataLines.add(String.join(newrowLst,','));
        }

        String extension = dataString.substringAfter('\n\n');

        return '\uFEFF'+header+'\n'+String.join(newdataLines,'\n')+'\n\n'+extension;
    }

    public static Map<String,List<Map<String,String>>> readCSVToMap(String dataString
                                                                    ,List<String> colHeaderList
                                                                    ,Integer batchSize
                                                                    ,Map<String,Integer> fieldNumMap) {

      Map<String,List<Map<String,String>>> valListMap = new Map<String,List<Map<String,String>>>();
      //List<String> dataLines = dataString.split('\n');

      List<String> dataLines = new List<String>();
      Integer STRING_LENGTH_LIMIT = 500000;
      Integer lengthBody = dataString.length();
      Integer lengthCount = 0;

      while(lengthCount < lengthBody) {
           String  subStr = null;

           if (dataString.length() >= STRING_LENGTH_LIMIT) {
                subStr = dataString.substring(0, STRING_LENGTH_LIMIT);
            } else {
                subStr = dataString.substring(0, dataString.length());
            }

            subStr = subStr.substringBeforeLast('\n');

            dataLines.addAll(subStr.split('\n'));

            lengthCount   += subStr.length()+1;

            if (dataString.length() >= subStr.length()+1) {
                dataString = dataString.substring(subStr.length()+1, dataString.length());
            }
            
       }

      List<Map<String,String>> mapList = new List<Map<String,String>>();
      valListMap.put(String.valueOf(valListMap.size()),mapList);

      for (String line: dataLines) {
            Map<String,String> valMap = new Map<String,String>();
            if (mapList.size() == batchSize) {
                mapList = new List<Map<String,String>>();
                valListMap.put(String.valueOf(valListMap.size() + 1),mapList);
            }
            
            mapList.add(valMap);

            List<String> csvRecordData = line.split(',');

            if (line.length()-1 == line.lastIndexOf(','))  {
                csvRecordData.add('');
            }


            for (String fieldName: colHeaderList) {
                if (!fieldName.startsWith(NOT_UPDATE_FIELD)) {
                    Integer fieldNumber = fieldNumMap.get(fieldName);
                    String fieldValue = csvRecordData.get(fieldNumber);
                    valMap.put(fieldName.trim(), fieldValue.trim());
                }
            }
      }
      return valListMap;   
    }

   public static Map<String,List<Sobject>> readCSVToSobjectList(String dataString
                                                    ,String sobjType
                                                    ,Integer batchSize
                                                    ,Map<String,String> mapField
                                                    ,List<String> columnHeaders) {

    Map<String,List<Sobject>> sobjMap = new Map<String,List<Sobject>>();

    String listType = 'List<' + sobjType + '>';
    

    Map<String,List<Map<String,String>>> mapData = readCSVToMap(dataString
                                                                ,columnHeaders
                                                                ,batchSize);

    Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe()
                                                    .get(sobjType).getDescribe()
                                                    .fields.getMap();
    for (String key : mapData.keyset()) {
        List<Sobject> sObjectList = (List<SObject>)Type.forName(listType).newInstance();

        List<Map<String,String>> mapList = mapData.get(key);

        for (Map<String,String> mapObj : mapList) {
            Sobject sobj = (SObject)Type.forName(sobjType).newInstance();

            for (String field :  mapObj.keySet()) {
                if (mapField.get(field) != null) {
                     String relField = mapField.get(field);
                     if (relField.contains('.')) {
                        List<String> sffieldList = relField.split('\\.');
                        //suport for 1 level
                        Sobject relObj = (SObject)Type.forName(sffieldList.get(0)).newInstance();
                        relObj.put(sffieldList.get(1),mapObj.get(field));
                        sobj.putSObject(field.replace('__c','__r'), relObj);         
                    }
                }else {
                    Schema.SObjectField sfield = objectFields.get(field);
                    String fieldType = sfield.getDescribe().getType().name();

                    if (fieldType == 'DATE') {
                        sobj.put(field,Date.valueOf(mapObj.get(field)));
                    }else {
                        sobj.put(field,String.valueOf(mapObj.get(field)));
                    } 
                }
            }

            sObjectList.add(sobj);
        }

        sobjMap.put(key,sObjectList);
    }

    return sobjMap;
  }
}