/**
* CCH_DataTableGenericHelper
* 
* @description Helper Class for Data Table Controller
* ============================================================================================
* Date                Developer           Description
* -----------         ---------------     ----------------------------------------------------
* 03-Spet-2020        Ashish Dave         Helper Class for Data Table Controller
*/
public with sharing class CCH_DataTableGenericHelper {
    
    public static Map<String,Boolean> fieldAccessMap = new Map<String,Boolean>();
    public static Map<String,Schema.DisplayType> fieldTypeMap = new Map<String,Schema.DisplayType>();
    
    /*
     * Method to get the JSON for the data table
     * */
    public static List<Map<String,String>> getRecordsAsPerUserProfile(String objectName,String fields,String whereClause,String orderByField,
                                                                      String orderBy,String userId,Integer limitValue) 
    {
        List<Sobject> recordList = new List<Sobject>();
        //List<String> responseMap = new List<String>();
        List<Map<String,String>> responseMap = new List<Map<String,String>>();
        try{
            String accessfields = checkProfileLevelAccess(objectName,fields);
            
            if(accessfields != null)
            {
                String loggedInUserId = userId != null ? userId : UserInfo.getUserId();
                String query = generateQuery(objectName,accessfields,whereClause,orderByField,orderBy,loggedInUserId,limitValue);
                recordList = Database.query(query);
                responseMap = generateJSON(recordList,objectName,fields);
                system.debug('responseMap  ***'+responseMap);
                return responseMap;
                
            }
        }
        catch(Exception ex)
        {
            system.debug('*** exception : ' + ex.getLineNumber() + ', ' + ex.getMessage());
        }
        return null; 
    }
    
    /*
     * Method to get the SOQL query
     * */
    public static String generateQuery(String objectName,String fields,String whereClause,
                                       String orderByField,String orderBy,String userId,Integer limitValue) 
    {
        String query = 'SELECT ';
        
        if(String.isNotBlank(fields)) query += fields;
        
        if(String.isNotBlank(objectName))  query += ' FROM ' + objectName ;
        
        if(String.isNotBlank(whereClause))
        {
            query += ' WHERE ' + whereClause;          
        }
        if(String.isNotBlank(userId))
        {
            if(String.isNotBlank(whereClause)) query += ' AND ';
            else query += ' WHERE ';
            query += 'createdById = \'' + userId + '\'';
        }  
        
        if(String.isNotBlank(orderByField) && String.isNotBlank(orderBy)) query += 'ORDER BY ' + orderByField + ' ' + orderBy;
        
        if(limitValue != null && limitValue > 0) query += ' LIMIT ' + limitValue;
        system.debug('query  ***'+query);
        return query;
    }
    
    /*
     * Method to get JSON for the Datatable
     * */
    public static List<Map<String,String>> generateJSON(List<Sobject> queryRecords,String objectName,String fields)
    {
        //  List<String> resMap = new List<String>();
        List<Map<String,String>> resMap = new List<Map<String,String>>();
        Map <Id,Sobject> sobjectMap = new Map <Id,Sobject>();
        sobjectMap.putAll(queryRecords);
        
        for(Sobject sObj : sobjectMap.values())
        {
            Map<String,String> tempMap = new Map<String,String>();
            
            for(String field : fields.split(','))
            {
                //if(isAccessible(objectName,field))
                if(fieldAccessMap.get(field))
                {
                    if(sobjectMap.containsKey((String)sObj.get('Id')))
                    {
                        String value;
                        String fieldValue;
                        if(!field.contains('.'))
                        {
                            fieldValue = field;
                            value = (String.valueOf(sobjectMap.get((String)sObj.get('Id')).get(field)));
                            //      tempMap.put(field, value != null ? value : '');
                        }
                        else if(field.contains('.'))
                        {
                            fieldValue = field.split('\\.')[0];
                            value = String.valueOf(TriggerUtility.getFieldValue(field,sObj));
                        }
                        if((fieldTypeMap.get(field) == Schema.DisplayType.DateTime ||
                            fieldTypeMap.get(field) == Schema.DisplayType.Date) && value != '' && value != null)
                        {
                            Date d = Date.valueOf(value);
                            value = d.month() + '/' + d.day() + '/' + d.year();
                        }
                        tempMap.put(fieldValue, value != null && value != '' ? value : '');
                    }
                }
                else
                {
                    tempMap.put(field, '');
                }
            }
            resMap.add(tempMap);
            //resMap.add(JSON.Serialize(tempMap));
        }
        system.debug('resMap  ***'+resMap);
        return resMap;
    }
   
    
    /*
     * Method to check the profile level access for the fields for the logged in user
     * */
    public static String checkProfileLevelAccess(String objectName, String fields)
    {
        SObjectType schemaType = Schema.getGlobalDescribe().get(objectName);
        Map<String, SObjectField> fieldMap = schemaType.getDescribe().fields.getMap();
        
        List<String> accessFields = new List<String>();
        for (String field : fields.split(','))
        {
            Boolean isValid = false;
            // if (fieldMap.get(field).getDescribe().isAccessible())
            SObjectField sfield = getSobjectField(objectName,field);
            if (sfield != null && sfield.getDescribe().isAccessible())
            {
                isValid = true;
                accessFields.add(field.trim());
            }
            fieldAccessMap.put(field,isValid);
            fieldTypeMap.put(field,sfield.getDescribe().getType());
        }
        return accessFields.size() >0 ? String.join(accessFields, ',') : null;
    }
     
    /*
     * Method to get the sobject Field
     * */
    public static SObjectField getSobjectField(String sObjectType, String fieldName)
    {
        SObjectType schemaType = Schema.getGlobalDescribe().get(sObjectType);
        
        SObjectField field = CCH_DescribeCache.getField(schemaType, fieldName);
        
        return (field == null) ? null : field;
    }
    
}