public class BulkDeleteSObject {
    
    @InvocableMethod()
    public static List<String> DeleteSObject(List<FlowInputs> inputs ) {
        if ( inputs == null || inputs.size() <= 0 ) {
            return new List<String>{'No records deleted'};
        }
        FlowInputs input = inputs.get(0);
        String idsString = input.idsString;
        List<String> idsList = input.idsList;
        
        List<String> sObjectIdsAsString = new List<String>();
        
        if ( idsString != null && idsString != '' ) {
            idsString = idsString.replace(' ', '');
            idsString = idsString.replace('[', '');// remove the opening bracket if it exists
            idsString = idsString.replace(']', '');// remove the closing bracket if it exists
            sObjectIdsAsString = idsString.split(',');
        } else if ( idsList != null && idsList.size() > 0 ) {
            sObjectIdsAsString = idsList;
        } else {
            return new List<String>{'No records deleted'}; 
        }
        
        
        List<SObject> sObjsToDelete = new List<SObject>();
        
        // constructs the query
        Id tempRecId = Id.valueOf(sObjectIdsAsString.get(0));
        String sObjectName = tempRecId.getSObjectType().getDescribe().getName();
        
        String query = 'select Id from ' + sObjectName + ' where Id IN: sObjectIdsAsString';
        System.debug(query);
        List<SObject> recordList = Database.query(query);
        
        Database.DeleteResult[] drList = Database.delete(recordList,false);
        
        // Error handeling
        Integer numOfRecordsToDelete = recordList.size();
        Integer numDeletedRecords = 0;
        String errorMessage = '';
        for(Database.DeleteResult dr : drList ) {
            if ( dr.isSuccess() ) {
                System.debug('Successfully deleted record with ID: ' + dr.getId());
                numDeletedRecords++;
            } else {
                // Operation failed, so get all errors                
                for(Database.Error err : dr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Record fields that affected this error: ' + err.getFields());
                    errorMessage += 'The following error has occurred\n';                    
                    errorMessage += err.getStatusCode() + ': ' + err.getMessage()+ '\n\n';
                }
            }
        }
        List<String> retVal = new List<String>();
        
        if ( numOfRecordsToDelete == numDeletedRecords ) {
            retVal.add('All records deleted');
        } else if (numDeletedRecords > 0) {
            retVal.add('' + numDeletedRecords + ' out of ' + numOfRecordsToDelete + ' deleted.\n\n' + errorMessage);
        } else {
            retVal.add('No records deleted:\n\n' + errorMessage);
        }
        
        return retVal;
    }
    
    //input details that comes to apex from flow
    public class FlowInputs{
    
        @InvocableVariable(label='String of Ids' description='Use this if using API 54 or before')
        public String idsString;
        
        @InvocableVariable(label='List of Ids' description='Use this if using API 55 or after')
        public List<String> idsList;
        
    }
}