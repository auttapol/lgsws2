public class II_TestUtility {
	
	static Integer m_num = 1;
	
	@TestVisible public String getFakeId(Schema.SObjectType sot)
	{
		String result = String.valueOf(m_num++);
		return sot.getDescribe().getKeyPrefix() + '0'.repeat(12-result.length()) + result;
	}
/*
	@TestVisible void assertSobjectListEquals(List<SObject> listA, List<SObject> listB)
	{
		if(listA==null || listB==null)
		{
			system.assert(listA==null && listB==null);
		}
		else
		{
			system.assert(listA.size()==listB.size(), listA.size() + ' <> ' + listB.size());
			Iterator<SObject> iterB = listB.iterator();
			for(SObject itemA : listA)
			{
				sObject itemB = iterB.next();
				system.assertEquals(itemA, itemB, itemA + ' <> ' + itemB);
			}
		}
	}*/
}