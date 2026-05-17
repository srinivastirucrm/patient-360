@IsTest
public class Patient360TestUtils {
    public class PatientData {
        public Patient__c patient;
        public List<Appointment__c> appointments = new List<Appointment__c>();
        public List<Case> cases = new List<Case>();
        public List<Patient_Note__c> notes = new List<Patient_Note__c>();
    }

    public static PatientData createPatient360TestData() {
        PatientData data = new PatientData();

        data.patient = new Patient__c(
            Name = 'Test Patient 360',
            Birthdate = Date.newInstance(1980, 1, 1),
            Phone = '555-123-4567',
            Email = 'test.patient@example.com',
            Program_Type__c = 'Care Management',
            Risk_Flag__c = 'High',
            Last_Interaction_Date__c = Date.today().addDays(-2),
            Care_Plan_Summary__c = 'Review medications and follow up in two weeks.'
        );
        insert data.patient;

        data.appointments.add(createAppointment(data.patient.Id, Date.today().addDays(1), 'Follow Up Visit', 'Scheduled', 'In-Person', data.patient.Program_Type__c));
        data.appointments.add(createAppointment(data.patient.Id, Date.today().addDays(-10), 'Discharge Planning', 'Completed', 'Virtual', data.patient.Program_Type__c));
        insert data.appointments;

        data.cases.add(createPatientCase(data.patient.Id, 'Medication question', 'New', 'Medium'));
        data.cases.add(createPatientCase(data.patient.Id, 'Transportation support', 'Closed', 'High'));
        insert data.cases;

        data.notes.add(createPatientNote(data.patient.Id, 'Care plan note', 'Patient is progressing well and requires medication review.'));
        data.notes.add(createPatientNote(data.patient.Id, 'Follow-up summary', 'Appointment scheduled for next week.'));
        insert data.notes;

        return data;
    }

    public static Appointment__c createAppointment(Id patientId, Date appointmentDate, String subject, String status, String type, String programType) {
        return new Appointment__c(
            Patient__c = patientId,
            Appointment_Date__c = appointmentDate,
            Subject__c = subject,
            Status__c = status,
            Type__c = type,
            Program_Type__c = programType
        );
    }

    public static Case createPatientCase(Id patientId, String subject, String status, String priority) {
        return new Case(
            Patient__c = patientId,
            Subject = subject,
            Status = status,
            Priority = priority
        );
    }

    public static Patient_Note__c createPatientNote(Id patientId, String title, String summary) {
        return new Patient_Note__c(
            Patient__c = patientId,
            Title__c = title,
            Summary__c = summary
        );
    }
}
