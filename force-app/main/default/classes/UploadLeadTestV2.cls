@IsTest
private class UploadLeadTestV2 {
    static testMethod void UploadLeadTestV2 (){
        
        
        //insert Statuscode;
        
        String csvLine1 = 'Lead Owner/Queue,Primary Campaign,Lead Owner Exception Flag,Link to Customer,Customer Type ,Customer Name,Customer Name EN,ID Type,ID Number,Contact Title,Contact First Name,Contact Last Name,Contact Position,Decision Map,Contact Phone Number,Industry,Group name,No. of years business run,Sales amount per year,Lead Source,Other Source,Branch Referred (Referred),"Referral Staff ID (Referred),Referral Staff Name,Total Expected Revenue,Address No/Moo/Soi/Street,"Sub District",District,Province ,Zip Code,Country,Mobile No. ,Office No. ,Ext,Email,Rating,Prescreening Result,Remark';
        String csvLine2 = 'T0010,Campaign_0,Yes,,Individual,Tokta 1,Tokjai 1,Citizen ID,5100600076849,Mr.,Tokta 1,ตกใจ 1,รองกรรมการผู้จัดการ,Decision Maker ,086-617-3839,industry0,group0,,7500000000,Campaign,อื่น ๆ ,517,40019,Kamolwan,500000,111 ถนนเจริญกรุง,บางโคล่,บางคอแหลม,กรุงเทพมหานคร,10120,Thailand,0877778888,026229322,517,test@tom,Hot,Passed,Commercial Lead - failed - duplicate lead';
        String csvLine3 = 'T0011,Campaign_1,No,,Individual,Tokta 2,Tokjai 2,Citizen ID,6996078001699,Mr.,Tokta 2,ตกใจ 2,รองกรรมการผู้จัดการ,Decision Maker ,086-617-38a39,Crop,NIPPON KIKAI ENGINEERING,,4000000000,Campaign,อื่น ๆ ,11111,40019,Kamolwan,500000,111 ถนนเจริญกรุง,บางโคล่,บางคอแหลม,กรุงเทพมหานคร,10120,Thailand,0877778888a,026229322a,111,test@test.com,Hot,Passed,Commercial Lead - failed - duplicate lead';
        String csvLine4 = '29610,,No,0000000000123,,,Tokjai 3,,,Mrs.,Tokta 3,ตกใจ 3,รองกรรมการผู้จัดการ,Decision Maker ,02-383-3839,Animal Food/Farm/Feed,,,800000000,Campaign,อื่น ๆ ,011,40019,Kamolwan,50000,111 ถนนเจริญกรุง,บางโคล่,บางคอแหลม,กรุงเทพมหานคร,10120,Thailand,0877778888,026229322,111,test@test.com,Hot,Passed,Commercial Lead - failed - missing mandatory field';
        String csvLine5 = '29610,,No,,Individual,Tokjai 4,Tokjai 4,,,Mr.,Tokta 4,ตกใจ 4,รองกรรมการผู้จัดการ,Decision Maker ,02-383-3839,Military,,15,4000000,Refer from branch,อื่น ๆ ,001,40019,Kamolwan,500000,111 ถนนเจริญกรุง,บางโคล่,บางคอแหลม,กรุงเทพมหานคร,10120,Thailand,0877778888,026229322,111,test@test.com,Warm,Passed,Success';
        String csvLine6 = '29610,,No,,Individual,Tokjai 5,Tokjai 5,,,,Tokta 5,,รองกรรมการผู้จัดการ,Decision Maker ,086-617-3839,Contractor,NINJANAN,20,15000000,Refer from customer,อื่น ๆ ,001,40019,Kamolwan,500000,111 ถนนเจริญกรุง,บางโคล่,บางคอแหลม,กรุงเทพมหานคร,10120,Thailand,0877778888,026229322,111,test@test.com,Cold,Passed,Commercial Lead - failed - missing mandatory field';
        String csvLine7 = 'leadqueue2,,No,,Individual,Tokta 6,Tokjai 6,Citizen ID,5100600076848,,Tokta 5,ตกใจ 6,รองกรรมการผู้จัดการ,Decision Maker ,086-617-3839,Consumer Goods & Services,,50,50000000,Walk-in customer,อื่น ๆ ,001,40019,Kamolwan,500000,111 ถนนเจริญกรุง,บางโคล่,บางคอแหลม,กรุงเทพมหานคร,10120,Thailand,0877778888,026229322,111,test@test.com,Cold,,Commercial Lead - failed - duplicate ID in file';
        String csvLine8 = 'leadqueue2,,No,,Individual,Tokta 7,Tokjai 4,,,Mr.,Tokta 6,ตกใจ 4,รองกรรมการผู้จัดการ,Decision Maker ,02-383-3839,Military,,15,4000000,Refer from branch,อื่น ๆ ,001,40019,Kamolwan,500000,111 ถนนเจริญกรุง,บางโคล่,บางคอแหลม,กรุงเทพมหานคร,10120,Thailand,0877778888,026229322,111,test@test.com,Warm,,Success';
        String csvLine9 = ',,No,,Individual,Tokta 8,Tokjai 7,BRN ID,67623852359,,Tokta 8,ตกใจ 8,รองกรรมการผู้จัดการ,Decision Maker ,086-617-3839,Contractor,NINJANAN,20,15000000,Refer from customer,อื่น ๆ ,001,40019,Kamolwan,500000,111 ถนนเจริญกรุง,บางโคล่,บางคอแหลม,กรุงเทพมหานคร,10120,Thailand,0877778888,026229322,111,test@test.com,Cold,,"Commercial Lead - failed incorrect ID Type"';
        String csvLine10 = ',,No,000000001234,Juristic,Tokta 9,Tokjai 8,Citizen ID,5100600076848,,Tokta 9,ตกใจ 9,รองกรรมการผู้จัดการ,Decision Maker ,086-617-3839,Contractor,NINJANAN,20,15000000,Refer from customer,อื่น ๆ ,001,40019,Kamolwan,500000,111 ถนนเจริญกรุง,บางโคล่,บางคอแหลม,กรุงเทพมหานคร,10120,Thailand,0877778888,026229322,111,test@test.com,Cold,,"Commercial Lead - failed, incorrect ID Type"';
        String csvLine11 = 'leadqueue,,Yes,00000001235,Juristic,Tokta 9,Tokjai 8,Passport ID,A332839202,,Tokta 9,ตกใจ 9,รองกรรมการผู้จัดการ,Decision Maker ,086-617-3839,Contractor,NINJANAN,20,15000000,Refer from customer,อื่น ๆ ,001,40019,Kamolwan,500000,111 ถนนเจริญกรุง,บางโคล่,บางคอแหลม,กรุงเทพมหานคร,10120,Thailand,0877778888,026229322,111,test@test.com,Cold,,"Commercial Lead - failed, incorrect ID Ty"';
        String csvLine12 = ',,No,0000001236,Juristic,Tokta 9,Tokjai 8,Passport ID,A332839202,,Tokta 9,ตกใจ 9,รองกรรมการผู้จัดการ,Decision Maker ,086-617-3839,Contractor,NINJANAN,20,15000000,Refer from customer,อื่น ๆ ,001,40019,Kamolwan,500000,111 ถนนเจริญกรุง,บางโคล่,บางคอแหลม,กรุงเทพมหานคร,10120,Thailand,0877778888,026229322,111,test@test.com,Cold,,"Commercial Lead - failed, incorrect ID Ty"';
        String csvLine13 = ',,No,000001237,Juristic,Tokta 9,Tokjai 8,Passport ID,A332839202,,Tokta 9,ตกใจ 9,รองกรรมการผู้จัดการ,Decision Maker ,086-617-3839,Contractor,NINJANAN,20,15000000,Refer from customer,อื่น ๆ ,001,40019,Kamolwan,500000,111 ถนนเจริญกรุง,บางโคล่,บางคอแหลม,กรุงเทพมหานคร,10120,Thailand,0877778888,026229322,111,test@test.com,Cold,,"Commercial Lead - failed, incorrect ID Ty"';
        String csvLine14 = ',,No,00001238,Juristic,Tokta 9,Tokjai 8,Passport ID,A332839202,,Tokta 9,ตกใจ 9,รองกรรมการผู้จัดการ,Decision Maker ,086-617-3839,Contractor,NINJANAN,20,15000000,Refer from customer,อื่น ๆ ,001,40019,Kamolwan,500000,111 ถนนเจริญกรุง,บางโคล่,บางคอแหลม,กรุงเทพมหานคร,10120,Thailand,0877778888,026229322,111,test@test.com,Cold,,"Commercial Lead - failed, incorrect ID Ty"';
        String csvLine15 = ',,No,0001239,Juristic,Tokta 9,Tokjai 8,Passport ID,A332839202,,Tokta 9,ตกใจ 9,รองกรรมการผู้จัดการ,Decision Maker ,086-617-3839,Contractor,NINJANAN,20,15000000,Refer from customer,อื่น ๆ ,001,40019,Kamolwan,500000,111 ถนนเจริญกรุง,บางโคล่,บางคอแหลม,กรุงเทพมหานคร,10120,Thailand,0877778888,026229322,111,test@test.com,Cold,,"Commercial Lead - failed, incorrect ID Ty"';
        String csvLine16 = ',,No,001240,Juristic,Tokta 9,Tokjai 8,Passport ID,A332839202,,Tokta 9,ตกใจ 9,รองกรรมการผู้จัดการ,Decision Maker ,086-617-3839,Contractor,NINJANAN,20,15000000,Refer from customer,อื่น ๆ ,001,40019,Kamolwan,500000,111 ถนนเจริญกรุง,บางโคล่,บางคอแหลม,กรุงเทพมหานคร,10120,Thailand,0877778888,026229322,111,test@test.com,Cold,,"Commercial Lead - failed, incorrect ID Ty"';
        String csvLine17 = ',,No,01241,Juristic,Tokta 9,Tokjai 8,Passport ID,A332839202,,Tokta 9,ตกใจ 9,รองกรรมการผู้จัดการ,Decision Maker ,086-617-3839,Contractor,NINJANAN,20,15000000,Refer from customer,อื่น ๆ ,001,40019,Kamolwan,500000,111 ถนนเจริญกรุง,บางโคล่,บางคอแหลม,กรุงเทพมหานคร,10120,Thailand,0877778888,026229322,111,test@test.com,Cold,,"Commercial Lead - failed, incorrect ID Ty"';
        String csvLine18 = ',,No,1242,Juristic,Tokta 9,Tokjai 8,Passport ID,A332839202,,Tokta 9,ตกใจ 9,รองกรรมการผู้จัดการ,Decision Maker ,086-617-3839,Contractor,NINJANAN,20,15000000,Refer from customer,อื่น ๆ ,001,40019,Kamolwan,500000,111 ถนนเจริญกรุง,บางโคล่,บางคอแหลม,กรุงเทพมหานคร,10120,Thailand,0877778888,026229322,111,test@test.com,Cold,,"Commercial Lead - failed, incorrect ID Ty"';
        String csvLine19 = ',,No,124,Juristic,Tokta 9,Tokjai 8,Passport ID,A332839202,,Tokta 9,ตกใจ 9,รองกรรมการผู้จัดการ,Decision Maker ,086-617-3839,Contractor,NINJANAN,20,15000000,Refer from customer,อื่น ๆ ,001,40019,Kamolwan,500000,111 ถนนเจริญกรุง,บางโคล่,บางคอแหลม,กรุงเทพมหานคร,10120,Thailand,0877778888,026229322,111,test@test.com,Cold,,"Commercial Lead - failed, incorrect ID Ty"';
        String csvLine20 = ',,No,12,Juristic,Tokta 9,Tokjai 8,Passport ID,A332839202,,Tokta 9,ตกใจ 9,รองกรรมการผู้จัดการ,Decision Maker ,086-617-3839,Contractor,NINJANAN,20,15000000,Refer from customer,อื่น ๆ ,001,40019,Kamolwan,500000,111 ถนนเจริญกรุง,บางโคล่,บางคอแหลม,กรุงเทพมหานคร,10120,Thailand,0877778888,026229322,111,test@test.com,Cold,,"Commercial Lead - failed, incorrect ID Ty"';   
        String csvLine21 = ',,,1,Juristic,ToktaaaaaaaasasasasasasrararararararsryascgahjvckhjSDvhbsadvbsdkllvbasdvbksdvlsdvhkdsvkasgdldgsvlasdvsdvhdvjdsvbdsvjjksdvbklsdbvjasbcbasbkasbklvblkasvbasjbkcbkasdhaskjcnskackasbckashdascaskbvkajscbjkaschskjvbdkslvbsdlvbasldvbadiuwevjbsjdlkvblsadkvbjksvbsdlbvlsadvbsdvlhadsbvlsdkvbksadflahdfjdksfklasdvaslvkjdndsnjbkjasnkbnajksdnjbnjkadgnjawrgnjreigwetwqitepeonvovnosdNVJVNKNBKJDJBLvkwlbldskbakldsbldkvbsaladagnajkbnjblQFJKQWKNJFJKSAFNJASFJk 9,Tokjai sadscnvnlvlnvdlnvaljnavjnvajnkvajnvadvjknvdjnkvdsnjkdsvnsdvnjsvdjnkdsvnjknjkdsvsdjnvkdsvjnksjknsdvjnkdvsnjkdsvnjdsvjknvdsjknsdvjnksdjknvsdvjnvdsjkndsvjknsdvjkndsvjnkndjsvdjnsvksdjvkndvjsknvdjksnsdvnjdsvjkndakvlnsjdlnjsabklabdslkbsdlhaldskjvslaegawkdsjbalsidubhiadjskbaskbsadkv8,Passport ID,A332839202232324242424242452342349823789238479823978978325798237984798234978237572839479823794827938579823798440537542752637894528934562348562834956723485967234859762345986723485769782349797823797239239,,Toktaasdasdadsadasdasdasdasdasda 9,sasadasdassadasdasdasdasdsadasdasdasdasdavjnksvjsdjlkvnlnsdvlnsdjnjklsvddasdasd,sdsdsadadasllsakfalskmasvmaslmvaslkmvsalalaskasdladjvdvnsdivdsvasifoasjiofjoasisadnjasoasvnsakmvskmavmasvmpsavpmasvpmasvmpddsnaslvnadsvnasdasdsadasdsad,Decision Maker ,086-617-387898689698689689689678967986798679845639495349787893457983498757349597832537923879234932567237593242347293572397423947236523953827472378439,Contractor,NINJANAN,20,15000000,Refer from customer,อื่น ๆ ,001,402232323232423234234019,Ksdldiuwejiojiwefijofeewiofjjiofewjosvjsdvsdosdvjodsvjosdjiovsdjoivjiodsvjoisdvjiodsvjiosdvjiodsvijodsvjiosdvjiovsdjiosdvjiosdjviosijovdjiodsvjiosdvjioqeorhwfiqwfqwofqiwofuqwu2938402384295203523048230823098482340823023472380823489sdfdsfsdfsdfsdfsdfdsffiuwe9th2ut9h2huwe9ug9hwehg9wegweh9g9ewhegwh9wegh9eh9ewgh9gweh9amolwan,500000,1sdasdasdasdsadasdasdasdsadasdasdsadkjnvdnjkajnsvjnasnjkasdjknkjn11 ถนนเจริญกรุง,บาxccxcxcxcxcssdsdsfsfsdsfsdssdvdsvdsvasasvasvasvadadvdsvdssdvsdvsdvงโคล่,บasdasdasdasadfsdvsddsvsadvassavasvasvasvasvasvasvasvasvasgwregeางคอแหลม,กรุงเทพมหานคร,100023023934023402340120,Thailand,0877778888,026234859238095237502520857823057827047023074409230924394802380923804989234890243089234234089809423428903023498248902348094238902390823489032480923480923098452390482390429322,34773473838483432458923758927835723957883484834811111,sadmlklkmsvalmasvmlksamklmklasvlkmasvklmasvlkmsavklmasvklm;dlasvnjdaVJDSALKVNKADSVNALDSNVKAKLSDVNLASDNVKASDLNVJKLASDVNJASDLKVDASKBJKDKVSDBLVLDKSAVBSALDKVNSADVNLSKADVNKSLADVNLKSADNVKJlvnlsdvalsvmsdlvmldksvkdlvldsvksfijijerijgrepw pjfwdmfdmokdfbfbwkmkmdfbmfdfds kfs bs flbsfmkbbfdsk mdbfs ld ffd m bmbf m bbfbfkmmbkbmfkbfmkmkfbdbmkkbdfskbsfbjksnnbjsknfkjbdnbjkffbjnslkfbjnsldkfbdjkndbfksjlndfsbknjwrgsdbsbsdsdsdbsdbsdbsdbsfdbfdbfdkbnkdfnjkbnjklbfnljkfbdslnjkbsdfnjklbfsdnjkbsfdnjklbsfdnjklbfsdnjklbfsdknjlbfsdnjkfbsdnjkfbdjnkbsdnjlbdfnjlfbdsjnlkwjgwwjgjijgrur8345984538u4383498534795345437895438957349857348957934573495734958test@test.com,Cold,,"Commercial Lead - failed, incorrect ID Ty"';   
        String csvLine22 = ',,No,1234567890123456789012345,Juristic,Tokta 9,Tokjai 8,Passport ID,A332839202,,Tokta 9,ตกใจ 9,รองกรรมการผู้จัดการ,Decision Maker ,086-617-3839,Contractor,NINJANAN,20,15000000,Refer from customer,อื่น ๆ ,001,40019,Kamolwan,500000,111 ถนนเจริญกรุง,บางโคล่,บางคอแหลม,กรุงเทพมหานคร,10120,Thailand,0877778888,026229322,111,test@test.com,Cold,,"Commercial Lead - failed, incorrect ID Ty"';   
        String csvLine23 = ',,No,123456789012345678901234,Juristic,Tokta 9,Tokjai 8,Passport ID,A332839202,,Tokta 9,ตกใจ 9,รองกรรมการผู้จัดการ,Decision Maker ,086-617-3839,Contractor,NINJANAN,20,15000000,Refer from customer,อื่น ๆ ,001,40019,Kamolwan,500000,111 ถนนเจริญกรุง,บางโคล่,บางคอแหลม,กรุงเทพมหานคร,10120,Thailand,0877778888,026229322,111,test@test.com,Cold,failed,"Commercial Lead - failed, incorrect ID Ty"';   
        String csvLine24 = ',,No,12345678901234567890123,Juristic,Tokta 9,Tokjai 8,Passport ID,A332839202,,Tokta 9,ตกใจ 9,รองกรรมการผู้จัดการ,Decision Maker ,086-617-3839,Contractor,NINJANAN,20,15000000,Refer from customer,อื่น ๆ ,001,40019,Kamolwan,500000,111 ถนนเจริญกรุง,บางโคล่,บางคอแหลม,กรุงเทพมหานคร,10120,Thailand,0877778888,026229322,111,test@test.com,Cold,,"Commercial Lead - failed, incorrect ID Ty"';   
        String csvLine25 = ',,No,1234567890123456789012,Juristic,Tokta 9,Tokjai 8,Passport ID,A332839202,,Tokta 9,ตกใจ 9,รองกรรมการผู้จัดการ,Decision Maker ,086-617-3839,Contractor,NINJANAN,20,15000000,Refer from customer,อื่น ๆ ,001,40019,Kamolwan,500000,111 ถนนเจริญกรุง,บางโคล่,บางคอแหลม,กรุงเทพมหานคร,10120,Thailand,0877778888,026229322,111,test@test.com,Cold,,"Commercial Lead - failed, incorrect ID Ty"';   
        String csvLine26 = ',,No,123456789012345678901,Juristic,Tokta 9,Tokjai 8,Passport ID,A332839202,,Tokta 9,ตกใจ 9,รองกรรมการผู้จัดการ,Decision Maker ,086-617-3839,Contractor,NINJANAN,20,15000000,Refer from customer,อื่น ๆ ,001,40019,Kamolwan,500000,111 ถนนเจริญกรุง,บางโคล่,บางคอแหลม,กรุงเทพมหานคร,10120,Thailand,0877778888,026229322,111,test@test.com,Cold,,"Commercial Lead - failed, incorrect ID Ty"';   
        String csvLine27 = ',,No,12345678901234567890,Juristic,Tokta 9,Tokjai 8,Passport ID,A332839202,,Tokta 9,ตกใจ 9,รองกรรมการผู้จัดการ,Decision Maker ,086-617-3839,Contractor,NINJANAN,20,15000000,Refer from customer,อื่น ๆ ,001,40019,Kamolwan,500000,111 ถนนเจริญกรุง,บางโคล่,บางคอแหลม,กรุงเทพมหานคร,10120,Thailand,0877778888,026229322,111,test@test.com,Cold,,"Commercial Lead - failed, incorrect ID Ty"';   
        String csvLine28 = ',,No,1234567890123456789,Juristic,Tokta 9,Tokjai 8,Passport ID,A332839202,,Tokta 9,ตกใจ 9,รองกรรมการผู้จัดการ,Decision Maker ,086-617-3839,Contractor,NINJANAN,20,15000000,Refer from customer,อื่น ๆ ,001,40019,Kamolwan,500000,111 ถนนเจริญกรุง,บางโคล่,บางคอแหลม,กรุงเทพมหานคร,10120,Thailand,0877778888,026229322,111,test@test.com,Cold,,"Commercial Lead - failed, incorrect ID Ty"';   
        String csvLine29 = ',,No,123456789012345678,Juristic,Tokta 9,Tokjai 8,Passport ID,A332839202,,Tokta 9,ตกใจ 9,รองกรรมการผู้จัดการ,Decision Maker ,086-617-3839,Contractor,NINJANAN,20,15000000,Refer from customer,อื่น ๆ ,001,40019,Kamolwan,500000,111 ถนนเจริญกรุง,บางโคล่,บางคอแหลม,กรุงเทพมหานคร,10120,Thailand,0877778888,026229322,111,test@test.com,Cold,,"Commercial Lead - failed, incorrect ID Ty"';   
        String csvLine30 = ',,No,12345678901234567,Juristic,Tokta 9,Tokjai 8,Passport ID,A332839202,,Tokta 9,ตกใจ 9,รองกรรมการผู้จัดการ,Decision Maker ,086-617-3839,Contractor,NINJANAN,20,15000000,Refer from customer,อื่น ๆ ,001,40019,Kamolwan,500000,111 ถนนเจริญกรุง,บางโคล่,บางคอแหลม,กรุงเทพมหานคร,10120,Thailand,0877778888,026229322,111,test@test.com,Cold,,"Commercial Lead - failed, incorrect ID Ty"';   
        String csvLine31 = ',,No,1234567890123456,Juristic,Tokta 9,Tokjai 8,Passport ID,A332839202,,Tokta 9,ตกใจ 9,รองกรรมการผู้จัดการ,Decision Maker ,086-617-3839,Contractor,NINJANAN,20,15000000,Refer from customer,อื่น ๆ ,001,40019,Kamolwan,500000,111 ถนนเจริญกรุง,บางโคล่,บางคอแหลม,กรุงเทพมหานคร,10120,Thailand,0877778888,026229322,111,test@test.com,Cold,,"Commercial Lead - failed, incorrect ID Ty"';   
        String csvLine32 = ',,No,123456789012345,Juristic,Tokta 9,Tokjai 8,Passport ID,A332839202,,Tokta 9,ตกใจ 9,รองกรรมการผู้จัดการ,Decision Maker ,086-617-3839,Contractor,NINJANAN,20,15000000,Refer from customer,อื่น ๆ ,001,40019,Kamolwan,500000,111 ถนนเจริญกรุง,บางโคล่,บางคอแหลม,กรุงเทพมหานคร,10120,Thailand,0877778888,026229322,111,test@test.com,Cold,,"Commercial Lead - failed, incorrect ID Ty"';   
        String csvLine33 = ',,No,123456789012345,Juristic,Tokta 9,Tokjai 8,Passport ID,A123456789B123456789C123456789D123456789E123456789F123456789G123456789H123456789I123456789J123456789K12345678912345678912345678912345678912345678912345678912345678912345678912345678912345678901234567891234567890123456789123456789012345678912345678901234567891234567890123456789123456789012345678912345678901234567891234567890123456789123456789012345678912345678901234567891234567890123456789123456789012345678912345678901234567891234567890123456789123456789012345678912345678901234567891234567890123456789123456789012345678912345678901234567891234567890123456789123456789012345678912345678901234567891234567890123456789123456789012345678912345678901234567891234567890123456789123456789012345678912345678901234567891234567890,,Tokta 912345678912345678901234567891234567890123456789123456789012345678912345678901234567891234567890,ตกใจ 912345678912345678901234567891234567890123456789123456789012345678912345678901234567891234567890123456789123456789012345678912345678901234567891234567890,รองกรรมการผู้จั12345678912345678901234567891234567890123456789123456789012345678912345678901234567891234567890123456789123456789012345678912345678901234567891234567890123456789123456789012345678912345678901234567891234567890123456789123456789012345678912345678901234567891234567890ดการ,Decision Maker ,086-617-3839,Contractor,NINJANAN,20,15000000,Refer from customer,อื่น ๆ ,001,40019,Kamolwan,500000,111 ถนนเจริญกรุง,บางโคล่,บางคอแหลม,กรุงเทพมหานคร,10120,Thailand,0877778888,026229322,111,test@test.com,Cold,,"Commercial Lead - failed, incorrect ID Ty"';
        String csvLine34 = '"99888","null","No","null","Juristic","ASSDSD.CO.,LTD","null","BRN ID","105545048820","null","null","N/A","null","null","null","null","null","null","null","null","null","null","null","null","null","null","null","null","null","null","null","null","null","null","null","Cold","null","null","Lead TF Lot1"';
        
        
        String blobCreator = csvLine1 + '\r\n' + csvLine2 + '\r\n' + csvLine3 + '\r\n' + csvLine4 + '\r\n' + csvLine5 + '\r\n' + csvLine6 + '\r\n' + csvLine7 + '\r\n' + csvLine8 + '\r\n' + csvLine9 + '\r\n' + csvLine10 + '\r\n' + csvLine11 + '\r\n' + csvLine12 + '\r\n' + csvLine13 + '\r\n' + csvLine14 + '\r\n' + csvLine15 + '\r\n' + csvLine16 + '\r\n' + csvLine17 + '\r\n' + csvLine18 + '\r\n' + csvLine19 +'\r\n' + csvLine20 +'\r\n'+ csvLine21 +'\r\n'+ csvLine22 +'\r\n'+ csvLine23 +'\r\n'+ csvLine24 +'\r\n'+ csvLine25 +'\r\n'+ csvLine26 +'\r\n'+ csvLine27 +'\r\n'+ csvLine28 +'\r\n'+ csvLine29 +'\r\n'+ csvLine30 +'\r\n'+ csvLine31 +'\r\n'+ csvLine32 +'\r\n'+ csvLine33;
        //String blobCreator = csvLine1 + '\r\n' + csvLine2 + '\r\n' + csvLine3;
        String strUrlUTF8 = EncodingUtil.urlEncode(blobCreator, 'UTF-8');
        
        
        test.startTest();
        
        List<User> us = TestUtils.createUsers(2,'Upload','Prospect','canvas@tmbbank.com',true);
        TestUtils.createStatusCode();
        TestUtils.createAppConfig();
        TestUtils.createCampaign(1,'MB',true);
        
        List<User> Luser = new list<User>();
        us[0].Employee_ID__c = '99009';
        us[1].Employee_ID__c = '99008';
        
        Luser.add(us[0]);
        Luser.add(us[1]);
        
        update Luser;
        
        List<LeadLogHeader__c> loghead = new List<LeadLogHeader__c>();
        LeadLogHeader__c loghead1 = new LeadLogHeader__c(Name='Test1',OwnerID=UserInfo.getUserId());
        LeadLogHeader__c loghead2 = new LeadLogHeader__c(Name='Test2',OwnerID=UserInfo.getUserId());
        LeadLogHeader__c loghead3 = new LeadLogHeader__c(Name='Test3',OwnerID=UserInfo.getUserId());
        loghead.add(loghead1);
        loghead.add(loghead2);
        loghead.add(loghead3);
        insert loghead;
        
        LeadLogHeader__c loghead4 = new LeadLogHeader__c(id=loghead[2].id,Name='Test3',OwnerID=UserInfo.getUserId(),Isdelete__c=false);
        update loghead4;
        
        List<LeadLogDetail__c> logdetail = new List<LeadLogDetail__c>();
        LeadLogDetail__c logdetail1 = new LeadLogDetail__c(Parrent__c=loghead[0].Id,Error_Message__c='Error',Success__c ='True',Lead_ID__c='1234asdf',Content__c=csvLine34,Lead_Valid__c=False);
        LeadLogDetail__c logdetail2 = new LeadLogDetail__c(Parrent__c=loghead[0].Id,Error_Message__c='Error',Success__c ='True',Lead_ID__c='1234asdf',Content__c=csvLine2,Lead_Valid__c=False);
        LeadLogDetail__c logdetail3 = new LeadLogDetail__c(Parrent__c=loghead[0].Id,Error_Message__c='Error',Success__c ='True',Lead_ID__c='1234asdf',Content__c=csvLine2,Lead_Valid__c=True);
        LeadLogDetail__c logdetail4 = new LeadLogDetail__c(Parrent__c=loghead[0].Id,Error_Message__c='Error',Success__c ='True',Lead_ID__c='1234asdf',Content__c=csvLine2,Lead_Valid__c=True);
        LeadLogDetail__c logdetail5 = new LeadLogDetail__c(Parrent__c=loghead[1].Id,Error_Message__c='Error',Success__c ='True',Lead_ID__c='1234asdf',Content__c=csvLine2,Lead_Valid__c=False);
        LeadLogDetail__c logdetail6 = new LeadLogDetail__c(Parrent__c=loghead[1].Id,Error_Message__c='Error',Success__c ='True',Lead_ID__c='1234asdf',Content__c=csvLine2,Lead_Valid__c=False);
        LeadLogDetail__c logdetail7 = new LeadLogDetail__c(Parrent__c=loghead[1].Id,Error_Message__c='Error',Success__c ='True',Lead_ID__c='1234asdf',Content__c=csvLine2,Lead_Valid__c=True);
        LeadLogDetail__c logdetail8 = new LeadLogDetail__c(Parrent__c=loghead[1].Id,Error_Message__c='Error',Success__c ='True',Lead_ID__c='1234asdf',Content__c=csvLine2,Lead_Valid__c=True);
        LeadLogDetail__c logdetail9 = new LeadLogDetail__c(Parrent__c=loghead[2].Id,Error_Message__c='Error',Success__c ='True',Lead_ID__c='1234asdf',Content__c=csvLine2,Lead_Valid__c=False);
        logdetail.add(logdetail1);
        logdetail.add(logdetail2);
        logdetail.add(logdetail3);
        logdetail.add(logdetail4);
        logdetail.add(logdetail5);
        logdetail.add(logdetail6);
        logdetail.add(logdetail7);
        logdetail.add(logdetail8);
        logdetail.add(logdetail9);

        for(Integer i =0 ; i<1001 ;i++) {
          LeadLogDetail__c logdetailloop = new LeadLogDetail__c();
          logdetailloop.Parrent__c=loghead[0].Id;
          logdetailloop.Error_Message__c='Error';
          logdetailloop.Success__c ='True';
          logdetailloop.Lead_ID__c='1234asdf'+i;
          logdetailloop.Content__c=csvLine1;
          logdetailloop.Lead_Valid__c=True;
          logdetail.add(logdetailloop);
        }
        insert logdetail;
            
        List<Account> acc = new List<Account>();
        Account acc1 = new Account ();
        //acc1.Office_Number_Temp__c = '0876213284';
        acc1.Rating = 'Hot';
        acc1.IsDisqualified__c = false;
        acc1.Customer_Type__c = 'Individual';
        acc1.First_name_PE__c = 'Visit';
        acc1.First_Name_ENG_PE__c = 'Visit';
        acc1.Last_name_PE__c = 'TestMock';
        acc1.Last_Name_PE_Eng__c  = 'TestMock';
        acc1.ID_Type_PE__c = 'Citizen ID';
        acc1.ID_Number_PE__c = '5100600076849';
        acc1.Name = 'Test Account';
        acc1.Segment_crm__c = '3';
        acc1.Phone ='345345';
        acc1.Phone ='050111222';
        acc1.OwnerId = us[0].id;
        acc1.Mobile_Number_PE__c  = '0801112233';
        acc1.TMB_Customer_ID_PE__c = '001100000000000000000000001235';
        
        Account acc2 = new Account ();
        //acc2.Office_Number_Temp__c = '0876213284';
        acc2.Rating = 'Hot';
        acc2.IsDisqualified__c = false;
        acc2.Customer_Type__c = 'Individual';
        acc2.First_name_PE__c = 'Visit';
        acc2.First_Name_ENG_PE__c = 'Visit';
        acc2.Last_name_PE__c = 'TestMock2';
        acc2.Last_Name_PE_Eng__c  = 'TestMock2';
        acc2.ID_Type_PE__c = 'BRN ID';
        acc2.ID_Number_PE__c = '1122334455667788';
        acc2.Name = 'Test Account2';
        acc2.Segment_crm__c = '3';
        acc2.Phone ='3453452';
        acc2.Phone ='050111222';
        acc2.OwnerId = us[1].id;
        acc2.Mobile_Number_PE__c  = '0801112233';
        acc2.TMB_Customer_ID_PE__c = '001100000000000000000000001234';
        
        Account acc3 = new Account ();
        //acc3.Office_Number_Temp__c = '0876213284';
        acc3.Rating = 'Hot';
        acc3.IsDisqualified__c = false;
        acc3.Customer_Type__c = 'Individual';
        acc2.First_name_PE__c = 'Visit';
        acc2.First_Name_ENG_PE__c = 'Visit';
        acc2.Last_name_PE__c = 'TestMock3';
        acc2.Last_Name_PE_Eng__c  = 'TestMock3';
        acc3.ID_Type_PE__c = 'BRN ID';
        acc3.ID_Number_PE__c = '1122334455667789';
        acc3.Name = 'Test Account2';
        acc3.Segment_crm__c = '3';
        acc3.Phone ='3453452';
        acc3.Phone ='050111222';
        acc3.OwnerId = us[1].id;
        acc3.Mobile_Number_PE__c  = '0801112233';
        acc3.TMB_Customer_ID_PE__c = '001100000000000000000000001236';
        
        acc.add(acc1);
        acc.add(acc2);
        acc.add(acc3);
        insert acc;
        
        AccountTeamMember accteam = new AccountTeamMember(AccountId=acc[1].Id ,UserId=us[0].id,TeamMemberRole='Sales Rep');
        insert accteam;
        
        Industry__c ind = new Industry__c();
        ind.Name = 'industry0';
        insert ind;
        
        Group__c grp = new Group__c();
        grp.name = 'group0';
        //grp.GroupIndustry__c = 'Crop';
        grp.Group_Segment__c = 'BB';
        insert grp;
        
        Branch_and_Zone__c baz = new Branch_and_Zone__c ();
        baz.name = 'test0';
        baz.Branch_Code__c = '517';
        baz.Branch_Name__c = 'test0';
        insert baz;
        
        List<Group> gru = new List<Group>();
        Group g1 = new Group(Name='leadqueue', type='Queue');
        Group g2 = new Group(Name='leadqueue2', type='Queue');
        Group g3 = new Group(Name='leadqueue2', type='Queue');
        gru.add(g1);
        gru.add(g2);
        gru.add(g3);
        insert gru;
      
        Campaign cam = new Campaign();
        cam.name = 'Test Campaign 123';
        cam.IsActive = true;
        cam.Segment__c = 'CB';
        insert cam;
        
        
                
        //List<LeadLogValidHeader__c> validhead = new List<LeadLogValidHeader__c>();
        LeadLogValidHeader__c validhead1 = new LeadLogValidHeader__c(name='valid1');
        insert validhead1;
        
        List<LeadLogValidDetail__c> validdetail = new List<LeadLogValidDetail__c>();
        LeadLogValidDetail__c validdetail1 = new LeadLogValidDetail__c();
        validdetail1.leadOwner__c = '99009';
        validdetail1.LeadLogValidHeader__c = validhead1.id;
        validdetail1.PrimaryCampaign__c = '';
        validdetail1.LeadOwnerExceptionFlag__c = 'Yes';
        validdetail1.LinktoCustomer__c = '001100000000000000000000001235';
        validdetail1.CustomerType__c = 'Juristic';
        validdetail1.CustomerName__c = 'Test Ken12345';
        validdetail1.CustomerNameEN__c = 'Test Ken12345';
        validdetail1.ContactLastname__c = 'Test Kennn33';
        validdetail1.ContactFirstname__c = 'Test Kennn32';
        validdetail1.IDType__c = 'BRN ID';
        validdetail1.IDNumber__c = '1122334455667788';
        validdetail1.Success__c = 'True';
        validdetail1.Row__c = 1;
        validdetail1.Industry__c = 'industry0';
        validdetail1.Groupname__c = 'group0';
        validdetail1.valid__c = True;
        
        LeadLogValidDetail__c validdetail2 = new LeadLogValidDetail__c();
        validdetail2.leadOwner__c = us[0].Id;
        validdetail2.LeadLogValidHeader__c = validhead1.id;
        validdetail2.PrimaryCampaign__c = '';
        validdetail2.LeadOwnerExceptionFlag__c = 'No';
        validdetail2.PrimaryCampaignName__c = 'Test Campaign 123';
        validdetail2.Groupname__c = 'group1';
        validdetail2.LinktoCustomer__c = '001100000000000000000000001236';
        validdetail2.CustomerType__c = 'Individual';
        validdetail2.CustomerName__c = '';
        validdetail2.CustomerNameEN__c = '';
        validdetail2.IDType__c = 'Citizen ID';
        validdetail2.IDNumber__c = '51006000768';
        validdetail2.Success__c = 'True';
        validdetail2.BranchedReferred__c = '5174444';
        validdetail2.BranchedReferredName__c = '5174444';
        validdetail2.Industry__c = 'industry5';
        validdetail2.Row__c = 2;
        validdetail2.BranchedReferred__c = '517';
        validdetail2.BranchedReferredName__c = '517';
        validdetail2.valid__c = True;
        
        LeadLogValidDetail__c validdetail3 = new LeadLogValidDetail__c();
        validdetail3.leadOwner__c = us[1].Id;
        validdetail3.LeadLogValidHeader__c = validhead1.id;
        validdetail3.PrimaryCampaign__c = '';
        validdetail3.LeadOwnerExceptionFlag__c = 'No';
        validdetail3.LinktoCustomer__c = acc[1].id;
        validdetail3.CustomerType__c = 'Juristic';
        validdetail3.CustomerName__c = '';
        validdetail3.CustomerNameEN__c = '';
        validdetail3.IDType__c = 'BRN ID';
        validdetail3.IDNumber__c = '1122334455667788';
        validdetail2.BranchedReferred__c = '578';
        validdetail2.BranchedReferredName__c = '578';
        validdetail3.Row__c = 3;
        validdetail3.valid__c = True;
        
        LeadLogValidDetail__c validdetail4 = new LeadLogValidDetail__c();
        validdetail4.leadOwner__c = us[1].Id;
        validdetail4.LeadLogValidHeader__c = validhead1.id;
        validdetail4.PrimaryCampaign__c = '';
        validdetail4.LeadOwnerExceptionFlag__c = 'No';
        validdetail4.LinktoCustomer__c = acc[1].id;
        validdetail4.CustomerType__c = 'Individual';
        validdetail4.CustomerName__c = '';
        validdetail4.CustomerNameEN__c = '';
        validdetail4.IDType__c = 'BRN ID';
        validdetail4.IDNumber__c = '';
        validdetail4.Row__c = 4;
        validdetail4.valid__c = False;
        
        LeadLogValidDetail__c validdetail5 = new LeadLogValidDetail__c();
        validdetail5.leadOwner__c = us[1].Id;
        validdetail5.LeadLogValidHeader__c = validhead1.id;
        validdetail5.PrimaryCampaign__c = '';
        validdetail5.LeadOwnerExceptionFlag__c = 'No';
        validdetail5.LinktoCustomer__c = acc[1].id;
        validdetail5.CustomerName__c = '';
        validdetail5.CustomerNameEN__c = '';
        validdetail5.TotalExpectedRevenue__c = '1234567890123456.12345';
        validdetail5.CustomerType__c = 'Individual';
        validdetail5.IDType__c = 'Citizen ID';
        validdetail5.IDNumber__c = '5100600076849';
        validdetail5.Row__c = 5;
        validdetail5.valid__c = true;
        
        LeadLogValidDetail__c validdetail6 = new LeadLogValidDetail__c();
        validdetail6.leadOwner__c = us[1].Id;
        validdetail6.LeadLogValidHeader__c = validhead1.id;
        validdetail6.PrimaryCampaign__c = '';
        validdetail6.LeadOwnerExceptionFlag__c = 'No';
        validdetail6.LinktoCustomer__c = acc[1].id;
        validdetail6.CustomerName__c = '';
        validdetail6.CustomerNameEN__c = '';
        validdetail6.ContactPhoneNumber__c = '08167988392test';
        validdetail6.OfficeNo__c = '08167988392test';
        validdetail6.MobileNo__c = '08167988392test';
        validdetail6.CustomerType__c = 'Individual';
        validdetail6.IDType__c = 'Citizen ID';
        validdetail6.IDNumber__c = '5100600076847';
        validdetail6.Row__c = 6;
        validdetail6.valid__c = true;
        
        LeadLogValidDetail__c validdetail7 = new LeadLogValidDetail__c();
        validdetail7.leadOwner__c = us[1].Id;
        validdetail7.LeadLogValidHeader__c = validhead1.id;
        validdetail7.PrimaryCampaign__c = '';
        validdetail7.LeadOwnerExceptionFlag__c = 'No';
        validdetail7.LinktoCustomer__c = acc[1].id;
        validdetail7.CustomerType__c = 'Juristic';
        validdetail7.CustomerName__c = '';
        validdetail7.CustomerNameEN__c = '';
        validdetail7.IDType__c = 'Citizen ID';
        validdetail7.Email__c = 'ken@#$%heisustest.com';
        validdetail7.IDNumber__c = '';
        validdetail7.Row__c = 7;
        validdetail7.valid__c = False;
        
        LeadLogValidDetail__c validdetail8 = new LeadLogValidDetail__c();
        validdetail8.leadOwner__c = us[1].Id;
        validdetail8.LeadLogValidHeader__c = validhead1.id;
        validdetail8.PrimaryCampaign__c = '';
        validdetail8.LeadOwnerExceptionFlag__c = 'No';
        validdetail8.LinktoCustomer__c = acc[1].id;
        validdetail8.CustomerType__c = '';
        validdetail8.CustomerName__c = '';
        validdetail8.CustomerNameEN__c = '';
        validdetail8.IDType__c = '';
        validdetail8.IDNumber__c = '123456789012345678901234567890';
        validdetail8.SubDistrict__c = 'one two three four five six seven eight nine ten eleven twevel thrith 123456778990 12344567890 123234992340230';
        validdetail8.Address__c = 'one two three four five six seven eight nine ten eleven twevel thrith 123456778990 12344567890 123234992340230';
        validdetail8.District__c = 'one two three four five six seven eight nine ten eleven twevel thrith 123456778990 12344567890 123234992340230';
        validdetail8.Email__c = '123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890@gmail.com';
        validdetail8.Ext__c = '123456789012345';
        validdetail8.ZipCode__c = '123456789012345';
        validdetail8.ReferralStaffID__c = '123456789012345';
        validdetail8.ReferralStaffName__c = '12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890';
        validdetail8.customerNameEN__c = '12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890';
        validdetail8.ContactPhoneNumber__C = '123456789012345123456789012345123456789012345123456789012345';
        validdetail8.MobileNo__c = '123456789012345123456789012345123456789012345123456789012345';
        validdetail8.OfficeNo__c = '123456789012345123456789012345123456789012345123456789012345';
        validdetail8.ContactPosition__c = '123456789012345123456789012345123456789012345123456789012345123456789012345123456789012345123456789012345123456789012345123456789012345123456789012345123456789012345123456789012345123456789012345';
        validdetail8.ContactFirstname__c = '12345678901234567890123456789012345678901234567890';
        validdetail8.ContactLastname__c = '123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890';
        validdetail8.NoOfyears__c = '1234567890';
        validdetail8.OtherSource__c = '123456789012345678901234567890';
        validdetail8.prescreen__c = 'failed';
        validdetail8.SalesAmountperyear__c = '12345678901234567890.123456';
        validdetail8.TotalExpectedRevenue__c = '12345678901234567890.123456';
        validdetail8.Row__c = 8;
        validdetail8.valid__c = False;
        
        LeadLogValidDetail__c validdetail9 = new LeadLogValidDetail__c();
        validdetail9.leadOwner__c = '99008';
        validdetail9.LeadLogValidHeader__c = validhead1.id;
        validdetail9.PrimaryCampaign__c = '';
        validdetail9.LeadOwnerExceptionFlag__c = 'no';
        validdetail9.LinktoCustomer__c = '';
        validdetail9.CustomerType__c = 'Juristic';
        validdetail9.CustomerName__c = 'Test Ken12345';
        validdetail9.CustomerNameEN__c = 'Test Ken12345';
        validdetail9.ContactLastname__c = 'Test Kennn33';
        validdetail9.ContactFirstname__c = 'Test Kennn32';
        validdetail9.IDType__c = 'BRN ID';
        validdetail9.IDNumber__c = '1122334455667789';
        validdetail9.Success__c = 'True';
        validdetail9.Row__c = 9;
        validdetail9.Industry__c = 'industry0';
        validdetail9.Groupname__c = 'group0';
        validdetail9.valid__c = True;
             
        validdetail.add(validdetail1);
        validdetail.add(validdetail2);
        validdetail.add(validdetail3);
        validdetail.add(validdetail4);
        validdetail.add(validdetail5);
        validdetail.add(validdetail6);
        validdetail.add(validdetail7);
        validdetail.add(validdetail8);
        validdetail.add(validdetail9);
        
        insert validdetail;
        
        set<id> setvalid = new set<id>();
        List<LeadLogValidDetail__c> scope = new List<LeadLogValidDetail__c>();
        for(LeadLogValidDetail__c val : validdetail){
            setvalid.add(val.id);
            scope.add(val);
        }        
        UploadLeadServiceV2 Testupload = new UploadLeadServiceV2();
        Testupload.csvFileBody = blob.valueOf(blobCreator);
        Testupload.importCSVFile();  
        Testupload.logfiles();
        
        
        PageReference pageRef = Page.UploadleadvalidV2;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', validhead1.id);
        
        UploadleadPagingControllerV2 Testuploadpage2 = new UploadleadPagingControllerV2();
        Testuploadpage2.Validatebatch();
        Testuploadpage2.insertLead();
        
        // Instantiate a new controller with all parameters in the page
        Testuploadpage2.getvalidlogs();
        Testuploadpage2.process();
        Testuploadpage2.Next();
        Testuploadpage2.First();
        Testuploadpage2.Last();
        Testuploadpage2.Previous();
        Testuploadpage2.Cancel();
        Testuploadpage2.con.getHasPrevious();
        Testuploadpage2.con.getHasNext();
        Testuploadpage2.con.getPageNumber();
        Testuploadpage2.con.getPageSize();
        
        
        
        PageReference pageRefcsv = Page.Uploadleadcsv;
        Test.setCurrentPage(pageRefcsv);
        ApexPages.currentPage().getParameters().put('idname', loghead[2].id);
        system.debug('ID : '+loghead[2].id);
        UploadleadLogCSV Testuploadcsv = new UploadleadLogCSV();
        Testuploadcsv.logdetail();//idname
            
        test.stopTest();
        
      
       
    }
}