import { LightningElement, api } from "lwc";
import { updateRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import SESSION_OBJECT from "@salesforce/schema/Session__c";
import SESSION_VENUE_OBJECT from "@salesforce/schema/Session_Venue__c";
import NAME_FIELD from "@salesforce/schema/Session__c.Name";
import findVenues from "@salesforce/apex/SessionWizardController.findVenues";
import createSessionVenues from "@salesforce/apex/SessionWizardController.createSessionVenues";
/**
 * Creates Session records.
 */
export default class SessionWizard extends LightningElement {
  @api recordId; // Id do Evento
  isLoading = false;
  // Objectos e campos
  sessionObject = SESSION_OBJECT;
  sessionVenueObject = SESSION_VENUE_OBJECT;
  sessionFields = [NAME_FIELD];

  // Boolean p/ mostrar determinado template
  venueSelected;
  venueListEmpty;
  showSessionsSaved = false;
  showCloningModal = true;
  // Listas
  sessions = undefined;
  sessionVenues = undefined;
  venues;
  // Ids
  venueId;
  sessionId;
  sessionVenueId;

  queryTerm = "";
  error;
  peridiocityValue;
  peridiocityOptions = [ 
    {label: 'Daily', value: 'Daily' }, 
    {label: 'Weekly', value: 'Weekly' },
    {label: 'Monthly', value: 'Monthly' },
    {label: 'Annualy', value: 'Annualy' }
  ];



  toggleCloningModal() {
    this.showCloningModal = !this.showCloningModal;
  }


  cloneSessions() {
    if(this.peridiocityValue == null || this.peridiocityValue === undefined || this.peridiocityValue === '' ) {
      this.dispatchToast('Warning', 'Select peridiocity to clone Sessions', 'info');
    }
    else {
      return null;
    }
    return null;
  }

  handlePeridiocityChange(event) {
    this.peridiocityValue = event.detail.value;
  } 
  
  // Método para pesquisar o espaço com base no termo de pesquisa introduzido
  handleSearch(event) {
    this.queryTerm = event.target.value;
    findVenues({ queryTerm: this.queryTerm, recordId: this.recordId })
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

  // Método para mostrar os registos do Session Venues
  handleShow() {
    this.showTemplateSesssionVenues = true;
  }

  handleSuccess(event) {
    this.dispatchToast("Success!", "The Session record has been successfully saved.", "success");
    updateRecord({ fields: { Id: this.recordId } });
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

  // Método para seleccionar o espaço
  selectVenue(event) {
    this.venueSelected = false;
    this.venueId = undefined;
    this.isLoading = true;
    this.venueId = event.currentTarget.dataset.venue;
    this.venues = undefined;
    this.venueSelected = true;
  }

  hideLoading() {
    this.isLoading = false;
  }

  showLoading() {
    this.isLoading = true;
  }

  dispatchToast(title, message, variant) {
    const evt = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant
    });
    this.dispatchEvent(evt);
  }

  

  /* handleSessionVenue(event) {
    updateRecord({ fields: { Id: this.recordId } });
    this.sessionVenueId = event.detail.id;
    this.sessionVenues.push(this.sessionVenueId);
    console.table(this.sessionsVenues);
    this.showTemplateSesssionVenues = false;
  } */

  /* list sessionsIds = guardar id;
     onsucess ref id
     enviar lista para o apex, para retornar a lista de sessões (do id)
     mostrar as sessões para depois selecionar e clonar ou n
     template is loading */
}
