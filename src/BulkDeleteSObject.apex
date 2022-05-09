public class BulkDeleteSObject {
    
    @InvocableMethod()
    public static List<String> DeleteSObject(List<String> s) {
        if ( s == null || s.size() <= 0 ) {
            return new List<String>{'No records deleted'};
        }
        String sObjectIdsList = s.get(0);
        sObjectIdsList = sObjectIdsList.replace(' ', '');
        List<String> sObjectIdsAsString = sObjectIdsList.split(',');
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
}