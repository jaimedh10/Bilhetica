import { LightningElement, api } from "lwc";
import { updateRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { refreshApex } from '@salesforce/apex';
import TICKET_OBJECT from "@salesforce/schema/Ticket__c";
import ID_FIELD from "@salesforce/schema/Ticket__c.Id";
import STATUS_FIELD from "@salesforce/schema/Ticket__c.Status__c";
import validateTicket from "@salesforce/apex/TicketCustomController.validateTicket";

export default class TicketValidation extends LightningElement {
  @api recordId;
  ticketObject = TICKET_OBJECT;




  @api async invoke() {
    validateTicket({
      ticketId: this.recordId
    })
      .then((result) => {
        this.result = result;
        if (this.result != null) {
          const fields = {};
          fields[ID_FIELD.fieldApiName] = this.recordId;
          fields[STATUS_FIELD.fieldApiName] = this.result.Status__c;
          const recordInput = { fields };

          updateRecord(recordInput)
            .then(() => {
              this.handleSucess();
              // Display fresh data in the form
              return refreshApex(this.result);
            })
            .catch((error) => {
              console.log(error);
            });

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
    this.dispatchToast("Error!", "The Ticket is invalid.", "error");
  }

  sleep(ms) {
    // eslint-disable-next-line @lwc/lwc/no-async-operation
    return new Promise((resolve) => setTimeout(resolve, ms));
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
