public class IDGenerator
{
	private static Integer fakeIdCount = 0;
	private static final String ID_PATTERN = '000000000000';

	/**
	 * Generate a fake Salesforce Id for the given SObjectType
	 */
	public static Id generate(Schema.SObjectType sobjectType)
	{
		String keyPrefix = sobjectType.getDescribe().getKeyPrefix();
		fakeIdCount++;

		String fakeIdPrefix = ID_PATTERN.substring(0, 12 - fakeIdCount.format().length());

		return Id.valueOf(keyPrefix + fakeIdPrefix + fakeIdCount);
	}
}