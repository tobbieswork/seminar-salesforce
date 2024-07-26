import { LightningElement, track, api } from 'lwc';
import insertBooking from '@salesforce/apex/CH4_BookingController.insertBooking';
import validateVoucher from '@salesforce/apex/CH4_BookingController.validateVoucher';
import updateBookingToDone from '@salesforce/apex/CH4_BookingController.updateBookingToDone';
import createPaymentForBooking from '@salesforce/apex/CH4_PaymentController.createPaymentForBooking';
import createOrder from '@salesforce/apex/CH4_PayPalAPI.createOrder';
export default class Ch4_BookingForm extends LightningElement {
    
    @api idser;
    @api img;
    @api name;
    @api description;
    @api price;
    
    @track isRegisting = false;
    @track selectedDateFormatted;

    contactName;
    contactEmail;
    contactPhone = '';
    contactBirthdate = [];
    voucher = '';
    discountPrice;
    voucherDiscount = 0;

    showValidVoucherMessage = false;
    showInvalidVoucherMessage = false;
    
    isVoucherApplied(){
        return this.showValidVoucherMessage;
    }


    handleDateChange(event) {
        this.selectedDateFormatted = event.target.value;
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
        let finalPrice;
        event.preventDefault();
        this.isRegisting = true;
        
        validateVoucher({
            voucher: this.voucher
        }).then(percent => {
            if(percent === 0){
                finalPrice = this.price;
            }else if(percent == null){
                this.showValidVoucherMessage = false;
                this.showInvalidVoucherMessage = true;
                this.voucherDiscount = null;
                this.discountPrice = null;
                this.isRegisting = false;
            }else{
                this.showValidVoucherMessage = true;
                this.showInvalidVoucherMessage = false;
                this.voucherDiscount = percent;
                this.discountPrice = Math.round(this.price * (100 - percent) / 100);
                finalPrice = this.discountPrice;
            }
        }).then(() => {
            if(this.isRegisting){
                insertBooking({
                    id: this.idser,
                    name: this.contactName, 
                    email: this.contactEmail, 
                    phone: this.contactPhone, 
                    birthdate: this.contactBirthdate, 
                    voucher: this.voucher, 
                    serName: this.name,
                    price: String(finalPrice)
                }).then(bkId => {
                    if(finalPrice){
                        const body = this.createOrderBody(String(bkId) ,String(finalPrice));
                        createOrder({
                            orderBody: body
                        }).then((orderLink) => {
                            window.location.href = orderLink;
                        }).catch(error => {
                            console.log(error);
                        })
                    }else{
                        updateBookingToDone({
                            bookingId: bkId
                        }).then(()=>{
                            this.handleBackHomepage();
                        })
                        createPaymentForBooking({
                            bookingId: bkId,
                            bookingPrice: String(finalPrice)
                        })

                    }
                })
                .catch(error => {
                    this.isRegisting = false;
                    console.log(error);
                })
            }
        }).catch(error => {
            console.log(error);
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