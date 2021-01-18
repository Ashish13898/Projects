public class  CCH_DataTableController {
    @AuraEnabled
    public static List<Map<String,String>> getRecordList(String objectName,String fields,String whereClause,String orderByField,String orderBy,String userId,Integer limitValue) 
    {
      return CCH_DataTableGenericHelper.getRecordsAsPerUserProfile(objectName,fields,whereClause,orderByField,orderBy,userId,limitValue);
    }
 
}