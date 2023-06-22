public  without sharing  class QuestionnaireServiceImpl implements IQuestionnaireService {	
	
	public List<QuestionnaireService.BusinessOppInfo> GetQuestionairByWalletId(Id walletId){	
		
		map<String, list<String>> orders = new map<String, list<String>>
		{
		  /**/
		 'Domain I' => new list<String> {'Domestic|Collection', 'Domestic|Payment', 'Domestic|Liquidity Management','International|Collection'},
		 'Domain III' => new list<String> {
			 				  'Contingent Liability|L/G transaction with Government sector'
			 				 ,'Contingent Liability|L/G issuing : Aval/Acceptance'
			 				 ,'Contingent Liability|L/G issuing : International bank guarantee or Standby L/C'
			 				 ,'Contingent Liability|L/G issuing : Shipping guarantee'
			 				 ,'Contingent Liability|Request L/G from Buyer'
		 				},
		 'Domain IV' => new list<String> {
						 	  'Hedging|Normal business transaction : Credit risk protection (Trade transaction)' 
						 	 ,'Hedging|Normal business transaction : Other revenue/ expenditure'
						 	 ,'Hedging|Insurance : Credit life insurance'
						 	 ,'Hedging|Insurance : Non credit life insurance'
						 	 ,'Hedging|Insurance : Non life insurance'
						 	 ,'Hedging|Balance sheet management : Liability management'
						 	 ,'Hedging|Balance sheet management : Investment & Capital expenditure plan'
						 } ,
		 'Internet' => new list<String> {'Internet Banking|Business Click'}
		};

		Map<string,string> mapSubDomainAndProductLabel = new Map<string,string>();
		for(string domain : orders.keySet()){
			for(string val : orders.get(domain)){
				mapSubDomainAndProductLabel.put(val,domain);
			}
		}
			
		List<AcctPlanQuestionnaire__c> questionOfWallet = new List<AcctPlanQuestionnaire__c>();
		II_TestUtility utility = new II_TestUtility();	
		//Get Questionair wallet	
		List<AcctPlanQuestionnaire__c> main = QuestionnaireSelector.SelectQuestionairByWalletIds(new Set<Id>{walletId});
		if(main != null && main.size() > 0){
			questionOfWallet.addAll(main);
		}	
		
		system.debug(':::: questionOfWallet size = '+ questionOfWallet.size());
		
		//AcctPlanOtherRevenueExpenditureSelector
	    for(AcctPlanOtherRevenueExpenditure__c item : AcctPlanOtherRevenueExpenditureSelector.SelectQuestionairByWalletIds(new Set<Id>{walletId})){
	    	string m_domain ='Domain IV' ;
            string m_subdomain ='Hedging';
            string m_product ='Normal business transaction : Other revenue/ expenditure' ;            
			AcctPlanQuestionnaire__c qt = new AcctPlanQuestionnaire__c();
			qt.Id  = utility.getFakeId(AcctPlanQuestionnaire__c.SObjectType);	
			qt.AcctPlanWallet__c  = walletId;
			qt.Answer__c ='Yes';		
			qt.Opportunity__c = item.Opportunity__c;
			qt.Question__c = 'mock question';
			qt.Question_TH__c = 'mock question';
			qt.Sub_Domain__c    = m_subdomain;
			qt.Product_Label__c = m_product; 	
			qt.Segment__c = m_domain;
			questionOfWallet.add(qt);	 
	    }
	
	     
		//AcctPlanExistingLongTermLoan
	    for(AcctPlanExistingLongTermLoan__c item : AcctPlanExistingLongTermLoanSelector.SelectQuestionairByWalletIds(new Set<Id>{walletId})){
	    	 string m_domain ='Domain IV' ;
	        string m_subdomain ='Hedging';
	        string m_product ='Balance sheet management : Liability management' ;                     
			AcctPlanQuestionnaire__c qt = new AcctPlanQuestionnaire__c();
			qt.Id  = utility.getFakeId(AcctPlanQuestionnaire__c.SObjectType);	
			qt.AcctPlanWallet__c  = walletId;
			qt.Answer__c ='Yes';		
			qt.Opportunity__c = item.Opportunity__c;
			qt.Question__c = 'mock question';
			qt.Question_TH__c = 'mock question';
			qt.Sub_Domain__c    = m_subdomain;
			qt.Product_Label__c = m_product; 	
			qt.Segment__c = m_domain;
			questionOfWallet.add(qt);		 
	    }
		
		//AcctPlanCapitalExpenditurePlan
		for(AcctPlanCapitalExpenditurePlan__c item : AcctPlanCapitalExpenditurePlanSelector.SelectQuestionairByWalletIds(new Set<Id>{walletId})){
			
			string m_domain ='Domain IV' ;
            string m_subdomain ='Hedging';
            string m_product ='Balance sheet management : Investment & Capital expenditure plan' ;                     
			AcctPlanQuestionnaire__c qt = new AcctPlanQuestionnaire__c();
			qt.Id  = utility.getFakeId(AcctPlanQuestionnaire__c.SObjectType);	
			qt.AcctPlanWallet__c  = walletId;
			qt.Answer__c ='Yes';		
			qt.Opportunity__c = item.Opportunity__c;
			qt.Question__c = 'mock question';
			qt.Question_TH__c = 'mock question';
			qt.Sub_Domain__c    = m_subdomain;
			qt.Product_Label__c = m_product; 	
			qt.Segment__c = m_domain;
			questionOfWallet.add(qt);	 
		}
		system.debug('::: Start Make Data :::');			
		Map<string/*Domain Name*/,List<AcctPlanQuestionnaire__c>> domainItems  = new  Map<string/*DomainWhitelist 1*/,List<AcctPlanQuestionnaire__c>>();											 	
		for(AcctPlanQuestionnaire__c qt : questionOfWallet){		    
		    string key = qt.Sub_Domain__c +'|'+qt.Product_Label__c;		    
		    if(mapSubDomainAndProductLabel.containsKey(key)){	 				
		        // Create new if not exist key
		        if(	!domainItems.containsKey(mapSubDomainAndProductLabel.get(key)/*Get Domain Name */)){
		            system.debug('::: >>>>PUT FOR DOMAIN = ' + key);
		            domainItems.put(mapSubDomainAndProductLabel.get(key), new List<AcctPlanQuestionnaire__c>());
		        }	
		        domainItems.get(mapSubDomainAndProductLabel.get(key)).add(qt);	 			 				
		    }
		}			
        Map<string,string> DomainLabel = new Map<string,string>{
														            'Domain I' => 'Domain I: Transactional Banking',
														            'Domain III' => 'Domain III: Funding & Borrowing',
														            'Domain IV' => 'Domain IV: Risk Protection',
														            'Internet' => 'Internet Banking'
														       };
       
       
       Map<string,QuestionnaireService.BusinessOppInfo> Display = new Map<string,QuestionnaireService.BusinessOppInfo>();
       for(string domain : DomainLabel.keySet()){
            system.debug('::: >>>> >>>>LOOP FOR DOMAIN = ' + domain);                   
           
            if(domainItems.containsKey(domain)){             
	            if(!Display.containsKey(domain))				
	                Display.put(domain , new QuestionnaireService.BusinessOppInfo(DomainLabel.get(domain)));
	            QuestionnaireService.BusinessOppInfo workItem = Display.get(domain);
	            
	            
	            
	            map<string,List<AcctPlanQuestionnaire__c>> items = new   map<string,List<AcctPlanQuestionnaire__c>>();
	            for(AcctPlanQuestionnaire__c item : domainItems.get(domain)){
	            	
	            	if(!items.containsKey(item.Sub_Domain__c+'|'+item.Product_Label__c)){
	            		 items.put(item.Sub_Domain__c+'|'+item.Product_Label__c,new List<AcctPlanQuestionnaire__c>());
	            	}
	            	items.get(item.Sub_Domain__c+'|'+item.Product_Label__c).add(item);
	                
	            }
	            
	            
	            for(string key : orders.get(domain)){	            	
	            	if(items.containsKey(key)){	
	            		            		
	            		List<AcctPlanQuestionnaire__c> objs = items.get(key);
	            		 //Each Item Each Domain
		                for(AcctPlanQuestionnaire__c  item : objs){
			                if(!workItem.Sectors.containsKey(item.Sub_Domain__c))
			                {
			                    system.debug('::: >>>> >>>> >>>>Create BusinessOppInfo = ' + item.Sub_Domain__c);
			                    workItem.Sectors.put(item.Sub_Domain__c, new QuestionnaireService.BusinessOppInfoSector(item.Sub_Domain__c));
			                }
			                QuestionnaireService.BusinessOppInfoSector oppsector = workItem.Sectors.get(item.Sub_Domain__c);	
			                if(!oppsector.ProductLable.containsKey(item.Product_Label__c)){                    
			                    QuestionnaireService.ProductLable prd = new QuestionnaireService.ProductLable(item.Product_Label__c,item.Sub_Domain__c);
			                    oppsector.ProductLable.put(item.Product_Label__c,prd);
			                    system.debug('::: >>>> >>>> >>>>Create New ProductLable With Key = ' + item.Product_Label__c +'  >>>> Under SubDomain = '+item.Sub_Domain__c);                    
			                }
			                QuestionnaireService.ProductLable productLabel = oppsector.ProductLable.get(item.Product_Label__c);		
			                productLabel.Questionnaires.add(item);	
		                }	
	            	}
	            }	            
            }            
        }
        system.debug('::: End Make Data :::');        
        return Display.values();
        
	}
}