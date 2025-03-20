public with sharing class EmailManager {
 // 公共方法
    public static void sendMail(String address, String subject, String body) {
        // 创建一个电子邮件对象
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {address};
        mail.setToAddresses(toAddresses);
        mail.setSubject(subject);
        mail.setPlainTextBody(body);
        // 将此电子邮件传递给内置的sendEmail方法
        // 消息类的
        Messaging.SendEmailResult[] results = Messaging.sendEmail(
                                 new Messaging.SingleEmailMessage[] { mail });
        
        // 调用一个帮助器方法来检查返回的结果
        inspectResults(results);
    }
    
    // 辅助方法
    private static Boolean inspectResults(Messaging.SendEmailResult[] results) {
        Boolean sendResult = true;
        
        // sendEmail返回一个结果对象数组。
        // 遍历列表来检查结果。
        // 在这个类中，方法只发送一封邮件，
        // 所以我们应该只有一个结果。
        for (Messaging.SendEmailResult res : results) {
            if (res.isSuccess()) {
                System.debug('Email sent successfully');
            }
            else {
                sendResult = false;
                System.debug('发生以下错误：' + res.getErrors());                 
            }
        }
        
        return sendResult;
    }
}