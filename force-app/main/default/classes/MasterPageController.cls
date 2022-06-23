public class MasterPageController {
    public List<Doctor__c> doctors = new List<Doctor__c>();
    public List<Patient__c> patients = new List<Patient__c>();
    public Doctor__c selectedDoctor {get; set;}
    public Patient__c selectedPatient;
    public Appointment__c app {get; set;}
    public Boolean errMess {get; set;}

    public MasterPageController(){
        app = new Appointment__c();
        doctors = [SELECT Name, Working_Hours_Start__c, Working_Hours_End__c FROM Doctor__c];
        selectedDoctor = doctors[0];
        patients = [SELECT Name FROM Patient__c];
        selectedPatient = patients[0];
        errMess = false;
    }
    
    public List<SelectOption> getDoctorsOptions() {
        List<SelectOption> doctorsOptions = new List<SelectOption>();
        for(Doctor__c doc: doctors){
                  doctorsOptions.add(new SelectOption(doc.Name, doc.Name));
        }
        return doctorsOptions;
    }
    
    public List<SelectOption> getPatientsOptions() {
        List<SelectOption> patientsOptions = new List<SelectOption>();
        for(Patient__c pat: patients){
           patientsOptions.add(new SelectOption(pat.Name, pat.Name));
        }
        return patientsOptions;
    }
            
    public Time getselectedDoctorHoursStart() {
        return selectedDoctor.Working_Hours_Start__c;
    }
        
    public Time getselectedDoctorHoursEnd() {
        return selectedDoctor.Working_Hours_End__c;
    }
        
    public String getselectedDoctorName() {
        return selectedDoctor.Name;
    }

    public String getselectedPatientName() {
        return selectedPatient.Name;
    }

    public void setselectedDoctorName(String selectedDoctorName) {
        for (Doctor__c doc: doctors){
            if (doc.Name == selectedDoctorName){
                selectedDoctor = doc;
                break;
            }
        }
    }

    public void setselectedPatientName(String selectedPatientName) {
        for (Patient__c pat: patients){
            if (pat.Name == selectedPatientName){
                selectedPatient = pat;
                break;
            }
        }
    }
	  	
    public void saveApp() {
        Datetime appDateBuf = app.Appointment_Date__c;
        Double appDurationBuf = app.Duration_in_minutes__c;
        try{
            app.Doctor__c = selectedDoctor.Id;
			app.Patient__c = selectedPatient.Id;
            insert app;
        
            app = new Appointment__c();
            app.Appointment_Date__c = appDateBuf;
            app.Duration_in_minutes__c = appDurationBuf;
        
            Integer pageNumber = setCon.getPageNumber();
			setCon = null;
            setCon.setPageNumber(pageNumber);
            errMess = false;
            }
        catch(Exception ex){
            errMess = true;
        }
    }  
    
    //----------PAGINATING------------------
    public ApexPages.StandardSetController setCon {
        get {
            if(setCon == null) {
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(
                    [SELECT Appointment_Date__c, Doctor__c, Patient__c, Duration_in_minutes__c
                     FROM Appointment__c WHERE Doctor__c = :selectedDoctor.Id ORDER BY Appointment_Date__c]));
                setCon.setPageSize(20);
            }
            return setCon;
        }
        set;
    }

    public List<Appointment__c> getApps() {
        return (List<Appointment__c>) setCon.getRecords();
    }
    
    public Boolean hasNext {
        get {
            return setCon.getHasNext();
        }
    }
    
  	public Boolean hasPrevious {
		get {
			return setCon.getHasPrevious();
		}
		set;
	}
  	
  	public Integer pageNumber {
		get {
			return setCon.getPageNumber();
		}
		set;
	}
	
	public Integer totalPages {
		get {
			totalPages = (Integer)(((Decimal)setCon.getResultSize() / (Decimal)setCon.getPageSize()).round(System.RoundingMode.CEILING));
			return totalPages;
		}
		set;
	}

 	public void previous() {
 		setCon.previous();
 	}

 	public void next() {
 		setCon.next();
 	}

    public PageReference updateDoctor() {
        Integer pageNumber = setCon.getPageNumber();
		setCon = null;
        setCon.setPageNumber(pageNumber);
        return null;
    }
}