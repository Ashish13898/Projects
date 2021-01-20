/**
* DescribeCacheTest
* 
* @description Test Class for DescribeCache
* ============================================================================================
* Date                Developer           Description
* -----------         ---------------     ----------------------------------------------------
* 03-Spet-2020        Ashish Dave         Test Class for DescribeCache
*/
@IsTest
class CCH_DescribeCacheTest
{
    static testMethod void testGetField()
    {
        Test.startTest();
            SObjectField field = DescribeCache.getField(User.sObjectType, 'Name');
        Test.stopTest();
        
        system.assertEquals(User.Name, field, 'The correct field should be retrieved');
    }
    static testMethod void testGetField_DNE()
    {
        Test.startTest();
            SObjectField field = DescribeCache.getField(User.sObjectType, 'Bogus');
        Test.stopTest();
        
        system.assertEquals(null, field,
            'Field names which do not exist should result in a null return value');
    }
    static testMethod void testGetField_CrossObject()
    {
        Test.startTest();
            SObjectField field = DescribeCache.getField(User.sObjectType, 'Profile.Name');
        Test.stopTest();
        
        system.assertEquals(Profile.Name, field, 'The correct field should be retrieved');
    }
    static testMethod void testGetField_CrossObject_DNE()
    {
        Test.startTest();
            SObjectField field = DescribeCache.getField(User.sObjectType, 'Bogus.Name');
        Test.stopTest();
        
        system.assertEquals(null, field,
            'Relationship names which do not exist should result in a null return value');
    }
}