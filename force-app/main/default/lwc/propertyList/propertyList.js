import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAllProperties from '@salesforce/apex/PropertyController.getAllProperties';
import searchTenants from '@salesforce/apex/TenantController.searchTenants';
import createContract from '@salesforce/apex/RentalContractController.createRenatlContract';
import checkAvailability from '@salesforce/apex/RentalContractController.checkAvailability';

const columns = [
    
    { label: 'Name', fieldName: 'Name' },
    { label: 'Type', fieldName: 'Type__c' },
    { label: 'Address', fieldName: 'Address__c' },
    { label: 'Rent', fieldName: 'Rent_Amount__c' },
    { label: 'Status', fieldName: 'Status__c' },
    {
        label: 'Action',
        type: 'button',
        typeAttributes: {
            label: 'Check Availability',
            name: 'check_availability',
            variant: 'brand',
            title: 'check for availability'
        }    
    },
    {
        label: 'Action',
        type: 'button',
        typeAttributes: {
            label: 'Rent Out',
            name: 'rent_out',
            variant: 'brand',
            title: 'Rent this property',
            disabled: { fieldName: 'disableRentOut' }
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
    @track startDate= '';
    @track endDate = '';
    @track isPropertyAvailable = false;
    @track selectedType='';
    @track selectedRent=200000;
    typeOptions = [
        {label: 'All', value: ''},
        {label: 'Studio', value: 'Studio'},
        {label: 'Apartment', value: 'Apartment'},
        {label: '1 Bedroom', value: '1 Bedroom'},
        {label: '2 Bedroom', value: '2 Bedroom'},
        {label: 'Villa', value: 'Villa'}
    ];

    connectedCallback() {
        this.fetchData();        
    }
    fetchData(){
        this.isLoading = true;
        getAllProperties({
            propertyType: this.selectedType,
            rentAmount: this.selectedRent? parseFloat(this.selectedRent) : null
        })
            .then(result => {
                //this.data = result;
                this.data = result.map(row => ({
                    ...row,
                    disableRentOut: true //  Rent Out disabled by default
                }));
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
        if(actionName === 'check_availability'){
            this.selectedProperty = row;
            //console.log('selected property unique id is: ', this.selectedProperty.Unique_Id__c);
            this.handlePropertyAvailability();

        }
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
    handleSubmit(){
        if(!this.selectedTenant || !this.selectedTenant.Id){
            this.showToast('Missing Fields', 'Please select a valid Tenant record.', 'error');
            return;
        }
        if(!this.selectedTenant || !this.startDate || !this.endDate){
            this.showToast('Missing Feilds', 'Please fill all the required Fields!','error');
            return;
        }
        if(new Date(this.startDate) > new Date(this.endDate)){
            this.showToast('Invalid Date','End Date should be greater than Start Date','error');
            return;
        }
        createContract({
            propertyId: this.selectedProperty.Id,
            tenantId: this.selectedTenant.Id,
            startDate: this.startDate,
            endDate: this.endDate,
            rentAmount: this.selectedProperty.Rent_Amount__c,
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
            console.log('Full error object:', JSON.stringify(error, null, 2));
        
            let message = 'Something went wrong.';
        
            // Check FIELD_CUSTOM_VALIDATION_EXCEPTION inside pageErrors
            if (
                error?.body?.pageErrors &&
                Array.isArray(error.body.pageErrors) &&
                error.body.pageErrors.length > 0 &&
                error.body.pageErrors[0].message
            ) {
                message = error.body.pageErrors[0].message;
        
            //  Fallback checks
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
    async handlePropertyAvailability() {  
        //console.log('selected property unique id inside handle method: ', this.selectedProperty.Unique_Id__c);          
        try {
            const result = await checkAvailability({ uniqueId: this.selectedProperty.Unique_Id__c });
    
            if (result.isAvailable) {
                this.isPropertyAvailable = true;
                this.showToast('Success', 'Property is available!', 'success');
                this.data = this.data.map(row => {
                    if (row.Id === this.selectedProperty.Id) {
                        return {
                            ...row,
                            disableRentOut: !result.isAvailable // 👈 true = disable, false = enable
                        };
                    }
                    return row;
                });
              } else {
                this.isPropertyAvailable = false;
                this.showToast('Warning', 'Property is not available.', 'warning');
              }
    
        } catch (error) {
            console.error('Error during availability check:', error);
            this.showToast('Error', 'Something went wrong', 'error');
        }
    }
    handleTypeChange(event){
        this.selectedType = event.detail.value;
        this.fetchData();
    }
    handleRentChange(event){
        this.selectedRent = event.detail.value;
        this.fetchData();
    }
     
}
