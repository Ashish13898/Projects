/**
* CCH_DescribeCache
* 
* @description Generic Class to get the SobjectType with SobjectField 
* ============================================================================================
* Date                Developer           Description
* -----------         ---------------     ----------------------------------------------------
* 03-Spet-2020        Ashish Dave         Generic Class to get the SobjectType with SobjectField
*/
global class CCH_DescribeCache
{
    static final Map<SObjectType, Map<String, SObjectField>> fields = new Map<SObjectType, Map<String, SObjectField>>();
    
    /*
     * Method to check the profile level access for the fields for the logged in user
     * */
    global static SObjectField getField(SObjectType sObjectType, String fieldPath)
    {
        if (sObjectType == null || fieldPath == null) return null;
        if (!fields.containsKey(sObjectType))
            fields.put(sObjectType, sObjectType.getDescribe().fields.getMap());
        if (!fieldPath.contains('.')) return fields.get(sObjectType).get(fieldPath);
        
        Relationship relation = new Relationship(fieldPath.substringBefore('.'));
        SObjectField field = fields.get(sObjectType).get(relation.getFieldPath());
        if (field == null) return null;
        
        SObjectType parentType = field.getDescribe().getReferenceTo()[0];
        return getField(parentType, fieldPath.substringAfter('.'));
    }
    class Relationship
    {
        final String name;
        public Relationship(String name) { this.name = name; }
        public String getFieldPath()
        {
            if (name == null) return null;
            return name.endsWith('__r') ?
                name.replace('__r', '__c') : name + 'Id';
        }
    }
}