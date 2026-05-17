@IsTest
private class Patient360ControllerTest {
    @IsTest
    static void testGetPatient360ReturnsExpectedData() {
        Patient360TestUtils.PatientData data = Patient360TestUtils.createPatient360TestData();

        Test.startTest();
        Patient360Controller.Patient360Data result = Patient360Controller.getPatient360(
            data.patient.Id,
            data.patient.Program_Type__c,
            Date.today().addDays(-30),
            Date.today().addDays(30)
        );
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(data.patient.Name, result.name, 'Patient name should match');
        System.assertEquals(data.patient.Email, result.email, 'Email should match');
        System.assertEquals(data.patient.Phone, result.phone, 'Phone should match');
        System.assertEquals(data.patient.Program_Type__c, result.programType, 'Program type should match');
        System.assertEquals(data.patient.Risk_Flag__c, result.riskFlag, 'Risk flag should match');
        System.assertEquals(data.patient.Care_Plan_Summary__c, result.carePlanSummary, 'Care plan summary should match');
        System.assertEquals(2, result.appointments.size(), 'Should return two appointments');
        System.assertEquals(2, result.cases.size(), 'Should return two cases');
        System.assertEquals(2, result.notes.size(), 'Should return two notes');
    }

    @IsTest
    static void testGetPatient360AppliesProgramAndDateFilters() {
        Patient360TestUtils.PatientData data = Patient360TestUtils.createPatient360TestData();

        Appointment__c outOfRange = Patient360TestUtils.createAppointment(
            data.patient.Id,
            Date.today().addDays(-90),
            'Old Appointment',
            'Completed',
            'Virtual',
            data.patient.Program_Type__c
        );
        insert outOfRange;

        Appointment__c otherProgram = Patient360TestUtils.createAppointment(
            data.patient.Id,
            Date.today().addDays(2),
            'Other Program Appointment',
            'Scheduled',
            'Virtual',
            'Different Program'
        );
        insert otherProgram;

        Test.startTest();
        Patient360Controller.Patient360Data result = Patient360Controller.getPatient360(
            data.patient.Id,
            data.patient.Program_Type__c,
            Date.today().addDays(-30),
            Date.today().addDays(30)
        );
        Test.stopTest();

        System.assertEquals(2, result.appointments.size(), 'Filter should exclude out-of-range and different program appointments');
        for (Patient360Controller.AppointmentSummary appointment : result.appointments) {
            System.assert(appointment.appointmentDate >= Date.today().addDays(-30), 'Appointment date should be in filter range');
            System.assert(appointment.appointmentDate <= Date.today().addDays(30), 'Appointment date should be in filter range');
        }
    }

    @IsTest
    static void testGetPatient360ThrowsWhenRecordIdMissing() {
        Test.startTest();
        try {
            Patient360Controller.getPatient360(null, null, null, null);
            System.assert(false, 'Method should throw an AuraHandledException when recordId is null');
        } catch (AuraHandledException expected) {
            System.assertEquals('Patient recordId is required.', expected.getMessage());
        }
        Test.stopTest();
    }
}
