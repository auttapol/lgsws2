public with sharing class ReportMobileExtension{

    public account acct {get;set;}
    public decimal RecordCount {get;set;}
    public decimal RecordCountP {get;set;}
    public decimal FamilyCount {get;set;}
    public decimal HierarchyCount {get;set;}
    public decimal StageCount {get;set;}
    public double SumOS {get;set;}
    public double SumAVG {get;set;}
    public double SumLimit {get;set;}
    public double SumAmt {get;set;}
    public boolean DataExist {get;set;}
    public string errorMsg {get;set;}
    public List<Product_Information_On_Hand__c> onhand {get;set;}
    public List<Product_Information_Detail__c> detail {get;set;}
    public List<AggregateResult> detail2 {get;set;}
    public List<Opportunity> oppt {get;set;}
    public List<AggregateResult> CountPRD {get;set;}
    public List<AggregateResult> CountPipe {get;set;}
    public Map<String,String> PRDNameMap {get;set;}
    public Map<String,double> FamSumOSMap {get;set;}
    public Map<String,double> FamSumAVGMap {get;set;}
    public Map<String,double> FamSumLimitMap {get;set;}
    public Map<String,double> PRDSumOSMap {get;set;}
    public Map<String,double> PRDSumAVGMap {get;set;}
    public Map<String,double> PRDSumLimitMap {get;set;}
    public Map<String,Integer> FamCountMap {get;set;}
    public Map<String,Integer> PRDCountMap {get;set;}
    public List<Opportunity> Optdetail {get;set;}
    public Map<String,double> StageSumMap {get;set;}
    public Map<Decimal,double> ProbSumMap {get;set;}
    public Map<String,Integer> StageCountMap {get;set;}
    public Map<Decimal,Integer> ProbCountMap {get;set;}
    public String CustomerStage {get;set;}     
    public integer recordDomain4 {get;set;}
    public Map<String,Integer> familyDomain4 {get;set;}
    public Map<String,Integer> hierarchyDomain4 {get;set;}
    
        public ReportMobileExtension(ApexPages.standardController sc){
        account acc = (account)sc.getRecord();
        acct = [select ID,Account_Type__c from account where id =: acc.ID];
        CustomerStage = acct.Account_Type__c ;
        DataExist = true;
        errorMsg = '';
        recordDomain4 = 0;

        }
        
        public void report1(){
        callReport('%Transactional%');
        }
        
        public void report2(){
        callReport('%Deposit%');
        }
        
        public void report3(){
        callReport('%Funding%');
        }
        
        public void report4(){
        callReport('%Risk%');
        }
        
        public void credit(){
        callCreditReport('Credit');
        }
        
        public void noncredit(){
        callCreditReport('Non-Credit');
        }
        
        
        public void callReport(String Domain){
        
         try {
         
            system.debug('acct.id '+acct.id);
            CountPRD = [select COUNT_DISTINCT(id),COUNT_DISTINCT(Product_Family__c),COUNT_DISTINCT(Product_Hierachy_Code__c ), SUM(Ending_out_Ending_Balance__c),SUM(Avg_out__c),SUM(Limit_Balance__c) from Product_Information_Detail__c where Customer__c =: acct.ID and Product_Domain__c like :Domain];
            for (AggregateResult ar : CountPRD ){
            RecordCount = Integer.valueOf(ar.get('expr0'));
            FamilyCount = Integer.valueof(ar.get('expr1'));
            HierarchyCount = Integer.valueof(ar.get('expr2'));
            SumOS= (Double.valueof(ar.get('expr3')) != null) ? Double.valueof(ar.get('expr3'))  : 0.00;
            SumAVG= (Double.valueof(ar.get('expr4')) != null) ? Double.valueof(ar.get('expr4'))  : 0.00;
            SumLimit= (Double.valueof(ar.get('expr5')) != null) ? Double.valueof(ar.get('expr5'))  : 0.00; 
            } 
            
            onhand = [select id,Product_Family__c,Product_Hierachy_Code__c,Product_Hierachy_Code__r.Name from Product_Information_On_Hand__c where Account__c =: acct.ID and Product_Domain__c like :Domain ];
            system.debug('onhand  '+onhand);
            Set<String> records = new Set<String>();
            List<String> distinctFam = new List<String>();
            List<String> distinctHie = new List<String>();
            PRDNameMap = new Map<String,String>();
            Boolean found,found2 = false;
   
            
            for(Product_Information_On_Hand__c a: onhand){
            found = false;
            found2 = false;
             system.debug('a.Id '+a.Id);
                if(a.Id != null){
                records.add(a.Id);
                
                //if(a.Product_Family__c!=null){
                
                for(Integer i=0; i< distinctFam.size(); i++){
                    //Check if current name has been added yet
                    if(a.Product_Family__c.equalsIgnoreCase(distinctFam[i])){ 
                        found=true;
                     
                    }
                   
                }
                if(!found){
                    if(a.Product_Family__c==null){
                    distinctFam.add('-');
                    }else{
                    distinctFam.add(a.Product_Family__c);
                    }
                }
                
               // } //check fam null
                
                //if(a.Product_Hierachy_Code__c!=null){
                
                for(Integer i=0; i< distinctHie.size(); i++){
                    //Check if current name has been added yet
                    if(a.Product_Hierachy_Code__r.Name.equalsIgnoreCase(distinctHie[i])){ 
            
                        found2=true;
                       
                    }
                }
                if(!found2){
                    //distinctHie.add(a.Product_Hierachy_Code__c);
                    //PRDNameMap.put(a.Product_Hierachy_Code__c,a.Product_Hierachy_Code__r.Name);
                    if(a.Product_Hierachy_Code__c==null){
                    distinctHie.add('-');
                    PRDNameMap.put('-','-');
                    }else{
                    distinctHie.add(a.Product_Hierachy_Code__c);
                    PRDNameMap.put(a.Product_Hierachy_Code__c,a.Product_Hierachy_Code__r.Name);
                    }
                    
                }
                
               // } //check Hie null
                
                }
            }
            
            system.debug('distinctFam '+distinctFam);
            system.debug('distinctHie '+distinctHie);
            system.debug('PRDNameMap '+PRDNameMap);
            
            FamSumOSMap= new Map<String,double>();
            FamSumAVGMap= new Map<String,double>();
            FamSumLimitMap= new Map<String,double>();
            PRDSumOSMap= new Map<String,double>();
            PRDSumAVGMap= new Map<String,double>();
            PRDSumLimitMap= new Map<String,double>();
            FamCountMap= new Map<String,Integer>();
            PRDCountMap= new Map<String,Integer>();
            familyDomain4= new map<string,integer>();
            hierarchyDomain4= new map<string,integer>();
            
            for(String f: distinctFam){
                if(f=='-')f=null;
                system.debug('distinctFam '+f);
                //List<AggregateResult> SumFam = [select SUM(Ending_out_Ending_Balance__c),SUM(Avg_out__c),Count(Product_Family__c ) from Product_Information_On_Hand__c where Account__c =: acct.ID and Product_Domain__c like :Domain and Product_Family__c =: f ];
                List<AggregateResult> SumFam = [select SUM(Ending_out_Ending_Balance__c),SUM(Avg_out__c),Count(Id ),SUM(Limit_Balance__c) from Product_Information_Detail__c where Customer__c =: acct.ID and Product_Domain__c like :Domain and Product_Family__c =: f ];
                if(f==null)f='-';
                for (AggregateResult ar : SumFam ){
                    //SumOS= Double.valueof(ar.get('expr0'));
                    //SumAVG= Double.valueof(ar.get('expr1')); 
                    FamSumOSMap.put(f,(Double.valueof(ar.get('expr0'))!= null) ? Double.valueof(ar.get('expr0')) : 0.00 );
                    FamSumAVGMap.put(f,(Double.valueof(ar.get('expr1')) != null) ? Double.valueof(ar.get('expr1')) : 0.00 );
                    FamCountMap.put(f,Integer.valueof(ar.get('expr2')));
                    FamSumLimitMap.put(f,(Double.valueof(ar.get('expr3')) != null) ? Double.valueof(ar.get('expr3')) : 0.00 );
                } 
            
                for(aggregateResult ar : [select count_distinct(Product_Information__r.Product_Hierachy_Code__c),Product_Information__r.Product_Hierachy_Code__r.Family
                                          from Product_Information_Detail__c 
                                          where Customer__c =: acct.ID 
                                          and Product_Domain__c like :Domain 
                                          and Product_Family__c =: f
                                          group by Product_Information__r.Product_Hierachy_Code__r.Family])
                {
                    familyDomain4.put(f,Integer.valueof(ar.get('expr0')));
                }
            }
            
            for(String h: distinctHie){
                if(h=='-')h=null;
                system.debug('distinctHie '+h);
                //List<AggregateResult> SumPRD = [select SUM(Ending_out_Ending_Balance__c),SUM(Avg_out__c),Count(Product_Hierachy_Code__c ) from Product_Information_On_Hand__c where Account__c =: acct.ID and Product_Domain__c like :Domain and Product_Hierachy_Code__c =: h ];
                List<AggregateResult> SumPRD = [select SUM(Ending_out_Ending_Balance__c),SUM(Avg_out__c),Count(Product_Information__r.Product_Hierachy_Code__c ),SUM(Limit_Balance__c) from Product_Information_Detail__c where Customer__c =: acct.ID and Product_Domain__c like :Domain and Product_Information__r.Product_Hierachy_Code__c =: h ];
                if(h==null)h='-'; 
                for (AggregateResult ar : SumPRD ){
                    //SumOS= Double.valueof(ar.get('expr0'));
                    //SumAVG= Double.valueof(ar.get('expr1')); 
                    PRDSumOSMap.put(h,(Double.valueof(ar.get('expr0')) != null) ? Double.valueof(ar.get('expr0'))  : 0.00 );
                    PRDSumAVGMap.put(h,(Double.valueof(ar.get('expr1')) != null) ? Double.valueof(ar.get('expr1'))  : 0.00 );
                    PRDCountMap.put(h,Integer.valueof(ar.get('expr2')));
                PRDSumLimitMap.put(h,(Double.valueof(ar.get('expr3')) != null) ? Double.valueof(ar.get('expr3'))  : 0.00);
                } 
                
                for(aggregateResult ar : [select count_distinct(Product_Information__c),Product_Information__r.Product_Hierachy_Code__c
                                          from Product_Information_Detail__c 
                                          where Customer__c =: acct.ID 
                                          and Product_Domain__c like :Domain 
                                          and Product_Information__r.Product_Hierachy_Code__c =: h
                                          group by Product_Information__r.Product_Hierachy_Code__c])
                {
                    hierarchyDomain4.put(h,Integer.valueof(ar.get('expr0')));
                }
            }
            
            system.debug('FamSumOSMap '+FamSumOSMap);
            system.debug('FamSumAVGMap '+FamSumAVGMap);
            system.debug('PRDSumOSMap '+PRDSumOSMap);
            system.debug('PRDSumAVGMap'+PRDSumAVGMap);
            system.debug('FamCountMap'+FamCountMap);
            system.debug('PRDCountMap'+PRDCountMap);
            
            detail = [select Product_Family__c,Product_Information__r.No_of_Account__c,Product_Information__r.Product_Hierachy_Code__c,TMB_Account_ID__c,TMB_Suffix__c,TMB_Ref__c,Account_Name__c,Product_Description__c,Product_Description_link__c,Ending_out_Ending_Balance__c,Avg_out__c,Issue_Date__c,Maturity_Date__c,Rate__c,Limit_Balance__c,DPD_Date__c,Loan_Status__c,Id,Product_Performance_Name__c from Product_Information_Detail__c where Product_Information__c IN : records order by Product_Family__c,Product_Information__r.Product_Hierachy_Code__c ASC]; 
            
            detail2 = [select //product_family__c
                              Product_Information__r.Product_Hierachy_Code__r.Family
                              , Product_Information__r.Product_Hierachy_Code__c
                              //, Product_Description__c
                              , Product_Information__r.Product_Description__c
                              , avg(Product_Information__r.No_of_Account__c)
                              , Product_Information__c
                              from Product_Information_Detail__c 
                              where Product_Information__c IN : records 
                              group by 
                              //product_family__c
                              Product_Information__r.Product_Hierachy_Code__r.Family
                              , Product_Information__r.Product_Hierachy_Code__c
                              //, Product_Description__c
                              , Product_Information__r.Product_Description__c
                              //, Product_Information__r.No_of_Account__c
                              , Product_Information__c
                              order by //Product_Family__c
                              Product_Information__r.Product_Hierachy_Code__r.Family
                              ,Product_Information__r.Product_Hierachy_Code__c ASC];
            
            system.debug('detail '+detail);
            system.debug('detail '+detail2);
            
            recordDomain4 = detail2.size();

        }catch(exception e){
            DataExist = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            //errorMsg = Trigger_Msg__c.getValues('Perf_no_data').Description__c;
        }
        
        }
        
        public void callCreditReport(String Domain){
        
         try {
         
            system.debug('acct.id '+acct.id);
            CountPipe = [select COUNT_DISTINCT(id),COUNT_DISTINCT(StageName), SUM(Pipeline_Amt__c) from opportunity where AccountId =: acct.ID and Opportunity_Type__c = :Domain and Probability != 0 and Probability != 100];
            for (AggregateResult ar : CountPipe){
            RecordCountP = Integer.valueOf(ar.get('expr0'));
            StageCount = Integer.valueof(ar.get('expr1'));
            SumAmt= (Double.valueof(ar.get('expr2')) != null) ? Double.valueof(ar.get('expr2'))  : 0.00;
            } 
            
            system.debug('RecordCountP '+RecordCountP );
            system.debug('StageCount '+StageCount );
            system.debug('SumAmt '+SumAmt);
            
            
            oppt = [select id,StageName,Probability  from opportunity where AccountId =: acct.ID and Opportunity_Type__c = :Domain and Probability != 0 and Probability != 100];
            system.debug('oppt '+oppt );
            Set<String> records = new Set<String>();
            List<String> distinctStage = new List<String>();
            List<Decimal> distinctProb = new List<Decimal>();
            //PRDNameMap = new Map<String,String>();
            Boolean found,found2 = false;
   
            
            for(opportunity a: oppt ){
            found = false;
            found2 = false;
             system.debug('a.Id '+a.Id);
                if(a.Id != null){
                records.add(a.Id);
                
                if(a.StageName!=null){
                
                for(Integer i=0; i< distinctStage.size(); i++){
                    //Check if current name has been added yet
                    if(a.StageName.equalsIgnoreCase(distinctStage[i])){ 
            
                        found=true;
                        
                    }
                }
                if(!found){
                    distinctStage.add(a.StageName);
                }
                
                } //check fam null
                
                if(a.Probability !=null){
                
                for(Integer i=0; i< distinctProb.size(); i++){
                    //Check if current name has been added yet
                    if(a.Probability==distinctProb[i]){ 
            
                        found2=true;
                       
                    }
                }
                if(!found2){
                    distinctProb.add(a.Probability);
                    //PRDNameMap.put(a.Product_Hierachy_Code__c,a.Product_Hierachy_Code__r.Name);
                }
                
                } //check Hie null
                
                }
            }
            
            system.debug('distinctStage '+distinctStage);
            system.debug('distinctProb '+distinctProb);
            //system.debug('PRDNameMap '+PRDNameMap);
            
            StageSumMap= new Map<String,double>();
            ProbSumMap= new Map<Decimal,double>();
            
            StageCountMap= new Map<String,Integer>();
            ProbCountMap= new Map<Decimal,Integer>();
            for(String f: distinctStage){
            List<AggregateResult> SumStage = [select SUM(Pipeline_Amt__c),Count(Id)  from opportunity where AccountId =: acct.ID and Opportunity_Type__c = :Domain and Probability != 0 and Probability != 100 and StageName =: f ];
            
            for (AggregateResult ar : SumStage ){ 
            StageSumMap.put(f,(Double.valueof(ar.get('expr0')) != null) ? Double.valueof(ar.get('expr0')) : 0.00 );
            StageCountMap.put(f,Integer.valueof(ar.get('expr1')));
            } 
            }
            
            for(Decimal h: distinctProb){
            List<AggregateResult> SumProb = [select SUM(Pipeline_Amt__c),Count(Id)  from opportunity where AccountId =: acct.ID and Opportunity_Type__c = :Domain and Probability != 0 and Probability != 100 and Probability =: h ];
             
            for (AggregateResult ar : SumProb ){
            ProbSumMap.put(h,(Double.valueof(ar.get('expr0')) != null) ? Double.valueof(ar.get('expr0')) : 0.00 );
            ProbCountMap.put(h,Integer.valueof(ar.get('expr1')));
            } 
            }
            
            system.debug('StageSumMap '+StageSumMap);
            system.debug('ProbSumMap '+ProbSumMap);
            system.debug('StageCountMap '+StageCountMap);
            system.debug('ProbCountMap '+ProbCountMap);
            
            Optdetail = [select AccountId,Pipeline_Amt__c,Opportunity_Amount__c,Opportunity_amount_adjust__c,LastModifiedDate,CreatedDate,CloseDate,Complete_Date__c,Name,OwnerId,StageName,Probability  from opportunity where AccountId =: acct.ID and Opportunity_Type__c = :Domain and Probability != 0 and Probability != 100 order by StageName, Probability ]; 
            
            system.debug('Optdetail '+Optdetail);
            
        }catch(exception e){
            DataExist = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            //errorMsg = Trigger_Msg__c.getValues('Perf_no_data').Description__c;
        }
        
        }
        
    
}