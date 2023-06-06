@isTest
public class CH3_SerminarControllerTest {
	@isTest
    static void testGetSerminarListWithoutKey() {
        // Test case when searchKey is empty
        List<Serminar__c> serminarPublicList = new List<Serminar__c>();

        for (Integer i = 0; i < 10; i++) {
            Serminar__c seminar = new Serminar__c();
            seminar.Name = 'Seminar ' + String.valueOf(i + 1);
            seminar.Start_Date__c = Date.today().addDays(i);
            seminar.Price__c = 100000 * (i + 1);
            seminar.Description__c = 'Description of Seminar ' + String.valueOf(i + 1);
            seminar.Is_Public__c = 'True';
            serminarPublicList.add(seminar);
        }
        
        Integer numberOfPublic = serminarPublicList.size();
        
        for (Integer i = 10; i < 20; i++) {
            Serminar__c seminar = new Serminar__c();
            seminar.Name = 'Seminar ' + String.valueOf(i + 1);
            seminar.Start_Date__c = Date.today().addDays(i);
            seminar.Price__c = 100000 * (i + 1);
            seminar.Description__c = 'Description of Seminar ' + String.valueOf(i + 1);
            seminar.Is_Public__c = 'False';
            serminarPublicList.add(seminar);
        }
        
        insert serminarPublicList;

        
        Test.startTest();
        List<Serminar__c> actualSerminars = CH3_SerminarController.getSerminarList('');
        Test.stopTest();
        System.assertEquals(numberOfPublic, actualSerminars.size());
    }
    
    @isTest
    static void testGetSerminarListWithKey(){
        // Test case when searchKey is not empty
        String searchKey = 'test';
        
		List<Serminar__c> serminarContainKeySearch = new List<Serminar__c>();
		
        Serminar__c publicSerminar = new Serminar__c();
        
        
        publicSerminar.Name = 'Test ';
        publicSerminar.Start_Date__c = Date.today();
        publicSerminar.Price__c = 100000;
        publicSerminar.Description__c = 'Description of Test test test ';
        publicSerminar.Is_Public__c = 'True';
        publicSerminar.Image__c = 'abcdefgh';
        
        insert publicSerminar;
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = publicSerminar.Id;
        Test.setFixedSearchResults(fixedSearchResults);
        
        //Id, Name, Description__c, Price__c, Start_Date__c, Image__c
        for (Integer i = 0; i < 10; i++) {
            Serminar__c seminar = new Serminar__c();
            seminar.Name = 'Test ' + String.valueOf(i + 1);
            seminar.Start_Date__c = Date.today().addDays(i);
            seminar.Price__c = 100000 * (i + 1);
            seminar.Description__c = 'Description of Test test test ' + String.valueOf(i + 1);
            seminar.Is_Public__c = 'True';
            seminar.Image__c = 'abcdefgh' + String.valueOf(i + 1);
            serminarContainKeySearch.add(seminar);
        }
        
        insert serminarContainKeySearch;

        
        System.debug([FIND :searchKey 
                      IN ALL FIELDS 
                      RETURNING Serminar__c(Id, Name, Description__c, Price__c, Start_Date__c, Image__c 
                                            WHERE Is_Public__c = 'True' LIMIT 1)]);
        
        System.debug([FIND :searchKey 
                      IN ALL FIELDS 
                      RETURNING Serminar__c(Id, Name, Description__c, Price__c, Start_Date__c, Image__c 
                                            WHERE Is_Public__c = 'True')][0].size());
        
        Test.startTest();
        Integer numberOfRecord = CH3_SerminarController.getSerminarList(searchKey).size();
        Test.stopTest();
        System.assertEquals(1, numberOfRecord);
    }
    
    @isTest
    static void testGetAllPublicSerminar() {
        List<Serminar__c> serminarPublicList = new List<Serminar__c>();

        for (Integer i = 0; i < 10; i++) {
            Serminar__c seminar = new Serminar__c();
            seminar.Name = 'Seminar ' + String.valueOf(i + 1);
            seminar.Start_Date__c = Date.today().addDays(i);
            seminar.Price__c = 100000 * (i + 1);
            seminar.Description__c = 'Description of Seminar ' + String.valueOf(i + 1);
            seminar.Is_Public__c = 'True';
            serminarPublicList.add(seminar);
        }
        
        insert serminarPublicList;
        Test.startTest();
        List<Serminar__c> actualSerminars = CH3_SerminarController.getAllPublicSerminar();
        Test.stopTest();
        System.assertEquals(serminarPublicList.size(), actualSerminars.size());
    }
}