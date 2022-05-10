import { LightningElement } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import VENUE_OBJECT from "@salesforce/schema/Venue__c";
import ROW_OBJECT from "@salesforce/schema/Row__c";
import createSections from "@salesforce/apex/SetupWizardController.createSections";
import createRows from "@salesforce/apex/SetupWizardController.createRows";

export default class SetupWizard extends LightningElement {
  venueObject = VENUE_OBJECT;
  rowObject = ROW_OBJECT;
  venueId;
  sectionId;

  numberOfSections = 0;
  numberOfRows = 0;

  // Boolean p/ mostrar determinado template
  isLoading = false;
  showSectionForm = false;
  showSectionButton = false;
  showSectionInput = false;
  showRows = false;
  test = true;

  // Listas
  venuesIdsList;
  sections = undefined;
  rows = undefined;

  


  

  handleSuccess(event) {
    this.successfulInsert();
    this.venueId = event.detail.id;
    //this.venuesIdsList.push(this.venueId);
    this.showSectionButton = true;
    //updateRecord({ fields: { Id: this.recordId } }); não está a fazer o efeito pretendido
  }

  handleSectionForm() {
    if (this.numberOfSections > 0) {
      createSections({
        numberOfSections: this.numberOfSections,
        venueId: this.venueId
      })
        .then((result) => {
          this.sections = result;
          if (this.sections.length > 0) 
            console.log(result);
            this.showSectionForm = true;
        })
        .catch((error) => {
          this.error = error;
          console.log(error);
        });
    }
  }

  handleRowsForm(event) {
    this.sectionId = event.currentTarget.dataset.section;
    if (this.numberOfRows > 0) {
      createRows({
        numberOfRows: this.numberOfRows,
        sectionId: this.sectionId
      })
        .then((result) => {
          this.rows = result;
          if (this.rows.length > 0) {
            console.log(result);
            this.showRows = true;
          }
            
        })
        .catch((error) => {
          this.error = error;
          console.log(error);
        });
    }
    
  }

  handleRowUpdate() {
    this.showLoading();
    this.dispatchToast(
      "Success!",
      "The Section record has been successfully updated.",
      "success"
    );
  }

  handleSectionUpdate() {
    this.showLoading();
    this.dispatchToast(
      "Success!",
      "The Section record has been successfully updated.",
      "success"
    );
  }

  handleNumberOfSections(event) {
    this.numberOfSections = event.detail.value;
  }

  handleNumberOfRows(event) {
    this.numberOfRows = event.detail.value;
  }

  handleSectionInput() {
    this.showSectionInput = true;
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
