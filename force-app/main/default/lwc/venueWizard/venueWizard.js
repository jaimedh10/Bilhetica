import { LightningElement } from "lwc";
import VENUE_OBJECT from "@salesforce/schema/Venue__c";
import ROW_OBJECT from "@salesforce/schema/Row__c";
import createSections from "@salesforce/apex/SetupWizardController.createSections";
import createRows from "@salesforce/apex/SetupWizardController.createRows";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class VenueWizard extends LightningElement {
  venueObject = VENUE_OBJECT;
  rowObject = ROW_OBJECT;
  venueId;
  sectionId;

  numberOfSections = 0;
  numberOfRows = 0;

  // Boolean p/ mostrar determinado template
  isLoading = false;
  showVenueForm = false;
  showShortVenueForm = true;
  showSectionForm = false;
  showSectionButton = false;
  showSectionInput = false;
  showRows = false;
  disabled = false;
  finishButton = true;

  // Listas
  venues = [];
  sections = undefined;
  rows = undefined;
  rowsMap = new Map();



  
  handleSuccess(event) {
    this.venueId = event.detail.id;
    this.venues.push(this.venueId);
    this.successfulInsert();
    this.disabled = true;
    this.finishButton = false;
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
          this.sections.forEach(sect => {
            sect.rows = [];
            return sect; 
          });
          if (this.sections.length > 0) console.log(result);
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
    this.numberOfRows = this.rowsMap.get(this.sectionId);
    this.showRows = false;

    if (this.numberOfRows > 0) {
      createRows({
        numberOfRows: this.numberOfRows,
        sectionId: this.sectionId
      })
        .then((result) => {
          let sectionIndex = this.sections.findIndex((sect) => sect.Id===this.sectionId); // retorna o índice da secção para a qual criamos filas;
          this.sections[sectionIndex].rows = result; // atribui o resultado (as filas) à secção pretendida
          if (this.sections[sectionIndex].rows.length > 0) {
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

  handleShortVenueForm() {
    this.showShortVenueForm = true;
    this.showVenueForm = false;
  }

  handleVenueForm() {
    this.showVenueForm = true;
    this.showShortVenueForm = false;
  }

  handleNumberOfSections(event) {
    this.numberOfSections = event.detail.value;
  }

  handleNumberOfRows(event) {
    this.numberOfRows = event.detail.value;
    this.sectionId = event.currentTarget.dataset.section;
    this.rowsMap.set(this.sectionId, this.numberOfRows);
    console.log(this.rowsMap);
  }

  handleSectionInput() {
    this.showVenueForm = false;
    this.showSectionInput = true;
  }

  hideVenueForm() {
    this.showVenueForm = false;
    this.showSectionForm = false;
    this.showSectionButton = false;
    this.showSectionInput = false;
    this.showShortVenueForm = true;
    this.disabled = false;
  }

  hideShortVenueForm() {
    this.showShortVenueForm = false;
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

  handleRowUpdate() {
    this.showLoading();
    this.dispatchToast(
      "Success!",
      "The Row record has been successfully updated.",
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
