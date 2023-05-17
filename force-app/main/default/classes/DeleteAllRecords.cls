// Apex class to delete all records from a specific object
public class DeleteAllRecords {
    public static void deleteAll(String objectName) {
        try {
            String query = 'SELECT Id FROM ' + objectName;
            List<sObject> recordsToDelete = Database.query(query);
            Database.delete(recordsToDelete);
            System.debug('All records deleted from ' + objectName);
        } catch (Exception ex) {
            System.debug('Error deleting records: ' + ex.getMessage());
        }
    }
}