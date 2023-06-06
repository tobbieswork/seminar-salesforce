import { LightningElement, track, wire } from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import getSerminarList from '@salesforce/apex/CH4_SerminarController.getSerminarList';
import getAllPublicSerminar from '@salesforce/apex/CH4_SerminarController.getAllPublicSerminar';

const SORT_ORDER_VALUE = [
    { label: 'ASC', value: 'asc' },
    { label: 'DESC', value: 'desc' },
];

const SORT_FIELD_VALUE = [
    { label: 'Name', value: 'name' },
    { label: 'Price', value: 'price' },
    { label: 'Start Date', value: 'startDate' },
];

const PAGE_SIZE_VALUE = [
    { label: '10', value: '10' },
    { label: '50', value: '50' },
    { label: '100', value: '100' },
]

export default class Ch4_AllSerminar extends NavigationMixin(LightningElement) {
    @track serminars;
    @track searchValue = null;
    @track dateRangeFrom = null;
    @track dateRangeTo = null;
    @track priceRangeFrom = null;
    @track priceRangeTo = null;
    @track sortOrder = 'asc';
    @track sortField = 'name';
    @track pageSize = '10';
    @track currentPage = 1;
    @track totalPage = 0;
    error;
    tempData;
    
    @wire(getAllPublicSerminar)
    allSerminar({ error, data}){
        if (data) {
            this.tempData = data;
            this.paginateSerminars(this.tempData);
            this.error = undefined;
        } else if (error) {
            console.log('error')
            this.error = error;
            this.tempData = undefined;
            this.serminars = undefined;
        }
    }

    connectedCallback(){
        console.log('homepage render!!!');
    }
    
    //DATA
    get orderOptions() {
        return SORT_ORDER_VALUE;
    }
    
    get fieldOptions() {
        return SORT_FIELD_VALUE;
    }

    get pageSizeOptions() {
        return PAGE_SIZE_VALUE;
    }

    filterAndSortOptions(){
        return {
            searchKey: this.searchValue,
            sortField: this.sortField,
            sortOrder: this.sortOrder,
            fromDate: this.dateRangeFrom,
            toDate: this.dateRangeTo,
            fromPrice: this.priceRangeFrom,
            toPrice: this.priceRangeTo
        }
    }
    //=============DATA=============//

    //METHOD

    resetFilter(){
        this.searchValue = null;
        this.dateRangeFrom = null;
        this.dateRangeTo = null;
        this.priceRangeFrom = null;
        this.priceRangeTo = null;
    }

    resetPagination(){
        this.currentPage = 1;
        this.totalPage = 0;
    }

    findSerminar(){
        console.log(this.searchValue, this.dateRangeFrom, this.dateRangeTo, this.priceRangeFrom, this.priceRangeTo)
        getSerminarList(this.filterAndSortOptions())
            .then((data) => {
                console.log(data);
                this.tempData = data;
                this.tempData = this.sortSerminars(this.tempData, this.sortOrder, this.sortField);
                this.resetPagination();
                this.paginateSerminars(this.tempData);
                this.error = undefined;
            })
            .catch((error) => {
                console.log('error');
                this.error = error;
                this.tempData = undefined;
                this.serminars = undefined;
                this.resetPagination();
            });
    }

    sortSerminars(data, order, field){
        if(data.length <= 1) return data;

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

    paginateSerminars(data){
        if(data.length < this.pageSize){
            console.log('no need to paginate');
            this.totalPage = 1;
            this.serminars = data;
        }else{
            console.log('paginated');
            this.totalPage = Math.ceil(data.length/this.pageSize);
            const allRecord = data;
            const start = (this.currentPage - 1) * parseInt(this.pageSize);
            const end = this.currentPage * parseInt(this.pageSize);
            this.serminars = allRecord.slice(start, end);
        }
    }

    //=============METHOD=============//

    //HANDLE EVENT
    handleChangeSearchValue(event) {
        this.searchValue = event.target.value;
    }

    handleChangeDateFrom(event){
        this.dateRangeFrom = event.target.value;
        console.log(event.target.value);
    }

    handleChangeDateTo(event){
        this.dateRangeTo = event.target.value;
        console.log(event.target.value);
    }

    handleChangePriceFrom(event){
        this.priceRangeFrom = event.target.value;
        console.log(event.target.value);
    }

    handleChangePriceTo(event){
        this.priceRangeTo = event.target.value;
        console.log(event.target.value);
    }

    handleChangePageSize(event){
        this.pageSize = event.target.value;
        console.log(this.pageSize);

        this.resetPagination();
        this.paginateSerminars(this.tempData);
    }

    handleChangeOrder(event) {
        this.sortOrder = event.target.value;

        this.tempData = this.sortSerminars(this.tempData, this.sortOrder, this.sortField);
        this.paginateSerminars(this.tempData);
    }
    
    handleChangeField(event) {
        this.sortField = event.target.value;

        this.tempData = this.sortSerminars(this.tempData, this.sortOrder, this.sortField);
        this.paginateSerminars(this.tempData);
    }

    handleClearFilter(event) {
        resetFilter();
    }
    
    handleSearch(event) {
        this.findSerminar();
    }
    
    handleOnEnter(event){
        if(event.keyCode === 13){
            this.searchValue = event.target.value;
            this.findSerminar();
        }
    }

    handleFirstPage(event){
        if(this.currentPage !== 1){
            this.currentPage = 1;
            this.paginateSerminars(this.tempData);
        }
    }

    handleLastPage(event){
        if(this.currentPage !== this.totalPage)
        this.currentPage = this.totalPage;
        this.paginateSerminars(this.tempData);
    }

    handlePreviousPage(event){
        if(this.currentPage > 1){
            this.currentPage -= 1;
            console.log(this.currentPage);
            this.paginateSerminars(this.tempData);

        }
    }
    
    handleNextPage(event){
        if(this.currentPage < this.totalPage){
            this.currentPage += 1;
            console.log(this.currentPage);
            this.paginateSerminars(this.tempData);
            
        }
    }

    handlePaginateDetail(event){
        console.log('clicked!')
        console.log(event.target.dataset.recordId);
        let cmpDef = {
            componentDef: "c:ch4_SerminarDetail",
            attributes: {
                recordId: event.target.dataset.recordId
            }
        };
        let encodedDef = btoa(JSON.stringify(cmpDef));

        this[NavigationMixin.Navigate]({
            type: "standard__webPage",
            attributes: {
                url: "/one/one.app#" + encodedDef
            }
        });
    }

    handleSubmit(event){
        event.preventDefault();
    }
    //=============HANDLE EVENT=============//

}