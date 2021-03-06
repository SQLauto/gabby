USE gabby
GO

CREATE OR ALTER VIEW tableau.accounting_compliance_feed AS

WITH status_curr AS (
  SELECT number
        ,CONVERT(DATETIME2,effective_start) AS last_status_or_salary_change
        ,base_salary AS base_salary_curr
        ,status AS status_curr
        ,LAG(base_salary, 1) OVER(PARTITION BY number ORDER BY CONVERT(DATETIME2,effective_start)) AS base_salary_prev
        ,LAG(status, 1) OVER(PARTITION BY number ORDER BY CONVERT(DATETIME2,effective_start)) AS status_prev
        ,ROW_NUMBER() OVER(PARTITION BY number ORDER BY CONVERT(DATETIME2,effective_start) DESC) AS rn_curr
  FROM dayforce.employee_status
 )

,properites_curr AS (
  SELECT employee_reference_code
        ,CONVERT(DATETIME2, employee_property_value_effective_start) AS pension_start_date
        ,RIGHT(employee_property_value_name, 4) AS pension_type
        ,property_value AS pension_number
        ,ROW_NUMBER() OVER(
           PARTITION BY employee_reference_code, employee_property_value_name
             ORDER BY CONVERT(DATETIME2, employee_property_value_effective_start)) AS rn_curr
  FROM dayforce.employee_properties
  WHERE employee_property_value_name IN ('Pension Number - DCRP', 'Pension Number - PERS', 'Pension Number - TPAF')
 )

SELECT r.df_employee_number
      ,r.first_name
      ,r.last_name
      ,r.original_hire_date
      ,r.rehire_date
      ,r.status
      ,r.status_reason
      ,r.legal_entity_name
      ,r.primary_site
      ,r.primary_on_site_department
      ,r.primary_job
      ,r.job_family
      ,r.payclass

      ,s.last_status_or_salary_change
      ,s.base_salary_curr
      ,s.base_salary_prev
      ,s.status_curr
      ,s.status_prev

      ,b.dental
      ,b.verizon_wireless
      ,b.basic_life
      ,b.basic_add
      ,b.fsa_dep
      ,b.life_sup
      ,b.imputed_income
      ,b.[403b]
      ,b.hsa
      ,b.eap
      ,b.vol_acc
      ,b.vision
      ,b.medical
      ,b.fsa_hc
      ,b.vol_hos
FROM gabby.dayforce.staff_roster r
LEFT JOIN status_curr s
  ON r.df_employee_number = s.number
 AND s.rn_curr = 1
LEFT JOIN properites_curr p
  ON r.df_employee_number = p.employee_reference_code
 AND p.rn_curr = 1
LEFT JOIN gabby.dayforce.employee_benefits_current b
  ON r.df_employee_number = b.employee_number;