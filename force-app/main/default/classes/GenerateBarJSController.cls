public class GenerateBarJSController{
   public String barcodeData {get;set;}
   public String CAID {get;set;}
   public Boolean stopPolling {get;set;}
   private String opptyId;


   public GenerateBarJSController(ApexPages.StandardController stdController) {
      opptyId = String.valueof(stdController.getRecord().get('id'));
   }

   public PageReference redirectToPDF(){  
      Opportunity oppty = new Opportunity(Id = opptyId);
      String imageSrc = '<img alt="'+CAID+'" src="'+barcodeData+'" width="300" height="80"/>';
      oppty.Barcode_Image__c = imageSrc;
      update oppty;


      PageReference page = new PageReference('/apex/GeneratebarCode');
      page.getParameters().put('nooverride','1');   
      page.getParameters().put('id',opptyId);
      page.setRedirect(true); 
      return page;  
   }

}