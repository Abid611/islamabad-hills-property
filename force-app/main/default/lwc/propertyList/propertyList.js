import { LightningElement, track } from 'lwc';
import getAllProperties from '@salesforce/apex/PropertyController.getAllProperties';

const columns = [
    
    { label: 'Name', fieldName: 'Name' },
    { label: 'Type', fieldName: 'Type__c' },
    { label: 'Address', fieldName: 'Address__c' },
    { label: 'Rent', fieldName: 'Rent_Amount__c' },
    { label: 'Status', fieldName: 'Status__c' }
];

export default class PropertyList extends LightningElement {
    @track data = [];
    @track isLoading = true;
    columns = columns;

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
}
