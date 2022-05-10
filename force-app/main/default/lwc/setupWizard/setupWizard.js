import { LightningElement } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import VENUE_OBJECT from "@salesforce/schema/Venue__c";
import createSections from "@salesforce/apex/SetupWizardController.createSections";

export default class SetupWizard extends LightningElement {
  venueObject = VENUE_OBJECT;
  venueId;

  numberOfSections = 0;

  // Boolean p/ mostrar determinado template
  isLoading = false;
  showSectionForm = false;
  showSectionButton = false;

  // Listas
  sections = [];

  handleNumberOfSections(event) {
    this.numberOfSections = event.detail.value;
    if(this.numberOfSections > 0) {
      createSections({
        numberOfSections: this.numberOfSections,
        venueId: this.venueId
      })
        .then((result) => {
          this.sections = result;
          if(this.sections.length > 0)
            
          console.log(result);
        })
        .catch((error) => {
          this.error = error;
          console.log(error);
        });
      
    } 
    
  }

  handleAddSection() {
    this.showSectionForm = true;
  }

  handleSuccess(event) {
    this.successfulInsert();
    this.venueId = event.detail.id;
    this.showSectionButton = true;
    //updateRecord({ fields: { Id: this.recordId } }); não está a fazer o efeito pretendido
  }

  handleSectionUpdate() {
    this.dispatchToast(
      "Success!",
      "The Section record has been successfully updated.",
      "success"
    );
  }

  successfulInsert() {
    this.dispatchToast(
      "Success!",
      "The Venue record has been successfully saved.",
      "success"
    );
  }

  errorDefaultMessage() {
    this.dispatchToast(
      "Error!",
      "An unexpected error has ocurred. Please try again",
      "error"
    );
  }

  dispatchToast(title, message, variant) {
    this.hideLoading();
    const evt = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant
    });
    this.dispatchEvent(evt);
  }

  hideLoading() {
    this.isLoading = false;
  }

  showLoading() {
    this.isLoading = true;
  }
}