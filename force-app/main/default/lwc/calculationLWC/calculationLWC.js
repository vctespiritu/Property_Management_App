import { LightningElement } from 'lwc';

export default class CalculationLWC extends LightningElement {

    firstNumber;
    secondNumber;
    calculationType;
    result;

    get options() {
        return [
            { label: 'Addition', value: 'addition' },
            { label: 'Substraction', value: 'substraction' },
            { label: 'Multiplication', value: 'multiplication' },
            { label: 'Division', value: 'division'}
        ];
    }

    handleNumberUpdate(event){
        if (event.target.name === 'first-number') {
            this.firstNumber = event.target.value;
        }else if(event.target.name === 'second-number'){
            this.secondNumber = event.target.value;
        }
    }

    handleCalculation(event){
        this.calculationType = event.detail.value;
        
        switch (this.calculationType) {
            case 'addition':
                this.result = parseInt(this.firstNumber) + parseInt(this.secondNumber);
                break;
            case 'substraction':
                this.result = parseInt(this.firstNumber) - parseInt(this.secondNumber);
                break;
            case 'multiplication':
                this.result = parseInt(this.firstNumber) * parseInt(this.secondNumber);
                break;
            case 'division':
                this.result = parseInt(this.firstNumber) / parseInt(this.secondNumber);
                break;
            default:
                break;
        }
    }

    get getCalculationType(){
        return this.calculationType.charAt(0).toUpperCase() + this.calculationType.slice(1);
    }

    get getResult(){
        return this.result;
    }

    get hasResult(){
        if(this.result == 0){
            return true;
        }
        else if(this.result == null || this.result == ''){
            return false;
        }
        else{
            return true;
        }
    }
}