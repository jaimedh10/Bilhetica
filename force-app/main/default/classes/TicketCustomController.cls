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

    // Manual ticket validation
    @AuraEnabled
    public static Ticket__c validateTicket(String ticketId) {
      Ticket__c ticket = [SELECT Id, Status__c FROM Ticket__c WHERE Id =:ticketId];
      if(ticket.Status__c == 'Paid') {
        ticket.Status__c = 'Invalid';
        try {
          update ticket;
          System.debug(LoggingLevel.INFO, ticket);
          return ticket;
        }
        catch(Exception e) {
          System.debug(e.getMessage());
          return null;
        }   
      }
      return null;
    }

    // Ticket validation trough QRCode Scanner
    @AuraEnabled
    public static Ticket__c checkQrCode(String qrCodeUrl){
      qrCodeUrl = '%' + qrCodeUrl + '%';
      Ticket__c ticket = [SELECT Id, Status__c, QRCode_Url__c FROM Ticket__c WHERE QRCode_Url__c LIKE :qrCodeUrl];
      if(ticket.Status__c == 'Paid') {
        ticket.Status__c = 'Invalid';
        try {
          update ticket;
          System.debug(LoggingLevel.INFO, ticket);
          return ticket;
        }
        catch(Exception e) {
          System.debug(e.getMessage());
          return null;
        }   
      }
      return null;
    }

    public TicketCustomController() {
		//this.ticketId = ApexPages.currentPage().get        
    }
}