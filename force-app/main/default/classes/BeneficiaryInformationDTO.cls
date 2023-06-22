global class BeneficiaryInformationDTO {
	/*----------------------------------------------------------------------------------
	  Author:        Keattisak Chinburarat
	  Company:       I&I Consulting 
	  Description:   Data Transfer Objects
	  Inputs:        None
	  Base Class:    -
	  Test Class:    -
	  History
	  <Date>      <Authors Name>     <Brief Description of Change>
	  ----------------------------------------------------------------------------------*/

	global string BeneficiaryName { get; set; }
	global string Relationship    { get; set; }
	global decimal BenefitPercent { get; set; }
}