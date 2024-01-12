global class AggregateResultIterable implements Iterable<AggregateResult> {
   
   global Set<id> contactIds;
   
   global  AggregateResultIterable(Set<id> contactIds){
    
        this.contactIds = contactIds;
   }
   
   global Iterator<AggregateResult> Iterator(){
      return new AggregateResultIterator(contactIds);
   }
}