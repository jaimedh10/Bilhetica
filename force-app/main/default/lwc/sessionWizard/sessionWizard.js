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
  // Objectos e campos
  sessionObject = SESSION_OBJECT;
  sessionVenueObject = SESSION_VENUE_OBJECT;
  sessionFields = [NAME_FIELD];

  // Boolean p/ mostrar determinado template
  venueSelected;
  venueListEmpty;
  showSessionsSaved = false;
  showTemplateSesssionVenues = false;
  // Listas
  sessions = undefined;
  sessionVenues;
  venues;
  // Ids
  venueId;
  sessionId;
  sessionVenueId;

  queryTerm = "";
  error;

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
    updateRecord({ fields: { Id: this.recordId } });
    this.sessionId = event.detail.id;
    let sessionsIdList;

    if (this.sessions === undefined) {
      sessionsIdList = [];
    } else {
      sessionsIdList = this.sessions;
    }
    this.sessions = undefined;
    sessionsIdList.push(event.detail.id);
    this.sessions = sessionsIdList;

    createSessionVenues({
      sessionId: this.sessionId
    })
      .then((result) => {
        if (result.length > 0) {
          this.sessionVenues = result;
        } else {
          this.sessionVenues = undefined;
        }
      })
      .catch((error) => {
        this.error = error;
      });
    const evt = new ShowToastEvent({
      title: "Success!",
      message: "The Session record has been successfully saved.",
      variant: "success"
    });
    this.dispatchEvent(evt);
    this.showSessionsSaved = true;
    console.table(this.sessions);
    console.table(this.sessionVenues);
  }
  
  // Método para seleccionar o espaço 
  selectVenue(event) {
    this.venueId = event.currentTarget.dataset.venue;
    this.venues = undefined;
    this.venueSelected = true;
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
