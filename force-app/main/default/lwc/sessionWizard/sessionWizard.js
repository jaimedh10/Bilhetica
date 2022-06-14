import { LightningElement, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import SESSION_OBJECT from "@salesforce/schema/Session__c";
import SESSION_VENUE_OBJECT from "@salesforce/schema/Session_Venue__c";
import findVenues from "@salesforce/apex/SessionWizardController.findVenues";
import createSessionVenues from "@salesforce/apex/SessionWizardController.createSessionVenues";
import cloneSessionsAndSessionVenues from "@salesforce/apex/SessionWizardController.cloneSessionsAndSessionVenues";
/**
 * Creates Session records.
 */
export default class SessionWizard extends LightningElement {
  @api recordId; // Event Id

  // Objects
  sessionObject = SESSION_OBJECT;
  sessionVenueObject = SESSION_VENUE_OBJECT;

  // Boolean, which shows a certain template
  venueSelected;
  venueListEmpty;
  showSessionsSaved = false;
  showCloningModal = false;
  showBasedOnRecordId = false;
  isLoading = false;
  // Lists
  sessions = undefined;
  sessionVenues = undefined;
  venues;
  sessionsToClone = [];
  // Ids
  venueId;
  sessionId;
  sessionVenueId;
  // Picklist
  peridiocityValue;
  peridiocityOptions = [
    { label: "Daily", value: "Daily" },
    { label: "Weekly", value: "Weekly" },
    { label: "Monthly", value: "Monthly" },
    { label: "Annualy", value: "Annualy" }
  ];

  queryTerm = "";
  error;

  // Method to display session cloning modal
  toggleCloningModal() {
    if (this.sessionsToClone === undefined || this.sessionsToClone.length === 0)
      this.dispatchToast("Warning", "There are no selected sessions.", "info");
    else this.showCloningModal = !this.showCloningModal;
  }

  // Method to clone sessions
  cloneSessions() {
    this.showLoading();
    if (
      this.peridiocityValue == null ||
      this.peridiocityValue === undefined ||
      this.peridiocityValue === ""
    ) {
      this.dispatchToast(
        "Warning",
        "In order to clone Sessions, you need to choose the periodicity.",
        "info"
      );
    } else {
      cloneSessionsAndSessionVenues({
        sessionIdList: this.sessionsToClone,
        peridiocityValue: this.peridiocityValue
      })
        .then((result) => {
          console.log(result);
          this.hideLoading();
          if (result === false) {
            this.dispatchToast(
              "Warning",
              "It wasn't possible to clone for the selected periodicity.",
              "info"
            );
          } else {
            this.dispatchToast(
              "Success!",
              "The Session(s) were successfully cloned.",
              "success"
            );
            this.showCloningModal = false;
          }
        })
        .catch((error) => {
          this.error = error;
          console.log(error);
          this.hideLoading();
          this.errorDefaultMessage();
        });
    }
  }

  handleCheckboxChange(event) {
    var i;
    this.checkboxValue = event.currentTarget.checked;
    this.sessionId = event.currentTarget.dataset.session;
    if (this.checkboxValue === true) {
      this.sessionsToClone.push(this.sessionId);
    } else {
      for (i = 0; i < this.sessionsToClone.length; i++) {
        if (this.sessionsToClone[i] === this.sessionId) {
          this.sessionsToClone.splice(i, 1);
        }
      }
    }
    console.table(this.sessionsToClone);
  }

  handlePeridiocityChange(event) {
    this.peridiocityValue = event.detail.value;
  }

  // Method to search the venue, based on the search term typed
  handleSearch(event) {
    this.queryTerm = event.target.value;
    findVenues({ queryTerm: this.queryTerm }) // recordId: this.recordId
      .then((result) => {
        if (result.length > 0) {
          this.venues = result;
          this.venueListEmpty = false;
        } else {
          this.venueListEmpty = true;
          this.venues = undefined;
        }
      })
      .catch((error) => {
        this.error = error;
        this.venues = undefined;
      });
  }

  // Method to show Session Venues records
  handleShow() {
    this.showTemplateSesssionVenues = true;
  }

  handleSuccess(event) {
    this.dispatchToast(
      "Success!",
      "The Session record has been successfully saved.",
      "success"
    );
    this.sessionId = event.detail.id;
    let sessionsIdList;

    if (this.sessions === undefined) {
      sessionsIdList = [];
    } else {
      sessionsIdList = this.sessions;
    }
    this.sessions = undefined;
    //sessionsIdList.push(event.detail.id);
    //this.sessions = sessionsIdList;

    createSessionVenues({
      sessionId: this.sessionId
    })
      .then((result) => {
        if (result) {
          sessionsIdList.push(result);
          this.sessions = sessionsIdList;
        } else {
          this.sessions = undefined;
        }
        this.hideLoading();
      })
      .catch((error) => {
        this.error = error;
        this.hideLoading();
      });

    this.showSessionsSaved = true;

    console.table(this.sessions);
    console.table(this.sessionVenues);
  }

  // Method to handle the venue selection
  selectVenue(event) {
    this.venueSelected = false;
    this.venueId = undefined;
    this.isLoading = true;
    this.venueId = event.currentTarget.dataset.venue;
    this.venues = undefined;
    this.venueSelected = true;
    this.checkForEventId();
    this.hideLoading();
  }

  hideLoading() {
    this.isLoading = false;
  }

  showLoading() {
    this.isLoading = true;
  }

  checkForEventId() {
    console.log(this.recordId);
    if (this.recordId != null || this.recordId !== undefined) {
      this.showBasedOnRecordId = true;
    }
  }

  successfulUpdate() {
    this.dispatchToast(
      "Success!",
      "The Session Venue record has been successfully updated.",
      "success"
    );
  }

  errorDefaultMessage() {
    this.dispatchToast(
      "Error!",
      "An unexpected error has ocurred. Please try again.",
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
}
