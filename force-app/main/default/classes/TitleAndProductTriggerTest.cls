@isTest
public class TitleAndProductTriggerTest {

    @TestSetup
    static void makeData(){
        createUser(5, 'Fmockuser', 'Lmockuser', 'mockuserForTrigger@test.com', 'Title');
        createTitleAndProduct(5, 'Title', 'product', true);
    }

    @isTest static void testHandleAfterInsert(){
        List<Title_and_Product_Group_Mapping__c> newTitle = createTitleAndProduct(2, 'newTitle', 'newProduct', true);
        

    }
    // @isTest static void testHandleAfterUpdate(){
    //     List<Title_and_Product_Group_Mapping__c> newTitle = updateTitleAndProduct('updateTitle', true);


    // }
    
    public static List<Title_and_Product_Group_Mapping__c> createTitleAndProduct(Integer size, String title, String product, Boolean doInsert){
        List<Title_and_Product_Group_Mapping__c> titleAndProductToCreate = new List<Title_and_Product_Group_Mapping__c>();
        for (Integer i = 0; i < size; i++) {
            Title_and_Product_Group_Mapping__c newTitleAndProduct = new Title_and_Product_Group_Mapping__c();
            newTitleAndProduct.Title__c = title+i;
            newTitleAndProduct.Product_Group__c = product+i ;
            newTitleAndProduct.Active__c = true;

            titleAndProductToCreate.add(newTitleAndProduct);
        }
        if(doInsert){
            insert titleAndProductToCreate;
        }
        return titleAndProductToCreate;
    }

    // public static List<Title_and_Product_Group_Mapping__c> updateTitleAndProduct(String title, Boolean doUpdate){
    //     List<Title_and_Product_Group_Mapping__c> titleAndProductToSelect = [SELECT Name, Title__c, Product_Group__c	, Active__c  FROM Title_and_Product_Group_Mapping__c LIMIT 1];

    //     for (Title_and_Product_Group_Mapping__c eachTitle : titleAndProductToSelect) {
    //         eachTitle.Title__c = title;
    //     }
    //     if(doUpdate){
    //         update titleAndProductToSelect;
    //     }
    //     return titleAndProductToSelect;
    // }
    public static void createUser(Integer size, String FName, String LName, String Email, String title){

        ID SYSADMIN_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
        List<User> userToCreate = new List<User>();
        for(Integer i = 0;i<size;i++){
            User newUser = new User(FirstName = FName+i , LastName = LName+i, 
            UserName=FName+i+LName+i+'@tmbbank.com',
            Email= i+Email, Alias='Testtmb'+i,
            LocaleSidKey='en_US', LanguageLocaleKey='en_US', EmailEncodingKey='ISO-8859-1', 
            CommunityNickname=FName+i+'_'+'TMBTesttmb'+i,
            ProfileId = SYSADMIN_PROFILE_ID , TimeZoneSidKey='America/New_York',isActive = true,
            Employee_ID__c ='AAAAAAAA'+i, Title = title+i, RTL_Branch_Code__c = '001');
            userToCreate.add(newUser);
        }

        insert userToCreate ;
    }

}