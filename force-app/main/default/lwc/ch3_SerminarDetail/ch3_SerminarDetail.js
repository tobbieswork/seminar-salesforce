import { LightningElement, track, wire } from 'lwc';
import getSerminarList from '@salesforce/apex/CH3_SerminarController.getSerminarList';


export default class Ch3_SerminarDetail extends LightningElement {
    @track field = 'name';
    @track sortOrder = 'asc';
    @track fromDate = '';
    @track toDate = '';
    @track fromPrice = '';
    @track toPrice = '';
    @track error;
    @track tempData = [];
    @track searchValue = null;
    @track serminars;

    @wire(getSerminarList, {keySearch: '$searchValue'})
    querySerminars({error, data}) {
        if(data) {
            this.tempData = data;
            this.tempData = this.sortSerminars(this.tempData, this.sortOrder, this.field);
            // this.formatCurrency(this.tempData);
            this.error = undefined;
        } else if(error) {
            this.error = error;
            this.tempData = undefined;
            console.log('error')
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
            console.log(field, order);
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

    // formatCurrency(data){
    //     if(data[0]){
    //         for(const d of data){
    //             if(d.Price__c){
    //                 let price = String(d.Price__c);
    //                 let formatedPrice = [];
    //                 while(price.length > 3){
    //                     formatedPrice.unshift(price.slice(-3));
    //                     price = price.slice(0,-3);
    //                 }
    //                 formatedPrice.unshift(price);
    //                 d.Price__c = formatedPrice.join('.') + 'đ';
    //             }
    //         }
    //     }
    // }

    
    handleChangeSearchValue(e) {
        this.searchValue = e.target.value;
    }
    
    handleChangeOrder(e) {
        this.sortOrder = e.target.value;
        this.serminars = this.sortSerminars(this.serminars, this.sortOrder, this.field);
    }
    
    handleChangeField(e) {
        this.field = e.target.value;
        this.serminars = this.sortSerminars(this.serminars, this.sortOrder, this.field);
    }

    handleOnBlur(e){
        this.searchValue = e.target.value;
    }

    handleSearch() {
        this.serminars = this.tempData;
    }
    
    handleOnEnter(e){
        if(e.keyCode === 13){
            this.searchValue = e.target.value;
            this.serminars = this.tempData;
        }
    }

    handleSubmit(e){
        e.preventDefault();
    }
}