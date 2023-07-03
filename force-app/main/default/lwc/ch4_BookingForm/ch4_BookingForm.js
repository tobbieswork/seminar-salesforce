import { LightningElement, track, api } from 'lwc';
import insertBooking from '@salesforce/apex/CH4_BookingController.insertBooking';
import validateVoucher from '@salesforce/apex/CH4_BookingController.validateVoucher';
import updateBookingToDone from '@salesforce/apex/CH4_BookingController.updateBookingToDone';
import createOrder from '@salesforce/apex/CH4_PayPalAPI.createOrder';
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

    convertVndToUsd(vndAmount) {
        // Assuming 1 USD = 23000 VND
        const exchangeRate = 23000;
        const usdAmount = vndAmount / exchangeRate;
        const roundedUsdAmount = Math.round(usdAmount * 100) / 100; // Round to 2 decimal places

        return roundedUsdAmount;
    }

    createOrderBody(bookingId, amount){
        const orderBody = {
            intent: "CAPTURE",
            purchase_units: [
                {
                    reference_id: String(bookingId),
                    amount: {
                        currency_code: "USD",
                        value: String(amount)
                    }
                }
            ],
            payment_source: {
                paypal: {
                    experience_context: {
                        payment_method_preference: "IMMEDIATE_PAYMENT_REQUIRED",
                        payment_method_selected: "PAYPAL",
                        brand_name: "FURU CRM",
                        locale: "en-US",
                        landing_page: "LOGIN",
                        user_action: "PAY_NOW",
                        return_url: "https://furucrm72-dev-ed.develop.my.salesforce-sites.com/successPayment",
                        cancel_url: "https://furucrm72-dev-ed.develop.my.site.com/BookingSerminar/"
                    }
                }
            }
        }

        const jsonBody = JSON.stringify(orderBody);
        return jsonBody;
    }

    handleRegister(event){
        event.preventDefault();
        this.isRegisting = true;

        if(this.voucher === ''){
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
                if(this.price){
                    const body = this.createOrderBody(String(result) ,String(this.price));
                    createOrder({
                        orderBody: body
                    }).then((link) => {
                        console.log(link);
                        window.location.href = link;
                    })
                }else{
                    updateBookingToDone({
                        bookingId: result
                    }).then((result)=>{
                        console.log(result);
                    }).then(()=>{
                        this.handleBackHomepage();
                    })
                }
            })
            .catch(error => {
                this.isRegisting = false;
                console.log(error);
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
                    this.discountPrice = Math.round(this.price * (100 - result) / 100);
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

                        if(this.discountPrice){
                            const body = this.createOrderBody(String(result) ,String(this.discountPrice));
                            createOrder({
                                orderBody: body
                            }).then((orderLink) => {
                                console.log(orderLink);
                                window.location.href = orderLink;
                            }).catch(error => {
                                console.log(error);
                            })
                        }else{
                            updateBookingToDone({
                                bookingId: result
                            }).then((result)=>{
                                console.log(result);
                            }).then(()=>{
                                this.handleBackHomepage();
                            })
                        }
                    })
                    .catch(error => {
                        this.isRegisting = false;
                        console.log(error);
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
                    this.discountPrice = Math.round(this.price * (100 - result) / 100);
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