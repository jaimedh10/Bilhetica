public with sharing class TicketCustomController {
    /* public String ticketId {get; set;}
    public String seat {get; set;}
    public String qrCode {get; set;}
    public String session {get; set;} */
    public List<Ticket__c> tickets {get; set;}

    public static List<Ticket__c> getContactTickets() {
        List<Ticket__c> tickets = new List<Ticket__c>();
        return tickets;
        //return [SELECT Id, Contact__r.Name, Session__c, Seat__c, QR_Code__c FROM Ticket__c WHERE Id =:ticketId];    
    }

    @AuraEnabled
    public static Boolean validateTicket(String ticketId) {
      Ticket__c ticket = [SELECT Id, Status__c FROM Ticket__c WHERE Id =:ticketId];
      if(ticket.Status__c == 'Paid') {
        ticket.Status__c = 'Invalid';
        try {
          update ticket;
          System.debug(LoggingLevel.INFO, ticket);
          return true;
        }
        catch(Exception e) {
          System.debug(e.getMessage());
          return false;
        }   
      }
      return false;
    }

    public TicketCustomController() {
		//this.ticketId = ApexPages.currentPage().get        
    }
}