global class lwc34_billtocontact_displaypicklist extends VisualEditor.DynamicPickList{
	
    global override VisualEditor.DataRow getDefaultValue(){
        VisualEditor.DataRow defaultValue = new VisualEditor.DataRow('Dealer', 'dealer');
        return defaultValue;
    }
    global override VisualEditor.DynamicPickListRows getValues() {
        VisualEditor.DynamicPickListRows  myValues = new VisualEditor.DynamicPickListRows();
        myValues.addRow(new VisualEditor.DataRow('Dealer', 'dealer'));
        myValues.addRow(new VisualEditor.DataRow('Contact', 'contact'));
        return myValues;
    }
}