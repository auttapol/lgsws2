public with sharing class RTL_AL_NotificationToOwner {
    private CampaignMember campaignMember;
    private String emailAddress;

    public RTL_AL_NotificationToOwner(CampaignMember campaignMember) {
        this.campaignMember = campaignMember;
        /**
            1. If Campaign Member is assigned to Branch pool then.				
            1.1 Get Branch code from Branch Queue Name in Campaign Member is created.				
            1.2 Get Branch Manager User is sames as Branch Code from No.1 .				
            1.3 Prepare new function to send notification to Branch Manager User.				
            RTL_Assigned_Branch__r.RTL_Branch_Manager_User__r.Email
         */
        /**
            2. If Campaign Member is assigned to Branch user then.    
            2.1 Prepare new function to send notification to Branch User.    
            RTL_Assigned_Agent__r.Email
         */

        if (this.campaignMember.RTL_Contact_Staff_Name__c != null) {
            this.emailAddress = campaignMember.RTL_Contact_Staff_Name__r.Email ;
        }else{
            this.emailAddress = campaignMember.RTL_Assigned_Agent__c != null ? 
            campaignMember.RTL_Assigned_Agent__r.Email:
            campaignMember.RTL_Assigned_Branch__r.RTL_Branch_Manager_User__r.Email;
        }
    }
    
    public void run() {
        if(!String.isEmpty(this.emailAddress)){
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            String owner ;
            message.setToAddresses(new String[] { this.emailAddress });
            message.setSenderDisplayName('CYC Center');
            message.setSubject(String.format('ลีดแคมเปญ {0} : คุณ {1} ตอบรับจากช่องทาง TOUCH {2}', new List<Object>{
                campaignMember.Campaign?.Name,
                campaignMember.Name,
                System.now().format()
            }));
            /**
             * 1	Sender			                Fixed: CYC Center	
             * 2	Campaign Name			        Touch.campaign_name	
             * 3	Customer Name			        Touch.first_name + Touch.last_name	
             * 4	Touch send data (date/time)		Touch send data (date/time)	
             * 5	Lead Owner Name			        Campaign member.owner name	
             * 6	Campaign Name			        Touch.campaign_name	
             * 7	Customer Name			        Touch.first_name + Touch.last_name	
             * 8	Customer phone no.			    Touch.phone	
             * 9	Campaign Name			        Touch.campaign_name	
             * 10	Touch send data (date/time)		Touch send data (date/time)	
             * 11	Car Brand			            Touch.car_brand	
             * 12	Car Model			            Touch.car_subtype	
             * 13	Car Year			            Touch.car_year	
             * 14	Plate Number			        Touch.PLATE_NO	
             * 15	Pre-Approve Amount			    Touch.max_setup_amount	
             * 16	Expiry Date			            Touch.CAMP_EXP_DTE	
             * 17	Customer selected amount		Touch.wanted_amount	
             * 18	Customer selected term			Touch.installment_periods	
             * 19	Customer selected installment	Touch.RTL_AL_installment_amount__c	
             * 20	ข้อความ			                 Fixed: กรุณาดำเนินการติดต่อลูกค้าตามรายละเอียดข้างต้น และบันทึกผลการติดต่อในระบบ CRM ทุกครั้ง	
             * 21	Remark			                Fixed: หมายเหตุ : อีเมลนี้นี้เป็นข้อความอัตโนมัติ  กรุณาอย่าตอบกลับที่อีเมลนี้	
             * 22	Signature			            Fixed: CYC Center	
             
            * เรียน คุณ (Lead Owner Name)[5]
                กรุณาเข้าระบบ CRM ทันทีเพื่อติดต่อลีดแคมเปญ (ชื่อแคมเปญ)[6] ซึ่งตอบรับมาจากช่องทาง TOUCH ตามรายละเอียดดังต่อไปนี้
                ชื่อลูกค้า : (Name Surname ID)[7]
                หมายเลขโทรศัพท์ : (Cust Tel)[8]
                แคมเปญ : (Campaign Name)  Lot (Lead Generation month)[9]
                วันที่ตอบรับทาง TOUCH : (Drop Lead Date, Time)[10]
                รถหลักประกัน : (Brand[11], Model[12], Year[13], Plate Number[14])
                ข้อเสนอแคมเปญ : วงเงิน Top-up Pre-approve (Pre-Approve Amount)[15] ภายใน (expiry date)[16]
                ลูกค้าตอบรับ : วงเงิน (Customer selected amount)[17] ระยะเวลาผ่อน (Selected Term)[18] ประมาณค่างวด (responded installment)[19]

                กรุณาดำเนินการติดต่อลูกค้าตามรายละเอียดข้างต้น และบันทึกผลการติดต่อในระบบ CRM ทุกครั้ง[20]

                หมายเหตุ : อีเมลนี้นี้เป็นข้อความอัตโนมัติ  กรุณาอย่าตอบกลับที่อีเมลนี้[21]

                CYC Center[22]
            */

            /** owner name has priority to display is
                1. If field RTL_Contact_Staff_Name__c has value then owner name = RTL_Contact_Staff_Name__c.
                2. If field RTL_Assigned_Agent__c has value then owner name = RTL_Assigned_Agent__c.
                3. If field RTL_Assigned_Branch__c has value then owner name = manager of RTL_Assigned_Branch__c.
            */

            if (this.campaignMember.RTL_Contact_Staff_Name__c != null) {
                owner = this.campaignMember.RTL_Contact_Staff_Name__r.Name ;
            }else if(this.campaignMember.RTL_Assigned_Agent__c != null){
                owner = this.campaignMember.RTL_Assigned_Agent__r.Name ;
            }else if(this.campaignMember.RTL_Assigned_Branch__c != null){
                owner = this.campaignMember.RTL_Assigned_Branch__r.RTL_Branch_Manager_User__r.Name ;
            }else {
                owner = this.campaignMember.LeadOrContactOwner?.Name;
            }
            message.setHtmlBody(String.format(
                '<p>'+
                'เรียน คุณ {0}<br/>'+
                'กรุณาเข้าระบบ CRM ทันทีเพื่อติดต่อลีดแคมเปญ {1} ซึ่งตอบรับมาจากช่องทาง TOUCH ตามรายละเอียดดังต่อไปนี้<br/>'+
                'ชื่อลูกค้า : {2}<br/>'+
                'หมายเลขโทรศัพท์ : {3}<br/>'+
                'แคมเปญ : {4}<br/>'+
                'วันที่ตอบรับทาง TOUCH : {5}<br/>'+
                'รถหลักประกัน : ({6})<br/>'+
                'ข้อเสนอแคมเปญ : วงเงิน Top-up Pre-approve {7} ภายใน {8}<br/>'+
                'ลูกค้าตอบรับ : วงเงิน {9} ระยะเวลาผ่อน {10} ประมาณค่างวด {11}<br/>'+
                '</p>'+
                '<br/>'+
                '<p>กรุณาดำเนินการติดต่อลูกค้าตามรายละเอียดข้างต้น และบันทึกผลการติดต่อในระบบ CRM ทุกครั้ง</p>'+
                '<br/>'+
                '<p>หมายเหตุ : อีเมลนี้เป็นข้อความอัตโนมัติ  กรุณาอย่าตอบกลับที่อีเมลนี้</p>'+
                '<p>CYC Center</p><br/>',
                new List<Object>{
                    //campaignMember.LeadOrContactOwner?.Name, // {0}
                    owner, //{0}
                    campaignMember.Campaign.Name, // {1}
                    campaignMember.Name, // {2}
                    campaignMember.RTL_CampHis_Phone__c, // {3}
                    campaignMember.Campaign.Name, // {4}
                    System.now().format(), // {5}
                    String.join(new List<String>{ // {6}
                        campaignMember.RTL_AL_car_brand__c != null ? campaignMember.RTL_AL_car_brand__c : '-', 
                        campaignMember.RTL_AL_car_subtype__c != null ? campaignMember.RTL_AL_car_subtype__c : '-', 
                        campaignMember.RTL_AL_car_year__c != null ? campaignMember.RTL_AL_car_year__c : '-', 
                        campaignMember.RTL_AL_car_plate_no__c != null ? campaignMember.RTL_AL_car_plate_no__c : '-' }, ', '),
                    campaignMember.RTL_AL_max_set_up_amount__c != null ? campaignMember.RTL_AL_max_set_up_amount__c?.format() : '-', // {7}
                    campaignMember.RTL_AL_CAMP_EXP_DTE__c != null ? campaignMember.RTL_AL_CAMP_EXP_DTE__c?.format() : '-',  // {8}
                    campaignMember.RTL_AL_wanted_amount__c?.format(), // {9}
                    campaignMember.RTL_AL_installment_periods__c, // {10}
                    campaignMember.RTL_AL_installment_amount__c?.format()  // {11}
                }));
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
        }
    }
}