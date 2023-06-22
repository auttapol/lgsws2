public class PurgeBatchHistoryServices {
    public List<BatchHistory__c> batchHistory {get;set;}
    public void Purgelog(){
        // Modify by Chatcharin N. - Change process to use for loop
        //batchHistory = new List<BatchHistory__c>([SELECT Id, LastModifiedDate,(SELECT Id FROM Batch_History_Detail__r) FROM BatchHistory__c]);
        batchHistory = new List<BatchHistory__c>();
        for(BatchHistory__c listbH : [SELECT Id, LastModifiedDate,(SELECT Id FROM Batch_History_Detail__r) FROM BatchHistory__c]){
            batchHistory.add(listbh);
        }
        // Modify End
        List<BatchHistory__c> deleteBatchHistory = new List<BatchHistory__c>();
        Integer purgeTime = Integer.valueOf('-'+AppConfig__c.getValues('Days_of_Delete_BatchHistory').Value__c); 
        if(batchHistory.size() > 0){
            for(BatchHistory__c bth : batchHistory){
                if(bth.LastModifiedDate.date() < system.today().addDays(purgeTime)){
                    system.debug(bth);
               		deleteBatchHistory.add(bth);
            	}
            }
        }
        if(deleteBatchHistory.size() > 0){
          delete deleteBatchHistory; 
        }
    }
}