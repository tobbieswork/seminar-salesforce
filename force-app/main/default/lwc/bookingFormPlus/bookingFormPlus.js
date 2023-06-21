import { LightningElement, track, api } from 'lwc';
import insertBooking from '@salesforce/apex/CH4_BookingController.insertBooking';
import validateVoucher from '@salesforce/apex/CH4_BookingController.validateVoucher';
import { loadScript } from "paypal/paypal-js";


export default class Ch4_BookingForm extends LightningElement {
    
    @api idser;
    @api img;
    @api name;
    @api description;
    @api price;

    contactName;
    contactEmail;
    contactPhone;
    contactBirthdate;
    voucher;

    validEmail = false;
    validName = false;
    validAgree = false;
    isRegisting = false;

    @track selectedDateFormatted;

    connectedCallback(){
        const clientId = 'YOUR_CLIENT_ID';
        // const clientSecret = 'YOUR_CLIENT_SECRET';

        loadScript({ "client-id": clientId })
        .then((paypal) => {
            console.log(paypal);
        })
        .catch((err) => {
            console.error("failed to load the PayPal JS SDK script", err);
        });
    }


    get isValidated (){
        return ! ((this.validEmail && (this.validName) && this.validAgree) && !this.isRegisting);
    }

    formatDate(dateValue) {
        const date = new Date(dateValue);
        const year = date.getFullYear();
        const month = ('0' + (date.getMonth() + 1)).slice(-2);
        const day = ('0' + date.getDate()).slice(-2);
        return `${year}/${month}/${day}`;
    }

    handleDateChange(event) {
        this.selectedDateFormatted = event.target.value;
        // this.selectedDateFormatted = this.formatDate(this.selectedDate);
    }

    handleRegister(){
        this.isRegisting = true;
        validateVoucher({
            name: this.contactName, 
            email: this.contactEmail, 
            phone: this.contactPhone, 
            birthdate: this.contactBirthdate, 
            voucher: this.voucher, 
            serName: this.name,
            price: String(this.price)
        })
            .then(result => {
                let newPrice = this.price;
                if(result === null){
                    this.voucher = ''

                }else{
                    newPrice = this.price*(100 - result)/100;
                }

                insertBooking({
                    id: this.idser,
                    name: this.contactName, 
                    email: this.contactEmail, 
                    phone: this.contactPhone, 
                    birthdate: this.contactBirthdate, 
                    voucher: this.voucher, 
                    serName: this.name,
                    price: String(newPrice)
                })
                    .then(result => {
                        this.handleBackHomepage();
                    })
                    .catch(error => {
                        this.isRegisting = false;
                    })
            })
    }
    handleChangeName(event){
        this.contactName = event.target.value;
        this.validName = event.target.checkValidity();
    }

    handleChangeEmail(event){
        this.contactEmail = event.target.value;
        this.validEmail = event.target.checkValidity();
    }
    
    handleChangePhone(event){
        this.contactPhone = event.target.value;
    }
    handleChangeBorn(event){
        console.log(event.target.value);
        this.contactBirthdate = (event.target.value).split('-');
    }
    handleChangeVoucher(event){
        this.voucher = event.target.value;
    }

    handleChangeAgree(event){
        this.validAgree = event.target.checked;
    }


    handleBackHomepage(event) {
        this.dispatchEvent(new CustomEvent('home'));
    }
}