trigger ExistedAppointment on Appointment__c (before insert) {

    for (Appointment__c newA : Trigger.new) {
       Appointment__c[] appointmentDate = [
       SELECT Appointment_Date__c, Duration_in_minutes__c
       FROM Appointment__c
       WHERE Doctor__c = :newA.Doctor__c
   ];
        Datetime newDate = newA.Appointment_Date__c;
        Datetime newEndDate = newA.Appointment_Date__c.addMinutes((Integer)newA.Duration_in_minutes__c);
        for (Appointment__c oldA : appointmentDate){
        	Datetime oldDate = oldA.Appointment_Date__c;
        	Datetime oldEndDate = oldA.Appointment_Date__c.addMinutes((Integer)oldA.Duration_in_minutes__c);
          if ((oldDate <= newDate && newDate <= oldEndDate) ||
              (oldDate <= newEndDate && newEndDate <= oldEndDate)||
              (newDate < oldDate && newEndDate > oldEndDate)
               )
          {
          	  newA.Appointment_Date__c.addError('This date is already used');
       	  }
        }
    }
}