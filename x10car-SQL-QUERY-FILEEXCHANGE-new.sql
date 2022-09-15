/* 
TABLE APPLICABILITY REGARDING THE SPARE PARTS
-----
	Action -- by default "Add"
	*Category -- ebay category
	CustomLabel -- sku
	Title -- title product
	*ConditionID  -- by default "1000" (new product)
	Product:EAN  -- ean
	C:Brand  -- name brand
	C:MPN  -- artnumber
	C:CrossReference -- list crooss reference, separator "|", max 30 group data
	Weight -- weight
	PicURL -- list images, max 12 images, separator "|"
	GalleryType -- by default "None"
	Description -- html page product
	*Format -- by default "FixedPrice"
	*Duration -- by default "GTC"
	*StartPrice -- price product
	*Quantity -- quantity
	PayPalAccepted -- by default = 1
	PayPalEmailAddress -- ebay user email
	ImmediatePayRequired -- by default = 1
	PaymentInstructions -- by default "Payment must be made within 3 business days"
	*Location -- by default "Bristol"
	ShippingService-1:Option -- by default "UK_SellersStandardRate"
	ShippingService-1:FreeShipping  -- by default = 1
	ShippingService-1:Cost  -- by default empty
	IntlShippingService-1:Option  -- by default "UK_SellersStandardInternationalRate"
	IntlShippingService-1:Locations  -- by default "Worldwide"
	IntlShippingService-1:Cost  -- by default = 0
	IntlShippingService-1:AdditionalCost  -- by default = 0
	IntlShippingService-1:Priority  -- by default = 1
	DomesticRateTable  -- by default empty
	ShippingType  -- by default empty
	WeightMajor -- weigh in Kg, for exampl product weight = 2.37 kg then here need use "2" and for "WeightMinor" = 370
	WeightMinor -- difference in gram 	
	InternationalRateTable  -- by default empty
	*DispatchTimeMax  -- by default = 2
	*ReturnsAcceptedOption -- by default "ReturnsAccepted"
	RefundOption  -- by default "MoneyBack"
	ReturnsWithinOption -- by default "Days_30"
	OutOfStockControl  -- by default empty
	ShippingCostPaidBy  -- by default "Buyer"
	AdditionalDetails -- default text "Returns are accepted in 30 days time after receiving an item. We will refund you or exchange the desired part. If it is our fault, we will cover all shipping expenses, associated with returning an item."
	Relationship  -- use "Compatibility"
	RelationshipDetails  -- use as "Ktype=3094|Notes=text". Need use separate ktype in new line  (http://pics.ebay.com/aw/pics/uk/pdf/file_exchange/file_exchange_advanced_instructions.pdf - 26 page)
*/


-- ----------------
SET @Action = 'Add'; -- by default "Add"
SET @ConditionID = '1000';  -- by default "1000" (new product)
SET @GalleryType = 'None'; -- by default "None"
SET @FormatPrice = 'FixedPrice'; -- by default "FixedPrice"
SET @Duration = 'GTC'; -- by default "GTC"
SET @PayPalAccepted = '1'; -- by default = 1
SET @PayPalEmailAddress = 'email@gmail.com'; -- ebay user email
SET @ImmediatePayRequired = '1'; -- by default = 1
SET @PaymentInstructions = 'Payment must be made within 3 business days'; -- by default "Payment must be made within 3 business days"
SET @Location = 'Bristol'; -- by default "Bristol"
SET @ShippingService1_Option = 'UK_SellersStandardRate'; -- by default "UK_SellersStandardRate"
SET @ShippingService1_FreeShipping = '1';  -- by default = 1
SET @ShippingService1_Cost = '';  -- by default empty
SET @IntlShippingService1_Option = 'UK_SellersStandardInternationalRate';  -- by default "UK_SellersStandardInternationalRate"
SET @IntlShippingService1_Locations ='Worldwide';  -- by default "Worldwide"
SET @IntlShippingService1_Cost = '0';  -- by default = 0
SET @IntlShippingService1_AdditionalCost = '0';  -- by default = 0
SET @IntlShippingService1_Priority = '1';  -- by default = 1
SET @DomesticRateTable = '';  -- by default empty
SET @ShippingType = '';  -- by default empty
SET @InternationalRateTable = '';  -- by default empty
SET @DispatchTimeMax = '2';  -- by default = 2
SET @ReturnsAcceptedOption = 'ReturnsAccepted'; -- by default "ReturnsAccepted"
SET @RefundOption = 'MoneyBack';  -- by default "MoneyBack"
SET @ReturnsWithinOption = 'Days_30'; -- by default "Days_30"
SET @OutOfStockControl = '';  -- by default empty
SET @ShippingCostPaidBy = 'Buyer';  -- by default "Buyer"
SET @AdditionalDetails = 'Returns are accepted in 30 days time after receiving an item. We will refund you or exchange the desired part. If it is our fault, we will cover all shipping expenses, associated with returning an item.'; -- default text "Returns are accepted in 30 days time after receiving an item. We will refund you or exchange the desired part. If it is our fault, we will cover all shipping expenses, associated with returning an item."

-- SEARCH PRODUCT
SET @SEARCH_BRAND = 'TRW'; -- IN CASE EMPTY VALUE THEN THIS MEAN THAT WILL SEARCHING BY EAN NUMBER
SET @SEARCH_ARTNUM = 'GDB1220'; -- IN CASE EMPTY VALUE WILL PREPARE DATA FOR ALL PRODUCTS BRAND "@SEARCH_BRAND" (ONLY FOR TECDOC BRANDS)
SET @USEPRICE = '100'; -- test price for product
SET @USESTOCK = '2';  -- test stock for product

-- LANGUAGE
SET @lang = 'en';
SET @SPRACHNR = IFNULL((SELECT SPRACHNR FROM `020` WHERE ISO_CODE = @lang LIMIT 1), 4);  -- TECDOC ID LANG regarding iso_code language, DEFAULT 4 = EN
SET @MEDIASERVER = 'https://media.bovsoft.com/TAF_24/img/';  -- PATH TO MAIN FOLDER WHERE PLACED FOLDERS WITH IMAGES, here you need use own image server

-- DESCRIPTION html/text - where vaues {xxxx} will replaced on necessary info
SET @DESC = '{TITLE}
-------------------
Criteries: {LIST CRITERIES}

Crossreference: {LIST_CROOSREF}
-------------------
Aplicability to vehicles: {LIST_APLICABILITY}'; -- themplate html/text page

-- TEMP VALUES FOR QUERY - not need change !!!!
SET @OLDSKU = '';
SET @NEEDSHOW = NULL;
SET @WW = null;
SET @CR_ANAL = null;


SELECT
		IF((CASE 
				WHEN @OLDSKU = '' THEN (@NEEDSHOW:=NULL)
				WHEN @OLDSKU <> CONCAT(T.artnum_short,'-',T.brand_short) THEN (@NEEDSHOW:=NULL)
				ELSE (@NEEDSHOW:='')
			END) IS NULL, @Action, '') AS 'Action', 
		IF(@NEEDSHOW IS NULL,
			IFNULL((SELECT IF(GA.ebayid = 0, 9886, GA.ebayid) FROM ebay_gaid AS GA WHERE GA.gaid = T.GA_ID LIMIT 1), 9886),
			'')AS '*Category', 		
		IF(@NEEDSHOW IS NULL,
			(@OLDSKU:=CONCAT(T.artnum_short,'-',T.brand_short)),
			'') AS 'CustomLabel',
			
		IF(@NEEDSHOW IS NULL,
			left(TRIM(CONCAT(T001.MARKE, ' ', T.ARTNR, ' ', ifnull((SELECT GET_BEZNR(T320.BEZNR, @SPRACHNR) FROM `320` AS T320 WHERE T320.GENARTNR = T.GA_ID LIMIT 1), ''))), 80),
			'') AS 'Title', 
		IF(@NEEDSHOW IS NULL, @ConditionID, '') AS '*ConditionID', 
		IF(@NEEDSHOW IS NULL,
			IFNULL((SELECT T209.EANNR FROM `209` AS T209 WHERE T.SORTT = 0 and T209.ARTNR = T.ARTNR AND T209.DLNR = T.DLNR LIMIT 1), ''),
			'') AS 'Product:EAN', 
		IF(@NEEDSHOW IS NULL, T001.MARKE, '') AS 'C:Brand', 
		IF(@NEEDSHOW IS NULL, T.ARTNR, '') AS 'C:MPN', 
		
		IF(@NEEDSHOW IS NULL,
			SUBSTRING_INDEX(ifnull((select 
										group_concat(distinct concat(GET_LBEZNR(T100.LBEZNR, @SPRACHNR), ' ', T203.REFNR) separator '|') 
									from `203` AS T203 
										JOIN `100` AS T100 ON T100.HERNR = T203.KHERNR
									where T203.ARTNR = T.ARTNR 
										AND T203.DLNR = T.DLNR
									), ''), '|', 30),
			'') as 'C:CrossReference', -- list crooss reference, separator "|", max 30 group data
		IF(@NEEDSHOW IS NULL,
			SUBSTRING_INDEX(ifnull((SELECT 
										GROUP_CONCAT(DISTINCT
													CONCAT(IFNULL(GET_BEZNR(T050.BEZNR, @SPRACHNR), ''), ' ', 
																IF(T050.TYP <> 'K', 
																	T210.KRITWERT, 
																	IFNULL(GET_BEZNR_FOR_KEY_TABLE(T050.TABNR, T210.KRITWERT, @SPRACHNR), '')
																	)
																)
													separator '|')
									FROM `200` AS T200
										JOIN `210` AS T210 ON T210.ARTNR = T200.ARTNR AND T210.DLNR = T200.DLNR
										JOIN `050` AS T050 ON T050.DLNR IN (T200.DLNR, 9999) AND T050.KRITNR = T210.KRITNR
									WHERE T200.ARTNR = T.ARTNR 
										AND T200.DLNR = T.DLNR
									ORDER BY T210.SORTNR
									), ''), '|', 30),
			'') as 'C:Criteries', -- list criteries, separator "|", max 30 group data
		
		IF(@NEEDSHOW IS NULL,
			  IFNULL((@WW:=(select
								replace(IF(T050.TYP <> 'K', 
									T210.KRITWERT, 
									IFNULL(GET_BEZNR_FOR_KEY_TABLE(T050.TABNR, T210.KRITWERT, @SPRACHNR), '')
									), ',', '.')
							FROM `200` AS T200
								JOIN `210` AS T210 ON T210.ARTNR = T200.ARTNR AND T210.DLNR = T200.DLNR
								JOIN `050` AS T050 ON T050.DLNR IN (T200.DLNR, 9999) AND T050.KRITNR = T210.KRITNR
							WHERE T200.ARTNR = T.ARTNR 
								AND T200.DLNR = T.DLNR
								and T050.KRITNR = 212
							limit 1
							)), ''),
		   '')	AS 'Weight', 
		IF(@NEEDSHOW IS NULL,
		   SUBSTRING_INDEX(IFNULL((SELECT
							GROUP_CONCAT(DISTINCT
									CONCAT(@MEDIASERVER, T200.DLNR, '/', T231.BILDNAME, '.', T014.EXTENSION)
							SEPARATOR '|')
					FROM `200` AS T200 
						JOIN `232` AS T232 ON T232.ARTNR = T200.ARTNR AND T232.DLNR = T200.DLNR
						JOIN `231` AS T231 ON T231.BILDNR = T232.BILDNR AND T231.SPRACHNR IN (@SPRACHNR, 255) AND T231.DOKUMENTENART = T232.DOKUMENTENART
						LEFT JOIN `014` AS T014 ON T014.DOKUMENTENART = T232.DOKUMENTENART
					WHERE T200.ARTNR = T.ARTNR 
						AND T200.DLNR = T.DLNR
						AND IFNULL(T014.EXTENSION, '') IN ('BMP','JPG','PNG','GIF')
					ORDER BY T232.SORTNR
					), -- old tecdoc images
			   ''), '|', 12),
			'') AS 'PicURL', 
		IF(@NEEDSHOW IS NULL, @GalleryType, '') AS 'GalleryType', 
		IF(@NEEDSHOW IS NULL,
				ifnull((
						replace(replace(replace(replace(@DESC, '{TITLE}', TRIM(CONCAT(T001.MARKE, ' ', T.ARTNR, ' ', ifnull((SELECT GET_BEZNR(T320.BEZNR, @SPRACHNR) FROM `320` AS T320 WHERE T320.GENARTNR = T.GA_ID LIMIT 1), '')))),
								'{LIST CRITERIES}', ifnull((
															SELECT 
																GROUP_CONCAT(DISTINCT
																			CONCAT(IFNULL(GET_BEZNR(T050.BEZNR, @SPRACHNR), ''), ' ', 
																						IF(T050.TYP <> 'K', 
																							T210.KRITWERT, 
																							IFNULL(GET_BEZNR_FOR_KEY_TABLE(T050.TABNR, T210.KRITWERT, @SPRACHNR), '')
																							)
																						)
																			separator ' | ')
															FROM `200` AS T200
																JOIN `210` AS T210 ON T210.ARTNR = T200.ARTNR AND T210.DLNR = T200.DLNR
																JOIN `050` AS T050 ON T050.DLNR IN (T200.DLNR, 9999) AND T050.KRITNR = T210.KRITNR
															WHERE T200.ARTNR = T.ARTNR 
																AND T200.DLNR = T.DLNR
															ORDER BY T210.SORTNR
															), '')),
								'{LIST_CROOSREF}', ifnull((
															select 
																group_concat(distinct concat(GET_LBEZNR(T100.LBEZNR, @SPRACHNR), ' ', T203.REFNR) separator ' | ') 
															from `203` AS T203 
																JOIN `100` AS T100 ON T100.HERNR = T203.KHERNR
															where T203.ARTNR = T.ARTNR 
																AND T203.DLNR = T.DLNR
															), '')),
								'{LIST_APLICABILITY}', ifnull((
																	select
																		GROUP_CONCAT(DISTINCT
																			CONCAT(IFNULL(GET_LBEZNR(T100P.LBEZNR, @SPRACHNR), GET_LBEZNR(T100T.LBEZNR, @SPRACHNR)), 
																					' ', 
																					IFNULL(GET_LBEZNR(T110P.LBEZNR, @SPRACHNR), GET_LBEZNR(T110T.LBEZNR, @SPRACHNR)),
																					'',
																					IFNULL(GET_LBEZNR(T120.LBEZNR, @SPRACHNR), GET_LBEZNR(T532.LBEZNR, @SPRACHNR))
																				)
																		SEPARATOR ' | ')
																	from `400` as APL
																		LEFT JOIN `120` AS T120 ON APL.VKNZIELART = 2 AND T120.KTYPNR = APL.VKNZIELNR
																		LEFT JOIN `110` AS T110P ON T110P.KMODNR = T120.KMODNR
																		LEFT JOIN `100` AS T100P ON T100P.HERNR = T110P.HERNR
																		-- ------
																		LEFT JOIN `532` AS T532 ON APL.VKNZIELART = 16 AND T532.NTYPNR = APL.VKNZIELNR
																		LEFT JOIN `110` AS T110T ON T110T.KMODNR = T532.KMODNR
																		LEFT JOIN `100` AS T100T ON T100T.HERNR = T110T.HERNR
																	where APL.ARTNR = T.ARTNR 
																		AND APL.DLNR = T.DLNR
																		AND APL.VKNZIELART IN (2,16)
																	), ''))
						), ''),
				'') AS 'Description',
		IF(@NEEDSHOW IS NULL, @FormatPrice, '') AS '*Format', 
		IF(@NEEDSHOW IS NULL, @Duration, '') AS '*Duration', 
		IF(@NEEDSHOW IS NULL, @USEPRICE, '') AS '*StartPrice', 
		IF(@NEEDSHOW IS NULL, @USESTOCK, '') AS '*Quantity', 
		IF(@NEEDSHOW IS NULL, @PayPalAccepted, '') AS 'PayPalAccepted', 
		IF(@NEEDSHOW IS NULL, @PayPalEmailAddress, '') AS 'PayPalEmailAddress', 
		IF(@NEEDSHOW IS NULL, @ImmediatePayRequired, '') AS 'ImmediatePayRequired', 
		IF(@NEEDSHOW IS NULL, @PaymentInstructions, '') AS 'PaymentInstructions', 
		IF(@NEEDSHOW IS NULL, @Location, '') AS '*Location', 
		IF(@NEEDSHOW IS NULL, @ShippingService1_Option, '') AS 'ShippingService-1:Option', 
		IF(@NEEDSHOW IS NULL, @ShippingService1_FreeShipping, '') AS 'ShippingService-1:FreeShipping', 
		IF(@NEEDSHOW IS NULL, @ShippingService1_Cost, '') AS 'ShippingService-1:Cost', 
		IF(@NEEDSHOW IS NULL, @IntlShippingService1_Option, '') AS 'IntlShippingService-1:Option', 
		IF(@NEEDSHOW IS NULL, @IntlShippingService1_Locations, '') AS 'IntlShippingService-1:Locations', 
		IF(@NEEDSHOW IS NULL, @IntlShippingService1_Cost, '') AS 'IntlShippingService-1:Cost', 
		IF(@NEEDSHOW IS NULL, @IntlShippingService1_AdditionalCost, '') AS 'IntlShippingService-1:AdditionalCost', 
		IF(@NEEDSHOW IS NULL, @IntlShippingService1_Priority, '') AS 'IntlShippingService-1:Priority', 
		IF(@NEEDSHOW IS NULL, @DomesticRateTable, '') AS 'DomesticRateTable', 
		IF(@NEEDSHOW IS NULL, @ShippingType, '') AS 'ShippingType', 
		IF(@NEEDSHOW IS NULL,
			IF(@WW IS NULL, '', RIGHT(@WW, LENGTH(@WW)-POSITION('.' IN @WW))),
			'') AS 'WeightMinor', -- GRAM
		IF(@NEEDSHOW IS NULL,
			IF(@WW IS NULL, '', LEFT(@WW, POSITION('.' IN @WW)-1)),
			'') AS 'WeightMajor', -- KG
		IF(@NEEDSHOW IS NULL, @InternationalRateTable, '') AS 'InternationalRateTable', 
		IF(@NEEDSHOW IS NULL, @DispatchTimeMax, '') AS '*DispatchTimeMax', 
		IF(@NEEDSHOW IS NULL, @ReturnsAcceptedOption, '') AS '*ReturnsAcceptedOption', 
		IF(@NEEDSHOW IS NULL, @RefundOption, '') AS 'RefundOption', 
		IF(@NEEDSHOW IS NULL, @ReturnsWithinOption, '') AS 'ReturnsWithinOption', 
		IF(@NEEDSHOW IS NULL, @OutOfStockControl, '') AS 'OutOfStockControl', 
		IF(@NEEDSHOW IS NULL, @ShippingCostPaidBy, '') AS 'ShippingCostPaidBy', 
		IF(@NEEDSHOW IS NULL, @AdditionalDetails, '') AS 'AdditionalDetails',
		
		IF(@NEEDSHOW IS NULL OR T400.VKNZIELNR IS NULL OR T400.VKNZIELART = 16,
			'',
			(@NEEDSHOW:='Compatibility')) as Relationship,  -- use "Compatibility"
		IF(@NEEDSHOW = 'Compatibility',
			CONCAT('Ktype=',T400.VKNZIELNR,
					IFNULL(CONCAT('|Notes=',synergy.GET_LIST_TERMSOFUSE_OLD(T.brand_short, T.artnum_short, T400.VKNZIELNR, @lang)), '')
				),
			''
			) as RelationshipDetails
		
		
FROM (select -- SEARCH IN MAIN TABLE
		T200F.ARTNR AS ARTNR,
		T200F.DLNR AS DLNR,
		CLEAN_NUMBER(T200F.ARTNR) AS artnum_short,
		CLEAN_NUMBER(T001.MARKE) AS brand_short,
		T211.GENARTNR as GA_ID,
		'' AS EAN,
		0 AS SORTT
	  from `200_fixed` as T200F
		join `001` as T001 ON T200F.DLNR = T001.DLNR
		join `211` as T211 ON T211.ARTNR = T200F.ARTNR AND T211.DLNR = T200F.DLNR
	  where TRIM(T001.MARKE) <> '' AND
		if(trim(@SEARCH_ARTNUM) <> '', 
			if(T200F.ARTNR_SHORT = CLEAN_NUMBER(@SEARCH_ARTNUM), 1, 0), 
			1) = 1
		AND T001.MARKE = @SEARCH_BRAND
	  
		union
		
	  select -- SEARCH IN EAN TABLE
		T209.ARTNR AS ARTNR,
		T209.DLNR AS DLNR,
		CLEAN_NUMBER(T209.ARTNR) AS artnum_short,
		CLEAN_NUMBER(T001.MARKE) AS brand_short,
		T211.GENARTNR as GA_ID,
		T209.EANNR AS EAN,
		0 AS SORTT
	  from `209` as T209
		join `001` as T001 ON T001.DLNR = T209.DLNR
		join `211` as T211 ON T211.ARTNR = T209.ARTNR AND T211.DLNR = T209.DLNR
	  where trim(@SEARCH_ARTNUM) <> ''
		AND T209.EANNR = CLEAN_NUMBER(@SEARCH_ARTNUM)
	  
	  order by SORTT
	  ) AS T
			LEFT JOIN `400` AS T400 ON T400.ARTNR = T.ARTNR AND T400.DLNR = T.DLNR AND T400.VKNZIELART IN (2, 16)
			LEFT JOIN `001` as T001 ON T001.DLNR = T.DLNR
	
WHERE if(trim(@SEARCH_ARTNUM) = '', 1,
		if(CLEAN_NUMBER(@SEARCH_ARTNUM) = T.artnum_short OR CLEAN_NUMBER(@SEARCH_ARTNUM) = T.EAN, 1, 0)
		) = 1





