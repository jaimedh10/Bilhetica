public with sharing class TicketCustomController {
    /* public String ticketId {get; set;}
    public String seat {get; set;}
    public String qrCode {get; set;}
    public String session {get; set;} */
    public List<Ticket__c> tickets {get; set;}

    public TicketCustomController() {
      tickets = contactTickets();
    }

    public static List<Ticket__c> contactTickets() {
        String contactId = Apexpages.currentPage().getParameters().get('id');
        String sessionId = Apexpages.currentPage().getParameters().get('sessionId');
        System.debug(contactId);
        System.debug(sessionId);
        return [SELECT Id, Contact__c, Contact__r.Name, Session__c, Session__r.Name, Seat__c, Seat__r.Seat__c, QR_Code__c, QRCode_Url__c FROM Ticket__c WHERE Session__c =:sessionId AND Contact__c =:contactId];    
    }

    // Manual ticket validation
    @AuraEnabled
    public static Ticket__c validateTicket(String ticketId) {
      List<Ticket__c> tickets = [SELECT Id, Status__c FROM Ticket__c WHERE Id =:ticketId LIMIT 1];
      if(tickets.isEmpty()) {
        return null;
      }
      if(tickets.get(0).Status__c == 'Paid') {
        tickets.get(0).Status__c = 'Invalid';
        try {
          update tickets;
          System.debug(LoggingLevel.INFO, tickets);
          return tickets.get(0);
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
      if(String.isBlank(qrCodeUrl)) {
        return null;
      }
      String qrCodeValue = '%' + qrCodeUrl + '%';
      Ticket__c ticket = [SELECT Id, Status__c, QRCode_Url__c FROM Ticket__c WHERE QRCode_Url__c LIKE :qrCodeValue LIMIT 1];
      if(ticket.Status__c == 'Paid') {
        ticket.Status__c = 'Invalid';
        try {
          update ticket;
          System.debug(LoggingLevel.INFO, ticket);
          return ticket;
        }
        catch(Exception e) {
          System.debug(e.getMessage());
        }   
      }
      return null;
    }
}