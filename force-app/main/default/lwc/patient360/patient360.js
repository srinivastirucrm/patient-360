import { LightningElement, api, track } from 'lwc';
import getPatient360 from '@salesforce/apex/Patient360Controller.getPatient360';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const APPOINTMENT_COLUMNS = [
    { label: 'Subject', fieldName: 'subject', type: 'text' },
    { label: 'Date', fieldName: 'appointmentDate', type: 'date' },
    { label: 'Status', fieldName: 'status', type: 'text' },
    { label: 'Type', fieldName: 'type', type: 'text' }
];

const CASE_COLUMNS = [
    { label: 'Case #', fieldName: 'caseNumber', type: 'text' },
    { label: 'Subject', fieldName: 'subject', type: 'text' },
    { label: 'Status', fieldName: 'status', type: 'text' },
    { label: 'Priority', fieldName: 'priority', type: 'text' },
    { label: 'Opened', fieldName: 'createdDate', type: 'date' }
];

export default class Patient360 extends LightningElement {
    @api recordId;
    @track patientData;
    @track appointments = [];
    @track cases = [];
    @track notes = [];
    @track isLoading = false;
    @track error;

    selectedProgram = '';
    filterStartDate = '';
    filterEndDate = '';
    activeTab = 'appointments';
    programOptions = [{ label: 'All programs', value: '' }];
    appointmentColumns = APPOINTMENT_COLUMNS;
    caseColumns = CASE_COLUMNS;

    connectedCallback() {
        this.fetchPatientData();
    }

    get errorMessage() {
        return this.error ? this.extractErrorMessage(this.error) : '';
    }

    fetchPatientData() {
        if (!this.recordId) {
            return;
        }

        this.isLoading = true;
        getPatient360({
            recordId: this.recordId,
            programTypeFilter: this.selectedProgram,
            startDate: this.filterStartDate || null,
            endDate: this.filterEndDate || null
        })
            .then((result) => {
                this.patientData = result;
                this.appointments = result.appointments || [];
                this.cases = result.cases || [];
                this.notes = result.notes || [];
                this.error = undefined;
                this.buildProgramOptions();
            })
            .catch((error) => {
                this.error = error;
                this.patientData = undefined;
                this.appointments = [];
                this.cases = [];
                this.notes = [];
                this.showToast('Error loading Patient 360', this.extractErrorMessage(error), 'error');
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    buildProgramOptions() {
        const programType = this.patientData?.programType;
        if (programType) {
            this.programOptions = [
                { label: 'All programs', value: '' },
                { label: programType, value: programType }
            ];
        } else {
            this.programOptions = [{ label: 'All programs', value: '' }];
        }
    }

    handleProgramChange(event) {
        this.selectedProgram = event.detail.value;
    }

    handleStartDateChange(event) {
        this.filterStartDate = event.detail.value;
    }

    handleEndDateChange(event) {
        this.filterEndDate = event.detail.value;
    }

    handleApplyFilters() {
        this.fetchPatientData();
    }

    handleTabActive(event) {
        this.activeTab = event.target.activeTabValue;
    }

    extractErrorMessage(error) {
        if (Array.isArray(error.body?.pageErrors) && error.body.pageErrors.length) {
            return error.body.pageErrors[0].message;
        }
        if (error.body?.message) {
            return error.body.message;
        }
        return error.message || 'Unknown error';
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title,
            message,
            variant
        });
        this.dispatchEvent(event);
    }

    formatDate(dateValue) {
        if (!dateValue) {
            return '';
        }
        return new Date(dateValue).toLocaleDateString();
    }
}
