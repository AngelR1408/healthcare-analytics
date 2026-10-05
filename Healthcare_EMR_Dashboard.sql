CREATE DATABASE IF NOT EXISTS healthcare_emr;
USE healthcare_emr;
drop database if exists healthcare_emr;

-- 1. Department (no dependencies)
CREATE TABLE department (
    DepartmentID INT PRIMARY KEY,
    DepartmentName VARCHAR(100),
    SpecialtyCovered VARCHAR(100),
    Location VARCHAR(100),
    DepartmentType VARCHAR(50)
);

-- 2. Doctor (depends on Department)
CREATE TABLE doctor (
    DoctorID INT PRIMARY KEY,
    DoctorName VARCHAR(100),
    Gender VARCHAR(20),
    Specialty VARCHAR(100),
    DepartmentID INT,
    YearsOfExperience INT,
    HospitalAffiliation VARCHAR(150),
    ClinicName VARCHAR(150),
    PhoneNumber VARCHAR(50),
    Email VARCHAR(100),
    LicenseNumber VARCHAR(50),
    IsActive VARCHAR(10),
    FOREIGN KEY (DepartmentID) REFERENCES department(DepartmentID)
);

-- 3. Patient (no FK dependencies)
CREATE TABLE patient (
    PatientID INT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Gender VARCHAR(20),
    DateOfBirth DATE,
    Age INT,
    BloodType VARCHAR(10),
    PhoneNumber VARCHAR(50),
    AlternatePhoneNumber VARCHAR(50),
    Address VARCHAR(255),
    State VARCHAR(50),
    City VARCHAR(50),
    Country VARCHAR(50),
    InsuranceProvider VARCHAR(100),
    PolicyNumber VARCHAR(50),
    MaritalStatus VARCHAR(30),
    Race VARCHAR(50),
    Ethnicity VARCHAR(50),
    ChronicConditions VARCHAR(255),
    Allergies VARCHAR(255),
    MedicalHistory VARCHAR(255),
    PatientStatus VARCHAR(30),
    RegistrationDate DATE,
    EmergencyContactName VARCHAR(100),
    EmergencyContactPhone VARCHAR(50)
);

-- 4. Insurance Provider (no dependencies)
CREATE TABLE insurance_provider (
    ProviderID VARCHAR(20) PRIMARY KEY,
    ProviderName VARCHAR(100),
    TickerSymbol VARCHAR(20),
    PrimaryPlanType VARCHAR(30),
    NetworkScope VARCHAR(50),
    MemberSatisfaction DECIMAL(3,1),
    CustomerServicePhone VARCHAR(50),
    FinancialRating VARCHAR(10)
);

-- 5. Visit (depends on Patient, Doctor)
CREATE TABLE visit (
    VisitID INT PRIMARY KEY,
    PatientID INT,
    DoctorID INT,
    VisitDate DATE,
    VisitYear INT,
    VisitMonth INT,
    VisitMonthName VARCHAR(20),
    VisitQuarter INT,
    VisitType VARCHAR(50),
    VisitStatus VARCHAR(30),
    Diagnosis VARCHAR(150),
    DiagnosisCode VARCHAR(30),
    ReasonForVisit VARCHAR(150),
    FollowUpRequired VARCHAR(10),
    PrescribedMedications VARCHAR(150),
    VisitDurationMins INT,
    FOREIGN KEY (PatientID) REFERENCES patient(PatientID),
    FOREIGN KEY (DoctorID) REFERENCES doctor(DoctorID)
);

-- 6. Insurance Policy (depends on Patient, Insurance Provider)
CREATE TABLE insurance_policy (
    PolicyNumber VARCHAR(50) PRIMARY KEY,
    PatientID INT,
    ProviderID VARCHAR(20),
    ProviderName VARCHAR(100),
    PlanType VARCHAR(30),
    CoverageTier VARCHAR(30),
    MonthlyPremium DECIMAL(10,2),
    AnnualDeductible DECIMAL(10,2),
    Copay DECIMAL(10,2),
    OutOfPocketMax DECIMAL(10,2),
    Coinsurance DECIMAL(5,2),
    CoverageStartDate DATE,
    CoverageEndDate DATE,
    PolicyStatus VARCHAR(30),
    RxCoverage VARCHAR(10),
    MentalHealthCoverage VARCHAR(10),
    DentalRider VARCHAR(10),
    VisionRider VARCHAR(10),
    FOREIGN KEY (PatientID) REFERENCES patient(PatientID),
    FOREIGN KEY (ProviderID) REFERENCES insurance_provider(ProviderID)
);

-- 7. Treatment (depends on Visit)
CREATE TABLE treatment (
    TreatmentID INT PRIMARY KEY,
    VisitID INT,
    TreatmentType VARCHAR(50),
    TreatmentName VARCHAR(150),
    MedicationPrescribed VARCHAR(150),
    Dosage VARCHAR(50),
    Instructions VARCHAR(255),
    TreatmentStartDate DATE,
    TreatmentEndDate DATE,
    DurationDays INT,
    Status VARCHAR(30),
    Outcome VARCHAR(50),
    DirectTreatmentCost DECIMAL(10,2),
    TotalEpisodeCost DECIMAL(10,2),
    TreatmentDescription VARCHAR(255),
    FOREIGN KEY (VisitID) REFERENCES visit(VisitID)
);

-- 8. Lab Test (depends on Visit, Doctor)
CREATE TABLE labtest (
    LabResultID INT PRIMARY KEY,
    VisitID INT,
    OrderedByDoctorID INT,
    TestName VARCHAR(100),
    TestDate DATE,
    TestYear INT,
    TestMonth INT,
    TestMonthName VARCHAR(20),
    TestResult VARCHAR(50),
    NumericResultValue DECIMAL(10,2),
    Units VARCHAR(30),
    ReferenceRange VARCHAR(50),
    Comments VARCHAR(255),
    FOREIGN KEY (VisitID) REFERENCES visit(VisitID),
    FOREIGN KEY (OrderedByDoctorID) REFERENCES doctor(DoctorID)
);

-- 9. Billing (depends on Visit, Patient)
CREATE TABLE billing (
    BillID INT PRIMARY KEY,
    VisitID INT,
    PatientID INT,
    AmountBilled DECIMAL(10,2),
    InsuranceCovered DECIMAL(10,2),
    PatientPaid DECIMAL(10,2),
    Outstanding DECIMAL(10,2),
    PaymentStatus VARCHAR(50),
    BillDate DATE,
    PaymentDate DATE,
    FOREIGN KEY (VisitID) REFERENCES visit(VisitID),
    FOREIGN KEY (PatientID) REFERENCES patient(PatientID)
);

-- 10. Insurance Claims (depends on Billing, Visit, Patient, Policy, Provider)
CREATE TABLE insurance_claims (
    ClaimID VARCHAR(20) PRIMARY KEY,
    BillID INT,
    VisitID INT,
    PatientID INT,
    PolicyNumber VARCHAR(50),
    ProviderID VARCHAR(20),
    ProviderName VARCHAR(100),
    PlanType VARCHAR(30),
    ClaimType VARCHAR(50),
    ClaimDate DATE,
    AmountBilled DECIMAL(10,2),
    AmountClaimed DECIMAL(10,2),
    ApprovedAmount DECIMAL(10,2),
    PatientResponsibility DECIMAL(10,2),
    Outstanding DECIMAL(10,2),
    ClaimStatus VARCHAR(50),
    DenialReason VARCHAR(150),
    ProcessingDays INT,
    AppealStatus VARCHAR(30),
    SubmittedElectronically VARCHAR(10),
    NetworkStatus VARCHAR(30),
    FOREIGN KEY (BillID) REFERENCES billing(BillID),
    FOREIGN KEY (VisitID) REFERENCES visit(VisitID),
    FOREIGN KEY (PatientID) REFERENCES patient(PatientID),
    FOREIGN KEY (PolicyNumber) REFERENCES insurance_policy(PolicyNumber),
    FOREIGN KEY (ProviderID) REFERENCES insurance_provider(ProviderID)
);



#KPI 1 — Total Patients, Doctors, Visits

SELECT COUNT(*) AS Total_Patients FROM patient;
SELECT COUNT(*) AS Total_Doctors FROM doctor;
SELECT COUNT(*) AS Total_Visits FROM visit;


#KPI 2 — Average Age of Patients
SELECT ROUND(AVG(Age), 4) AS Average_Age FROM patient;


#Patients by Age Group
SELECT IFNULL(Age_Group, 'Grand Total') AS Age_Group, Patients
FROM (
  SELECT 
    CASE 
      WHEN Age BETWEEN 0 AND 18 THEN '0-18'
      WHEN Age BETWEEN 19 AND 35 THEN '19-35'
      WHEN Age BETWEEN 36 AND 50 THEN '36-50'
      WHEN Age BETWEEN 51 AND 65 THEN '51-65'
      ELSE '65+'
    END AS Age_Group,
    COUNT(*) AS Patients
  FROM patient
  GROUP BY Age_Group WITH ROLLUP
) AS sub;



#Patients by Gender
SELECT IFNULL(Gender, 'Grand Total') AS Gender, COUNT(*) AS Patients
FROM patient
GROUP BY Gender WITH ROLLUP;


#Doctors by Specialty
SELECT IFNULL(Specialty, 'Grand Total') AS Specialty, COUNT(*) AS Total_Doctors
FROM doctor
GROUP BY Specialty WITH ROLLUP;

#Visits by Type
SELECT IFNULL(VisitType, 'Grand Total') AS VisitType, COUNT(*) AS Visits
FROM visit
GROUP BY VisitType WITH ROLLUP;

#Visits by Year & Month (matches the pivot table exactly)

SELECT 
  IFNULL(VisitYear, 'Grand Total') AS VisitYear, 
  IFNULL(VisitMonthName, 'Total') AS VisitMonthName, 
  Visits
FROM (
  SELECT VisitYear, VisitMonthName, MIN(VisitMonth) AS SortMonth, COUNT(*) AS Visits
  FROM visit
  GROUP BY VisitYear, VisitMonthName WITH ROLLUP
) AS sub
ORDER BY 
  VisitYear IS NULL, VisitYear,
  CASE WHEN VisitMonthName IS NULL THEN 9999 ELSE SortMonth END;
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  






