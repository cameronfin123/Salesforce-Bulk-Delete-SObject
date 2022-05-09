@isTest
public class BulkDeleteSObjectTest {

    // Test delete when no records are deleted
    @isTest static void testNoRecordsSelected() {
        Account a1 = new Account(Name='Test Account 1');
        insert a1;
        List<String> inputStrings = new List<String>{};
        List<String> expectedResults = new List<String>{'No records deleted'};
            
        List<String> retVal1 = BulkDeleteSObject.DeleteSObject(null);
        System.assertEquals(expectedResults, retVal1);
        List<String> retVal2 = BulkDeleteSObject.DeleteSObject(inputStrings);
        System.assertEquals(expectedResults, retVal2);
    }
    
    @isTest static void testDeleteRecordSelected() {
        // Create sample accounts
        Account a1 = new Account(Name='Test Account 1');
        insert a1;
        Account a2 = new Account(Name='Test Account 2');
        insert a2;
        Account a3 = new Account(Name='Test Account 3');
        insert a3;
        
        String inputString1 = String.valueOf(a1.Id);
        String inputString2 = String.valueOf(a2.Id) + ','+ String.valueOf(a3.Id);
        List<String> expectedResults = new List<String>{'All records deleted'};
            
        List<String> retVal1 = BulkDeleteSObject.DeleteSObject(new List<String>{inputString1});
        System.assertEquals(expectedResults, retVal1);
        List<String> retVal2 = BulkDeleteSObject.DeleteSObject(new List<String>{inputString2});
        System.assertEquals(expectedResults, retVal2);
    }
}