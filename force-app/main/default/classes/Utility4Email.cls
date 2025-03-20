public with sharing class Utility4Email {
    //In some cases exception happen and even with try ... catch it can not send email,
    //For example, update the user and fails, send email will get error 
    //"DML is not allowed after Setup Object or vice versa"
    //This is why make the send email function async way. 
    public static void sendEmailToAdmin (String subject, String body,String emailString) {

    	List<String> emailList = emailString.split(';');
        if( Limits.getQueueableJobs() == 0) {
            System.enqueueJob(new AsyncEmailService(subject, body, emailList));
        }
        else {
            sendEmail(subject, body, emailList);
        } 
    }

    public static void sendEmailToEmail(String subject, String body, List<String> emailList) {
        if(Limits.getQueueableJobs() == 0) {
            System.enqueueJob(new AsyncEmailService(subject, body, emailList));
        }
        else{
            sendEmail(subject, body, emailList);
        }
    }

    public static void sendEmailToEmailBatch(List<EmailInfoWrapper> ewList){
        if(Limits.getQueueableJobs() == 0){
            System.enqueueJob(new AsyncEmailService(ewList));
        }
        else{
            sendEmail(ewList);
        }
    }
    public static String populateEmailBodyOnSucc(String whoRequest, String whichService, 
            String upsertedData, String requestdata) {

        List<String> emailText = new List<String> {
            'Hi Admin,',
            'Please note that ' + whoRequest
            + ' request the webservice provided by ' 
            + whichService + '.cls successfully.',
            'Result:',
            upsertedData,
            'Request data:',
            requestdata,
            'Thank you',
            whichService
        };
        return concateList(emailText, '\n');
    }
    //单个邮件
    public static void sendEmail(String subject, String body, List<String> emails){
        if (emails.isEmpty()) {
                return;
            }

        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.subject = subject;
        message.toAddresses = emails;
        // message.plainTextBody = body;
        message.setHtmlBody(body);

        Messaging.SingleEmailMessage[] messages =
            new List<Messaging.SingleEmailMessage> {message};
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        if (results[0].success) {
            System.debug('The email was sent successfully.');
        } else {
            System.debug('The email failed to send: '
            + results[0].errors[0].message);
        }
    }

    //批量邮件 body 的内容不同
    public static void sendEmail(List<EmailInfoWrapper> ewList) {

        if(ewList == null || ewList.size() <=0 ) {
            return;
        }

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        for(EmailInfoWrapper ew : ewList){
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.subject = ew.subject;
            // message.plainTextBody = ew.body;
            message.setHtmlBody(ew.body);
            message.toAddresses = ew.toaddress;
            emails.add(message);
        }

        if(emails.size() >0){
            Messaging.SendEmailResult[] results = Messaging.sendEmail(emails);
            for(Messaging.SendEmailResult result :results){
                if (result.success) {
                    System.debug('The email was sent successfully.');
                } else {
                    System.debug('The email failed to send: '
                    + result.errors[0].message);
                }
            }
        }
    }

    public static String populateEmailBodyOnError (String whoRequest, String whichService, 
            Exception ex, String requestdata) {   

        List<String> emailText = new List<String> {
            'Hi Admin,',
            'Please note that ' + whoRequest 
            + ' request the webservice provided by ' 
            + whichService + '.cls but meet with error:',
            ex.getMessage(),
            ex.getStackTraceString(),
            'Request data:',
            requestdata,
            'Thank you',
            whichService
        };
        return concateList(emailText, '\n');
    }

    public static String concateList (List<String> list2Concate, String concateStr) {
        String result = '';
        for(String str : list2Concate) {
            result += str + concateStr;
        }
        return result;
    }

    //@future can not be called in another @future
    //So "Queueable" is a safer way to async the send-email function
    class AsyncEmailService implements Queueable {
        List<EmailInfoWrapper> ewList;
        AsyncEmailService (String subject, String body, List<String> emails) {
       
            EmailInfoWrapper ew = new EmailInfoWrapper();
            ew.subject = subject;
            ew.body = body;
            ew.toaddress = emails;
            ewList = new List<EmailInfoWrapper>();
            ewList.add(ew);
        }

        AsyncEmailService (List<EmailInfoWrapper> ewList) {
            this.ewList = ewList;
        }

        public void execute (QueueableContext context) {
            //admin email, this should be defined as custom settings
            if (ewList == null || ewList.size() <=0 ) {
                return;
            }

            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            for(EmailInfoWrapper ew : ewList){
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.subject = ew.subject;
                // message.plainTextBody = ew.body;
                message.setHtmlBody(ew.body);
                message.toAddresses = ew.toaddress;
                
                emails.add(message);
            }
            if(emails.size() >0){
                Messaging.SendEmailResult[] results = Messaging.sendEmail(emails);

                for(Messaging.SendEmailResult result :results){
                    if (result.success) {
                        System.debug('The email was sent successfully.');
                    } else {
                        System.debug('The email failed to send: ' + result.errors[0].message);
                    }
                }
            }
        }
    }

    public class EmailInfoWrapper{ 
        public String subject;
        public String body;
        public List<String> toaddress;
    }
}