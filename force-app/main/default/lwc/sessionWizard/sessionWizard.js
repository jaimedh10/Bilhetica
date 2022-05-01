import { LightningElement, api } from "lwc";
import { updateRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import SESSION_OBJECT from "@salesforce/schema/Session__c";
import SESSION_VENUE_OBJECT from "@salesforce/schema/Session_Venue__c";
import NAME_FIELD from "@salesforce/schema/Session__c.Name";
import findVenues from "@salesforce/apex/SessionWizardController.findVenues";
/**
 * Creates Session records.
 */
export default class SessionWizard extends LightningElement {
  @api recordId; // Id do Evento
  sessionObject = SESSION_OBJECT;
  sessionVenueObject = SESSION_VENUE_OBJECT;
  sessionFields = [NAME_FIELD];
  queryTerm = "";
  venueSelected;
  venueListEmpty;
  venues;
  venueId;
  sessionId;
  sessionVenueId;
  sessions = undefined;
  sessionVenues = [];
  showSessionsSaved = false;
  showTemplateSesssionVenues = false;
  error;

  handleSearch(event) {
    this.queryTerm = event.target.value;
    findVenues({ queryTerm: this.queryTerm, recordId: this.recordId })
      .then((result) => {
        
        if(result.length > 0) {
          this.venues = result;
          this.venueListEmpty = false;
        }
        else {
          this.venueListEmpty = true;
          this.venues = undefined;
        }
          
        
      })
      .catch((error) => {
        this.error = error;
        this.venues = undefined;
      });
  }
  
  selectVenue(event) {
    this.venueId = event.currentTarget.dataset.venue;
    this.venues = undefined;
    this.venueSelected = true;
  }

  handleShow() {
    this.showTemplateSesssionVenues = true;
  }

  handleSuccess(event) {
    updateRecord({ fields: { Id: this.recordId } });
    //this.sessionId = event.detail.id;
    let sessionsIdList; 
    
    if(this.sessions === undefined){
      sessionsIdList = [];
    }else{
      sessionsIdList = this.sessions;
    }
    this.sessions = undefined;
    sessionsIdList.push(event.detail.id);
    this.sessions = sessionsIdList;
    this.showSessionsSaved = true;
    const evt = new ShowToastEvent({
      title: "Success!",
      message: "The Session record has been successfully saved.",
      variant: "success",
    });
    this.dispatchEvent(evt);
      console.table(this.sessions);
    }

  handleSessionVenue(event) {
    updateRecord({ fields: { Id: this.recordId } });
    this.sessionVenueId = event.detail.id; 
    this.sessionVenues.push(this.sessionVenueId);
    console.table(this.sessionsVenues);
    this.showTemplateSesssionVenues = false;
  }

  //list sessionsIds = guardar id;
  //onsucess ref id
  //enviar lista para o apex, para retornar a lista de sessões (do id)
  // mostrar as sessões para depois selecionar e clonar ou n
  // template is loading
}
