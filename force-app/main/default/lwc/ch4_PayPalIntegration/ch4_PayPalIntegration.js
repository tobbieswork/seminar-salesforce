import { LightningElement, track, api } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import PAYPAL_SDK from '@salesforce/resourceUrl/paypal_sdk';
import paypal from 'paypal-rest-sdk';

export default class PayPalIntegration extends LightningElement {
  @api amountToPay;
  @track isPayPalScriptLoaded = false;

  renderedCallback() {
    if (this.isPayPalScriptLoaded) {
      return;
    }

    loadScript(this, PAYPAL_SDK)
      .then(() => {
        this.isPayPalScriptLoaded = true;
        this.initializePayPal();
      })
      .catch(error => {
        console.error('Error loading PayPal SDK:', error);
      });
  }

  initializePayPal() {
    const paypalButtonContainer = this.template.querySelector('.paypal-button-container');

    if (paypalButtonContainer) {
      paypal.Buttons({
        createOrder: (data, actions) => {
          return actions.order.create({
            purchase_units: [
              {
                amount: {
                  currency_code: 'USD',
                  value: 1000,
                },
              },
            ],
          });
        },
        onApprove: (data, actions) => {
          return actions.order.capture().then(details => {
            // Payment is successfully captured
            console.log('Payment successful:', details);
            // Perform further actions or update the order status
          });
        },
        onError: error => {
          console.error('PayPal error:', error);
        },
      }).render(paypalButtonContainer);
    }
  }
}
