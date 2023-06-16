import { LightningElement, track, api } from 'lwc';
import insertBooking from '@salesforce/apex/CH4_BookingController.insertBooking';
import validateVoucher from '@salesforce/apex/CH4_BookingController.validateVoucher';
export default class Ch4_BookingForm extends LightningElement {
    
    @api idser;
    @api img;
    @api name;
    @api description;
    @api price;

    contactName;
    contactEmail;
    contactPhone = '';
    contactBirthdate = [];
    voucher = '';
    discountPrice;
    voucherDiscount = 0;

    showValidVoucherMessage = false;
    showInvalidVoucherMessage = false;
    
    @track isRegisting = false;
    @track selectedDateFormatted;

    isVoucherApplied(){
        return this.showValidVoucherMessage;
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

    handleRegister(event){
        event.preventDefault();
        this.isRegisting = true;

        if(this.voucher === ''){
            console.log(this.voucher);
            insertBooking({
                id: this.idser,
                name: this.contactName, 
                email: this.contactEmail, 
                phone: this.contactPhone, 
                birthdate: this.contactBirthdate, 
                voucher: this.voucher, 
                serName: this.name,
                price: String(this.price)
            })
            .then(result => {
                this.handleBackHomepage();
            })
            .catch(error => {
                this.isRegisting = false;
            })
        }else{
            validateVoucher({
                voucher: this.voucher
            })
            .then(result => {
                if(result !== null){
                    this.showValidVoucherMessage = true;
                    this.showInvalidVoucherMessage = false;
                    this.voucherDiscount = result;
                    this.discountPrice = this.price * (100 - result) / 100;
                }else{
                    this.showValidVoucherMessage = false;
                    this.showInvalidVoucherMessage = true;
                    this.voucherDiscount = null;
                    this.discountPrice = null;
                    this.isRegisting = false;
                }
            })
            .then(() => {
                if(this.voucherDiscount){
                    insertBooking({
                        id: this.idser,
                        name: this.contactName, 
                        email: this.contactEmail, 
                        phone: this.contactPhone, 
                        birthdate: this.contactBirthdate, 
                        voucher: this.voucher, 
                        serName: this.name,
                        price: String(this.discountPrice)
                    })
                    .then(result => {
                        this.handleBackHomepage();
                    })
                    .catch(error => {
                        this.isRegisting = false;
                    })
                }
    
            })
        }

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
        const bdArr = [];
        if(event.target.value !== ''){
            const bd = new Date(event.target.value);
            bdArr.push(bd.getFullYear());
            bdArr.push(bd.getMonth() + 1);
            bdArr.push(bd.getDate());
        }
        this.contactBirthdate = [...bdArr];
    }
    handleChangeVoucher(event){
        this.voucher = event.target.value;
        this.showValidVoucherMessage = false;
        this.showInvalidVoucherMessage = false;
    }

    handleChangeAgree(event){
        this.validAgree = event.target.checked;
    }

    handleVerifyVoucher(event){
        if(this.voucher !== ''){
            validateVoucher({
                voucher: this.voucher
            })
            .then(result => {
                if(result !== null){
                    this.showValidVoucherMessage = true;
                    this.showInvalidVoucherMessage = false;
                    this.voucherDiscount = result;
                    this.discountPrice = this.price * (100 - result) / 100;
                }else{
                    this.showValidVoucherMessage = false;
                    this.showInvalidVoucherMessage = true;
                    this.voucherDiscount = null;
                    this.discountPrice = null;
                }
            })
        }
    }


    handleBackHomepage(event) {
        this.dispatchEvent(new CustomEvent('home'));
    }
}