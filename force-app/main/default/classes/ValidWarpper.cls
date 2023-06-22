public class ValidWarpper {
	public LeadLogValidDetail__c tempvalidlog { get; set;}
    
    public ValidWarpper(){
        tempvalidlog = new LeadLogValidDetail__c();
    }
    
    public ValidWarpper(LeadLogValidDetail__c v){
        tempvalidlog = v;
    }
}