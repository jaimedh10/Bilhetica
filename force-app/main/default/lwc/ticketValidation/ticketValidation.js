import { LightningElement, api } from "lwc";
import TICKET_OBJECT from "@salesforce/schema/Ticket__c";
import validateTicket from "@salesforce/apex/TicketCustomController.validateTicket";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class TicketValidation extends LightningElement {
  @api recordId;
  ticketObject = TICKET_OBJECT;




  @api async invoke() {
    validateTicket({
      ticketId: this.recordId
    })
      .then((result) => {
        this.result = result;
        if (this.result === true) {
          this.handleSucess();
          console.log(result);
        } else {
          this.errorMessage();
        }
      })
      .catch((error) => {
        this.error = error;
        console.log(error);
      });
      await this.sleep(2000);
  }

  handleSucess() {
    this.dispatchToast(
      "Success!",
      "The Ticket was successfully validated.",
      "success"
    );
  }

  errorMessage() {
    this.dispatchToast(
      "Error!",
      "The Ticket is invalid.",
      "error"
    );
  }

  sleep(ms) {
    // eslint-disable-next-line @lwc/lwc/no-async-operation
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  dispatchToast(title, message, variant) {
    const evt = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant
    });
    this.dispatchEvent(evt);
  }
}