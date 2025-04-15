import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAllProperties from '@salesforce/apex/PropertyController.getAllProperties';
import searchTenants from '@salesforce/apex/TenantController.searchTenants';
import createContract from '@salesforce/apex/RentalContractController.createRenatlContract';
const columns = [
    
    { label: 'Name', fieldName: 'Name' },
    { label: 'Type', fieldName: 'Type__c' },
    { label: 'Address', fieldName: 'Address__c' },
    { label: 'Rent', fieldName: 'Rent_Amount__c' },
    { label: 'Status', fieldName: 'Status__c' },
    {
        type: 'button',
        typeAttributes: {
            label: 'Rent Out',
            name: 'rent_out',
            variant: 'brand',
            title: 'Rent this Property'
        }
    }
];

export default class PropertyList extends NavigationMixin(LightningElement) {
    columns = columns;
    @track data = [];
    @track isLoading = true;
    @track selectedProperty;
    @track isModalOpen = false;
    @track tenantSearchKey = '';
    @track tenantOptions = [];
    @track selectedTenant = null;
    @track ejariNumber = '';
    @track startDate= '';
    @track endDate = '';
    

    connectedCallback() {
        this.fetchData();        
    }
    fetchData(){
        this.isLoading = true;
        getAllProperties()
            .then(result => {
                this.data = result;
                console.log('Data fetched:', result);
            })
            .catch(error => {
                console.error('Error fetching properties:', error);
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    handleRowAction(event){
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        if(actionName === 'rent_out'){
            this.selectedProperty = row;
            this.isModalOpen = true;
        }
    }

    closeModal(){
        this.isModalOpen = false;
        this.selectedProperty = undefined;
    }

    handleTenantSearch(event){
        this.tenantSearchKey = event.target.value;
        if(this.tenantSearchKey.length >= 3){
            searchTenants({keyword: this.tenantSearchKey})
                .then(result =>{
                    this.tenantOptions = result;
                    console.log('Tenants found:', result);
                })
                .catch(error =>{
                    console.error('Tenant search error: ', error);
                });
        }else{
            this.tenantOptions = [];
        }
    }

    selectTenant(event){
        const selectedId = event.currentTarget.dataset.id;
        const found = this.tenantOptions.find(t => t.Id === selectedId);
        this.selectedTenant = found;
        this.tenantSearchKey = found.Name; // fill input field
        this.tenantOptions = []; // hide dropdown
    }
    get hasTenantResults() {
        return this.tenantOptions && this.tenantOptions.length > 0;
    }
    handleInputChange(event) {
        const field = event.target.name;
        const value = event.target.value;
    
        if (field && value !== undefined) {
            console.log(`Setting ${field} = ${value}`);
            this[field] = value;
        } else {
            console.warn('Invalid input change:', field, value);
        }
    }

    createTenantRecord(){
        window.open('/lightning/o/Tenant__c/new', '_blank');
    }
    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant
            })
        );
    }
    restrictToNumbers(event) {
        const charCode = event.which ? event.which : event.keyCode;
        // Allow only digits (0-9)
        if (charCode < 48 || charCode > 57) {
            event.preventDefault();
        }
    }
    handleSubmit(){
        if(!this.selectedTenant || !this.startDate || !this.endDate || !this.ejariNumber){
            this.showToast('Missing Feilds', 'Please fill all the required Fields!','error');
            return;
        }
        if(new Date(this.startDate) > new Date(this.endDate)){
            this.showToast('Invalid Date','End Date should be greater than Start Date','error');
            return;
        }
        if(this.ejariNumber.length > 16 || this.ejariNumber.length < 16){
            this.showToast('Invalid Ejari Number', 'Ejari Number must be 16 digits', 'error');
            return;
        }
        createContract({
            propertyId: this.selectedProperty.Id,
            tenantId: this.selectedTenant.Id,
            startDate: this.startDate,
            endDate: this.endDate,
            rentAmount: this.selectedProperty.Rent_Amount__c,
            ejariNumber: this.ejariNumber
        })
        .then(result =>{
            this.showToast('Success', 'Contract Created Successfully!', 'success');
            this.closeModal();
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: result.Id,
                    objectApiName: 'Rental_Contract__c',
                    actionName: 'view'
                }
            });
        })
        .catch(error => {
            console.log('🔥 Full error object:', JSON.stringify(error, null, 2));
        
            let message = 'Something went wrong.';
        
            // ✅ Check FIELD_CUSTOM_VALIDATION_EXCEPTION inside pageErrors
            if (
                error?.body?.pageErrors &&
                Array.isArray(error.body.pageErrors) &&
                error.body.pageErrors.length > 0 &&
                error.body.pageErrors[0].message
            ) {
                message = error.body.pageErrors[0].message;
        
            // ✅ Fallback checks
            } else if (error?.body?.message) {
                message = error.body.message;
        
            } else if (Array.isArray(error.body) && error.body[0]?.message) {
                message = error.body[0].message;
        
            } else if (error?.message) {
                message = error.message;
            }
        
            this.showToast('Error', message, 'error');
        });                
        
    }
    
}
