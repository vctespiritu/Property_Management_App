import { LightningElement, track } from 'lwc';

export default class CalculatorButtons extends LightningElement {

    // calcExpressionField = this.template.querySelector("lightning-input[name=calcExpressionField]");
    @track calcExpressionFieldVal = 100;

    handleClick(event){
        console.log(event.target.name);
        this.calcExpressionFieldVal = event.target.name;
    }

}