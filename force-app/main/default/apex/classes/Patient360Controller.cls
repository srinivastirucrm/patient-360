public with sharing class Patient360Controller {
    @AuraEnabled(cacheable=false)
    public static Patient360Data getPatient360(Id recordId, String programTypeFilter, Date startDate, Date endDate) {
        if (recordId == null) {
            throw new AuraHandledException('Patient recordId is required.');
        }

        Patient__c patient = [
            SELECT Id, Name, Birthdate, Phone, Email, Program_Type__c, Risk_Flag__c, Last_Interaction_Date__c, Care_Plan_Summary__c
            FROM Patient__c
            WHERE Id = :recordId
            LIMIT 1
        ];

        Patient360Data response = new Patient360Data();
        response.name = patient.Name;
        response.email = patient.Email;
        response.phone = patient.Phone;
        response.programType = patient.Program_Type__c;
        response.riskFlag = patient.Risk_Flag__c;
        response.lastInteraction = patient.Last_Interaction_Date__c != null ? String.valueOf(patient.Last_Interaction_Date__c) : 'N/A';
        response.carePlanSummary = patient.Care_Plan_Summary__c;
        response.appointments = new List<AppointmentSummary>();
        response.cases = new List<CaseSummary>();
        response.notes = new List<NoteSummary>();

        String appointmentFilter = 'Patient__c = :recordId';
        if (String.isNotBlank(programTypeFilter)) {
            appointmentFilter += ' AND Program_Type__c = :programTypeFilter';
        }
        if (startDate != null) {
            appointmentFilter += ' AND Appointment_Date__c >= :startDate';
        }
        if (endDate != null) {
            appointmentFilter += ' AND Appointment_Date__c <= :endDate';
        }

        List<Appointment__c> appointmentRecords = Database.query(
            'SELECT Id, Subject__c, Appointment_Date__c, Status__c, Type__c FROM Appointment__c WHERE ' + appointmentFilter + ' ORDER BY Appointment_Date__c DESC LIMIT 100'
        );

        for (Appointment__c appointment : appointmentRecords) {
            response.appointments.add(new AppointmentSummary(
                appointment.Id,
                appointment.Subject__c,
                appointment.Appointment_Date__c,
                appointment.Status__c,
                appointment.Type__c
            ));
        }

        List<Case> caseRecords = [
            SELECT Id, CaseNumber, Subject, Status, Priority, CreatedDate
            FROM Case
            WHERE Patient__c = :recordId
            ORDER BY CreatedDate DESC
            LIMIT 100
        ];

        for (Case caseRecord : caseRecords) {
            response.cases.add(new CaseSummary(
                caseRecord.Id,
                caseRecord.CaseNumber,
                caseRecord.Subject,
                caseRecord.Status,
                caseRecord.Priority,
                caseRecord.CreatedDate
            ));
        }

        List<Patient_Note__c> noteRecords = [
            SELECT Id, Title__c, Summary__c, CreatedDate
            FROM Patient_Note__c
            WHERE Patient__c = :recordId
            ORDER BY CreatedDate DESC
            LIMIT 20
        ];

        for (Patient_Note__c noteRecord : noteRecords) {
            response.notes.add(new NoteSummary(
                noteRecord.Id,
                noteRecord.Title__c,
                noteRecord.Summary__c,
                noteRecord.CreatedDate
            ));
        }

        return response;
    }

    public class Patient360Data {
        @AuraEnabled public String name;
        @AuraEnabled public String email;
        @AuraEnabled public String phone;
        @AuraEnabled public String programType;
        @AuraEnabled public String riskFlag;
        @AuraEnabled public String lastInteraction;
        @AuraEnabled public String carePlanSummary;
        @AuraEnabled public List<AppointmentSummary> appointments;
        @AuraEnabled public List<CaseSummary> cases;
        @AuraEnabled public List<NoteSummary> notes;
    }

    public class AppointmentSummary {
        @AuraEnabled public Id id;
        @AuraEnabled public String subject;
        @AuraEnabled public Date appointmentDate;
        @AuraEnabled public String status;
        @AuraEnabled public String type;

        public AppointmentSummary(Id id, String subject, Date appointmentDate, String status, String type) {
            this.id = id;
            this.subject = subject;
            this.appointmentDate = appointmentDate;
            this.status = status;
            this.type = type;
        }
    }

    public class CaseSummary {
        @AuraEnabled public Id id;
        @AuraEnabled public String caseNumber;
        @AuraEnabled public String subject;
        @AuraEnabled public String status;
        @AuraEnabled public String priority;
        @AuraEnabled public DateTime createdDate;

        public CaseSummary(Id id, String caseNumber, String subject, String status, String priority, DateTime createdDate) {
            this.id = id;
            this.caseNumber = caseNumber;
            this.subject = subject;
            this.status = status;
            this.priority = priority;
            this.createdDate = createdDate;
        }
    }

    public class NoteSummary {
        @AuraEnabled public Id id;
        @AuraEnabled public String title;
        @AuraEnabled public String summary;
        @AuraEnabled public DateTime createdDate;

        public NoteSummary(Id id, String title, String summary, DateTime createdDate) {
            this.id = id;
            this.title = title;
            this.summary = summary;
            this.createdDate = createdDate;
        }
    }
}
