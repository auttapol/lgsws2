public class ProductSelectionController {
    public List<Product2> ProductsList {get;set;}
    public List<ProductWrapper> ProductWrapperList {get;set;}
    public List<SelectOption> ProductLevel1SelectOption {get;set;}
    public List<SelectOption> ProductLevel2SelectOption {get;set;}
        public List<SelectOption> ProductLevel3SelectOption {get;set;}
        public List<SelectOption> ProductLevel4SelectOption {get;set;}
        public List<SelectOption> ProductLevel5SelectOption {get;set;}
        public List<SelectOption> ProductdomainSelectOption {get;set;}

    public String Product1Selected {get;set;}
    public String Product2Selected {get;set;}
        public String Product3Selected {get;set;}
        public String Product4Selected {get;set;}
        public String Product5Selected {get;set;}
        public String  productdomainselected {get;set;}
        public String domainselected {get;set;} 
    
    public boolean IsProduct1HasValue{get;set;}
    public boolean IsProduct2HasValue{get;set;}
    public boolean IsProduct3HasValue{get;set;}
    public boolean IsProduct4HasValue{get;set;}
    
    public Opportunity oppty {get;set;}
    public List<SelectOption> PricebookOptionList {get;set;}
    public String pricebookselected {get;set;}
    public String ActionPlanId {get;set;}  
    public String CompanyID {get;set;} 
    public String opptyid {get;set;}
    public String pageName {get;set;}
    public String AccountName{get;set;}
    
    public Integer NoProd {get;set;}
    public String[] Prodcode {get;set;}
    public String[] Prodname {get;set;}
    public Map<String,PricebookEntry> ProductPricebookMap {get;set;}

    public String msgProductSelection {get;set;}

    public ProductSelectionController(Apexpages.StandardController ctrl){
        pageName = ApexPages.CurrentPage().getUrl();  
        pageName = pageName.replaceFirst('/apex/','');         
        pageName = EncodingUtil.urlEncode(pageName, 'UTF-8');  
        string[] pageNameExtra = pageName.split('%3F',0);   
        pageName = pageNameExtra[0];
        
       
        msgProductSelection = Account_Plan_Status_Code__c.GetValues('5034').Status_Message__c;
        
        if(pageName =='ProductSelection'){
            pricebookselected = ApexPages.currentPage().getParameters().get('pricebookid');
            opptyid = ApexPages.currentPage().getParameters().get('opptyid');
          ProductWrapperList = new List<ProductWrapper>();
          ProductLevel1SelectOption = new List<SelectOption>();
            if(opptyid !=null && opptyid !='' &&pricebookselected!=null && pricebookselected!=''){  
               
             ProductLevel1SelectOption.add(new SelectOption('','Please Select'));
                for(Product2 prod : queryproductlist('','1')){ 
                    ProductWrapper pw = new ProductWrapper();
                    pw.product = prod;
                    pw.IsSelected =false;
            ProductWrapperList.add(pw);             
            ProductLevel1SelectOption.add(new SelectOption(prod.id,prod.Name));
                }
            }else{
                 //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Opportunity ID and Pricebook cannot be null.'));
                 ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('5017').Status_Message__c));
        
           
            }   
        
        
        
        
        }else if (pagename=='OpportunityPriceBookSelection'){
            try{
                 oppty = (Opportunity)ctrl.getRecord();
                pricebookselected =null;
                String oppid = oppty.id;
                if(oppid !=null && oppid != ''){
                    
                    PricebookOptionList = new List<Selectoption>();
                   oppty =[SELECT ID,Name from opportunity WHERE ID =:oppid LIMIT 1]; 
                    
               for(pricebook2 pb : [Select Id, Name, IsStandard 
                     From Pricebook2  where IsStandard = false]){
                          PricebookOptionList.add(new SelectOption(pb.id,pb.name));
                     }
                    
                }else{
                     //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Not found any opportunity record or ID is null.'));
                     ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('5018').Status_Message__c));
        
                }
            }catch(DMLException e){
                 //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Not found any opportunity record or ID is null.'));
                 ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('5018').Status_Message__c));
        
           
            }
        }
        else if (pagename=='NIProjectionProduct'){
           System.debug(':::::::::::  NIProjectionProduct ::::::::');     
        
            try{
            
                //oppty = (Opportunity)ctrl.getRecord();
                //String oppid = oppty.id;
                //System.debug('oppid  :'+oppid );
                pricebookselected =null;
                ActionPlanId= ApexPages.currentPage().getParameters().get('ActionPlanID');
                CompanyID= ApexPages.currentPage().getParameters().get('CompanyID');
                productdomainselected = ApexPages.currentPage().getParameters().get('Domain');
                //AccountName= ApexPages.currentPage().getParameters().get('AccountName');
                AcctPlanCompanyProfile__c companyprofile = AccountPlanUtilities.QueryCompanyProfileByID(CompanyID).get(0);
             	AccountName = companyprofile.AccountName__c;
                Pricebook2 standardPricebook = new Pricebook2(); 
                Pricebook2[] Records = [SELECT Name FROM Pricebook2 WHERE IsActive = true ORDER BY Name ASC];
                Map<String,Pricebook2> pricebookmap = new Map<String,Pricebook2>();
                for(Pricebook2 R : Records){
                   pricebookmap.put(r.Name,r);
                }
                
                //System.debug('Pricebook :'+Records+' Map :'+pricebookmap);

                User us = [SELECT ID,Segment__c FROM User WHERE ID=:UserInfo.getUserId() LIMIT 1]; 
                //User us = [SELECT ID,Segment__c FROM User WHERE ID='005O0000002b85q' LIMIT 1];  CB
                //System.debug('user : '+us);
          
                if(us.Segment__c != null){
                   //standardPricebook.id = pricebookmap.get('SE Price Book').id;
                    pricebookselected = pricebookmap.get(Price_book_access__c.GetValues(us.Segment__c).PricebookItem__c).id;
                  
                }else if(Test.isRunningTest()){
                    pricebookselected = Test.getStandardPricebookId();
                }else{ 
                    pricebookselected = pricebookmap.get(Price_book_access__c.GetValues('Default').PricebookItem__c).id;
                }
                
                ProductWrapperList = new List<ProductWrapper>();
                ProductdomainSelectOption = new List<SelectOption>();
               // if(productdomainselected !=null && productdomainselected!='' &&pricebookselected!=null && pricebookselected!=''){  
                   
                 ProductdomainSelectOption.add(new SelectOption('','Please Select'));
                 ProductdomainSelectOption.add(new SelectOption('1','1. Transactional Banking'));
                 ProductdomainSelectOption.add(new SelectOption('2','2. Deposit and Investment'));
                 ProductdomainSelectOption.add(new SelectOption('3','3. Funding & Borrowing'));
                 ProductdomainSelectOption.add(new SelectOption('4','4. Risk Protection'));
                 
                 
                 if(productdomainselected=='1'){
                     domainselected = '%Transaction%';
                    }else if(productdomainselected=='2'){
                     domainselected = '%Deposit%';
                    }else if(productdomainselected=='3'){
                     domainselected = '%Fund%';
                    }else if(productdomainselected=='4'){
                     domainselected = '%Risk%';
                    }
                    
                    system.debug('domainselected '+domainselected );
                 
                        for(Product2 prod : queryproductlistNI(domainselected ,'0')){ 
                            ProductWrapper pw = new ProductWrapper();
                            pw.product = prod;
                            pw.IsSelected =false;
                            ProductWrapperList.add(pw);             
                   //ProductdomainSelectOption.add(new SelectOption(prod.id,prod.Name));
                        }
                //    }
              
            }catch(DMLException e){
                 //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Not found any opportunity pricebook record or ID is null.'));
                 ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('5019').Status_Message__c));
        
           
            }
        }
         System.debug('pricebook :  '+pricebookselected);
        
    }
    
    public void refreshselected(){
        ProductsList = new List<Product2>();
        ProductWrapperList = new List<ProductWrapper>();
        System.debug(Product4Selected + ' : ' + Product3Selected + ' : ' + Product2Selected + ' : ' + Product1Selected );
    }
    
    
    public void productdomainselect(){
              refreshselected();
              
              if(productdomainselected=='1'){
                     domainselected = '%Transaction%';
                    }else if(productdomainselected=='2'){
                     domainselected = '%Deposit%';
                    }else if(productdomainselected=='3'){
                     domainselected = '%Fund%';
                    }else if(productdomainselected=='4'){
                     domainselected = '%Risk%';
                    }
                    
                    system.debug('domainselected '+domainselected );
              
            //if(productdomainselected != null ){
            //IsProduct1HasValue =true;
            //ProductLevel2SelectOption = new List<SelectOption>();
            //ProductLevel2SelectOption.add(new SelectOption('','Please Select'));
             for(Product2 prod :  queryproductlistNI(domainselected ,'0')){
                 ProductWrapper pw = new ProductWrapper();
                                    pw.product = prod;
                                    pw.IsSelected =false;
                            ProductWrapperList.add(pw); 
                 //ProductLevel2SelectOption.add(new SelectOption(prod.id,prod.Name));
      }
        //System.debug(IsProduct1HasValue);
    }
    
    public void product1select(){
        refreshselected();

        if(Product1Selected != null ){
            IsProduct1HasValue =true;
            ProductLevel2SelectOption = new List<SelectOption>();
            ProductLevel2SelectOption.add(new SelectOption('','Please Select'));
             for(Product2 prod :  queryproductlist(product1selected,'4')){
                 ProductWrapper pw = new ProductWrapper();
                                    pw.product = prod;
                                    pw.IsSelected =false;
                            ProductWrapperList.add(pw); 
                 ProductLevel2SelectOption.add(new SelectOption(prod.id,prod.Name));
            } 
        }else{
           IsProduct1HasValue =false;
             clarify();
        }
        System.debug(IsProduct1HasValue);
    }
    
     public void product2select(){
          refreshselected();
        if(Product2Selected != null && Product1Selected != null){
            IsProduct2HasValue =true;
            ProductLevel3SelectOption = new List<SelectOption>();
            ProductLevel3SelectOption.add(new SelectOption('','Please Select'));
             for(Product2 prod :  queryproductlist(product2selected,'5')){
                 ProductWrapper pw = new ProductWrapper();
                                    pw.product = prod;
                                    pw.IsSelected =false;
                            ProductWrapperList.add(pw); 
                 
                 ProductLevel3SelectOption.add(new SelectOption(prod.id,prod.Name));
            } 
        }
         else{
           clarify();
         }
    }
    
    public void product3select(){
         refreshselected();
        if(Product3Selected != null && Product2Selected != null && Product1Selected != null){
            IsProduct3HasValue =true;
            ProductLevel4SelectOption = new List<SelectOption>();
            ProductLevel4SelectOption.add(new SelectOption('','Please Select'));
            System.debug(product3selected);
             for(Product2 prod :  queryproductlist(product3selected,'6')){
                 ProductWrapper pw = new ProductWrapper();
                                    pw.product = prod;
                                    pw.IsSelected =false;
                            ProductWrapperList.add(pw); 
                 
                 ProductLevel4SelectOption.add(new SelectOption(prod.id,prod.Name));
            } 
        }else{
             clarify();
        }
    }
    
    public void product4select(){
         refreshselected();
        if(Product4Selected != null && Product3Selected != null && Product2Selected != null && Product1Selected != null){
            IsProduct4HasValue =true;
           ProductLevel5SelectOption = new List<SelectOption>();
            ProductLevel5SelectOption.add(new SelectOption('','Please Select'));
             for(Product2 prod :  queryproductlist(product4selected,'7')){
                 ProductWrapper pw = new ProductWrapper();
                                    pw.product = prod;
                                    pw.IsSelected =false;
                            ProductWrapperList.add(pw); 
                 
                 ProductLevel5SelectOption.add(new SelectOption(prod.id,prod.Name));
            } 
        }else{
           clarify();
        }
    }
    
    public void clarify(){
              if( product1selected ==null){IsProduct1HasValue = false;product2selected=null;}
             if( product2selected ==null){IsProduct2HasValue = false;product3selected=null;}
             if( product3selected ==null){IsProduct3HasValue = false;product4selected=null;}
             if( product4selected ==null){IsProduct4HasValue = false;product5selected=null;}

    }
    
    private List<Product2> queryproductlist(String domain,String level ){
        List<PricebookEntry> PricebookList = [SELECT ID,Name,
                                      IsActive,Product2Id,
                                      Pricebook2Id,
                                      Product2.Name,
                                      Product2.Product_Level__c,
                                      Product2.ProductCode
                                      From PricebookEntry 
                                      WHERE IsActive =: true
                                     AND PriceBook2ID =: pricebookselected
                                     AND Product2.Product_Level__c =:level
                                     AND Product2.Product_Domain__c =:domain];
        
        ProductsList = new List<Product2>();
        ProductPricebookMap = new Map<String,PricebookEntry>();
        for(PricebookEntry PbE : PricebookList){
            ProductsList.add(PbE.Product2);
            ProductPricebookMap.put(Pbe.PRoduct2.id,pbe);
        }
           
            return productslist;
    }
    
    
        private List<Product2> queryproductlistNI(String domain,String level ){
        List<PricebookEntry> PricebookList = [SELECT ID,Name,
                                      IsActive,Product2Id,
                                      Pricebook2Id,
                                      Product2.Name,
                                      Product2.Product_Level__c,
                                      Product2.family,
                                      Product2.ProductCode,
                                      Product2.Product_Domain__c        
                                      From PricebookEntry 
                                      WHERE IsActive =: true
                                     AND PriceBook2ID =: pricebookselected
                                     //AND Product2.Product_Level__c =:level
                                     //AND Product2.Product_Domain__c =:domain]; 
                                     AND Product2.Product_Domain__c Like : domain order by Product2.Name ];
        System.debug('pricebookselected :  '+pricebookselected);
       System.debug('level:  '+level);
        System.debug('domain:  '+domain);
        ProductsList = new List<Product2>();
        ProductPricebookMap = new Map<String,PricebookEntry>();
        for(PricebookEntry PbE : PricebookList){
            ProductsList.add(PbE.Product2);
            ProductPricebookMap.put(Pbe.PRoduct2.id,pbe);
        }
           
            return productslist;
    }
    
    
    public PageReference selectpricebook() {
        System.debug('pricebookselected :  '+pricebookselected);
        
        PageReference productselect = Page.ProductSelection;
         productselect.getParameters().put('pricebookid',pricebookselected);
         productselect.getParameters().put('opptyid',oppty.id);
        productselect.setRedirect(true);
        return productselect;
    }
    
    
    public PageReference SelectedProduct(){
        if(pageName != 'NIProjectionProduct'){
        
        List<Product2> productselectedlist = new List<Product2>();
        for(ProductWrapper pw : ProductWrapperList){
            if(pw.isSelected == true){
               productselectedlist.add(pw.product);
            }
        }
        
         System.debug('Selected Product: '+productselectedlist);
         //System.debug('pageName : '+pageName );
        
        
        
        //ProductPricebookMap
        
                
        
        
        
        if(productselectedlist.size() > 0){
            List <OpportunityLineItem> Opplinelist = new List<OpportunityLineItem >();
            for(Product2 pro : productselectedlist){
                
                OpportunityLineItem opline = new OpportunityLineItem ();
                opline.OpportunityId = opptyid;
                opline.PricebookEntryId = ProductPricebookMap.get(pro.id).id;
                opline.isTemporary__c =true;
                opline.UnitPrice =1;          
                opline.Quantity = 1;
                Opplinelist.add(opline);
            }
            
            try{
                insert Opplinelist;
                
                PageReference addOppor = Page.AddProductsToOpp;
                addOppor.getParameters().put('opptyid',opptyid);
                addOppor.getParameters().put('pricebookid',pricebookselected);
                addOppor.setRedirect(true);
                return addOppor;
            }catch(DMLException e ){ 
                   ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            }
            
            
            
        }else{
             //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select at least one row.'));
             ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('5020').Status_Message__c));
        
           
        }
         }else{
            //AccountPlan NI Projection Add Product
            
            
             try{
                
                PageReference nidetails = Page.NIProjectionDetails;
                nidetails.getParameters().put('ActionPlanID',ActionPlanId);
                nidetails.getParameters().put('CompanyID',CompanyID);
                /*for(integer i=0;i<NoProd;i++){
                nidetails.getParameters().put('ProdCode'+string.valueof(i),ProdCode[i]);
                nidetails.getParameters().put('ProdName'+string.valueof(i),ProdName[i]);
                system.debug('ProdCode[i] '+ProdCode[i]);
                system.debug('ProdName[i] '+ProdName[i]);
                }*/
                NoProd = 0;
                List<Product2> productselectedlist = new List<Product2>();
                    for(ProductWrapper pw : ProductWrapperList){
                        if(pw.isSelected == true){
                           //ProdCode[NoProd] = string.valueof(pw.product.Id);
                            //ProdName[NoProd] = string.valueof(pw.product.Name);
                            nidetails.getParameters().put('ProdCode'+string.valueof(NoProd), string.valueof(pw.product.Id));
                            nidetails.getParameters().put('ProdName'+string.valueof(NoProd),string.valueof(pw.product.Name));
                            NoProd++;
                        }
                    }
                    system.debug('NoProd '+NoProd );
                if(NoProd > 0){    
                nidetails.getParameters().put('NoProd',string.valueof(NoProd));
                system.debug('NoProd '+NoProd);
                nidetails.setRedirect(true);
                return nidetails;
                }else{
                 //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select at least one row.'));
                 ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('5020').Status_Message__c));
        
                }
            }catch(DMLException e ){
                   ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            }
            
        }
        
        
        return null;
        
    }
    
    public class ProductWrapper {
        public boolean IsSelected {get;set;}
        public Product2 product {get;set;}
        
    }
}