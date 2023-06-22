global class CallMeNowDTO {

    global Request request;
    global Response response;

    global class Request{
        
        private String request_id { get; set;}
        private String first_name {get;set;}
        private String last_name {get;set;}
        private String product_name { get; set;}
        private String mobile {get;set;}
        private String campaign {get;set;}
        private String droplead_datetime { get; set;}
    
        private String var_1 {get;set;}
        private String var_2 {get;set;}
        private String var_3 {get;set;}
        private String var_4 {get;set;}
        private String var_5 {get;set;}
        private String var_6 {get;set;}
    
        private String url_field {get;set;}
        private String channel_name {get;set;}
        private String required_wrap_up {get;set;}

        global Request(){
            request_id = '';
            first_name = '';
            last_name = '';
            product_name = '';
            mobile = '';
            campaign = '';
            droplead_datetime = '';
            var_1 = '';
            var_2 = '';
            var_3 = '';
            var_4 = '';
            var_5 = '';
            var_6 = '';
            url_field = '';
            channel_name = '';
            required_wrap_up = '';
        }


        // -------- > 
        // start request id getter / setter
        global void setRequestId(String inRequestId){
            this.request_id = inRequestId;
        }

        global String getRequestId(){
            return request_id;
        }
        //end  request id getter / setter 
        //<-----------

        // -------- > 
        // start  first name getter / setter
        global void setFirstName(String inFirstName){
            this.first_name = inFirstName;
        }

        global String getFirstName(){
            return first_name;
        }

        global String getTruncateFirstName(){
            return RTL_Utility.truncateString(first_name,40);
        }
        //end  first name getter / setter 
        //<-----------

        // -------- > 
        // start  last name getter / setter
        global void setLastName(String inLastName){
            this.last_name = inLastName;
        }

        global String getLastName(){
            return last_name;
        }

        global String getTruncateLastName(){
            return RTL_Utility.truncateString(last_name,40);
        }
        //end last name getter / setter 
        //<-----------

        // -------- > 
        // start  product name getter / setter
        global void setProductName(String inProductName){
            this.product_name = inProductName;
        }

        global String getProductName(){
            return product_name;
        }

        global String getTruncateProductName(){
            return RTL_Utility.truncateString(product_name, 40);
        }
        //end product name getter / setter 
        //<-----------

        // -------- > 
        // start  Mobile getter / setter
        global void setMobile(String inMobile){
            this.mobile = inMobile;
        }

        global String getMobile(){
            return mobile;
        }
        //end Mobile getter / setter 
        //<-----------

        // -------- > 
        // start  Campaign getter / setter
        global void setCampaign(String inCampaign){
            this.campaign = inCampaign;
        }

        global String getCampaign(){
            return campaign;
        }
        //end Campaing getter / setter 
        //<-----------

        // -------- > 
        // start  Drop Lead Date Time getter / setter
        global void setDropLeadDateTime(String inDropLeadDateTime){
            this.droplead_datetime = inDropLeadDateTime;
        }

        global String getDropLeadDateTime(){
            return droplead_datetime;
        }
        //end Drop Lead Date Time getter / setter 
        //<-----------

        // -------- > 
        // start  Var1 getter / setter
        global void setVar1(String inVar1){
            this.var_1 = inVar1;
        }

        global String getVar1(){
            return var_1;
        }

        global String getTruncateVar1(){
            return RTL_Utility.truncateString(var_1,150);
        }
        //end Var1 getter / setter 
        //<-----------
        
        // -------- > 
        // start  Var2 getter / setter
        global void setVar2(String inVar2){
            this.var_2 = inVar2;
        }

        global String getVar2(){
            return var_2;
        }
        //end Var2 getter / setter 
        //<-----------
        
        // -------- > 
        // start  Var3 getter / setter
        global void setVar3(String inVar3){
            this.var_3 = inVar3;
        }

        global String getVar3(){
            return var_3;
        }
        //end Var3 getter / setter 
        //<-----------

        // -------- > 
        // start  Var4 getter / setter
        global void setVar4(String inVar4){
            this.var_4 = inVar4;
        }

        global String getVar4(){
            return var_4;
        }
        //end Var4 getter / setter 
        //<-----------
        
        // -------- > 
        // start  Var5 getter / setter
        global void setVar5(String inVar5){
            this.var_5 = inVar5;
        }

        global String getVar5(){
            return var_5;
        }
        //end Var5 getter / setter 
        //<-----------

        // -------- > 
        // start  Var6 getter / setter
        global void setVar6(String inVar6){
            this.var_6 = inVar6;
        }

        global String getVar6(){
            return var_6;
        }
        //end Var6 getter / setter 
        //<-----------

        // -------- > 
        // start  URL getter / setter
        global void setURL(String inURL){
            this.url_field = inURL;
        }

        global String getURL(){
            return url_field;
        }

        global String getTruncateURL(){
            return RTL_Utility.truncateString(url_field,256);
        }
        //end URL getter / setter 
        //<-----------
        
        global void setChannel(String inChannel){
            this.channel_name = inChannel;
        }

        // -------- > 
        // start  Channel getter / setter
        global String getChannel(){
            return channel_name;
        }

        global String getTruncateChannel(){
            return RTL_Utility.truncateString(channel_name,150);
        }
        //end Channel getter / setter 
        //<-----------
        
        // -------- > 
        // start  Wrap Up getter / setter
        global void setRequiredWrapUp(String inRequiredWrapUp){
            this.required_wrap_up = inRequiredWrapUp;
        }

        global String getRequiredWrapUp(){
            return required_wrap_up;
        }

        
        //end Wrap Up getter / setter 
        //<-----------


    }

    global class Response{

        global String code {get;set;}
        global String message {get;set;}/*message return from service or internal error message*/
        global String rawResponse {get;set;}
        global String status {get;set;} /*callout status , success,fail*/
    }
    
    global CallMeNowDTO(){
        request = new Request();
        response = new Response();
  
    }
    
    global String generateJSONContent(){
        JSONGenerator gen = JSON.createGenerator(true);
        String jsonString = '';
        
        // Write data to the JSON string.
        gen.writeStartObject();
        gen.writeStringField('request_id', RTL_Utility.checkNull(request.getRequestId(),''));
        gen.writeStringField('first_name', RTL_Utility.checkNull(request.getTruncateFirstName(),''));
        gen.writeStringField('last_name',RTL_Utility.checkNull(request.getTruncateLastName(),''));
        gen.writeStringField('product_name',RTL_Utility.checkNull(request.getTruncateProductName(),'') );
        gen.writeStringField('mobile', RTL_Utility.checkNull(request.getMobile(),''));
        gen.writeStringField('campaign',RTL_Utility.checkNull(request.getCampaign(),'') );
        gen.writeStringField('droplead_datetime',RTL_Utility.checkNull(request.getDropLeadDateTime(),'') );
        gen.writeStringField('var_1',RTL_Utility.checkNull(request.getTruncateVar1(),'') );
        gen.writeStringField('var_2',RTL_Utility.checkNull(request.getVar2(),'') );
        gen.writeStringField('var_3',RTL_Utility.checkNull(request.getVar3(),'') );
        gen.writeStringField('var_4',RTL_Utility.checkNull(request.getVar4(),'') );
        gen.writeStringField('var_5',RTL_Utility.checkNull(request.getVar5(),'') );
        gen.writeStringField('var_6',RTL_Utility.checkNull(request.getVar6(),'') );
        gen.writeStringField('url_field',RTL_Utility.checkNull(request.getTruncateURL(),'') );
        gen.writeStringField('channel_name',RTL_Utility.checkNull(request.getTruncateChannel(),'') );
        gen.writeStringField('required_wrap_up',RTL_Utility.checkNull(request.getRequiredWrapUp(),''));
        
        gen.writeEndObject();
        
        // Get the JSON string.
        jsonString = gen.getAsString();
        
        return jsonString;
    }


}