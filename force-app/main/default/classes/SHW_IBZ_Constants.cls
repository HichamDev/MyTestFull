public with sharing class SHW_IBZ_Constants {
/*
----------------------------------------------------------------------
-- - Name          : SHW_IBZ_Constants 
-- - Author        : noor.goolamnabee@businessdecision.com
-- - Description   : This class contains all constant for the project
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 21-AUG-2012  NGO    1.0      Initial version         
----------------------------------------------------------------------	
**********************************************************************
*/	
	
	/*********************************************************************** 
	Constant that store the value for CONSTANT_READ_PERMISSION.
	************************************************************************/
	public static final String CONSTANT_READ_PERMISSION = 'Read';
	
	
	/***********************************************************************
	* AGI_AgendaItem__c constants
	************************************************************************/
	public static string AGI = 'AGI_AgendaItem__c';


	/***************************************************************
	* Constant that store the value for PREFIX_READ_ONLY.
	****************************************************************/
	public static final String PREFIX_READ_ONLY = 'RO_';
	
	
	/***************************************************************
	* Constant that store the value for REPORTS_TO_LEVEL_NBR.
	****************************************************************/
	public static final Integer REPORTS_TO_LEVEL_NBR = 5;
	
	/***********************************************************************
	* PER_Period__c constants
	************************************************************************/
	public static string PER = 'PER_Period__c';

	/***************************************************************/
	
	/*Constant that store the value for CONSTANT_READ_PERMISSION.
	************************************************************************/
	public static final String CONSTANT_CONTACT_OBJECT_NAME = 'Contact';
	
	
	 /*Constant that date format pattern for Agenda dealer.
	************************************************************************/
	public static final String AGENDA_DATE_FORMAT_PATTERN = 'h:mm a';
	
	
	
	/*Constant for the month 
	************************************************************************/
	public static final String MONTH_JANUARY = 'January';
	public static final String MONTH_FEBRUARY = 'February';
	public static final String MONTH_MARCH = 'March';
	public static final String MONTH_APRIL = 'April';
	public static final String MONTH_MAY = 'May';
	public static final String MONTH_JUNE = 'June';
	public static final String MONTH_JULY = 'July';
	public static final String MONTH_AUGUST = 'August';
	public static final String MONTH_SEPTEMBER = 'September';
	public static final String MONTH_OCTOBER = 'October';
	public static final String MONTH_NOVEMBER = 'November';
	public static final String MONTH_DECEMBER = 'December';
	
	/*Constant for Order Status 
	************************************************************************/
	public static final String ORDER_STATUS_DRAFT = 'Draft';
	public static final String ORDER_STATUS_PENDING = 'Pending';
	public static final String ORDER_STATUS_PROCESS = 'Processing';
	public static final String ORDER_STATUS_SHIPPED= 'Shipped';
	public static final String ORDER_STATUS_CANCELLED =  'Cancelled';
	public static final String ORDER_STATUS_DELEGATED =  'Delegated';
	public static final String ORDER_STATUS_CLOSED =  'Closed';
	
}