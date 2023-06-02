import { LightningElement, track, wire } from 'lwc';
import getSerminarList from '@salesforce/apex/CH3_SerminarController.getSerminarList';
import getAllPublicSerminar from '@salesforce/apex/CH3_SerminarController.getAllPublicSerminar';
export default class Ch3_SerminarDetail extends LightningElement {
    @track searchValue = null;
    @track serminars;
    @track field = 'name';
    @track sortOrder = 'asc';
    @track fromDate = '';
    @track toDate = '';
    @track fromPrice = '';
    @track toPrice = '';
    error;
    tempData;

    @wire(getAllPublicSerminar)
    allSerminar({ error, data}){
        if (data) {
            this.serminars = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.serminars = undefined;
        }
    }
    
    get orderOptions() {
        return [
            { label: 'ASC', value: 'asc' },
            { label: 'DESC', value: 'desc' },
        ];
    }
    
    get fieldOptions() {
        return [
            { label: 'Name', value: 'name' },
            { label: 'Price', value: 'price' },
            { label: 'Start Date', value: 'startDate' },
        ];
    }
    
    sortSerminars(data, order, field){
        if(data.length > 1){
            const serminarsSorted = [...data];
            let isAsc;

            if (order === 'asc'){
                isAsc = 1;
            }else{
                isAsc = -1;
            }

            switch (field) {
                case 'name':
                    serminarsSorted.sort((a,b) => {
                        return a.Name > b.Name ? isAsc : a.Name < b.Name ? -isAsc : 0;
                    })
                    break;
                case 'price':
                    serminarsSorted.sort((a,b) => {
                        const priceA = a.Price__c || 0;
                        const priceB = b.Price__c || 0;
                        return priceA > priceB ? isAsc : priceA < priceB ? -isAsc : 0;
                    })
                    break;
                case 'startDate':
                    serminarsSorted.sort((a,b) => {
                        const dateA = a.Start_Date__c ? new Date(a.Start_Date__c) : 0;
                        const dateB = b.Start_Date__c ? new Date(b.Start_Date__c) : 0;
                        return dateA > dateB ? isAsc : dateA < dateB ? -isAsc : 0;
                    })
                    break;
                default:
                    break;
            }

            return serminarsSorted;
        }
    }

    findSerminar(){
        getSerminarList({ searchKey : this.searchValue})
            .then((data) => {
                this.tempData = data;
                this.tempData = this.sortSerminars(this.tempData, this.sortOrder, this.field);
                this.serminars = this.tempData;
                this.error = undefined;
            })
            .catch((error) => {
                this.error = error;
                this.tempData = undefined;
            });
    }
    
    handleChangeSearchValue(e) {
        this.searchValue = e.target.value;
    }

    handleSearch() {
        this.findSerminar();
    }
    
    handleOnEnter(e){
        if(e.keyCode === 13){
            this.searchValue = e.target.value;
            this.findSerminar();
        }
    }
    
    handleChangeOrder(e) {
        this.sortOrder = e.target.value;
        this.serminars = this.sortSerminars(this.serminars, this.sortOrder, this.field);
    }
    
    handleChangeField(e) {
        this.field = e.target.value;
        this.serminars = this.sortSerminars(this.serminars, this.sortOrder, this.field);
    }

    handleSubmit(e){
        e.preventDefault();
    }
}