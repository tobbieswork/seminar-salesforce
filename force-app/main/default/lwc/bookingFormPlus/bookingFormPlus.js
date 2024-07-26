import { LightningElement, track, api } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import insertBooking from '@salesforce/apex/CH4_BookingController.insertBooking';
import validateVoucher from '@salesforce/apex/CH4_BookingController.validateVoucher';
import PayPal_JS_SDK from "@salesforce/resourceUrl/PayPal_JS_SDK";
import paypaljs from "@salesforce/resourceUrl/paypal_sdk";


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

    async connectedCallback(){
        console.log('Component mounted');

        await loadScript(this, PayPal_JS_SDK + '/PAYPAL_SDK/paypal_sdk.js')
        .then(() => {
            this.initializePayPal();
        })
        .catch((err) => {
            console.log(...err);
        });
    }

    initializePayPal() {
        console.log('Component run initial');

        // Check if PayPal SDK is loaded
    
        // Configure PayPal SDK with API credentials
        // paypal.configure({
        //   client_id: 'YOUR_CLIENT_ID',
        //   secret_key: 'YOUR_SECRET_KEY',
        // });
    
        // Create a PayPal checkout button
        paypal.Buttons({
          createOrder: (data, actions) => {
            return actions.order.create({
              purchase_units: [
                {
                  amount: {
                    currency_code: 'USD',
                    value: '10.00', // Set the amount to pay here
                  },
                },
              ],
            });
          },
          onApprove: (data, actions) => {
            // Handle the payment approval and completion
            actions.order.capture().then((details) => {
              // Payment is successfully captured
              console.log('Payment successful:', details);
              // Perform further actions or update the order status
            });
          },
          onError: (err) => {
            // Handle errors that occur during the payment process
            console.error(err);
          },
        }).render(this.template.querySelector('.paypal-container'));
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